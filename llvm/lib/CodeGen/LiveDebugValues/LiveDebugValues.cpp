//===- LiveDebugValues.cpp - Tracking Debug Value MIs ---------------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#include "LiveDebugValues.h"

#include "llvm/CodeGen/LiveDebugValuesPass.h"
#include "llvm/CodeGen/MachineDominators.h"
#include "llvm/CodeGen/MachineFunction.h"
#include "llvm/CodeGen/MachineFunctionPass.h"
#include "llvm/CodeGen/Passes.h"
#include "llvm/CodeGen/TargetPassConfig.h"
#include "llvm/InitializePasses.h"
#include "llvm/Pass.h"
#include "llvm/PassRegistry.h"
#include "llvm/Support/CommandLine.h"
#include "llvm/Target/TargetMachine.h"
#include "llvm/TargetParser/Triple.h"

/// \file LiveDebugValues.cpp
///
/// The LiveDebugValues pass extends the range of variable locations
/// (specified by DBG_VALUE instructions) from single blocks to successors
/// and any other code locations where the variable location is valid.
/// There are currently two implementations: the "VarLoc" implementation
/// explicitly tracks the location of a variable, while the "InstrRef"
/// implementation tracks the values defined by instructions through locations.
///
/// This file implements neither; it merely registers the pass, allows the
/// user to pick which implementation will be used to propagate variable
/// locations.

#define DEBUG_TYPE "livedebugvalues"

using namespace llvm;

static cl::opt<bool>
    ForceInstrRefLDV("force-instr-ref-livedebugvalues", cl::Hidden,
                     cl::desc("Use instruction-ref based LiveDebugValues with "
                              "normal DBG_VALUE inputs"),
                     cl::init(false));

static cl::opt<cl::boolOrDefault> ValueTrackingVariableLocations(
    "experimental-debug-variable-locations",
    cl::desc("Use experimental new value-tracking variable locations"));

// Options to prevent pathological compile-time behavior. If InputBBLimit and
// InputDbgValueLimit are both exceeded, range extension is disabled.
static cl::opt<unsigned> InputBBLimit(
    "livedebugvalues-input-bb-limit",
    cl::desc("Maximum input basic blocks before DBG_VALUE limit applies"),
    cl::init(10000), cl::Hidden);
static cl::opt<unsigned> InputDbgValueLimit(
    "livedebugvalues-input-dbg-value-limit",
    cl::desc(
        "Maximum input DBG_VALUE insts supported by debug range extension"),
    cl::init(50000), cl::Hidden);

namespace {
/// Generic LiveDebugValues pass. Calls through to VarLocBasedLDV or
/// InstrRefBasedLDV to perform location propagation, via the LDVImpl
/// base class.
class LiveDebugValuesLegacy : public MachineFunctionPass {
public:
  static char ID;

  LiveDebugValuesLegacy();
  ~LiveDebugValuesLegacy() = default;

  /// Calculate the liveness information for the given machine function.
  bool runOnMachineFunction(MachineFunction &MF) override;

  void getAnalysisUsage(AnalysisUsage &AU) const override {
    AU.setPreservesCFG();
    AU.addRequired<TargetPassConfig>();
    MachineFunctionPass::getAnalysisUsage(AU);
  }
};

struct LiveDebugValues {
  LiveDebugValues();
  ~LiveDebugValues() = default;
  bool run(MachineFunction &MF, bool ShouldEmitDebugEntryValues);

private:
  std::unique_ptr<LDVImpl> InstrRefImpl;
  std::unique_ptr<LDVImpl> VarLocImpl;
  MachineDominatorTree MDT;
};
} // namespace

char LiveDebugValuesLegacy::ID = 0;

char &llvm::LiveDebugValuesID = LiveDebugValuesLegacy::ID;

INITIALIZE_PASS(LiveDebugValuesLegacy, DEBUG_TYPE, "Live DEBUG_VALUE analysis",
                false, false)

/// Default construct and initialize the pass.
LiveDebugValuesLegacy::LiveDebugValuesLegacy() : MachineFunctionPass(ID) {
  initializeLiveDebugValuesLegacyPass(*PassRegistry::getPassRegistry());
}

LiveDebugValues::LiveDebugValues() {
  InstrRefImpl =
      std::unique_ptr<LDVImpl>(llvm::makeInstrRefBasedLiveDebugValues());
  VarLocImpl = std::unique_ptr<LDVImpl>(llvm::makeVarLocBasedLiveDebugValues());
}

PreservedAnalyses
LiveDebugValuesPass::run(MachineFunction &MF,
                         MachineFunctionAnalysisManager &MFAM) {
  if (!LiveDebugValues().run(MF, ShouldEmitDebugEntryValues))
    return PreservedAnalyses::all();
  auto PA = getMachineFunctionPassPreservedAnalyses();
  PA.preserveSet<CFGAnalyses>();
  return PA;
}

void LiveDebugValuesPass::printPipeline(
    raw_ostream &OS, function_ref<StringRef(StringRef)> MapClassName2PassName) {
  OS << MapClassName2PassName(name());
  if (ShouldEmitDebugEntryValues)
    OS << "<emit-debug-entry-values>";
}

bool LiveDebugValuesLegacy::runOnMachineFunction(MachineFunction &MF) {
  auto *TPC = &getAnalysis<TargetPassConfig>();
  return LiveDebugValues().run(
      MF, TPC->getTM<TargetMachine>().Options.ShouldEmitDebugEntryValues());
}

bool LiveDebugValues::run(MachineFunction &MF,
                          bool ShouldEmitDebugEntryValues) {
  bool InstrRefBased = MF.useDebugInstrRef();
  // Allow the user to force selection of InstrRef LDV.
  InstrRefBased |= ForceInstrRefLDV;

  LDVImpl *TheImpl = &*VarLocImpl;

  MachineDominatorTree *DomTree = nullptr;
  if (InstrRefBased) {
    DomTree = &MDT;
    MDT.recalculate(MF);
    TheImpl = &*InstrRefImpl;
  }

  return TheImpl->ExtendRanges(MF, DomTree, ShouldEmitDebugEntryValues,
                               InputBBLimit, InputDbgValueLimit);
}

bool llvm::debuginfoShouldUseDebugInstrRef(const Triple &T) {
  // Enable by default on x86_64, disable if explicitly turned off on cmdline.
  if (T.getArch() == llvm::Triple::x86_64 &&
      ValueTrackingVariableLocations != cl::boolOrDefault::BOU_FALSE)
    return true;

  // Enable if explicitly requested on command line.
  return ValueTrackingVariableLocations == cl::boolOrDefault::BOU_TRUE;
}

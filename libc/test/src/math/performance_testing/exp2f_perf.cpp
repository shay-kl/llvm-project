//===-- Differential test for exp2f----------------------------------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#include "PerfTest.h"
#include "src/math/exp2f.h"

#include <math.h>

int main() {
  SINGLE_INPUT_SINGLE_OUTPUT_PERF(float, LIBC_NAMESPACE::exp2f, ::exp2f,
                                  "exp2f_perf.log")
  return 0;
}

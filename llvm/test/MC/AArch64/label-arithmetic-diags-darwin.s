// RUN: not llvm-mc -triple aarch64-darwin -filetype=obj --defsym PARSE=1 %s -o /dev/null 2>&1 | FileCheck %s --check-prefix=ERR
// RUN: not llvm-mc -triple aarch64-darwin -filetype=obj %s -o /dev/null 2>&1 | FileCheck %s
// RUN: not llvm-mc -triple aarch64-ios -filetype=obj %s -o /dev/null 2>&1 | FileCheck %s

Lstart:
  .space 8
Lend:
.ifdef PARSE
  add w0, w1, #(Lend - var@TLVPPAGEOFF)
  // ERR: [[#@LINE-1]]:27: error: expected ')'
  cmp w0, #(Lend - var@TLVPPAGEOFF)
  // ERR: [[#@LINE-1]]:23: error: expected ')'

.else
  add w0, w1, #(Lend - external)
  cmp w0, #(Lend - external)
  // CHECK: error: unknown AArch64 fixup kind!
  // CHECK-NEXT: add w0, w1, #(Lend - external)
  // CHECK-NEXT: ^
  // CHECK: error: unknown AArch64 fixup kind!
  // CHECK-NEXT: cmp w0, #(Lend - external)
  // CHECK-NEXT: ^

  add w0, w1, #(Lstart - Lend)
  cmp w0, #(Lstart - Lend)
  // CHECK: error: fixup value out of range
  // CHECK-NEXT: add w0, w1, #(Lstart - Lend)
  // CHECK-NEXT: ^
  // CHECK: error: fixup value out of range
  // CHECK-NEXT: cmp w0, #(Lstart - Lend)
  // CHECK-NEXT: ^

  .space 5000
Lfar:
  add w0, w1, #(Lfar - Lend)
  cmp w0, #(Lfar - Lend)
  // CHECK: error: fixup value out of range
  // CHECK-NEXT: add w0, w1, #(Lfar - Lend)
  // CHECK-NEXT: ^
  // CHECK: error: fixup value out of range
  // CHECK-NEXT: cmp w0, #(Lfar - Lend)
  // CHECK-NEXT: ^

Lprivate1:
  .space 8
notprivate:
  .space 8
Lprivate2:
  add w0, w1, #(Lprivate2 - Lprivate1)
  cmp w0, #(Lprivate2 - Lprivate1)
  // CHECK: error: unknown AArch64 fixup kind!
  // CHECK-NEXT: add w0, w1, #(Lprivate2 - Lprivate1)
  // CHECK-NEXT: ^
  // CHECK: error: unknown AArch64 fixup kind!
  // CHECK-NEXT: cmp w0, #(Lprivate2 - Lprivate1)
  // CHECK-NEXT: ^

  .section __TEXT, sec_y, regular, pure_instructions
Lend_across_sec:
  add w0, w1, #(Lend_across_sec - Lprivate2)
  cmp w0, #(Lend_across_sec - Lprivate2)
  // CHECK: error: unknown AArch64 fixup kind!
  // CHECK-NEXT: add w0, w1, #(Lend_across_sec - Lprivate2)
  // CHECK-NEXT: ^
  // CHECK: error: unknown AArch64 fixup kind!
  // CHECK-NEXT: cmp w0, #(Lend_across_sec - Lprivate2)
  // CHECK-NEXT: ^
.endif

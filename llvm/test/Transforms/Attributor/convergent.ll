; NOTE: Assertions have been autogenerated by utils/update_test_checks.py UTC_ARGS: --function-signature --check-attributes --check-globals
; RUN: opt -aa-pipeline=basic-aa -passes=attributor -attributor-manifest-internal  -attributor-annotate-decl-cs  -S < %s | FileCheck %s --check-prefixes=CHECK,TUNIT
; RUN: opt -aa-pipeline=basic-aa -passes=attributor-cgscc -attributor-manifest-internal  -attributor-annotate-decl-cs -S < %s | FileCheck %s --check-prefixes=CHECK,CGSCC

define i32 @defined() convergent {
; CHECK: Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(none)
; CHECK-LABEL: define {{[^@]+}}@defined
; CHECK-SAME: () #[[ATTR0:[0-9]+]] {
; CHECK-NEXT:    ret i32 1
;
  ret i32 1
}

define i32 @calls_defined() convergent {
; TUNIT: Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(none)
; TUNIT-LABEL: define {{[^@]+}}@calls_defined
; TUNIT-SAME: () #[[ATTR0]] {
; TUNIT-NEXT:    ret i32 1
;
; CGSCC: Function Attrs: convergent mustprogress nofree nosync nounwind willreturn memory(none)
; CGSCC-LABEL: define {{[^@]+}}@calls_defined
; CGSCC-SAME: () #[[ATTR1:[0-9]+]] {
; CGSCC-NEXT:    [[A:%.*]] = call noundef i32 @defined() #[[ATTR6:[0-9]+]]
; CGSCC-NEXT:    ret i32 [[A]]
;
  %a = call i32 @defined()
  ret i32 %a
}

declare void @declared_non_convergent()

define void @calls_declared_non_convergent() convergent {
; CHECK-LABEL: define {{[^@]+}}@calls_declared_non_convergent() {
; CHECK-NEXT:    call void @declared_non_convergent()
; CHECK-NEXT:    ret void
;
  call void @declared_non_convergent()
  ret void
}

; CHECK: Function Attrs: convergent
declare i32 @declared_convergent() convergent

define i32 @calls_declared_convergent() convergent {
; TUNIT: Function Attrs: convergent
; TUNIT-LABEL: define {{[^@]+}}@calls_declared_convergent
; TUNIT-SAME: () #[[ATTR1:[0-9]+]] {
; TUNIT-NEXT:    [[A:%.*]] = call i32 @declared_convergent()
; TUNIT-NEXT:    ret i32 [[A]]
;
; CGSCC: Function Attrs: convergent
; CGSCC-LABEL: define {{[^@]+}}@calls_declared_convergent
; CGSCC-SAME: () #[[ATTR2:[0-9]+]] {
; CGSCC-NEXT:    [[A:%.*]] = call i32 @declared_convergent()
; CGSCC-NEXT:    ret i32 [[A]]
;
  %a = call i32 @declared_convergent()
  ret i32 %a
}

define i32 @defined_with_asm(i32 %a, i32 %b) {
; CHECK-LABEL: define {{[^@]+}}@defined_with_asm
; CHECK-SAME: (i32 [[A:%.*]], i32 [[B:%.*]]) {
; CHECK-NEXT:    [[RESULT:%.*]] = add i32 [[A]], [[B]]
; CHECK-NEXT:    [[ASM_RESULT:%.*]] = call i32 asm sideeffect "addl $1, $0", "=r,r"(i32 [[RESULT]])
; CHECK-NEXT:    ret i32 [[ASM_RESULT]]
;
  %result = add i32 %a, %b
  %asm_result = call i32 asm sideeffect "addl $1, $0", "=r,r"(i32 %result)
  ret i32 %asm_result
}

define i32 @calls_defined_with_asm(i32 %a, i32 %b) convergent {
; TUNIT: Function Attrs: convergent
; TUNIT-LABEL: define {{[^@]+}}@calls_defined_with_asm
; TUNIT-SAME: (i32 [[A:%.*]], i32 [[B:%.*]]) #[[ATTR1]] {
; TUNIT-NEXT:    [[C:%.*]] = call i32 @defined_with_asm(i32 [[A]], i32 [[B]])
; TUNIT-NEXT:    ret i32 [[C]]
;
; CGSCC: Function Attrs: convergent
; CGSCC-LABEL: define {{[^@]+}}@calls_defined_with_asm
; CGSCC-SAME: (i32 [[A:%.*]], i32 [[B:%.*]]) #[[ATTR2]] {
; CGSCC-NEXT:    [[C:%.*]] = call i32 @defined_with_asm(i32 [[A]], i32 [[B]])
; CGSCC-NEXT:    ret i32 [[C]]
;
  %c = call i32 @defined_with_asm(i32 %a, i32 %b)
  ret i32 %c
}

declare void @llvm.convergent.copy.p0.p0.i64(ptr %dest, ptr %src, i64 %size, i1 %isVolatile) #0

define void @calls_convergent_intrinsic(ptr %dest, ptr %src, i64 %size) convergent {
; TUNIT: Function Attrs: convergent mustprogress nofree nosync nounwind willreturn memory(argmem: readwrite)
; TUNIT-LABEL: define {{[^@]+}}@calls_convergent_intrinsic
; TUNIT-SAME: (ptr nofree [[DEST:%.*]], ptr nofree [[SRC:%.*]], i64 [[SIZE:%.*]]) #[[ATTR3:[0-9]+]] {
; TUNIT-NEXT:    call void @llvm.convergent.copy.p0.p0.i64(ptr nofree [[DEST]], ptr nofree [[SRC]], i64 [[SIZE]], i1 noundef false) #[[ATTR5:[0-9]+]]
; TUNIT-NEXT:    ret void
;
; CGSCC: Function Attrs: convergent mustprogress nofree nosync nounwind willreturn memory(argmem: readwrite)
; CGSCC-LABEL: define {{[^@]+}}@calls_convergent_intrinsic
; CGSCC-SAME: (ptr nofree [[DEST:%.*]], ptr nofree [[SRC:%.*]], i64 [[SIZE:%.*]]) #[[ATTR4:[0-9]+]] {
; CGSCC-NEXT:    call void @llvm.convergent.copy.p0.p0.i64(ptr nofree [[DEST]], ptr nofree [[SRC]], i64 [[SIZE]], i1 noundef false) #[[ATTR7:[0-9]+]]
; CGSCC-NEXT:    ret void
;
  call void @llvm.convergent.copy.p0.p0.i64(ptr %dest, ptr %src, i64 %size, i1 false)
  ret void
}

declare void @llvm.memcpy.p0.p0.i64(ptr %dest, ptr %src, i64 %size, i1 %isVolatile) #0

define void @calls_intrinsic(ptr %dest, ptr %src, i64 %size) convergent {
; TUNIT: Function Attrs: convergent mustprogress nofree norecurse nosync nounwind willreturn memory(argmem: readwrite)
; TUNIT-LABEL: define {{[^@]+}}@calls_intrinsic
; TUNIT-SAME: (ptr nofree writeonly captures(none) [[DEST:%.*]], ptr nofree readonly captures(none) [[SRC:%.*]], i64 [[SIZE:%.*]]) #[[ATTR2:[0-9]+]] {
; TUNIT-NEXT:    call void @llvm.memcpy.p0.p0.i64(ptr nofree writeonly captures(none) [[DEST]], ptr nofree readonly captures(none) [[SRC]], i64 [[SIZE]], i1 noundef false) #[[ATTR5]]
; TUNIT-NEXT:    ret void
;
; CGSCC: Function Attrs: convergent mustprogress nofree norecurse nosync nounwind willreturn memory(argmem: readwrite)
; CGSCC-LABEL: define {{[^@]+}}@calls_intrinsic
; CGSCC-SAME: (ptr nofree writeonly captures(none) [[DEST:%.*]], ptr nofree readonly captures(none) [[SRC:%.*]], i64 [[SIZE:%.*]]) #[[ATTR3:[0-9]+]] {
; CGSCC-NEXT:    call void @llvm.memcpy.p0.p0.i64(ptr nofree writeonly captures(none) [[DEST]], ptr nofree readonly captures(none) [[SRC]], i64 [[SIZE]], i1 noundef false) #[[ATTR7]]
; CGSCC-NEXT:    ret void
;
  call void @llvm.memcpy.p0.p0.i64(ptr %dest, ptr %src, i64 %size, i1 false)
  ret void
}

attributes #0 = { convergent mustprogress nofree norecurse nosync nounwind willreturn memory(argmem: readwrite) }

;.
; TUNIT: attributes #[[ATTR0]] = { mustprogress nofree norecurse nosync nounwind willreturn memory(none) }
; TUNIT: attributes #[[ATTR1]] = { convergent }
; TUNIT: attributes #[[ATTR2]] = { convergent mustprogress nofree norecurse nosync nounwind willreturn memory(argmem: readwrite) }
; TUNIT: attributes #[[ATTR3]] = { convergent mustprogress nofree nosync nounwind willreturn memory(argmem: readwrite) }
; TUNIT: attributes #[[ATTR4:[0-9]+]] = { nocallback nofree nounwind willreturn memory(argmem: readwrite) }
; TUNIT: attributes #[[ATTR5]] = { nofree willreturn }
;.
; CGSCC: attributes #[[ATTR0]] = { mustprogress nofree norecurse nosync nounwind willreturn memory(none) }
; CGSCC: attributes #[[ATTR1]] = { convergent mustprogress nofree nosync nounwind willreturn memory(none) }
; CGSCC: attributes #[[ATTR2]] = { convergent }
; CGSCC: attributes #[[ATTR3]] = { convergent mustprogress nofree norecurse nosync nounwind willreturn memory(argmem: readwrite) }
; CGSCC: attributes #[[ATTR4]] = { convergent mustprogress nofree nosync nounwind willreturn memory(argmem: readwrite) }
; CGSCC: attributes #[[ATTR5:[0-9]+]] = { nocallback nofree nounwind willreturn memory(argmem: readwrite) }
; CGSCC: attributes #[[ATTR6]] = { nofree nosync willreturn }
; CGSCC: attributes #[[ATTR7]] = { nofree willreturn }
;.

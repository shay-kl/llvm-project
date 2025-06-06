; RUN: llc < %s -mtriple=nvptx64 -mcpu=sm_70 -mattr=+ptx82 | FileCheck %s
; RUN: %if ptxas-12.2 %{ llc < %s -mtriple=nvptx64 -mcpu=sm_70 -mattr=+ptx82 | %ptxas-verify -arch=sm_70 %}

; TODO: fix "atomic load volatile acquire": generates "ld.acquire.sys;"
;       but should generate "ld.mmio.relaxed.sys; fence.acq_rel.sys;"
; TODO: fix "atomic store volatile release": generates "st.release.sys;"
;       but should generate "fence.acq_rel.sys; st.mmio.relaxed.sys;"

; TODO: fix "atomic load volatile seq_cst": generates "fence.sc.sys; ld.acquire.sys;"
;       but should generate "fence.sc.sys; ld.relaxed.mmio.sys; fence.acq_rel.sys;"
; TODO: fix "atomic store volatile seq_cst": generates "fence.sc.sys; st.release.sys;"
;       but should generate "fence.sc.sys; st.relaxed.mmio.sys;"

; TODO: add i1, <8 x i8>, and <6 x i8> vector tests.

; TODO: add test for vectors that exceed 128-bit length
; Per https://docs.nvidia.com/cuda/parallel-thread-execution/index.html#vectors
; vectors cannot exceed 128-bit in length, i.e., .v4.u64 is not allowed.

; TODO: generate PTX that preserves Concurrent Forward Progress
;       for atomic operations to local statespace
;       by generating atomic or volatile operations.

; TODO: design exposure for atomic operations on vector types.

; TODO: implement and test thread scope.

; TODO: add weak,atomic,volatile,atomic volatile tests
;       for .const and .param statespaces.

; TODO: optimize .sys.shared into .cta.shared or .cluster.shared .

;; generic statespace

; CHECK-LABEL: generic_unordered_gpu
define void @generic_unordered_gpu(ptr %a, ptr %b, ptr %c, ptr %d, ptr %e) local_unnamed_addr {
  ; CHECK: ld.relaxed.gpu.b8 %rs{{[0-9]+}}, [%rd{{[0-9]+}}]
  %a.load = load atomic i8, ptr %a syncscope("device") unordered, align 1
  %a.add = add i8 %a.load, 1
  ; CHECK: st.relaxed.gpu.b8 [%rd{{[0-9]+}}], %rs{{[0-9]+}}
  store atomic i8 %a.add, ptr %a syncscope("device") unordered, align 1

  ; CHECK: ld.relaxed.gpu.b16 %rs{{[0-9]+}}, [%rd{{[0-9]+}}]
  %b.load = load atomic i16, ptr %b syncscope("device") unordered, align 2
  %b.add = add i16 %b.load, 1
  ; CHECK: st.relaxed.gpu.b16 [%rd{{[0-9]+}}], %rs{{[0-9]+}}
  store atomic i16 %b.add, ptr %b syncscope("device") unordered, align 2

  ; CHECK: ld.relaxed.gpu.b32 %r{{[0-9]+}}, [%rd{{[0-9]+}}]
  %c.load = load atomic i32, ptr %c syncscope("device") unordered, align 4
  %c.add = add i32 %c.load, 1
  ; CHECK: st.relaxed.gpu.b32 [%rd{{[0-9]+}}], %r{{[0-9]+}}
  store atomic i32 %c.add, ptr %c syncscope("device") unordered, align 4

  ; CHECK: ld.relaxed.gpu.b64 %rd{{[0-9]+}}, [%rd{{[0-9]+}}]
  %d.load = load atomic i64, ptr %d syncscope("device") unordered, align 8
  %d.add = add i64 %d.load, 1
  ; CHECK: st.relaxed.gpu.b64 [%rd{{[0-9]+}}], %rd{{[0-9]+}}
  store atomic i64 %d.add, ptr %d syncscope("device") unordered, align 8

  ; CHECK: ld.relaxed.gpu.b32 %f{{[0-9]+}}, [%rd{{[0-9]+}}]
  %e.load = load atomic float, ptr %e syncscope("device") unordered, align 4
  %e.add = fadd float %e.load, 1.
  ; CHECK: st.relaxed.gpu.b32 [%rd{{[0-9]+}}], %f{{[0-9]+}}
  store atomic float %e.add, ptr %e syncscope("device") unordered, align 4

  ; CHECK: ld.relaxed.gpu.b64 %fd{{[0-9]+}}, [%rd{{[0-9]+}}]
  %f.load = load atomic double, ptr %e syncscope("device") unordered, align 8
  %f.add = fadd double %f.load, 1.
  ; CHECK: st.relaxed.gpu.b64 [%rd{{[0-9]+}}], %fd{{[0-9]+}}
  store atomic double %f.add, ptr %e syncscope("device") unordered, align 8

  ret void
}

; CHECK-LABEL: generic_unordered_volatile_gpu
define void @generic_unordered_volatile_gpu(ptr %a, ptr %b, ptr %c, ptr %d, ptr %e) local_unnamed_addr {
  ; CHECK: ld.volatile.b8 %rs{{[0-9]+}}, [%rd{{[0-9]+}}]
  %a.load = load atomic volatile i8, ptr %a syncscope("device") unordered, align 1
  %a.add = add i8 %a.load, 1
  ; CHECK: st.volatile.b8 [%rd{{[0-9]+}}], %rs{{[0-9]+}}
  store atomic volatile i8 %a.add, ptr %a syncscope("device") unordered, align 1

  ; CHECK: ld.volatile.b16 %rs{{[0-9]+}}, [%rd{{[0-9]+}}]
  %b.load = load atomic volatile i16, ptr %b syncscope("device") unordered, align 2
  %b.add = add i16 %b.load, 1
  ; CHECK: st.volatile.b16 [%rd{{[0-9]+}}], %rs{{[0-9]+}}
  store atomic volatile i16 %b.add, ptr %b syncscope("device") unordered, align 2

  ; CHECK: ld.volatile.b32 %r{{[0-9]+}}, [%rd{{[0-9]+}}]
  %c.load = load atomic volatile i32, ptr %c syncscope("device") unordered, align 4
  %c.add = add i32 %c.load, 1
  ; CHECK: st.volatile.b32 [%rd{{[0-9]+}}], %r{{[0-9]+}}
  store atomic volatile i32 %c.add, ptr %c syncscope("device") unordered, align 4

  ; CHECK: ld.volatile.b64 %rd{{[0-9]+}}, [%rd{{[0-9]+}}]
  %d.load = load atomic volatile i64, ptr %d syncscope("device") unordered, align 8
  %d.add = add i64 %d.load, 1
  ; CHECK: st.volatile.b64 [%rd{{[0-9]+}}], %rd{{[0-9]+}}
  store atomic volatile i64 %d.add, ptr %d syncscope("device") unordered, align 8

  ; CHECK: ld.volatile.b32 %f{{[0-9]+}}, [%rd{{[0-9]+}}]
  %e.load = load atomic volatile float, ptr %e syncscope("device") unordered, align 4
  %e.add = fadd float %e.load, 1.
  ; CHECK: st.volatile.b32 [%rd{{[0-9]+}}], %f{{[0-9]+}}
  store atomic volatile float %e.add, ptr %e syncscope("device") unordered, align 4

  ; CHECK: ld.volatile.b64 %fd{{[0-9]+}}, [%rd{{[0-9]+}}]
  %f.load = load atomic volatile double, ptr %e syncscope("device") unordered, align 8
  %f.add = fadd double %f.load, 1.
  ; CHECK: st.volatile.b64 [%rd{{[0-9]+}}], %fd{{[0-9]+}}
  store atomic volatile double %f.add, ptr %e syncscope("device") unordered, align 8

  ret void
}

; CHECK-LABEL: generic_unordered_cta
define void @generic_unordered_cta(ptr %a, ptr %b, ptr %c, ptr %d, ptr %e) local_unnamed_addr {
  ; CHECK: ld.relaxed.cta.b8 %rs{{[0-9]+}}, [%rd{{[0-9]+}}]
  %a.load = load atomic i8, ptr %a syncscope("block") unordered, align 1
  %a.add = add i8 %a.load, 1
  ; CHECK: st.relaxed.cta.b8 [%rd{{[0-9]+}}], %rs{{[0-9]+}}
  store atomic i8 %a.add, ptr %a syncscope("block") unordered, align 1

  ; CHECK: ld.relaxed.cta.b16 %rs{{[0-9]+}}, [%rd{{[0-9]+}}]
  %b.load = load atomic i16, ptr %b syncscope("block") unordered, align 2
  %b.add = add i16 %b.load, 1
  ; CHECK: st.relaxed.cta.b16 [%rd{{[0-9]+}}], %rs{{[0-9]+}}
  store atomic i16 %b.add, ptr %b syncscope("block") unordered, align 2

  ; CHECK: ld.relaxed.cta.b32 %r{{[0-9]+}}, [%rd{{[0-9]+}}]
  %c.load = load atomic i32, ptr %c syncscope("block") unordered, align 4
  %c.add = add i32 %c.load, 1
  ; CHECK: st.relaxed.cta.b32 [%rd{{[0-9]+}}], %r{{[0-9]+}}
  store atomic i32 %c.add, ptr %c syncscope("block") unordered, align 4

  ; CHECK: ld.relaxed.cta.b64 %rd{{[0-9]+}}, [%rd{{[0-9]+}}]
  %d.load = load atomic i64, ptr %d syncscope("block") unordered, align 8
  %d.add = add i64 %d.load, 1
  ; CHECK: st.relaxed.cta.b64 [%rd{{[0-9]+}}], %rd{{[0-9]+}}
  store atomic i64 %d.add, ptr %d syncscope("block") unordered, align 8

  ; CHECK: ld.relaxed.cta.b32 %f{{[0-9]+}}, [%rd{{[0-9]+}}]
  %e.load = load atomic float, ptr %e syncscope("block") unordered, align 4
  %e.add = fadd float %e.load, 1.
  ; CHECK: st.relaxed.cta.b32 [%rd{{[0-9]+}}], %f{{[0-9]+}}
  store atomic float %e.add, ptr %e syncscope("block") unordered, align 4

  ; CHECK: ld.relaxed.cta.b64 %fd{{[0-9]+}}, [%rd{{[0-9]+}}]
  %f.load = load atomic double, ptr %e syncscope("block") unordered, align 8
  %f.add = fadd double %f.load, 1.
  ; CHECK: st.relaxed.cta.b64 [%rd{{[0-9]+}}], %fd{{[0-9]+}}
  store atomic double %f.add, ptr %e syncscope("block") unordered, align 8

  ret void
}

; CHECK-LABEL: generic_unordered_volatile_cta
define void @generic_unordered_volatile_cta(ptr %a, ptr %b, ptr %c, ptr %d, ptr %e) local_unnamed_addr {
  ; CHECK: ld.volatile.b8 %rs{{[0-9]+}}, [%rd{{[0-9]+}}]
  %a.load = load atomic volatile i8, ptr %a syncscope("block") unordered, align 1
  %a.add = add i8 %a.load, 1
  ; CHECK: st.volatile.b8 [%rd{{[0-9]+}}], %rs{{[0-9]+}}
  store atomic volatile i8 %a.add, ptr %a syncscope("block") unordered, align 1

  ; CHECK: ld.volatile.b16 %rs{{[0-9]+}}, [%rd{{[0-9]+}}]
  %b.load = load atomic volatile i16, ptr %b syncscope("block") unordered, align 2
  %b.add = add i16 %b.load, 1
  ; CHECK: st.volatile.b16 [%rd{{[0-9]+}}], %rs{{[0-9]+}}
  store atomic volatile i16 %b.add, ptr %b syncscope("block") unordered, align 2

  ; CHECK: ld.volatile.b32 %r{{[0-9]+}}, [%rd{{[0-9]+}}]
  %c.load = load atomic volatile i32, ptr %c syncscope("block") unordered, align 4
  %c.add = add i32 %c.load, 1
  ; CHECK: st.volatile.b32 [%rd{{[0-9]+}}], %r{{[0-9]+}}
  store atomic volatile i32 %c.add, ptr %c syncscope("block") unordered, align 4

  ; CHECK: ld.volatile.b64 %rd{{[0-9]+}}, [%rd{{[0-9]+}}]
  %d.load = load atomic volatile i64, ptr %d syncscope("block") unordered, align 8
  %d.add = add i64 %d.load, 1
  ; CHECK: st.volatile.b64 [%rd{{[0-9]+}}], %rd{{[0-9]+}}
  store atomic volatile i64 %d.add, ptr %d syncscope("block") unordered, align 8

  ; CHECK: ld.volatile.b32 %f{{[0-9]+}}, [%rd{{[0-9]+}}]
  %e.load = load atomic volatile float, ptr %e syncscope("block") unordered, align 4
  %e.add = fadd float %e.load, 1.
  ; CHECK: st.volatile.b32 [%rd{{[0-9]+}}], %f{{[0-9]+}}
  store atomic volatile float %e.add, ptr %e syncscope("block") unordered, align 4

  ; CHECK: ld.volatile.b64 %fd{{[0-9]+}}, [%rd{{[0-9]+}}]
  %f.load = load atomic volatile double, ptr %e syncscope("block") unordered, align 8
  %f.add = fadd double %f.load, 1.
  ; CHECK: st.volatile.b64 [%rd{{[0-9]+}}], %fd{{[0-9]+}}
  store atomic volatile double %f.add, ptr %e syncscope("block") unordered, align 8

  ret void
}

; CHECK-LABEL: generic_monotonic_gpu
define void @generic_monotonic_gpu(ptr %a, ptr %b, ptr %c, ptr %d, ptr %e) local_unnamed_addr {
  ; CHECK: ld.relaxed.gpu.b8 %rs{{[0-9]+}}, [%rd{{[0-9]+}}]
  %a.load = load atomic i8, ptr %a syncscope("device") monotonic, align 1
  %a.add = add i8 %a.load, 1
  ; CHECK: st.relaxed.gpu.b8 [%rd{{[0-9]+}}], %rs{{[0-9]+}}
  store atomic i8 %a.add, ptr %a syncscope("device") monotonic, align 1

  ; CHECK: ld.relaxed.gpu.b16 %rs{{[0-9]+}}, [%rd{{[0-9]+}}]
  %b.load = load atomic i16, ptr %b syncscope("device") monotonic, align 2
  %b.add = add i16 %b.load, 1
  ; CHECK: st.relaxed.gpu.b16 [%rd{{[0-9]+}}], %rs{{[0-9]+}}
  store atomic i16 %b.add, ptr %b syncscope("device") monotonic, align 2

  ; CHECK: ld.relaxed.gpu.b32 %r{{[0-9]+}}, [%rd{{[0-9]+}}]
  %c.load = load atomic i32, ptr %c syncscope("device") monotonic, align 4
  %c.add = add i32 %c.load, 1
  ; CHECK: st.relaxed.gpu.b32 [%rd{{[0-9]+}}], %r{{[0-9]+}}
  store atomic i32 %c.add, ptr %c syncscope("device") monotonic, align 4

  ; CHECK: ld.relaxed.gpu.b64 %rd{{[0-9]+}}, [%rd{{[0-9]+}}]
  %d.load = load atomic i64, ptr %d syncscope("device") monotonic, align 8
  %d.add = add i64 %d.load, 1
  ; CHECK: st.relaxed.gpu.b64 [%rd{{[0-9]+}}], %rd{{[0-9]+}}
  store atomic i64 %d.add, ptr %d syncscope("device") monotonic, align 8

  ; CHECK: ld.relaxed.gpu.b32 %f{{[0-9]+}}, [%rd{{[0-9]+}}]
  %e.load = load atomic float, ptr %e syncscope("device") monotonic, align 4
  %e.add = fadd float %e.load, 1.
  ; CHECK: st.relaxed.gpu.b32 [%rd{{[0-9]+}}], %f{{[0-9]+}}
  store atomic float %e.add, ptr %e syncscope("device") monotonic, align 4

  ; CHECK: ld.relaxed.gpu.b64 %fd{{[0-9]+}}, [%rd{{[0-9]+}}]
  %f.load = load atomic double, ptr %e syncscope("device") monotonic, align 8
  %f.add = fadd double %f.load, 1.
  ; CHECK: st.relaxed.gpu.b64 [%rd{{[0-9]+}}], %fd{{[0-9]+}}
  store atomic double %f.add, ptr %e syncscope("device") monotonic, align 8

  ret void
}

; CHECK-LABEL: generic_monotonic_volatile_gpu
define void @generic_monotonic_volatile_gpu(ptr %a, ptr %b, ptr %c, ptr %d, ptr %e) local_unnamed_addr {
  ; CHECK: ld.volatile.b8 %rs{{[0-9]+}}, [%rd{{[0-9]+}}]
  %a.load = load atomic volatile i8, ptr %a syncscope("device") monotonic, align 1
  %a.add = add i8 %a.load, 1
  ; CHECK: st.volatile.b8 [%rd{{[0-9]+}}], %rs{{[0-9]+}}
  store atomic volatile i8 %a.add, ptr %a syncscope("device") monotonic, align 1

  ; CHECK: ld.volatile.b16 %rs{{[0-9]+}}, [%rd{{[0-9]+}}]
  %b.load = load atomic volatile i16, ptr %b syncscope("device") monotonic, align 2
  %b.add = add i16 %b.load, 1
  ; CHECK: st.volatile.b16 [%rd{{[0-9]+}}], %rs{{[0-9]+}}
  store atomic volatile i16 %b.add, ptr %b syncscope("device") monotonic, align 2

  ; CHECK: ld.volatile.b32 %r{{[0-9]+}}, [%rd{{[0-9]+}}]
  %c.load = load atomic volatile i32, ptr %c syncscope("device") monotonic, align 4
  %c.add = add i32 %c.load, 1
  ; CHECK: st.volatile.b32 [%rd{{[0-9]+}}], %r{{[0-9]+}}
  store atomic volatile i32 %c.add, ptr %c syncscope("device") monotonic, align 4

  ; CHECK: ld.volatile.b64 %rd{{[0-9]+}}, [%rd{{[0-9]+}}]
  %d.load = load atomic volatile i64, ptr %d syncscope("device") monotonic, align 8
  %d.add = add i64 %d.load, 1
  ; CHECK: st.volatile.b64 [%rd{{[0-9]+}}], %rd{{[0-9]+}}
  store atomic volatile i64 %d.add, ptr %d syncscope("device") monotonic, align 8

  ; CHECK: ld.volatile.b32 %f{{[0-9]+}}, [%rd{{[0-9]+}}]
  %e.load = load atomic volatile float, ptr %e syncscope("device") monotonic, align 4
  %e.add = fadd float %e.load, 1.
  ; CHECK: st.volatile.b32 [%rd{{[0-9]+}}], %f{{[0-9]+}}
  store atomic volatile float %e.add, ptr %e syncscope("device") monotonic, align 4

  ; CHECK: ld.volatile.b64 %fd{{[0-9]+}}, [%rd{{[0-9]+}}]
  %f.load = load atomic volatile double, ptr %e syncscope("device") monotonic, align 8
  %f.add = fadd double %f.load, 1.
  ; CHECK: st.volatile.b64 [%rd{{[0-9]+}}], %fd{{[0-9]+}}
  store atomic volatile double %f.add, ptr %e syncscope("device") monotonic, align 8

  ret void
}

; CHECK-LABEL: generic_monotonic_cta
define void @generic_monotonic_cta(ptr %a, ptr %b, ptr %c, ptr %d, ptr %e) local_unnamed_addr {
  ; CHECK: ld.relaxed.cta.b8 %rs{{[0-9]+}}, [%rd{{[0-9]+}}]
  %a.load = load atomic i8, ptr %a syncscope("block") monotonic, align 1
  %a.add = add i8 %a.load, 1
  ; CHECK: st.relaxed.cta.b8 [%rd{{[0-9]+}}], %rs{{[0-9]+}}
  store atomic i8 %a.add, ptr %a syncscope("block") monotonic, align 1

  ; CHECK: ld.relaxed.cta.b16 %rs{{[0-9]+}}, [%rd{{[0-9]+}}]
  %b.load = load atomic i16, ptr %b syncscope("block") monotonic, align 2
  %b.add = add i16 %b.load, 1
  ; CHECK: st.relaxed.cta.b16 [%rd{{[0-9]+}}], %rs{{[0-9]+}}
  store atomic i16 %b.add, ptr %b syncscope("block") monotonic, align 2

  ; CHECK: ld.relaxed.cta.b32 %r{{[0-9]+}}, [%rd{{[0-9]+}}]
  %c.load = load atomic i32, ptr %c syncscope("block") monotonic, align 4
  %c.add = add i32 %c.load, 1
  ; CHECK: st.relaxed.cta.b32 [%rd{{[0-9]+}}], %r{{[0-9]+}}
  store atomic i32 %c.add, ptr %c syncscope("block") monotonic, align 4

  ; CHECK: ld.relaxed.cta.b64 %rd{{[0-9]+}}, [%rd{{[0-9]+}}]
  %d.load = load atomic i64, ptr %d syncscope("block") monotonic, align 8
  %d.add = add i64 %d.load, 1
  ; CHECK: st.relaxed.cta.b64 [%rd{{[0-9]+}}], %rd{{[0-9]+}}
  store atomic i64 %d.add, ptr %d syncscope("block") monotonic, align 8

  ; CHECK: ld.relaxed.cta.b32 %f{{[0-9]+}}, [%rd{{[0-9]+}}]
  %e.load = load atomic float, ptr %e syncscope("block") monotonic, align 4
  %e.add = fadd float %e.load, 1.
  ; CHECK: st.relaxed.cta.b32 [%rd{{[0-9]+}}], %f{{[0-9]+}}
  store atomic float %e.add, ptr %e syncscope("block") monotonic, align 4

  ; CHECK: ld.relaxed.cta.b64 %fd{{[0-9]+}}, [%rd{{[0-9]+}}]
  %f.load = load atomic double, ptr %e syncscope("block") monotonic, align 8
  %f.add = fadd double %f.load, 1.
  ; CHECK: st.relaxed.cta.b64 [%rd{{[0-9]+}}], %fd{{[0-9]+}}
  store atomic double %f.add, ptr %e syncscope("block") monotonic, align 8

  ret void
}

; CHECK-LABEL: generic_monotonic_volatile_cta
define void @generic_monotonic_volatile_cta(ptr %a, ptr %b, ptr %c, ptr %d, ptr %e) local_unnamed_addr {
  ; CHECK: ld.volatile.b8 %rs{{[0-9]+}}, [%rd{{[0-9]+}}]
  %a.load = load atomic volatile i8, ptr %a syncscope("block") monotonic, align 1
  %a.add = add i8 %a.load, 1
  ; CHECK: st.volatile.b8 [%rd{{[0-9]+}}], %rs{{[0-9]+}}
  store atomic volatile i8 %a.add, ptr %a syncscope("block") monotonic, align 1

  ; CHECK: ld.volatile.b16 %rs{{[0-9]+}}, [%rd{{[0-9]+}}]
  %b.load = load atomic volatile i16, ptr %b syncscope("block") monotonic, align 2
  %b.add = add i16 %b.load, 1
  ; CHECK: st.volatile.b16 [%rd{{[0-9]+}}], %rs{{[0-9]+}}
  store atomic volatile i16 %b.add, ptr %b syncscope("block") monotonic, align 2

  ; CHECK: ld.volatile.b32 %r{{[0-9]+}}, [%rd{{[0-9]+}}]
  %c.load = load atomic volatile i32, ptr %c syncscope("block") monotonic, align 4
  %c.add = add i32 %c.load, 1
  ; CHECK: st.volatile.b32 [%rd{{[0-9]+}}], %r{{[0-9]+}}
  store atomic volatile i32 %c.add, ptr %c syncscope("block") monotonic, align 4

  ; CHECK: ld.volatile.b64 %rd{{[0-9]+}}, [%rd{{[0-9]+}}]
  %d.load = load atomic volatile i64, ptr %d syncscope("block") monotonic, align 8
  %d.add = add i64 %d.load, 1
  ; CHECK: st.volatile.b64 [%rd{{[0-9]+}}], %rd{{[0-9]+}}
  store atomic volatile i64 %d.add, ptr %d syncscope("block") monotonic, align 8

  ; CHECK: ld.volatile.b32 %f{{[0-9]+}}, [%rd{{[0-9]+}}]
  %e.load = load atomic volatile float, ptr %e syncscope("block") monotonic, align 4
  %e.add = fadd float %e.load, 1.
  ; CHECK: st.volatile.b32 [%rd{{[0-9]+}}], %f{{[0-9]+}}
  store atomic volatile float %e.add, ptr %e syncscope("block") monotonic, align 4

  ; CHECK: ld.volatile.b64 %fd{{[0-9]+}}, [%rd{{[0-9]+}}]
  %f.load = load atomic volatile double, ptr %e syncscope("block") monotonic, align 8
  %f.add = fadd double %f.load, 1.
  ; CHECK: st.volatile.b64 [%rd{{[0-9]+}}], %fd{{[0-9]+}}
  store atomic volatile double %f.add, ptr %e syncscope("block") monotonic, align 8

  ret void
}

; CHECK-LABEL: generic_acq_rel_sys
define void @generic_acq_rel_sys(ptr %a, ptr %b, ptr %c, ptr %d, ptr %e) local_unnamed_addr {
  ; CHECK: ld.acquire.sys.b8 %rs{{[0-9]+}}, [%rd{{[0-9]+}}]
  %a.load = load atomic i8, ptr %a acquire, align 1
  %a.add = add i8 %a.load, 1
  ; CHECK: st.release.sys.b8 [%rd{{[0-9]+}}], %rs{{[0-9]+}}
  store atomic i8 %a.add, ptr %a release, align 1

  ; CHECK: ld.acquire.sys.b16 %rs{{[0-9]+}}, [%rd{{[0-9]+}}]
  %b.load = load atomic i16, ptr %b acquire, align 2
  %b.add = add i16 %b.load, 1
  ; CHECK: st.release.sys.b16 [%rd{{[0-9]+}}], %rs{{[0-9]+}}
  store atomic i16 %b.add, ptr %b release, align 2

  ; CHECK: ld.acquire.sys.b32 %r{{[0-9]+}}, [%rd{{[0-9]+}}]
  %c.load = load atomic i32, ptr %c acquire, align 4
  %c.add = add i32 %c.load, 1
  ; CHECK: st.release.sys.b32 [%rd{{[0-9]+}}], %r{{[0-9]+}}
  store atomic i32 %c.add, ptr %c release, align 4

  ; CHECK: ld.acquire.sys.b64 %rd{{[0-9]+}}, [%rd{{[0-9]+}}]
  %d.load = load atomic i64, ptr %d acquire, align 8
  %d.add = add i64 %d.load, 1
  ; CHECK: st.release.sys.b64 [%rd{{[0-9]+}}], %rd{{[0-9]+}}
  store atomic i64 %d.add, ptr %d release, align 8

  ; CHECK: ld.acquire.sys.b32 %f{{[0-9]+}}, [%rd{{[0-9]+}}]
  %e.load = load atomic float, ptr %e acquire, align 4
  %e.add = fadd float %e.load, 1.
  ; CHECK: st.release.sys.b32 [%rd{{[0-9]+}}], %f{{[0-9]+}}
  store atomic float %e.add, ptr %e release, align 4

  ; CHECK: ld.acquire.sys.b64 %fd{{[0-9]+}}, [%rd{{[0-9]+}}]
  %f.load = load atomic double, ptr %e acquire, align 8
  %f.add = fadd double %f.load, 1.
  ; CHECK: st.release.sys.b64 [%rd{{[0-9]+}}], %fd{{[0-9]+}}
  store atomic double %f.add, ptr %e release, align 8

  ret void
}

; CHECK-LABEL: generic_acq_rel_volatile_sys
define void @generic_acq_rel_volatile_sys(ptr %a, ptr %b, ptr %c, ptr %d, ptr %e) local_unnamed_addr {
  ; CHECK: ld.acquire.sys.b8 %rs{{[0-9]+}}, [%rd{{[0-9]+}}]
  %a.load = load atomic volatile i8, ptr %a acquire, align 1
  %a.add = add i8 %a.load, 1
  ; CHECK: st.release.sys.b8 [%rd{{[0-9]+}}], %rs{{[0-9]+}}
  store atomic volatile i8 %a.add, ptr %a release, align 1

  ; CHECK: ld.acquire.sys.b16 %rs{{[0-9]+}}, [%rd{{[0-9]+}}]
  %b.load = load atomic volatile i16, ptr %b acquire, align 2
  %b.add = add i16 %b.load, 1
  ; CHECK: st.release.sys.b16 [%rd{{[0-9]+}}], %rs{{[0-9]+}}
  store atomic volatile i16 %b.add, ptr %b release, align 2

  ; CHECK: ld.acquire.sys.b32 %r{{[0-9]+}}, [%rd{{[0-9]+}}]
  %c.load = load atomic volatile i32, ptr %c acquire, align 4
  %c.add = add i32 %c.load, 1
  ; CHECK: st.release.sys.b32 [%rd{{[0-9]+}}], %r{{[0-9]+}}
  store atomic volatile i32 %c.add, ptr %c release, align 4

  ; CHECK: ld.acquire.sys.b64 %rd{{[0-9]+}}, [%rd{{[0-9]+}}]
  %d.load = load atomic volatile i64, ptr %d acquire, align 8
  %d.add = add i64 %d.load, 1
  ; CHECK: st.release.sys.b64 [%rd{{[0-9]+}}], %rd{{[0-9]+}}
  store atomic volatile i64 %d.add, ptr %d release, align 8

  ; CHECK: ld.acquire.sys.b32 %f{{[0-9]+}}, [%rd{{[0-9]+}}]
  %e.load = load atomic volatile float, ptr %e acquire, align 4
  %e.add = fadd float %e.load, 1.
  ; CHECK: st.release.sys.b32 [%rd{{[0-9]+}}], %f{{[0-9]+}}
  store atomic volatile float %e.add, ptr %e release, align 4

  ; CHECK: ld.acquire.sys.b64 %fd{{[0-9]+}}, [%rd{{[0-9]+}}]
  %f.load = load atomic volatile double, ptr %e acquire, align 8
  %f.add = fadd double %f.load, 1.
  ; CHECK: st.release.sys.b64 [%rd{{[0-9]+}}], %fd{{[0-9]+}}
  store atomic volatile double %f.add, ptr %e release, align 8

  ret void
}

; CHECK-LABEL: generic_acq_rel_gpu
define void @generic_acq_rel_gpu(ptr %a, ptr %b, ptr %c, ptr %d, ptr %e) local_unnamed_addr {
  ; CHECK: ld.acquire.gpu.b8 %rs{{[0-9]+}}, [%rd{{[0-9]+}}]
  %a.load = load atomic i8, ptr %a syncscope("device") acquire, align 1
  %a.add = add i8 %a.load, 1
  ; CHECK: st.release.gpu.b8 [%rd{{[0-9]+}}], %rs{{[0-9]+}}
  store atomic i8 %a.add, ptr %a syncscope("device") release, align 1

  ; CHECK: ld.acquire.gpu.b16 %rs{{[0-9]+}}, [%rd{{[0-9]+}}]
  %b.load = load atomic i16, ptr %b syncscope("device") acquire, align 2
  %b.add = add i16 %b.load, 1
  ; CHECK: st.release.gpu.b16 [%rd{{[0-9]+}}], %rs{{[0-9]+}}
  store atomic i16 %b.add, ptr %b syncscope("device") release, align 2

  ; CHECK: ld.acquire.gpu.b32 %r{{[0-9]+}}, [%rd{{[0-9]+}}]
  %c.load = load atomic i32, ptr %c syncscope("device") acquire, align 4
  %c.add = add i32 %c.load, 1
  ; CHECK: st.release.gpu.b32 [%rd{{[0-9]+}}], %r{{[0-9]+}}
  store atomic i32 %c.add, ptr %c syncscope("device") release, align 4

  ; CHECK: ld.acquire.gpu.b64 %rd{{[0-9]+}}, [%rd{{[0-9]+}}]
  %d.load = load atomic i64, ptr %d syncscope("device") acquire, align 8
  %d.add = add i64 %d.load, 1
  ; CHECK: st.release.gpu.b64 [%rd{{[0-9]+}}], %rd{{[0-9]+}}
  store atomic i64 %d.add, ptr %d syncscope("device") release, align 8

  ; CHECK: ld.acquire.gpu.b32 %f{{[0-9]+}}, [%rd{{[0-9]+}}]
  %e.load = load atomic float, ptr %e syncscope("device") acquire, align 4
  %e.add = fadd float %e.load, 1.
  ; CHECK: st.release.gpu.b32 [%rd{{[0-9]+}}], %f{{[0-9]+}}
  store atomic float %e.add, ptr %e syncscope("device") release, align 4

  ; CHECK: ld.acquire.gpu.b64 %fd{{[0-9]+}}, [%rd{{[0-9]+}}]
  %f.load = load atomic double, ptr %e syncscope("device") acquire, align 8
  %f.add = fadd double %f.load, 1.
  ; CHECK: st.release.gpu.b64 [%rd{{[0-9]+}}], %fd{{[0-9]+}}
  store atomic double %f.add, ptr %e syncscope("device") release, align 8

  ret void
}

; CHECK-LABEL: generic_acq_rel_volatile_gpu
define void @generic_acq_rel_volatile_gpu(ptr %a, ptr %b, ptr %c, ptr %d, ptr %e) local_unnamed_addr {
  ; CHECK: ld.acquire.sys.b8 %rs{{[0-9]+}}, [%rd{{[0-9]+}}]
  %a.load = load atomic volatile i8, ptr %a syncscope("device") acquire, align 1
  %a.add = add i8 %a.load, 1
  ; CHECK: st.release.sys.b8 [%rd{{[0-9]+}}], %rs{{[0-9]+}}
  store atomic volatile i8 %a.add, ptr %a syncscope("device") release, align 1

  ; CHECK: ld.acquire.sys.b16 %rs{{[0-9]+}}, [%rd{{[0-9]+}}]
  %b.load = load atomic volatile i16, ptr %b syncscope("device") acquire, align 2
  %b.add = add i16 %b.load, 1
  ; CHECK: st.release.sys.b16 [%rd{{[0-9]+}}], %rs{{[0-9]+}}
  store atomic volatile i16 %b.add, ptr %b syncscope("device") release, align 2

  ; CHECK: ld.acquire.sys.b32 %r{{[0-9]+}}, [%rd{{[0-9]+}}]
  %c.load = load atomic volatile i32, ptr %c syncscope("device") acquire, align 4
  %c.add = add i32 %c.load, 1
  ; CHECK: st.release.sys.b32 [%rd{{[0-9]+}}], %r{{[0-9]+}}
  store atomic volatile i32 %c.add, ptr %c syncscope("device") release, align 4

  ; CHECK: ld.acquire.sys.b64 %rd{{[0-9]+}}, [%rd{{[0-9]+}}]
  %d.load = load atomic volatile i64, ptr %d syncscope("device") acquire, align 8
  %d.add = add i64 %d.load, 1
  ; CHECK: st.release.sys.b64 [%rd{{[0-9]+}}], %rd{{[0-9]+}}
  store atomic volatile i64 %d.add, ptr %d syncscope("device") release, align 8

  ; CHECK: ld.acquire.sys.b32 %f{{[0-9]+}}, [%rd{{[0-9]+}}]
  %e.load = load atomic volatile float, ptr %e syncscope("device") acquire, align 4
  %e.add = fadd float %e.load, 1.
  ; CHECK: st.release.sys.b32 [%rd{{[0-9]+}}], %f{{[0-9]+}}
  store atomic volatile float %e.add, ptr %e syncscope("device") release, align 4

  ; CHECK: ld.acquire.sys.b64 %fd{{[0-9]+}}, [%rd{{[0-9]+}}]
  %f.load = load atomic volatile double, ptr %e syncscope("device") acquire, align 8
  %f.add = fadd double %f.load, 1.
  ; CHECK: st.release.sys.b64 [%rd{{[0-9]+}}], %fd{{[0-9]+}}
  store atomic volatile double %f.add, ptr %e syncscope("device") release, align 8

  ret void
}

; CHECK-LABEL: generic_acq_rel_cta
define void @generic_acq_rel_cta(ptr %a, ptr %b, ptr %c, ptr %d, ptr %e) local_unnamed_addr {
  ; CHECK: ld.acquire.cta.b8 %rs{{[0-9]+}}, [%rd{{[0-9]+}}]
  %a.load = load atomic i8, ptr %a syncscope("block") acquire, align 1
  %a.add = add i8 %a.load, 1
  ; CHECK: st.release.cta.b8 [%rd{{[0-9]+}}], %rs{{[0-9]+}}
  store atomic i8 %a.add, ptr %a syncscope("block") release, align 1

  ; CHECK: ld.acquire.cta.b16 %rs{{[0-9]+}}, [%rd{{[0-9]+}}]
  %b.load = load atomic i16, ptr %b syncscope("block") acquire, align 2
  %b.add = add i16 %b.load, 1
  ; CHECK: st.release.cta.b16 [%rd{{[0-9]+}}], %rs{{[0-9]+}}
  store atomic i16 %b.add, ptr %b syncscope("block") release, align 2

  ; CHECK: ld.acquire.cta.b32 %r{{[0-9]+}}, [%rd{{[0-9]+}}]
  %c.load = load atomic i32, ptr %c syncscope("block") acquire, align 4
  %c.add = add i32 %c.load, 1
  ; CHECK: st.release.cta.b32 [%rd{{[0-9]+}}], %r{{[0-9]+}}
  store atomic i32 %c.add, ptr %c syncscope("block") release, align 4

  ; CHECK: ld.acquire.cta.b64 %rd{{[0-9]+}}, [%rd{{[0-9]+}}]
  %d.load = load atomic i64, ptr %d syncscope("block") acquire, align 8
  %d.add = add i64 %d.load, 1
  ; CHECK: st.release.cta.b64 [%rd{{[0-9]+}}], %rd{{[0-9]+}}
  store atomic i64 %d.add, ptr %d syncscope("block") release, align 8

  ; CHECK: ld.acquire.cta.b32 %f{{[0-9]+}}, [%rd{{[0-9]+}}]
  %e.load = load atomic float, ptr %e syncscope("block") acquire, align 4
  %e.add = fadd float %e.load, 1.
  ; CHECK: st.release.cta.b32 [%rd{{[0-9]+}}], %f{{[0-9]+}}
  store atomic float %e.add, ptr %e syncscope("block") release, align 4

  ; CHECK: ld.acquire.cta.b64 %fd{{[0-9]+}}, [%rd{{[0-9]+}}]
  %f.load = load atomic double, ptr %e syncscope("block") acquire, align 8
  %f.add = fadd double %f.load, 1.
  ; CHECK: st.release.cta.b64 [%rd{{[0-9]+}}], %fd{{[0-9]+}}
  store atomic double %f.add, ptr %e syncscope("block") release, align 8

  ret void
}

; CHECK-LABEL: generic_acq_rel_volatile_cta
define void @generic_acq_rel_volatile_cta(ptr %a, ptr %b, ptr %c, ptr %d, ptr %e) local_unnamed_addr {
  ; CHECK: ld.acquire.sys.b8 %rs{{[0-9]+}}, [%rd{{[0-9]+}}]
  %a.load = load atomic volatile i8, ptr %a syncscope("block") acquire, align 1
  %a.add = add i8 %a.load, 1
  ; CHECK: st.release.sys.b8 [%rd{{[0-9]+}}], %rs{{[0-9]+}}
  store atomic volatile i8 %a.add, ptr %a syncscope("block") release, align 1

  ; CHECK: ld.acquire.sys.b16 %rs{{[0-9]+}}, [%rd{{[0-9]+}}]
  %b.load = load atomic volatile i16, ptr %b syncscope("block") acquire, align 2
  %b.add = add i16 %b.load, 1
  ; CHECK: st.release.sys.b16 [%rd{{[0-9]+}}], %rs{{[0-9]+}}
  store atomic volatile i16 %b.add, ptr %b syncscope("block") release, align 2

  ; CHECK: ld.acquire.sys.b32 %r{{[0-9]+}}, [%rd{{[0-9]+}}]
  %c.load = load atomic volatile i32, ptr %c syncscope("block") acquire, align 4
  %c.add = add i32 %c.load, 1
  ; CHECK: st.release.sys.b32 [%rd{{[0-9]+}}], %r{{[0-9]+}}
  store atomic volatile i32 %c.add, ptr %c syncscope("block") release, align 4

  ; CHECK: ld.acquire.sys.b64 %rd{{[0-9]+}}, [%rd{{[0-9]+}}]
  %d.load = load atomic volatile i64, ptr %d syncscope("block") acquire, align 8
  %d.add = add i64 %d.load, 1
  ; CHECK: st.release.sys.b64 [%rd{{[0-9]+}}], %rd{{[0-9]+}}
  store atomic volatile i64 %d.add, ptr %d syncscope("block") release, align 8

  ; CHECK: ld.acquire.sys.b32 %f{{[0-9]+}}, [%rd{{[0-9]+}}]
  %e.load = load atomic volatile float, ptr %e syncscope("block") acquire, align 4
  %e.add = fadd float %e.load, 1.
  ; CHECK: st.release.sys.b32 [%rd{{[0-9]+}}], %f{{[0-9]+}}
  store atomic volatile float %e.add, ptr %e syncscope("block") release, align 4

  ; CHECK: ld.acquire.sys.b64 %fd{{[0-9]+}}, [%rd{{[0-9]+}}]
  %f.load = load atomic volatile double, ptr %e syncscope("block") acquire, align 8
  %f.add = fadd double %f.load, 1.
  ; CHECK: st.release.sys.b64 [%rd{{[0-9]+}}], %fd{{[0-9]+}}
  store atomic volatile double %f.add, ptr %e syncscope("block") release, align 8

  ret void
}

; CHECK-LABEL: generic_sc_sys
define void @generic_sc_sys(ptr %a, ptr %b, ptr %c, ptr %d, ptr %e) local_unnamed_addr {
  ; CHECK: fence.sc.sys
  ; CHECK: ld.acquire.sys.b8 %rs{{[0-9]+}}, [%rd{{[0-9]+}}]
  %a.load = load atomic i8, ptr %a seq_cst, align 1
  %a.add = add i8 %a.load, 1
  ; CHECK: fence.sc.sys
  ; CHECK: st.release.sys.b8 [%rd{{[0-9]+}}], %rs{{[0-9]+}}
  store atomic i8 %a.add, ptr %a seq_cst, align 1

  ; CHECK: fence.sc.sys
  ; CHECK: ld.acquire.sys.b16 %rs{{[0-9]+}}, [%rd{{[0-9]+}}]
  %b.load = load atomic i16, ptr %b seq_cst, align 2
  %b.add = add i16 %b.load, 1
  ; CHECK: fence.sc.sys
  ; CHECK: st.release.sys.b16 [%rd{{[0-9]+}}], %rs{{[0-9]+}}
  store atomic i16 %b.add, ptr %b seq_cst, align 2

  ; CHECK: fence.sc.sys
  ; CHECK: ld.acquire.sys.b32 %r{{[0-9]+}}, [%rd{{[0-9]+}}]
  %c.load = load atomic i32, ptr %c seq_cst, align 4
  %c.add = add i32 %c.load, 1
  ; CHECK: fence.sc.sys
  ; CHECK: st.release.sys.b32 [%rd{{[0-9]+}}], %r{{[0-9]+}}
  store atomic i32 %c.add, ptr %c seq_cst, align 4

  ; CHECK: fence.sc.sys
  ; CHECK: ld.acquire.sys.b64 %rd{{[0-9]+}}, [%rd{{[0-9]+}}]
  %d.load = load atomic i64, ptr %d seq_cst, align 8
  %d.add = add i64 %d.load, 1
  ; CHECK: fence.sc.sys
  ; CHECK: st.release.sys.b64 [%rd{{[0-9]+}}], %rd{{[0-9]+}}
  store atomic i64 %d.add, ptr %d seq_cst, align 8

  ; CHECK: fence.sc.sys
  ; CHECK: ld.acquire.sys.b32 %f{{[0-9]+}}, [%rd{{[0-9]+}}]
  %e.load = load atomic float, ptr %e seq_cst, align 4
  %e.add = fadd float %e.load, 1.
  ; CHECK: fence.sc.sys
  ; CHECK: st.release.sys.b32 [%rd{{[0-9]+}}], %f{{[0-9]+}}
  store atomic float %e.add, ptr %e seq_cst, align 4

  ; CHECK: fence.sc.sys
  ; CHECK: ld.acquire.sys.b64 %fd{{[0-9]+}}, [%rd{{[0-9]+}}]
  %f.load = load atomic double, ptr %e seq_cst, align 8
  %f.add = fadd double %f.load, 1.
  ; CHECK: fence.sc.sys
  ; CHECK: st.release.sys.b64 [%rd{{[0-9]+}}], %fd{{[0-9]+}}
  store atomic double %f.add, ptr %e seq_cst, align 8

  ret void
}

; CHECK-LABEL: generic_sc_volatile_sys
define void @generic_sc_volatile_sys(ptr %a, ptr %b, ptr %c, ptr %d, ptr %e) local_unnamed_addr {
  ; CHECK: fence.sc.sys
  ; CHECK: ld.acquire.sys.b8 %rs{{[0-9]+}}, [%rd{{[0-9]+}}]
  %a.load = load atomic volatile i8, ptr %a seq_cst, align 1
  %a.add = add i8 %a.load, 1
  ; CHECK: fence.sc.sys
  ; CHECK: st.release.sys.b8 [%rd{{[0-9]+}}], %rs{{[0-9]+}}
  store atomic volatile i8 %a.add, ptr %a seq_cst, align 1

  ; CHECK: fence.sc.sys
  ; CHECK: ld.acquire.sys.b16 %rs{{[0-9]+}}, [%rd{{[0-9]+}}]
  %b.load = load atomic volatile i16, ptr %b seq_cst, align 2
  %b.add = add i16 %b.load, 1
  ; CHECK: fence.sc.sys
  ; CHECK: st.release.sys.b16 [%rd{{[0-9]+}}], %rs{{[0-9]+}}
  store atomic volatile i16 %b.add, ptr %b seq_cst, align 2

  ; CHECK: fence.sc.sys
  ; CHECK: ld.acquire.sys.b32 %r{{[0-9]+}}, [%rd{{[0-9]+}}]
  %c.load = load atomic volatile i32, ptr %c seq_cst, align 4
  %c.add = add i32 %c.load, 1
  ; CHECK: fence.sc.sys
  ; CHECK: st.release.sys.b32 [%rd{{[0-9]+}}], %r{{[0-9]+}}
  store atomic volatile i32 %c.add, ptr %c seq_cst, align 4

  ; CHECK: fence.sc.sys
  ; CHECK: ld.acquire.sys.b64 %rd{{[0-9]+}}, [%rd{{[0-9]+}}]
  %d.load = load atomic volatile i64, ptr %d seq_cst, align 8
  %d.add = add i64 %d.load, 1
  ; CHECK: fence.sc.sys
  ; CHECK: st.release.sys.b64 [%rd{{[0-9]+}}], %rd{{[0-9]+}}
  store atomic volatile i64 %d.add, ptr %d seq_cst, align 8

  ; CHECK: fence.sc.sys
  ; CHECK: ld.acquire.sys.b32 %f{{[0-9]+}}, [%rd{{[0-9]+}}]
  %e.load = load atomic volatile float, ptr %e seq_cst, align 4
  %e.add = fadd float %e.load, 1.
  ; CHECK: fence.sc.sys
  ; CHECK: st.release.sys.b32 [%rd{{[0-9]+}}], %f{{[0-9]+}}
  store atomic volatile float %e.add, ptr %e seq_cst, align 4

  ; CHECK: fence.sc.sys
  ; CHECK: ld.acquire.sys.b64 %fd{{[0-9]+}}, [%rd{{[0-9]+}}]
  %f.load = load atomic volatile double, ptr %e seq_cst, align 8
  %f.add = fadd double %f.load, 1.
  ; CHECK: fence.sc.sys
  ; CHECK: st.release.sys.b64 [%rd{{[0-9]+}}], %fd{{[0-9]+}}
  store atomic volatile double %f.add, ptr %e seq_cst, align 8

  ret void
}

; CHECK-LABEL: generic_sc_gpu
define void @generic_sc_gpu(ptr %a, ptr %b, ptr %c, ptr %d, ptr %e) local_unnamed_addr {
  ; CHECK: fence.sc.gpu
  ; CHECK: ld.acquire.gpu.b8 %rs{{[0-9]+}}, [%rd{{[0-9]+}}]
  %a.load = load atomic i8, ptr %a syncscope("device") seq_cst, align 1
  %a.add = add i8 %a.load, 1
  ; CHECK: fence.sc.gpu
  ; CHECK: st.release.gpu.b8 [%rd{{[0-9]+}}], %rs{{[0-9]+}}
  store atomic i8 %a.add, ptr %a syncscope("device") seq_cst, align 1

  ; CHECK: fence.sc.gpu
  ; CHECK: ld.acquire.gpu.b16 %rs{{[0-9]+}}, [%rd{{[0-9]+}}]
  %b.load = load atomic i16, ptr %b syncscope("device") seq_cst, align 2
  %b.add = add i16 %b.load, 1
  ; CHECK: fence.sc.gpu
  ; CHECK: st.release.gpu.b16 [%rd{{[0-9]+}}], %rs{{[0-9]+}}
  store atomic i16 %b.add, ptr %b syncscope("device") seq_cst, align 2

  ; CHECK: fence.sc.gpu
  ; CHECK: ld.acquire.gpu.b32 %r{{[0-9]+}}, [%rd{{[0-9]+}}]
  %c.load = load atomic i32, ptr %c syncscope("device") seq_cst, align 4
  %c.add = add i32 %c.load, 1
  ; CHECK: fence.sc.gpu
  ; CHECK: st.release.gpu.b32 [%rd{{[0-9]+}}], %r{{[0-9]+}}
  store atomic i32 %c.add, ptr %c syncscope("device") seq_cst, align 4

  ; CHECK: fence.sc.gpu
  ; CHECK: ld.acquire.gpu.b64 %rd{{[0-9]+}}, [%rd{{[0-9]+}}]
  %d.load = load atomic i64, ptr %d syncscope("device") seq_cst, align 8
  %d.add = add i64 %d.load, 1
  ; CHECK: fence.sc.gpu
  ; CHECK: st.release.gpu.b64 [%rd{{[0-9]+}}], %rd{{[0-9]+}}
  store atomic i64 %d.add, ptr %d syncscope("device") seq_cst, align 8

  ; CHECK: fence.sc.gpu
  ; CHECK: ld.acquire.gpu.b32 %f{{[0-9]+}}, [%rd{{[0-9]+}}]
  %e.load = load atomic float, ptr %e syncscope("device") seq_cst, align 4
  %e.add = fadd float %e.load, 1.
  ; CHECK: fence.sc.gpu
  ; CHECK: st.release.gpu.b32 [%rd{{[0-9]+}}], %f{{[0-9]+}}
  store atomic float %e.add, ptr %e syncscope("device") seq_cst, align 4

  ; CHECK: fence.sc.gpu
  ; CHECK: ld.acquire.gpu.b64 %fd{{[0-9]+}}, [%rd{{[0-9]+}}]
  %f.load = load atomic double, ptr %e syncscope("device") seq_cst, align 8
  %f.add = fadd double %f.load, 1.
  ; CHECK: fence.sc.gpu
  ; CHECK: st.release.gpu.b64 [%rd{{[0-9]+}}], %fd{{[0-9]+}}
  store atomic double %f.add, ptr %e syncscope("device") seq_cst, align 8

  ret void
}

; CHECK-LABEL: generic_sc_volatile_gpu
define void @generic_sc_volatile_gpu(ptr %a, ptr %b, ptr %c, ptr %d, ptr %e) local_unnamed_addr {
  ; CHECK: fence.sc.sys
  ; CHECK: ld.acquire.sys.b8 %rs{{[0-9]+}}, [%rd{{[0-9]+}}]  
  %a.load = load atomic volatile i8, ptr %a syncscope("device") seq_cst, align 1
  %a.add = add i8 %a.load, 1
  ; CHECK: fence.sc.sys
  ; CHECK: st.release.sys.b8 [%rd{{[0-9]+}}], %rs{{[0-9]+}}
  store atomic volatile i8 %a.add, ptr %a syncscope("device") seq_cst, align 1

  ; CHECK: fence.sc.sys
  ; CHECK: ld.acquire.sys.b16 %rs{{[0-9]+}}, [%rd{{[0-9]+}}]
  %b.load = load atomic volatile i16, ptr %b syncscope("device") seq_cst, align 2
  %b.add = add i16 %b.load, 1
  ; CHECK: fence.sc.sys
  ; CHECK: st.release.sys.b16 [%rd{{[0-9]+}}], %rs{{[0-9]+}}
  store atomic volatile i16 %b.add, ptr %b syncscope("device") seq_cst, align 2

  ; CHECK: fence.sc.sys
  ; CHECK: ld.acquire.sys.b32 %r{{[0-9]+}}, [%rd{{[0-9]+}}]
  %c.load = load atomic volatile i32, ptr %c syncscope("device") seq_cst, align 4
  %c.add = add i32 %c.load, 1
  ; CHECK: fence.sc.sys
  ; CHECK: st.release.sys.b32 [%rd{{[0-9]+}}], %r{{[0-9]+}}
  store atomic volatile i32 %c.add, ptr %c syncscope("device") seq_cst, align 4

  ; CHECK: fence.sc.sys
  ; CHECK: ld.acquire.sys.b64 %rd{{[0-9]+}}, [%rd{{[0-9]+}}]
  %d.load = load atomic volatile i64, ptr %d syncscope("device") seq_cst, align 8
  %d.add = add i64 %d.load, 1
  ; CHECK: fence.sc.sys
  ; CHECK: st.release.sys.b64 [%rd{{[0-9]+}}], %rd{{[0-9]+}}
  store atomic volatile i64 %d.add, ptr %d syncscope("device") seq_cst, align 8

  ; CHECK: fence.sc.sys
  ; CHECK: ld.acquire.sys.b32 %f{{[0-9]+}}, [%rd{{[0-9]+}}]
  %e.load = load atomic volatile float, ptr %e syncscope("device") seq_cst, align 4
  %e.add = fadd float %e.load, 1.
  ; CHECK: fence.sc.sys
  ; CHECK: st.release.sys.b32 [%rd{{[0-9]+}}], %f{{[0-9]+}}
  store atomic volatile float %e.add, ptr %e syncscope("device") seq_cst, align 4

  ; CHECK: fence.sc.sys
  ; CHECK: ld.acquire.sys.b64 %fd{{[0-9]+}}, [%rd{{[0-9]+}}]
  %f.load = load atomic volatile double, ptr %e syncscope("device") seq_cst, align 8
  %f.add = fadd double %f.load, 1.
  ; CHECK: fence.sc.sys
  ; CHECK: st.release.sys.b64 [%rd{{[0-9]+}}], %fd{{[0-9]+}}
  store atomic volatile double %f.add, ptr %e syncscope("device") seq_cst, align 8

  ret void
}

; CHECK-LABEL: generic_sc_cta
define void @generic_sc_cta(ptr %a, ptr %b, ptr %c, ptr %d, ptr %e) local_unnamed_addr {
  ; CHECK: fence.sc.cta
  ; CHECK: ld.acquire.cta.b8 %rs{{[0-9]+}}, [%rd{{[0-9]+}}]
  %a.load = load atomic i8, ptr %a syncscope("block") seq_cst, align 1
  %a.add = add i8 %a.load, 1
  ; CHECK: fence.sc.cta
  ; CHECK: st.release.cta.b8 [%rd{{[0-9]+}}], %rs{{[0-9]+}}
  store atomic i8 %a.add, ptr %a syncscope("block") seq_cst, align 1

  ; CHECK: fence.sc.cta
  ; CHECK: ld.acquire.cta.b16 %rs{{[0-9]+}}, [%rd{{[0-9]+}}]
  %b.load = load atomic i16, ptr %b syncscope("block") seq_cst, align 2
  %b.add = add i16 %b.load, 1
  ; CHECK: fence.sc.cta
  ; CHECK: st.release.cta.b16 [%rd{{[0-9]+}}], %rs{{[0-9]+}}
  store atomic i16 %b.add, ptr %b syncscope("block") seq_cst, align 2

  ; CHECK: fence.sc.cta
  ; CHECK: ld.acquire.cta.b32 %r{{[0-9]+}}, [%rd{{[0-9]+}}]
  %c.load = load atomic i32, ptr %c syncscope("block") seq_cst, align 4
  %c.add = add i32 %c.load, 1
  ; CHECK: fence.sc.cta
  ; CHECK: st.release.cta.b32 [%rd{{[0-9]+}}], %r{{[0-9]+}}
  store atomic i32 %c.add, ptr %c syncscope("block") seq_cst, align 4

  ; CHECK: fence.sc.cta
  ; CHECK: ld.acquire.cta.b64 %rd{{[0-9]+}}, [%rd{{[0-9]+}}]
  %d.load = load atomic i64, ptr %d syncscope("block") seq_cst, align 8
  %d.add = add i64 %d.load, 1
  ; CHECK: fence.sc.cta
  ; CHECK: st.release.cta.b64 [%rd{{[0-9]+}}], %rd{{[0-9]+}}
  store atomic i64 %d.add, ptr %d syncscope("block") seq_cst, align 8

  ; CHECK: fence.sc.cta
  ; CHECK: ld.acquire.cta.b32 %f{{[0-9]+}}, [%rd{{[0-9]+}}]
  %e.load = load atomic float, ptr %e syncscope("block") seq_cst, align 4
  %e.add = fadd float %e.load, 1.
  ; CHECK: fence.sc.cta
  ; CHECK: st.release.cta.b32 [%rd{{[0-9]+}}], %f{{[0-9]+}}
  store atomic float %e.add, ptr %e syncscope("block") seq_cst, align 4

  ; CHECK: fence.sc.cta
  ; CHECK: ld.acquire.cta.b64 %fd{{[0-9]+}}, [%rd{{[0-9]+}}]
  %f.load = load atomic double, ptr %e syncscope("block") seq_cst, align 8
  %f.add = fadd double %f.load, 1.
  ; CHECK: fence.sc.cta
  ; CHECK: st.release.cta.b64 [%rd{{[0-9]+}}], %fd{{[0-9]+}}
  store atomic double %f.add, ptr %e syncscope("block") seq_cst, align 8

  ret void
}

; CHECK-LABEL: generic_sc_volatile_cta
define void @generic_sc_volatile_cta(ptr %a, ptr %b, ptr %c, ptr %d, ptr %e) local_unnamed_addr {
  ; CHECK: fence.sc.sys
  ; CHECK: ld.acquire.sys.b8 %rs{{[0-9]+}}, [%rd{{[0-9]+}}]
  %a.load = load atomic volatile i8, ptr %a syncscope("block") seq_cst, align 1
  %a.add = add i8 %a.load, 1
  ; CHECK: fence.sc.sys
  ; CHECK: st.release.sys.b8 [%rd{{[0-9]+}}], %rs{{[0-9]+}}
  store atomic volatile i8 %a.add, ptr %a syncscope("block") seq_cst, align 1

  ; CHECK: fence.sc.sys
  ; CHECK: ld.acquire.sys.b16 %rs{{[0-9]+}}, [%rd{{[0-9]+}}]
  %b.load = load atomic volatile i16, ptr %b syncscope("block") seq_cst, align 2
  %b.add = add i16 %b.load, 1
  ; CHECK: fence.sc.sys
  ; CHECK: st.release.sys.b16 [%rd{{[0-9]+}}], %rs{{[0-9]+}}
  store atomic volatile i16 %b.add, ptr %b syncscope("block") seq_cst, align 2

  ; CHECK: fence.sc.sys
  ; CHECK: ld.acquire.sys.b32 %r{{[0-9]+}}, [%rd{{[0-9]+}}]
  %c.load = load atomic volatile i32, ptr %c syncscope("block") seq_cst, align 4
  %c.add = add i32 %c.load, 1
  ; CHECK: fence.sc.sys
  ; CHECK: st.release.sys.b32 [%rd{{[0-9]+}}], %r{{[0-9]+}}
  store atomic volatile i32 %c.add, ptr %c syncscope("block") seq_cst, align 4

  ; CHECK: fence.sc.sys
  ; CHECK: ld.acquire.sys.b64 %rd{{[0-9]+}}, [%rd{{[0-9]+}}]
  %d.load = load atomic volatile i64, ptr %d syncscope("block") seq_cst, align 8
  %d.add = add i64 %d.load, 1
  ; CHECK: fence.sc.sys
  ; CHECK: st.release.sys.b64 [%rd{{[0-9]+}}], %rd{{[0-9]+}}
  store atomic volatile i64 %d.add, ptr %d syncscope("block") seq_cst, align 8

  ; CHECK: fence.sc.sys
  ; CHECK: ld.acquire.sys.b32 %f{{[0-9]+}}, [%rd{{[0-9]+}}]
  %e.load = load atomic volatile float, ptr %e syncscope("block") seq_cst, align 4
  %e.add = fadd float %e.load, 1.
  ; CHECK: fence.sc.sys
  ; CHECK: st.release.sys.b32 [%rd{{[0-9]+}}], %f{{[0-9]+}}
  store atomic volatile float %e.add, ptr %e syncscope("block") seq_cst, align 4

  ; CHECK: fence.sc.sys
  ; CHECK: ld.acquire.sys.b64 %fd{{[0-9]+}}, [%rd{{[0-9]+}}]
  %f.load = load atomic volatile double, ptr %e syncscope("block") seq_cst, align 8
  %f.add = fadd double %f.load, 1.
  ; CHECK: fence.sc.sys
  ; CHECK: st.release.sys.b64 [%rd{{[0-9]+}}], %fd{{[0-9]+}}
  store atomic volatile double %f.add, ptr %e syncscope("block") seq_cst, align 8

  ret void
}

;; global statespace

; CHECK-LABEL: global_unordered_gpu
define void @global_unordered_gpu(ptr addrspace(1) %a, ptr addrspace(1) %b, ptr addrspace(1) %c, ptr addrspace(1) %d, ptr addrspace(1) %e) local_unnamed_addr {
  ; CHECK: ld.relaxed.gpu.global.b8 %rs{{[0-9]+}}, [%rd{{[0-9]+}}]
  %a.load = load atomic i8, ptr addrspace(1) %a syncscope("device") unordered, align 1
  %a.add = add i8 %a.load, 1
  ; CHECK: st.relaxed.gpu.global.b8 [%rd{{[0-9]+}}], %rs{{[0-9]+}}
  store atomic i8 %a.add, ptr addrspace(1) %a syncscope("device") unordered, align 1

  ; CHECK: ld.relaxed.gpu.global.b16 %rs{{[0-9]+}}, [%rd{{[0-9]+}}]
  %b.load = load atomic i16, ptr addrspace(1) %b syncscope("device") unordered, align 2
  %b.add = add i16 %b.load, 1
  ; CHECK: st.relaxed.gpu.global.b16 [%rd{{[0-9]+}}], %rs{{[0-9]+}}
  store atomic i16 %b.add, ptr addrspace(1) %b syncscope("device") unordered, align 2

  ; CHECK: ld.relaxed.gpu.global.b32 %r{{[0-9]+}}, [%rd{{[0-9]+}}]
  %c.load = load atomic i32, ptr addrspace(1) %c syncscope("device") unordered, align 4
  %c.add = add i32 %c.load, 1
  ; CHECK: st.relaxed.gpu.global.b32 [%rd{{[0-9]+}}], %r{{[0-9]+}}
  store atomic i32 %c.add, ptr addrspace(1) %c syncscope("device") unordered, align 4

  ; CHECK: ld.relaxed.gpu.global.b64 %rd{{[0-9]+}}, [%rd{{[0-9]+}}]
  %d.load = load atomic i64, ptr addrspace(1) %d syncscope("device") unordered, align 8
  %d.add = add i64 %d.load, 1
  ; CHECK: st.relaxed.gpu.global.b64 [%rd{{[0-9]+}}], %rd{{[0-9]+}}
  store atomic i64 %d.add, ptr addrspace(1) %d syncscope("device") unordered, align 8

  ; CHECK: ld.relaxed.gpu.global.b32 %f{{[0-9]+}}, [%rd{{[0-9]+}}]
  %e.load = load atomic float, ptr addrspace(1) %e syncscope("device") unordered, align 4
  %e.add = fadd float %e.load, 1.
  ; CHECK: st.relaxed.gpu.global.b32 [%rd{{[0-9]+}}], %f{{[0-9]+}}
  store atomic float %e.add, ptr addrspace(1) %e syncscope("device") unordered, align 4

  ; CHECK: ld.relaxed.gpu.global.b64 %fd{{[0-9]+}}, [%rd{{[0-9]+}}]
  %f.load = load atomic double, ptr addrspace(1) %e syncscope("device") unordered, align 8
  %f.add = fadd double %f.load, 1.
  ; CHECK: st.relaxed.gpu.global.b64 [%rd{{[0-9]+}}], %fd{{[0-9]+}}
  store atomic double %f.add, ptr addrspace(1) %e syncscope("device") unordered, align 8

  ret void
}

; CHECK-LABEL: global_unordered_volatile_gpu
define void @global_unordered_volatile_gpu(ptr addrspace(1) %a, ptr addrspace(1) %b, ptr addrspace(1) %c, ptr addrspace(1) %d, ptr addrspace(1) %e) local_unnamed_addr {
  ; CHECK: ld.mmio.relaxed.sys.global.b8 %rs{{[0-9]+}}, [%rd{{[0-9]+}}]
  %a.load = load atomic volatile i8, ptr addrspace(1) %a syncscope("device") unordered, align 1
  %a.add = add i8 %a.load, 1
  ; CHECK: st.mmio.relaxed.sys.global.b8 [%rd{{[0-9]+}}], %rs{{[0-9]+}}
  store atomic volatile i8 %a.add, ptr addrspace(1) %a syncscope("device") unordered, align 1

  ; CHECK: ld.mmio.relaxed.sys.global.b16 %rs{{[0-9]+}}, [%rd{{[0-9]+}}]
  %b.load = load atomic volatile i16, ptr addrspace(1) %b syncscope("device") unordered, align 2
  %b.add = add i16 %b.load, 1
  ; CHECK: st.mmio.relaxed.sys.global.b16 [%rd{{[0-9]+}}], %rs{{[0-9]+}}
  store atomic volatile i16 %b.add, ptr addrspace(1) %b syncscope("device") unordered, align 2

  ; CHECK: ld.mmio.relaxed.sys.global.b32 %r{{[0-9]+}}, [%rd{{[0-9]+}}]
  %c.load = load atomic volatile i32, ptr addrspace(1) %c syncscope("device") unordered, align 4
  %c.add = add i32 %c.load, 1
  ; CHECK: st.mmio.relaxed.sys.global.b32 [%rd{{[0-9]+}}], %r{{[0-9]+}}
  store atomic volatile i32 %c.add, ptr addrspace(1) %c syncscope("device") unordered, align 4

  ; CHECK: ld.mmio.relaxed.sys.global.b64 %rd{{[0-9]+}}, [%rd{{[0-9]+}}]
  %d.load = load atomic volatile i64, ptr addrspace(1) %d syncscope("device") unordered, align 8
  %d.add = add i64 %d.load, 1
  ; CHECK: st.mmio.relaxed.sys.global.b64 [%rd{{[0-9]+}}], %rd{{[0-9]+}}
  store atomic volatile i64 %d.add, ptr addrspace(1) %d syncscope("device") unordered, align 8

  ; CHECK: ld.mmio.relaxed.sys.global.b32 %f{{[0-9]+}}, [%rd{{[0-9]+}}]
  %e.load = load atomic volatile float, ptr addrspace(1) %e syncscope("device") unordered, align 4
  %e.add = fadd float %e.load, 1.
  ; CHECK: st.mmio.relaxed.sys.global.b32 [%rd{{[0-9]+}}], %f{{[0-9]+}}
  store atomic volatile float %e.add, ptr addrspace(1) %e syncscope("device") unordered, align 4

  ; CHECK: ld.mmio.relaxed.sys.global.b64 %fd{{[0-9]+}}, [%rd{{[0-9]+}}]
  %f.load = load atomic volatile double, ptr addrspace(1) %e syncscope("device") unordered, align 8
  %f.add = fadd double %f.load, 1.
  ; CHECK: st.mmio.relaxed.sys.global.b64 [%rd{{[0-9]+}}], %fd{{[0-9]+}}
  store atomic volatile double %f.add, ptr addrspace(1) %e syncscope("device") unordered, align 8

  ret void
}

; CHECK-LABEL: global_unordered_cta
define void @global_unordered_cta(ptr addrspace(1) %a, ptr addrspace(1) %b, ptr addrspace(1) %c, ptr addrspace(1) %d, ptr addrspace(1) %e) local_unnamed_addr {
  ; CHECK: ld.relaxed.cta.global.b8 %rs{{[0-9]+}}, [%rd{{[0-9]+}}]
  %a.load = load atomic i8, ptr addrspace(1) %a syncscope("block") unordered, align 1
  %a.add = add i8 %a.load, 1
  ; CHECK: st.relaxed.cta.global.b8 [%rd{{[0-9]+}}], %rs{{[0-9]+}}
  store atomic i8 %a.add, ptr addrspace(1) %a syncscope("block") unordered, align 1

  ; CHECK: ld.relaxed.cta.global.b16 %rs{{[0-9]+}}, [%rd{{[0-9]+}}]
  %b.load = load atomic i16, ptr addrspace(1) %b syncscope("block") unordered, align 2
  %b.add = add i16 %b.load, 1
  ; CHECK: st.relaxed.cta.global.b16 [%rd{{[0-9]+}}], %rs{{[0-9]+}}
  store atomic i16 %b.add, ptr addrspace(1) %b syncscope("block") unordered, align 2

  ; CHECK: ld.relaxed.cta.global.b32 %r{{[0-9]+}}, [%rd{{[0-9]+}}]
  %c.load = load atomic i32, ptr addrspace(1) %c syncscope("block") unordered, align 4
  %c.add = add i32 %c.load, 1
  ; CHECK: st.relaxed.cta.global.b32 [%rd{{[0-9]+}}], %r{{[0-9]+}}
  store atomic i32 %c.add, ptr addrspace(1) %c syncscope("block") unordered, align 4

  ; CHECK: ld.relaxed.cta.global.b64 %rd{{[0-9]+}}, [%rd{{[0-9]+}}]
  %d.load = load atomic i64, ptr addrspace(1) %d syncscope("block") unordered, align 8
  %d.add = add i64 %d.load, 1
  ; CHECK: st.relaxed.cta.global.b64 [%rd{{[0-9]+}}], %rd{{[0-9]+}}
  store atomic i64 %d.add, ptr addrspace(1) %d syncscope("block") unordered, align 8

  ; CHECK: ld.relaxed.cta.global.b32 %f{{[0-9]+}}, [%rd{{[0-9]+}}]
  %e.load = load atomic float, ptr addrspace(1) %e syncscope("block") unordered, align 4
  %e.add = fadd float %e.load, 1.
  ; CHECK: st.relaxed.cta.global.b32 [%rd{{[0-9]+}}], %f{{[0-9]+}}
  store atomic float %e.add, ptr addrspace(1) %e syncscope("block") unordered, align 4

  ; CHECK: ld.relaxed.cta.global.b64 %fd{{[0-9]+}}, [%rd{{[0-9]+}}]
  %f.load = load atomic double, ptr addrspace(1) %e syncscope("block") unordered, align 8
  %f.add = fadd double %f.load, 1.
  ; CHECK: st.relaxed.cta.global.b64 [%rd{{[0-9]+}}], %fd{{[0-9]+}}
  store atomic double %f.add, ptr addrspace(1) %e syncscope("block") unordered, align 8

  ret void
}

; CHECK-LABEL: global_unordered_volatile_cta
define void @global_unordered_volatile_cta(ptr addrspace(1) %a, ptr addrspace(1) %b, ptr addrspace(1) %c, ptr addrspace(1) %d, ptr addrspace(1) %e) local_unnamed_addr {
  ; CHECK: ld.mmio.relaxed.sys.global.b8 %rs{{[0-9]+}}, [%rd{{[0-9]+}}]
  %a.load = load atomic volatile i8, ptr addrspace(1) %a syncscope("block") unordered, align 1
  %a.add = add i8 %a.load, 1
  ; CHECK: st.mmio.relaxed.sys.global.b8 [%rd{{[0-9]+}}], %rs{{[0-9]+}}
  store atomic volatile i8 %a.add, ptr addrspace(1) %a syncscope("block") unordered, align 1

  ; CHECK: ld.mmio.relaxed.sys.global.b16 %rs{{[0-9]+}}, [%rd{{[0-9]+}}]
  %b.load = load atomic volatile i16, ptr addrspace(1) %b syncscope("block") unordered, align 2
  %b.add = add i16 %b.load, 1
  ; CHECK: st.mmio.relaxed.sys.global.b16 [%rd{{[0-9]+}}], %rs{{[0-9]+}}
  store atomic volatile i16 %b.add, ptr addrspace(1) %b syncscope("block") unordered, align 2

  ; CHECK: ld.mmio.relaxed.sys.global.b32 %r{{[0-9]+}}, [%rd{{[0-9]+}}]
  %c.load = load atomic volatile i32, ptr addrspace(1) %c syncscope("block") unordered, align 4
  %c.add = add i32 %c.load, 1
  ; CHECK: st.mmio.relaxed.sys.global.b32 [%rd{{[0-9]+}}], %r{{[0-9]+}}
  store atomic volatile i32 %c.add, ptr addrspace(1) %c syncscope("block") unordered, align 4

  ; CHECK: ld.mmio.relaxed.sys.global.b64 %rd{{[0-9]+}}, [%rd{{[0-9]+}}]
  %d.load = load atomic volatile i64, ptr addrspace(1) %d syncscope("block") unordered, align 8
  %d.add = add i64 %d.load, 1
  ; CHECK: st.mmio.relaxed.sys.global.b64 [%rd{{[0-9]+}}], %rd{{[0-9]+}}
  store atomic volatile i64 %d.add, ptr addrspace(1) %d syncscope("block") unordered, align 8

  ; CHECK: ld.mmio.relaxed.sys.global.b32 %f{{[0-9]+}}, [%rd{{[0-9]+}}]
  %e.load = load atomic volatile float, ptr addrspace(1) %e syncscope("block") unordered, align 4
  %e.add = fadd float %e.load, 1.
  ; CHECK: st.mmio.relaxed.sys.global.b32 [%rd{{[0-9]+}}], %f{{[0-9]+}}
  store atomic volatile float %e.add, ptr addrspace(1) %e syncscope("block") unordered, align 4

  ; CHECK: ld.mmio.relaxed.sys.global.b64 %fd{{[0-9]+}}, [%rd{{[0-9]+}}]
  %f.load = load atomic volatile double, ptr addrspace(1) %e syncscope("block") unordered, align 8
  %f.add = fadd double %f.load, 1.
  ; CHECK: st.mmio.relaxed.sys.global.b64 [%rd{{[0-9]+}}], %fd{{[0-9]+}}
  store atomic volatile double %f.add, ptr addrspace(1) %e syncscope("block") unordered, align 8

  ret void
}

; CHECK-LABEL: global_monotonic_gpu
define void @global_monotonic_gpu(ptr addrspace(1) %a, ptr addrspace(1) %b, ptr addrspace(1) %c, ptr addrspace(1) %d, ptr addrspace(1) %e) local_unnamed_addr {
  ; CHECK: ld.relaxed.gpu.global.b8 %rs{{[0-9]+}}, [%rd{{[0-9]+}}]
  %a.load = load atomic i8, ptr addrspace(1) %a syncscope("device") monotonic, align 1
  %a.add = add i8 %a.load, 1
  ; CHECK: st.relaxed.gpu.global.b8 [%rd{{[0-9]+}}], %rs{{[0-9]+}}
  store atomic i8 %a.add, ptr addrspace(1) %a syncscope("device") monotonic, align 1

  ; CHECK: ld.relaxed.gpu.global.b16 %rs{{[0-9]+}}, [%rd{{[0-9]+}}]
  %b.load = load atomic i16, ptr addrspace(1) %b syncscope("device") monotonic, align 2
  %b.add = add i16 %b.load, 1
  ; CHECK: st.relaxed.gpu.global.b16 [%rd{{[0-9]+}}], %rs{{[0-9]+}}
  store atomic i16 %b.add, ptr addrspace(1) %b syncscope("device") monotonic, align 2

  ; CHECK: ld.relaxed.gpu.global.b32 %r{{[0-9]+}}, [%rd{{[0-9]+}}]
  %c.load = load atomic i32, ptr addrspace(1) %c syncscope("device") monotonic, align 4
  %c.add = add i32 %c.load, 1
  ; CHECK: st.relaxed.gpu.global.b32 [%rd{{[0-9]+}}], %r{{[0-9]+}}
  store atomic i32 %c.add, ptr addrspace(1) %c syncscope("device") monotonic, align 4

  ; CHECK: ld.relaxed.gpu.global.b64 %rd{{[0-9]+}}, [%rd{{[0-9]+}}]
  %d.load = load atomic i64, ptr addrspace(1) %d syncscope("device") monotonic, align 8
  %d.add = add i64 %d.load, 1
  ; CHECK: st.relaxed.gpu.global.b64 [%rd{{[0-9]+}}], %rd{{[0-9]+}}
  store atomic i64 %d.add, ptr addrspace(1) %d syncscope("device") monotonic, align 8

  ; CHECK: ld.relaxed.gpu.global.b32 %f{{[0-9]+}}, [%rd{{[0-9]+}}]
  %e.load = load atomic float, ptr addrspace(1) %e syncscope("device") monotonic, align 4
  %e.add = fadd float %e.load, 1.
  ; CHECK: st.relaxed.gpu.global.b32 [%rd{{[0-9]+}}], %f{{[0-9]+}}
  store atomic float %e.add, ptr addrspace(1) %e syncscope("device") monotonic, align 4

  ; CHECK: ld.relaxed.gpu.global.b64 %fd{{[0-9]+}}, [%rd{{[0-9]+}}]
  %f.load = load atomic double, ptr addrspace(1) %e syncscope("device") monotonic, align 8
  %f.add = fadd double %f.load, 1.
  ; CHECK: st.relaxed.gpu.global.b64 [%rd{{[0-9]+}}], %fd{{[0-9]+}}
  store atomic double %f.add, ptr addrspace(1) %e syncscope("device") monotonic, align 8

  ret void
}

; CHECK-LABEL: global_monotonic_volatile_gpu
define void @global_monotonic_volatile_gpu(ptr addrspace(1) %a, ptr addrspace(1) %b, ptr addrspace(1) %c, ptr addrspace(1) %d, ptr addrspace(1) %e) local_unnamed_addr {
  ; CHECK: ld.mmio.relaxed.sys.global.b8 %rs{{[0-9]+}}, [%rd{{[0-9]+}}]
  %a.load = load atomic volatile i8, ptr addrspace(1) %a syncscope("device") monotonic, align 1
  %a.add = add i8 %a.load, 1
  ; CHECK: st.mmio.relaxed.sys.global.b8 [%rd{{[0-9]+}}], %rs{{[0-9]+}}
  store atomic volatile i8 %a.add, ptr addrspace(1) %a syncscope("device") monotonic, align 1

  ; CHECK: ld.mmio.relaxed.sys.global.b16 %rs{{[0-9]+}}, [%rd{{[0-9]+}}]
  %b.load = load atomic volatile i16, ptr addrspace(1) %b syncscope("device") monotonic, align 2
  %b.add = add i16 %b.load, 1
  ; CHECK: st.mmio.relaxed.sys.global.b16 [%rd{{[0-9]+}}], %rs{{[0-9]+}}
  store atomic volatile i16 %b.add, ptr addrspace(1) %b syncscope("device") monotonic, align 2

  ; CHECK: ld.mmio.relaxed.sys.global.b32 %r{{[0-9]+}}, [%rd{{[0-9]+}}]
  %c.load = load atomic volatile i32, ptr addrspace(1) %c syncscope("device") monotonic, align 4
  %c.add = add i32 %c.load, 1
  ; CHECK: st.mmio.relaxed.sys.global.b32 [%rd{{[0-9]+}}], %r{{[0-9]+}}
  store atomic volatile i32 %c.add, ptr addrspace(1) %c syncscope("device") monotonic, align 4

  ; CHECK: ld.mmio.relaxed.sys.global.b64 %rd{{[0-9]+}}, [%rd{{[0-9]+}}]
  %d.load = load atomic volatile i64, ptr addrspace(1) %d syncscope("device") monotonic, align 8
  %d.add = add i64 %d.load, 1
  ; CHECK: st.mmio.relaxed.sys.global.b64 [%rd{{[0-9]+}}], %rd{{[0-9]+}}
  store atomic volatile i64 %d.add, ptr addrspace(1) %d syncscope("device") monotonic, align 8

  ; CHECK: ld.mmio.relaxed.sys.global.b32 %f{{[0-9]+}}, [%rd{{[0-9]+}}]
  %e.load = load atomic volatile float, ptr addrspace(1) %e syncscope("device") monotonic, align 4
  %e.add = fadd float %e.load, 1.
  ; CHECK: st.mmio.relaxed.sys.global.b32 [%rd{{[0-9]+}}], %f{{[0-9]+}}
  store atomic volatile float %e.add, ptr addrspace(1) %e syncscope("device") monotonic, align 4

  ; CHECK: ld.mmio.relaxed.sys.global.b64 %fd{{[0-9]+}}, [%rd{{[0-9]+}}]
  %f.load = load atomic volatile double, ptr addrspace(1) %e syncscope("device") monotonic, align 8
  %f.add = fadd double %f.load, 1.
  ; CHECK: st.mmio.relaxed.sys.global.b64 [%rd{{[0-9]+}}], %fd{{[0-9]+}}
  store atomic volatile double %f.add, ptr addrspace(1) %e syncscope("device") monotonic, align 8

  ret void
}

; CHECK-LABEL: global_monotonic_cta
define void @global_monotonic_cta(ptr addrspace(1) %a, ptr addrspace(1) %b, ptr addrspace(1) %c, ptr addrspace(1) %d, ptr addrspace(1) %e) local_unnamed_addr {
  ; CHECK: ld.relaxed.cta.global.b8 %rs{{[0-9]+}}, [%rd{{[0-9]+}}]
  %a.load = load atomic i8, ptr addrspace(1) %a syncscope("block") monotonic, align 1
  %a.add = add i8 %a.load, 1
  ; CHECK: st.relaxed.cta.global.b8 [%rd{{[0-9]+}}], %rs{{[0-9]+}}
  store atomic i8 %a.add, ptr addrspace(1) %a syncscope("block") monotonic, align 1

  ; CHECK: ld.relaxed.cta.global.b16 %rs{{[0-9]+}}, [%rd{{[0-9]+}}]
  %b.load = load atomic i16, ptr addrspace(1) %b syncscope("block") monotonic, align 2
  %b.add = add i16 %b.load, 1
  ; CHECK: st.relaxed.cta.global.b16 [%rd{{[0-9]+}}], %rs{{[0-9]+}}
  store atomic i16 %b.add, ptr addrspace(1) %b syncscope("block") monotonic, align 2

  ; CHECK: ld.relaxed.cta.global.b32 %r{{[0-9]+}}, [%rd{{[0-9]+}}]
  %c.load = load atomic i32, ptr addrspace(1) %c syncscope("block") monotonic, align 4
  %c.add = add i32 %c.load, 1
  ; CHECK: st.relaxed.cta.global.b32 [%rd{{[0-9]+}}], %r{{[0-9]+}}
  store atomic i32 %c.add, ptr addrspace(1) %c syncscope("block") monotonic, align 4

  ; CHECK: ld.relaxed.cta.global.b64 %rd{{[0-9]+}}, [%rd{{[0-9]+}}]
  %d.load = load atomic i64, ptr addrspace(1) %d syncscope("block") monotonic, align 8
  %d.add = add i64 %d.load, 1
  ; CHECK: st.relaxed.cta.global.b64 [%rd{{[0-9]+}}], %rd{{[0-9]+}}
  store atomic i64 %d.add, ptr addrspace(1) %d syncscope("block") monotonic, align 8

  ; CHECK: ld.relaxed.cta.global.b32 %f{{[0-9]+}}, [%rd{{[0-9]+}}]
  %e.load = load atomic float, ptr addrspace(1) %e syncscope("block") monotonic, align 4
  %e.add = fadd float %e.load, 1.
  ; CHECK: st.relaxed.cta.global.b32 [%rd{{[0-9]+}}], %f{{[0-9]+}}
  store atomic float %e.add, ptr addrspace(1) %e syncscope("block") monotonic, align 4

  ; CHECK: ld.relaxed.cta.global.b64 %fd{{[0-9]+}}, [%rd{{[0-9]+}}]
  %f.load = load atomic double, ptr addrspace(1) %e syncscope("block") monotonic, align 8
  %f.add = fadd double %f.load, 1.
  ; CHECK: st.relaxed.cta.global.b64 [%rd{{[0-9]+}}], %fd{{[0-9]+}}
  store atomic double %f.add, ptr addrspace(1) %e syncscope("block") monotonic, align 8

  ret void
}

; CHECK-LABEL: global_monotonic_volatile_cta
define void @global_monotonic_volatile_cta(ptr addrspace(1) %a, ptr addrspace(1) %b, ptr addrspace(1) %c, ptr addrspace(1) %d, ptr addrspace(1) %e) local_unnamed_addr {
  ; CHECK: ld.mmio.relaxed.sys.global.b8 %rs{{[0-9]+}}, [%rd{{[0-9]+}}]
  %a.load = load atomic volatile i8, ptr addrspace(1) %a syncscope("block") monotonic, align 1
  %a.add = add i8 %a.load, 1
  ; CHECK: st.mmio.relaxed.sys.global.b8 [%rd{{[0-9]+}}], %rs{{[0-9]+}}
  store atomic volatile i8 %a.add, ptr addrspace(1) %a syncscope("block") monotonic, align 1

  ; CHECK: ld.mmio.relaxed.sys.global.b16 %rs{{[0-9]+}}, [%rd{{[0-9]+}}]
  %b.load = load atomic volatile i16, ptr addrspace(1) %b syncscope("block") monotonic, align 2
  %b.add = add i16 %b.load, 1
  ; CHECK: st.mmio.relaxed.sys.global.b16 [%rd{{[0-9]+}}], %rs{{[0-9]+}}
  store atomic volatile i16 %b.add, ptr addrspace(1) %b syncscope("block") monotonic, align 2

  ; CHECK: ld.mmio.relaxed.sys.global.b32 %r{{[0-9]+}}, [%rd{{[0-9]+}}]
  %c.load = load atomic volatile i32, ptr addrspace(1) %c syncscope("block") monotonic, align 4
  %c.add = add i32 %c.load, 1
  ; CHECK: st.mmio.relaxed.sys.global.b32 [%rd{{[0-9]+}}], %r{{[0-9]+}}
  store atomic volatile i32 %c.add, ptr addrspace(1) %c syncscope("block") monotonic, align 4

  ; CHECK: ld.mmio.relaxed.sys.global.b64 %rd{{[0-9]+}}, [%rd{{[0-9]+}}]
  %d.load = load atomic volatile i64, ptr addrspace(1) %d syncscope("block") monotonic, align 8
  %d.add = add i64 %d.load, 1
  ; CHECK: st.mmio.relaxed.sys.global.b64 [%rd{{[0-9]+}}], %rd{{[0-9]+}}
  store atomic volatile i64 %d.add, ptr addrspace(1) %d syncscope("block") monotonic, align 8

  ; CHECK: ld.mmio.relaxed.sys.global.b32 %f{{[0-9]+}}, [%rd{{[0-9]+}}]
  %e.load = load atomic volatile float, ptr addrspace(1) %e syncscope("block") monotonic, align 4
  %e.add = fadd float %e.load, 1.
  ; CHECK: st.mmio.relaxed.sys.global.b32 [%rd{{[0-9]+}}], %f{{[0-9]+}}
  store atomic volatile float %e.add, ptr addrspace(1) %e syncscope("block") monotonic, align 4

  ; CHECK: ld.mmio.relaxed.sys.global.b64 %fd{{[0-9]+}}, [%rd{{[0-9]+}}]
  %f.load = load atomic volatile double, ptr addrspace(1) %e syncscope("block") monotonic, align 8
  %f.add = fadd double %f.load, 1.
  ; CHECK: st.mmio.relaxed.sys.global.b64 [%rd{{[0-9]+}}], %fd{{[0-9]+}}
  store atomic volatile double %f.add, ptr addrspace(1) %e syncscope("block") monotonic, align 8

  ret void
}

; CHECK-LABEL: global_acq_rel_sys
define void @global_acq_rel_sys(ptr addrspace(1) %a, ptr addrspace(1) %b, ptr addrspace(1) %c, ptr addrspace(1) %d, ptr addrspace(1) %e) local_unnamed_addr {
  ; CHECK: ld.acquire.sys.global.b8 %rs{{[0-9]+}}, [%rd{{[0-9]+}}]
  %a.load = load atomic i8, ptr addrspace(1) %a acquire, align 1
  %a.add = add i8 %a.load, 1
  ; CHECK: st.release.sys.global.b8 [%rd{{[0-9]+}}], %rs{{[0-9]+}}
  store atomic i8 %a.add, ptr addrspace(1) %a release, align 1

  ; CHECK: ld.acquire.sys.global.b16 %rs{{[0-9]+}}, [%rd{{[0-9]+}}]
  %b.load = load atomic i16, ptr addrspace(1) %b acquire, align 2
  %b.add = add i16 %b.load, 1
  ; CHECK: st.release.sys.global.b16 [%rd{{[0-9]+}}], %rs{{[0-9]+}}
  store atomic i16 %b.add, ptr addrspace(1) %b release, align 2

  ; CHECK: ld.acquire.sys.global.b32 %r{{[0-9]+}}, [%rd{{[0-9]+}}]
  %c.load = load atomic i32, ptr addrspace(1) %c acquire, align 4
  %c.add = add i32 %c.load, 1
  ; CHECK: st.release.sys.global.b32 [%rd{{[0-9]+}}], %r{{[0-9]+}}
  store atomic i32 %c.add, ptr addrspace(1) %c release, align 4

  ; CHECK: ld.acquire.sys.global.b64 %rd{{[0-9]+}}, [%rd{{[0-9]+}}]
  %d.load = load atomic i64, ptr addrspace(1) %d acquire, align 8
  %d.add = add i64 %d.load, 1
  ; CHECK: st.release.sys.global.b64 [%rd{{[0-9]+}}], %rd{{[0-9]+}}
  store atomic i64 %d.add, ptr addrspace(1) %d release, align 8

  ; CHECK: ld.acquire.sys.global.b32 %f{{[0-9]+}}, [%rd{{[0-9]+}}]
  %e.load = load atomic float, ptr addrspace(1) %e acquire, align 4
  %e.add = fadd float %e.load, 1.
  ; CHECK: st.release.sys.global.b32 [%rd{{[0-9]+}}], %f{{[0-9]+}}
  store atomic float %e.add, ptr addrspace(1) %e release, align 4

  ; CHECK: ld.acquire.sys.global.b64 %fd{{[0-9]+}}, [%rd{{[0-9]+}}]
  %f.load = load atomic double, ptr addrspace(1) %e acquire, align 8
  %f.add = fadd double %f.load, 1.
  ; CHECK: st.release.sys.global.b64 [%rd{{[0-9]+}}], %fd{{[0-9]+}}
  store atomic double %f.add, ptr addrspace(1) %e release, align 8

  ret void
}

; CHECK-LABEL: global_acq_rel_volatile_sys
define void @global_acq_rel_volatile_sys(ptr addrspace(1) %a, ptr addrspace(1) %b, ptr addrspace(1) %c, ptr addrspace(1) %d, ptr addrspace(1) %e) local_unnamed_addr {
  ; CHECK: ld.acquire.sys.global.b8 %rs{{[0-9]+}}, [%rd{{[0-9]+}}]
  %a.load = load atomic volatile i8, ptr addrspace(1) %a acquire, align 1
  %a.add = add i8 %a.load, 1
  ; CHECK: st.release.sys.global.b8 [%rd{{[0-9]+}}], %rs{{[0-9]+}}
  store atomic volatile i8 %a.add, ptr addrspace(1) %a release, align 1

  ; CHECK: ld.acquire.sys.global.b16 %rs{{[0-9]+}}, [%rd{{[0-9]+}}]
  %b.load = load atomic volatile i16, ptr addrspace(1) %b acquire, align 2
  %b.add = add i16 %b.load, 1
  ; CHECK: st.release.sys.global.b16 [%rd{{[0-9]+}}], %rs{{[0-9]+}}
  store atomic volatile i16 %b.add, ptr addrspace(1) %b release, align 2

  ; CHECK: ld.acquire.sys.global.b32 %r{{[0-9]+}}, [%rd{{[0-9]+}}]
  %c.load = load atomic volatile i32, ptr addrspace(1) %c acquire, align 4
  %c.add = add i32 %c.load, 1
  ; CHECK: st.release.sys.global.b32 [%rd{{[0-9]+}}], %r{{[0-9]+}}
  store atomic volatile i32 %c.add, ptr addrspace(1) %c release, align 4

  ; CHECK: ld.acquire.sys.global.b64 %rd{{[0-9]+}}, [%rd{{[0-9]+}}]
  %d.load = load atomic volatile i64, ptr addrspace(1) %d acquire, align 8
  %d.add = add i64 %d.load, 1
  ; CHECK: st.release.sys.global.b64 [%rd{{[0-9]+}}], %rd{{[0-9]+}}
  store atomic volatile i64 %d.add, ptr addrspace(1) %d release, align 8

  ; CHECK: ld.acquire.sys.global.b32 %f{{[0-9]+}}, [%rd{{[0-9]+}}]
  %e.load = load atomic volatile float, ptr addrspace(1) %e acquire, align 4
  %e.add = fadd float %e.load, 1.
  ; CHECK: st.release.sys.global.b32 [%rd{{[0-9]+}}], %f{{[0-9]+}}
  store atomic volatile float %e.add, ptr addrspace(1) %e release, align 4

  ; CHECK: ld.acquire.sys.global.b64 %fd{{[0-9]+}}, [%rd{{[0-9]+}}]
  %f.load = load atomic volatile double, ptr addrspace(1) %e acquire, align 8
  %f.add = fadd double %f.load, 1.
  ; CHECK: st.release.sys.global.b64 [%rd{{[0-9]+}}], %fd{{[0-9]+}}
  store atomic volatile double %f.add, ptr addrspace(1) %e release, align 8

  ret void
}

; CHECK-LABEL: global_acq_rel_gpu
define void @global_acq_rel_gpu(ptr addrspace(1) %a, ptr addrspace(1) %b, ptr addrspace(1) %c, ptr addrspace(1) %d, ptr addrspace(1) %e) local_unnamed_addr {
  ; CHECK: ld.acquire.gpu.global.b8 %rs{{[0-9]+}}, [%rd{{[0-9]+}}]
  %a.load = load atomic i8, ptr addrspace(1) %a syncscope("device") acquire, align 1
  %a.add = add i8 %a.load, 1
  ; CHECK: st.release.gpu.global.b8 [%rd{{[0-9]+}}], %rs{{[0-9]+}}
  store atomic i8 %a.add, ptr addrspace(1) %a syncscope("device") release, align 1

  ; CHECK: ld.acquire.gpu.global.b16 %rs{{[0-9]+}}, [%rd{{[0-9]+}}]
  %b.load = load atomic i16, ptr addrspace(1) %b syncscope("device") acquire, align 2
  %b.add = add i16 %b.load, 1
  ; CHECK: st.release.gpu.global.b16 [%rd{{[0-9]+}}], %rs{{[0-9]+}}
  store atomic i16 %b.add, ptr addrspace(1) %b syncscope("device") release, align 2

  ; CHECK: ld.acquire.gpu.global.b32 %r{{[0-9]+}}, [%rd{{[0-9]+}}]
  %c.load = load atomic i32, ptr addrspace(1) %c syncscope("device") acquire, align 4
  %c.add = add i32 %c.load, 1
  ; CHECK: st.release.gpu.global.b32 [%rd{{[0-9]+}}], %r{{[0-9]+}}
  store atomic i32 %c.add, ptr addrspace(1) %c syncscope("device") release, align 4

  ; CHECK: ld.acquire.gpu.global.b64 %rd{{[0-9]+}}, [%rd{{[0-9]+}}]
  %d.load = load atomic i64, ptr addrspace(1) %d syncscope("device") acquire, align 8
  %d.add = add i64 %d.load, 1
  ; CHECK: st.release.gpu.global.b64 [%rd{{[0-9]+}}], %rd{{[0-9]+}}
  store atomic i64 %d.add, ptr addrspace(1) %d syncscope("device") release, align 8

  ; CHECK: ld.acquire.gpu.global.b32 %f{{[0-9]+}}, [%rd{{[0-9]+}}]
  %e.load = load atomic float, ptr addrspace(1) %e syncscope("device") acquire, align 4
  %e.add = fadd float %e.load, 1.
  ; CHECK: st.release.gpu.global.b32 [%rd{{[0-9]+}}], %f{{[0-9]+}}
  store atomic float %e.add, ptr addrspace(1) %e syncscope("device") release, align 4

  ; CHECK: ld.acquire.gpu.global.b64 %fd{{[0-9]+}}, [%rd{{[0-9]+}}]
  %f.load = load atomic double, ptr addrspace(1) %e syncscope("device") acquire, align 8
  %f.add = fadd double %f.load, 1.
  ; CHECK: st.release.gpu.global.b64 [%rd{{[0-9]+}}], %fd{{[0-9]+}}
  store atomic double %f.add, ptr addrspace(1) %e syncscope("device") release, align 8

  ret void
}

; CHECK-LABEL: global_acq_rel_volatile_gpu
define void @global_acq_rel_volatile_gpu(ptr addrspace(1) %a, ptr addrspace(1) %b, ptr addrspace(1) %c, ptr addrspace(1) %d, ptr addrspace(1) %e) local_unnamed_addr {
  ; CHECK: ld.acquire.sys.global.b8 %rs{{[0-9]+}}, [%rd{{[0-9]+}}]
  %a.load = load atomic volatile i8, ptr addrspace(1) %a syncscope("device") acquire, align 1
  %a.add = add i8 %a.load, 1
  ; CHECK: st.release.sys.global.b8 [%rd{{[0-9]+}}], %rs{{[0-9]+}}
  store atomic volatile i8 %a.add, ptr addrspace(1) %a syncscope("device") release, align 1

  ; CHECK: ld.acquire.sys.global.b16 %rs{{[0-9]+}}, [%rd{{[0-9]+}}]
  %b.load = load atomic volatile i16, ptr addrspace(1) %b syncscope("device") acquire, align 2
  %b.add = add i16 %b.load, 1
  ; CHECK: st.release.sys.global.b16 [%rd{{[0-9]+}}], %rs{{[0-9]+}}
  store atomic volatile i16 %b.add, ptr addrspace(1) %b syncscope("device") release, align 2

  ; CHECK: ld.acquire.sys.global.b32 %r{{[0-9]+}}, [%rd{{[0-9]+}}]
  %c.load = load atomic volatile i32, ptr addrspace(1) %c syncscope("device") acquire, align 4
  %c.add = add i32 %c.load, 1
  ; CHECK: st.release.sys.global.b32 [%rd{{[0-9]+}}], %r{{[0-9]+}}
  store atomic volatile i32 %c.add, ptr addrspace(1) %c syncscope("device") release, align 4

  ; CHECK: ld.acquire.sys.global.b64 %rd{{[0-9]+}}, [%rd{{[0-9]+}}]
  %d.load = load atomic volatile i64, ptr addrspace(1) %d syncscope("device") acquire, align 8
  %d.add = add i64 %d.load, 1
  ; CHECK: st.release.sys.global.b64 [%rd{{[0-9]+}}], %rd{{[0-9]+}}
  store atomic volatile i64 %d.add, ptr addrspace(1) %d syncscope("device") release, align 8

  ; CHECK: ld.acquire.sys.global.b32 %f{{[0-9]+}}, [%rd{{[0-9]+}}]
  %e.load = load atomic volatile float, ptr addrspace(1) %e syncscope("device") acquire, align 4
  %e.add = fadd float %e.load, 1.
  ; CHECK: st.release.sys.global.b32 [%rd{{[0-9]+}}], %f{{[0-9]+}}
  store atomic volatile float %e.add, ptr addrspace(1) %e syncscope("device") release, align 4

  ; CHECK: ld.acquire.sys.global.b64 %fd{{[0-9]+}}, [%rd{{[0-9]+}}]
  %f.load = load atomic volatile double, ptr addrspace(1) %e syncscope("device") acquire, align 8
  %f.add = fadd double %f.load, 1.
  ; CHECK: st.release.sys.global.b64 [%rd{{[0-9]+}}], %fd{{[0-9]+}}
  store atomic volatile double %f.add, ptr addrspace(1) %e syncscope("device") release, align 8

  ret void
}

; CHECK-LABEL: global_acq_rel_cta
define void @global_acq_rel_cta(ptr addrspace(1) %a, ptr addrspace(1) %b, ptr addrspace(1) %c, ptr addrspace(1) %d, ptr addrspace(1) %e) local_unnamed_addr {
  ; CHECK: ld.acquire.cta.global.b8 %rs{{[0-9]+}}, [%rd{{[0-9]+}}]
  %a.load = load atomic i8, ptr addrspace(1) %a syncscope("block") acquire, align 1
  %a.add = add i8 %a.load, 1
  ; CHECK: st.release.cta.global.b8 [%rd{{[0-9]+}}], %rs{{[0-9]+}}
  store atomic i8 %a.add, ptr addrspace(1) %a syncscope("block") release, align 1

  ; CHECK: ld.acquire.cta.global.b16 %rs{{[0-9]+}}, [%rd{{[0-9]+}}]
  %b.load = load atomic i16, ptr addrspace(1) %b syncscope("block") acquire, align 2
  %b.add = add i16 %b.load, 1
  ; CHECK: st.release.cta.global.b16 [%rd{{[0-9]+}}], %rs{{[0-9]+}}
  store atomic i16 %b.add, ptr addrspace(1) %b syncscope("block") release, align 2

  ; CHECK: ld.acquire.cta.global.b32 %r{{[0-9]+}}, [%rd{{[0-9]+}}]
  %c.load = load atomic i32, ptr addrspace(1) %c syncscope("block") acquire, align 4
  %c.add = add i32 %c.load, 1
  ; CHECK: st.release.cta.global.b32 [%rd{{[0-9]+}}], %r{{[0-9]+}}
  store atomic i32 %c.add, ptr addrspace(1) %c syncscope("block") release, align 4

  ; CHECK: ld.acquire.cta.global.b64 %rd{{[0-9]+}}, [%rd{{[0-9]+}}]
  %d.load = load atomic i64, ptr addrspace(1) %d syncscope("block") acquire, align 8
  %d.add = add i64 %d.load, 1
  ; CHECK: st.release.cta.global.b64 [%rd{{[0-9]+}}], %rd{{[0-9]+}}
  store atomic i64 %d.add, ptr addrspace(1) %d syncscope("block") release, align 8

  ; CHECK: ld.acquire.cta.global.b32 %f{{[0-9]+}}, [%rd{{[0-9]+}}]
  %e.load = load atomic float, ptr addrspace(1) %e syncscope("block") acquire, align 4
  %e.add = fadd float %e.load, 1.
  ; CHECK: st.release.cta.global.b32 [%rd{{[0-9]+}}], %f{{[0-9]+}}
  store atomic float %e.add, ptr addrspace(1) %e syncscope("block") release, align 4

  ; CHECK: ld.acquire.cta.global.b64 %fd{{[0-9]+}}, [%rd{{[0-9]+}}]
  %f.load = load atomic double, ptr addrspace(1) %e syncscope("block") acquire, align 8
  %f.add = fadd double %f.load, 1.
  ; CHECK: st.release.cta.global.b64 [%rd{{[0-9]+}}], %fd{{[0-9]+}}
  store atomic double %f.add, ptr addrspace(1) %e syncscope("block") release, align 8

  ret void
}

; CHECK-LABEL: global_acq_rel_volatile_cta
define void @global_acq_rel_volatile_cta(ptr addrspace(1) %a, ptr addrspace(1) %b, ptr addrspace(1) %c, ptr addrspace(1) %d, ptr addrspace(1) %e) local_unnamed_addr {
  ; CHECK: ld.acquire.sys.global.b8 %rs{{[0-9]+}}, [%rd{{[0-9]+}}]
  %a.load = load atomic volatile i8, ptr addrspace(1) %a syncscope("block") acquire, align 1
  %a.add = add i8 %a.load, 1
  ; CHECK: st.release.sys.global.b8 [%rd{{[0-9]+}}], %rs{{[0-9]+}}
  store atomic volatile i8 %a.add, ptr addrspace(1) %a syncscope("block") release, align 1

  ; CHECK: ld.acquire.sys.global.b16 %rs{{[0-9]+}}, [%rd{{[0-9]+}}]
  %b.load = load atomic volatile i16, ptr addrspace(1) %b syncscope("block") acquire, align 2
  %b.add = add i16 %b.load, 1
  ; CHECK: st.release.sys.global.b16 [%rd{{[0-9]+}}], %rs{{[0-9]+}}
  store atomic volatile i16 %b.add, ptr addrspace(1) %b syncscope("block") release, align 2

  ; CHECK: ld.acquire.sys.global.b32 %r{{[0-9]+}}, [%rd{{[0-9]+}}]
  %c.load = load atomic volatile i32, ptr addrspace(1) %c syncscope("block") acquire, align 4
  %c.add = add i32 %c.load, 1
  ; CHECK: st.release.sys.global.b32 [%rd{{[0-9]+}}], %r{{[0-9]+}}
  store atomic volatile i32 %c.add, ptr addrspace(1) %c syncscope("block") release, align 4

  ; CHECK: ld.acquire.sys.global.b64 %rd{{[0-9]+}}, [%rd{{[0-9]+}}]
  %d.load = load atomic volatile i64, ptr addrspace(1) %d syncscope("block") acquire, align 8
  %d.add = add i64 %d.load, 1
  ; CHECK: st.release.sys.global.b64 [%rd{{[0-9]+}}], %rd{{[0-9]+}}
  store atomic volatile i64 %d.add, ptr addrspace(1) %d syncscope("block") release, align 8

  ; CHECK: ld.acquire.sys.global.b32 %f{{[0-9]+}}, [%rd{{[0-9]+}}]
  %e.load = load atomic volatile float, ptr addrspace(1) %e syncscope("block") acquire, align 4
  %e.add = fadd float %e.load, 1.
  ; CHECK: st.release.sys.global.b32 [%rd{{[0-9]+}}], %f{{[0-9]+}}
  store atomic volatile float %e.add, ptr addrspace(1) %e syncscope("block") release, align 4

  ; CHECK: ld.acquire.sys.global.b64 %fd{{[0-9]+}}, [%rd{{[0-9]+}}]
  %f.load = load atomic volatile double, ptr addrspace(1) %e syncscope("block") acquire, align 8
  %f.add = fadd double %f.load, 1.
  ; CHECK: st.release.sys.global.b64 [%rd{{[0-9]+}}], %fd{{[0-9]+}}
  store atomic volatile double %f.add, ptr addrspace(1) %e syncscope("block") release, align 8

  ret void
}

; CHECK-LABEL: global_seq_cst_sys
define void @global_seq_cst_sys(ptr addrspace(1) %a, ptr addrspace(1) %b, ptr addrspace(1) %c, ptr addrspace(1) %d, ptr addrspace(1) %e) local_unnamed_addr {
  ; CHECK: fence.sc.sys
  ; CHECK: ld.acquire.sys.global.b8 %rs{{[0-9]+}}, [%rd{{[0-9]+}}]
  %a.load = load atomic i8, ptr addrspace(1) %a seq_cst, align 1
  %a.add = add i8 %a.load, 1
  ; CHECK: fence.sc.sys
  ; CHECK: st.release.sys.global.b8 [%rd{{[0-9]+}}], %rs{{[0-9]+}}
  store atomic i8 %a.add, ptr addrspace(1) %a seq_cst, align 1

  ; CHECK: fence.sc.sys
  ; CHECK: ld.acquire.sys.global.b16 %rs{{[0-9]+}}, [%rd{{[0-9]+}}]
  %b.load = load atomic i16, ptr addrspace(1) %b seq_cst, align 2
  %b.add = add i16 %b.load, 1
  ; CHECK: fence.sc.sys
  ; CHECK: st.release.sys.global.b16 [%rd{{[0-9]+}}], %rs{{[0-9]+}}
  store atomic i16 %b.add, ptr addrspace(1) %b seq_cst, align 2

  ; CHECK: fence.sc.sys
  ; CHECK: ld.acquire.sys.global.b32 %r{{[0-9]+}}, [%rd{{[0-9]+}}]
  %c.load = load atomic i32, ptr addrspace(1) %c seq_cst, align 4
  %c.add = add i32 %c.load, 1
  ; CHECK: fence.sc.sys
  ; CHECK: st.release.sys.global.b32 [%rd{{[0-9]+}}], %r{{[0-9]+}}
  store atomic i32 %c.add, ptr addrspace(1) %c seq_cst, align 4

  ; CHECK: fence.sc.sys
  ; CHECK: ld.acquire.sys.global.b64 %rd{{[0-9]+}}, [%rd{{[0-9]+}}]
  %d.load = load atomic i64, ptr addrspace(1) %d seq_cst, align 8
  %d.add = add i64 %d.load, 1
  ; CHECK: fence.sc.sys
  ; CHECK: st.release.sys.global.b64 [%rd{{[0-9]+}}], %rd{{[0-9]+}}
  store atomic i64 %d.add, ptr addrspace(1) %d seq_cst, align 8

  ; CHECK: fence.sc.sys
  ; CHECK: ld.acquire.sys.global.b32 %f{{[0-9]+}}, [%rd{{[0-9]+}}]
  %e.load = load atomic float, ptr addrspace(1) %e seq_cst, align 4
  %e.add = fadd float %e.load, 1.
  ; CHECK: fence.sc.sys
  ; CHECK: st.release.sys.global.b32 [%rd{{[0-9]+}}], %f{{[0-9]+}}
  store atomic float %e.add, ptr addrspace(1) %e seq_cst, align 4

  ; CHECK: fence.sc.sys
  ; CHECK: ld.acquire.sys.global.b64 %fd{{[0-9]+}}, [%rd{{[0-9]+}}]
  %f.load = load atomic double, ptr addrspace(1) %e seq_cst, align 8
  %f.add = fadd double %f.load, 1.
  ; CHECK: fence.sc.sys
  ; CHECK: st.release.sys.global.b64 [%rd{{[0-9]+}}], %fd{{[0-9]+}}
  store atomic double %f.add, ptr addrspace(1) %e seq_cst, align 8

  ret void
}

; CHECK-LABEL: global_seq_cst_volatile_sys
define void @global_seq_cst_volatile_sys(ptr addrspace(1) %a, ptr addrspace(1) %b, ptr addrspace(1) %c, ptr addrspace(1) %d, ptr addrspace(1) %e) local_unnamed_addr {
  ; CHECK: fence.sc.sys
  ; CHECK: ld.acquire.sys.global.b8 %rs{{[0-9]+}}, [%rd{{[0-9]+}}]
  %a.load = load atomic volatile i8, ptr addrspace(1) %a seq_cst, align 1
  %a.add = add i8 %a.load, 1
  ; CHECK: fence.sc.sys
  ; CHECK: st.release.sys.global.b8 [%rd{{[0-9]+}}], %rs{{[0-9]+}}
  store atomic volatile i8 %a.add, ptr addrspace(1) %a seq_cst, align 1

  ; CHECK: fence.sc.sys
  ; CHECK: ld.acquire.sys.global.b16 %rs{{[0-9]+}}, [%rd{{[0-9]+}}]
  %b.load = load atomic volatile i16, ptr addrspace(1) %b seq_cst, align 2
  %b.add = add i16 %b.load, 1
  ; CHECK: fence.sc.sys
  ; CHECK: st.release.sys.global.b16 [%rd{{[0-9]+}}], %rs{{[0-9]+}}
  store atomic volatile i16 %b.add, ptr addrspace(1) %b seq_cst, align 2

  ; CHECK: fence.sc.sys
  ; CHECK: ld.acquire.sys.global.b32 %r{{[0-9]+}}, [%rd{{[0-9]+}}]
  %c.load = load atomic volatile i32, ptr addrspace(1) %c seq_cst, align 4
  %c.add = add i32 %c.load, 1
  ; CHECK: fence.sc.sys
  ; CHECK: st.release.sys.global.b32 [%rd{{[0-9]+}}], %r{{[0-9]+}}
  store atomic volatile i32 %c.add, ptr addrspace(1) %c seq_cst, align 4

  ; CHECK: fence.sc.sys
  ; CHECK: ld.acquire.sys.global.b64 %rd{{[0-9]+}}, [%rd{{[0-9]+}}]
  %d.load = load atomic volatile i64, ptr addrspace(1) %d seq_cst, align 8
  %d.add = add i64 %d.load, 1
  ; CHECK: fence.sc.sys
  ; CHECK: st.release.sys.global.b64 [%rd{{[0-9]+}}], %rd{{[0-9]+}}
  store atomic volatile i64 %d.add, ptr addrspace(1) %d seq_cst, align 8

  ; CHECK: fence.sc.sys
  ; CHECK: ld.acquire.sys.global.b32 %f{{[0-9]+}}, [%rd{{[0-9]+}}]
  %e.load = load atomic volatile float, ptr addrspace(1) %e seq_cst, align 4
  %e.add = fadd float %e.load, 1.
  ; CHECK: fence.sc.sys
  ; CHECK: st.release.sys.global.b32 [%rd{{[0-9]+}}], %f{{[0-9]+}}
  store atomic volatile float %e.add, ptr addrspace(1) %e seq_cst, align 4

  ; CHECK: fence.sc.sys
  ; CHECK: ld.acquire.sys.global.b64 %fd{{[0-9]+}}, [%rd{{[0-9]+}}]
  %f.load = load atomic volatile double, ptr addrspace(1) %e seq_cst, align 8
  %f.add = fadd double %f.load, 1.
  ; CHECK: fence.sc.sys
  ; CHECK: st.release.sys.global.b64 [%rd{{[0-9]+}}], %fd{{[0-9]+}}
  store atomic volatile double %f.add, ptr addrspace(1) %e seq_cst, align 8

  ret void
}

; CHECK-LABEL: global_seq_cst_gpu
define void @global_seq_cst_gpu(ptr addrspace(1) %a, ptr addrspace(1) %b, ptr addrspace(1) %c, ptr addrspace(1) %d, ptr addrspace(1) %e) local_unnamed_addr {
  ; CHECK: fence.sc.gpu
  ; CHECK: ld.acquire.gpu.global.b8 %rs{{[0-9]+}}, [%rd{{[0-9]+}}]
  %a.load = load atomic i8, ptr addrspace(1) %a syncscope("device") seq_cst, align 1
  %a.add = add i8 %a.load, 1
  ; CHECK: fence.sc.gpu
  ; CHECK: st.release.gpu.global.b8 [%rd{{[0-9]+}}], %rs{{[0-9]+}}
  store atomic i8 %a.add, ptr addrspace(1) %a syncscope("device") seq_cst, align 1

  ; CHECK: fence.sc.gpu
  ; CHECK: ld.acquire.gpu.global.b16 %rs{{[0-9]+}}, [%rd{{[0-9]+}}]
  %b.load = load atomic i16, ptr addrspace(1) %b syncscope("device") seq_cst, align 2
  %b.add = add i16 %b.load, 1
  ; CHECK: fence.sc.gpu
  ; CHECK: st.release.gpu.global.b16 [%rd{{[0-9]+}}], %rs{{[0-9]+}}
  store atomic i16 %b.add, ptr addrspace(1) %b syncscope("device") seq_cst, align 2

  ; CHECK: fence.sc.gpu
  ; CHECK: ld.acquire.gpu.global.b32 %r{{[0-9]+}}, [%rd{{[0-9]+}}]
  %c.load = load atomic i32, ptr addrspace(1) %c syncscope("device") seq_cst, align 4
  %c.add = add i32 %c.load, 1
  ; CHECK: fence.sc.gpu
  ; CHECK: st.release.gpu.global.b32 [%rd{{[0-9]+}}], %r{{[0-9]+}}
  store atomic i32 %c.add, ptr addrspace(1) %c syncscope("device") seq_cst, align 4

  ; CHECK: fence.sc.gpu
  ; CHECK: ld.acquire.gpu.global.b64 %rd{{[0-9]+}}, [%rd{{[0-9]+}}]
  %d.load = load atomic i64, ptr addrspace(1) %d syncscope("device") seq_cst, align 8
  %d.add = add i64 %d.load, 1
  ; CHECK: fence.sc.gpu
  ; CHECK: st.release.gpu.global.b64 [%rd{{[0-9]+}}], %rd{{[0-9]+}}
  store atomic i64 %d.add, ptr addrspace(1) %d syncscope("device") seq_cst, align 8

  ; CHECK: fence.sc.gpu
  ; CHECK: ld.acquire.gpu.global.b32 %f{{[0-9]+}}, [%rd{{[0-9]+}}]
  %e.load = load atomic float, ptr addrspace(1) %e syncscope("device") seq_cst, align 4
  %e.add = fadd float %e.load, 1.
  ; CHECK: fence.sc.gpu
  ; CHECK: st.release.gpu.global.b32 [%rd{{[0-9]+}}], %f{{[0-9]+}}
  store atomic float %e.add, ptr addrspace(1) %e syncscope("device") seq_cst, align 4

  ; CHECK: fence.sc.gpu
  ; CHECK: ld.acquire.gpu.global.b64 %fd{{[0-9]+}}, [%rd{{[0-9]+}}]
  %f.load = load atomic double, ptr addrspace(1) %e syncscope("device") seq_cst, align 8
  %f.add = fadd double %f.load, 1.
  ; CHECK: fence.sc.gpu
  ; CHECK: st.release.gpu.global.b64 [%rd{{[0-9]+}}], %fd{{[0-9]+}}
  store atomic double %f.add, ptr addrspace(1) %e syncscope("device") seq_cst, align 8

  ret void
}

; CHECK-LABEL: global_seq_cst_volatile_gpu
define void @global_seq_cst_volatile_gpu(ptr addrspace(1) %a, ptr addrspace(1) %b, ptr addrspace(1) %c, ptr addrspace(1) %d, ptr addrspace(1) %e) local_unnamed_addr {
  ; CHECK: fence.sc.sys
  ; CHECK: ld.acquire.sys.global.b8 %rs{{[0-9]+}}, [%rd{{[0-9]+}}]
  %a.load = load atomic volatile i8, ptr addrspace(1) %a syncscope("device") seq_cst, align 1
  %a.add = add i8 %a.load, 1
  ; CHECK: fence.sc.sys
  ; CHECK: st.release.sys.global.b8 [%rd{{[0-9]+}}], %rs{{[0-9]+}}
  store atomic volatile i8 %a.add, ptr addrspace(1) %a syncscope("device") seq_cst, align 1

  ; CHECK: fence.sc.sys
  ; CHECK: ld.acquire.sys.global.b16 %rs{{[0-9]+}}, [%rd{{[0-9]+}}]
  %b.load = load atomic volatile i16, ptr addrspace(1) %b syncscope("device") seq_cst, align 2
  %b.add = add i16 %b.load, 1
  ; CHECK: fence.sc.sys
  ; CHECK: st.release.sys.global.b16 [%rd{{[0-9]+}}], %rs{{[0-9]+}}
  store atomic volatile i16 %b.add, ptr addrspace(1) %b syncscope("device") seq_cst, align 2

  ; CHECK: fence.sc.sys
  ; CHECK: ld.acquire.sys.global.b32 %r{{[0-9]+}}, [%rd{{[0-9]+}}]
  %c.load = load atomic volatile i32, ptr addrspace(1) %c syncscope("device") seq_cst, align 4
  %c.add = add i32 %c.load, 1
  ; CHECK: fence.sc.sys
  ; CHECK: st.release.sys.global.b32 [%rd{{[0-9]+}}], %r{{[0-9]+}}
  store atomic volatile i32 %c.add, ptr addrspace(1) %c syncscope("device") seq_cst, align 4

  ; CHECK: fence.sc.sys
  ; CHECK: ld.acquire.sys.global.b64 %rd{{[0-9]+}}, [%rd{{[0-9]+}}]
  %d.load = load atomic volatile i64, ptr addrspace(1) %d syncscope("device") seq_cst, align 8
  %d.add = add i64 %d.load, 1
  ; CHECK: fence.sc.sys
  ; CHECK: st.release.sys.global.b64 [%rd{{[0-9]+}}], %rd{{[0-9]+}}
  store atomic volatile i64 %d.add, ptr addrspace(1) %d syncscope("device") seq_cst, align 8

  ; CHECK: fence.sc.sys
  ; CHECK: ld.acquire.sys.global.b32 %f{{[0-9]+}}, [%rd{{[0-9]+}}]
  %e.load = load atomic volatile float, ptr addrspace(1) %e syncscope("device") seq_cst, align 4
  %e.add = fadd float %e.load, 1.
  ; CHECK: fence.sc.sys
  ; CHECK: st.release.sys.global.b32 [%rd{{[0-9]+}}], %f{{[0-9]+}}
  store atomic volatile float %e.add, ptr addrspace(1) %e syncscope("device") seq_cst, align 4

  ; CHECK: fence.sc.sys
  ; CHECK: ld.acquire.sys.global.b64 %fd{{[0-9]+}}, [%rd{{[0-9]+}}]
  %f.load = load atomic volatile double, ptr addrspace(1) %e syncscope("device") seq_cst, align 8
  %f.add = fadd double %f.load, 1.
  ; CHECK: fence.sc.sys
  ; CHECK: st.release.sys.global.b64 [%rd{{[0-9]+}}], %fd{{[0-9]+}}
  store atomic volatile double %f.add, ptr addrspace(1) %e syncscope("device") seq_cst, align 8

  ret void
}

; CHECK-LABEL: global_seq_cst_cta
define void @global_seq_cst_cta(ptr addrspace(1) %a, ptr addrspace(1) %b, ptr addrspace(1) %c, ptr addrspace(1) %d, ptr addrspace(1) %e) local_unnamed_addr {
  ; CHECK: fence.sc.cta
  ; CHECK: ld.acquire.cta.global.b8 %rs{{[0-9]+}}, [%rd{{[0-9]+}}]
  %a.load = load atomic i8, ptr addrspace(1) %a syncscope("block") seq_cst, align 1
  %a.add = add i8 %a.load, 1
  ; CHECK: fence.sc.cta
  ; CHECK: st.release.cta.global.b8 [%rd{{[0-9]+}}], %rs{{[0-9]+}}
  store atomic i8 %a.add, ptr addrspace(1) %a syncscope("block") seq_cst, align 1

  ; CHECK: fence.sc.cta
  ; CHECK: ld.acquire.cta.global.b16 %rs{{[0-9]+}}, [%rd{{[0-9]+}}]
  %b.load = load atomic i16, ptr addrspace(1) %b syncscope("block") seq_cst, align 2
  %b.add = add i16 %b.load, 1
  ; CHECK: fence.sc.cta
  ; CHECK: st.release.cta.global.b16 [%rd{{[0-9]+}}], %rs{{[0-9]+}}
  store atomic i16 %b.add, ptr addrspace(1) %b syncscope("block") seq_cst, align 2

  ; CHECK: fence.sc.cta
  ; CHECK: ld.acquire.cta.global.b32 %r{{[0-9]+}}, [%rd{{[0-9]+}}]
  %c.load = load atomic i32, ptr addrspace(1) %c syncscope("block") seq_cst, align 4
  %c.add = add i32 %c.load, 1
  ; CHECK: fence.sc.cta
  ; CHECK: st.release.cta.global.b32 [%rd{{[0-9]+}}], %r{{[0-9]+}}
  store atomic i32 %c.add, ptr addrspace(1) %c syncscope("block") seq_cst, align 4

  ; CHECK: fence.sc.cta
  ; CHECK: ld.acquire.cta.global.b64 %rd{{[0-9]+}}, [%rd{{[0-9]+}}]
  %d.load = load atomic i64, ptr addrspace(1) %d syncscope("block") seq_cst, align 8
  %d.add = add i64 %d.load, 1
  ; CHECK: fence.sc.cta
  ; CHECK: st.release.cta.global.b64 [%rd{{[0-9]+}}], %rd{{[0-9]+}}
  store atomic i64 %d.add, ptr addrspace(1) %d syncscope("block") seq_cst, align 8

  ; CHECK: fence.sc.cta
  ; CHECK: ld.acquire.cta.global.b32 %f{{[0-9]+}}, [%rd{{[0-9]+}}]
  %e.load = load atomic float, ptr addrspace(1) %e syncscope("block") seq_cst, align 4
  %e.add = fadd float %e.load, 1.
  ; CHECK: fence.sc.cta
  ; CHECK: st.release.cta.global.b32 [%rd{{[0-9]+}}], %f{{[0-9]+}}
  store atomic float %e.add, ptr addrspace(1) %e syncscope("block") seq_cst, align 4

  ; CHECK: fence.sc.cta
  ; CHECK: ld.acquire.cta.global.b64 %fd{{[0-9]+}}, [%rd{{[0-9]+}}]
  %f.load = load atomic double, ptr addrspace(1) %e syncscope("block") seq_cst, align 8
  %f.add = fadd double %f.load, 1.
  ; CHECK: fence.sc.cta
  ; CHECK: st.release.cta.global.b64 [%rd{{[0-9]+}}], %fd{{[0-9]+}}
  store atomic double %f.add, ptr addrspace(1) %e syncscope("block") seq_cst, align 8

  ret void
}

; CHECK-LABEL: global_seq_cst_volatile_cta
define void @global_seq_cst_volatile_cta(ptr addrspace(1) %a, ptr addrspace(1) %b, ptr addrspace(1) %c, ptr addrspace(1) %d, ptr addrspace(1) %e) local_unnamed_addr {
  ; CHECK: fence.sc.sys
  ; CHECK: ld.acquire.sys.global.b8 %rs{{[0-9]+}}, [%rd{{[0-9]+}}]
  %a.load = load atomic volatile i8, ptr addrspace(1) %a syncscope("block") seq_cst, align 1
  %a.add = add i8 %a.load, 1
  ; CHECK: fence.sc.sys
  ; CHECK: st.release.sys.global.b8 [%rd{{[0-9]+}}], %rs{{[0-9]+}}
  store atomic volatile i8 %a.add, ptr addrspace(1) %a syncscope("block") seq_cst, align 1

  ; CHECK: fence.sc.sys
  ; CHECK: ld.acquire.sys.global.b16 %rs{{[0-9]+}}, [%rd{{[0-9]+}}]
  %b.load = load atomic volatile i16, ptr addrspace(1) %b syncscope("block") seq_cst, align 2
  %b.add = add i16 %b.load, 1
  ; CHECK: fence.sc.sys
  ; CHECK: st.release.sys.global.b16 [%rd{{[0-9]+}}], %rs{{[0-9]+}}
  store atomic volatile i16 %b.add, ptr addrspace(1) %b syncscope("block") seq_cst, align 2

  ; CHECK: fence.sc.sys
  ; CHECK: ld.acquire.sys.global.b32 %r{{[0-9]+}}, [%rd{{[0-9]+}}]
  %c.load = load atomic volatile i32, ptr addrspace(1) %c syncscope("block") seq_cst, align 4
  %c.add = add i32 %c.load, 1
  ; CHECK: fence.sc.sys
  ; CHECK: st.release.sys.global.b32 [%rd{{[0-9]+}}], %r{{[0-9]+}}
  store atomic volatile i32 %c.add, ptr addrspace(1) %c syncscope("block") seq_cst, align 4

  ; CHECK: fence.sc.sys
  ; CHECK: ld.acquire.sys.global.b64 %rd{{[0-9]+}}, [%rd{{[0-9]+}}]
  %d.load = load atomic volatile i64, ptr addrspace(1) %d syncscope("block") seq_cst, align 8
  %d.add = add i64 %d.load, 1
  ; CHECK: fence.sc.sys
  ; CHECK: st.release.sys.global.b64 [%rd{{[0-9]+}}], %rd{{[0-9]+}}
  store atomic volatile i64 %d.add, ptr addrspace(1) %d syncscope("block") seq_cst, align 8

  ; CHECK: fence.sc.sys
  ; CHECK: ld.acquire.sys.global.b32 %f{{[0-9]+}}, [%rd{{[0-9]+}}]
  %e.load = load atomic volatile float, ptr addrspace(1) %e syncscope("block") seq_cst, align 4
  %e.add = fadd float %e.load, 1.
  ; CHECK: fence.sc.sys
  ; CHECK: st.release.sys.global.b32 [%rd{{[0-9]+}}], %f{{[0-9]+}}
  store atomic volatile float %e.add, ptr addrspace(1) %e syncscope("block") seq_cst, align 4

  ; CHECK: fence.sc.sys
  ; CHECK: ld.acquire.sys.global.b64 %fd{{[0-9]+}}, [%rd{{[0-9]+}}]
  %f.load = load atomic volatile double, ptr addrspace(1) %e syncscope("block") seq_cst, align 8
  %f.add = fadd double %f.load, 1.
  ; CHECK: fence.sc.sys
  ; CHECK: st.release.sys.global.b64 [%rd{{[0-9]+}}], %fd{{[0-9]+}}
  store atomic volatile double %f.add, ptr addrspace(1) %e syncscope("block") seq_cst, align 8

  ret void
}

;; shared statespace

; CHECK-LABEL: shared_unordered_gpu
define void @shared_unordered_gpu(ptr addrspace(3) %a, ptr addrspace(3) %b, ptr addrspace(3) %c, ptr addrspace(3) %d, ptr addrspace(3) %e) local_unnamed_addr {
  ; CHECK: ld.relaxed.gpu.shared.b8 %rs{{[0-9]+}}, [%rd{{[0-9]+}}]
  %a.load = load atomic i8, ptr addrspace(3) %a syncscope("device") unordered, align 1
  %a.add = add i8 %a.load, 1
  ; CHECK: st.relaxed.gpu.shared.b8 [%rd{{[0-9]+}}], %rs{{[0-9]+}}
  store atomic i8 %a.add, ptr addrspace(3) %a syncscope("device") unordered, align 1

  ; CHECK: ld.relaxed.gpu.shared.b16 %rs{{[0-9]+}}, [%rd{{[0-9]+}}]
  %b.load = load atomic i16, ptr addrspace(3) %b syncscope("device") unordered, align 2
  %b.add = add i16 %b.load, 1
  ; CHECK: st.relaxed.gpu.shared.b16 [%rd{{[0-9]+}}], %rs{{[0-9]+}}
  store atomic i16 %b.add, ptr addrspace(3) %b syncscope("device") unordered, align 2

  ; CHECK: ld.relaxed.gpu.shared.b32 %r{{[0-9]+}}, [%rd{{[0-9]+}}]
  %c.load = load atomic i32, ptr addrspace(3) %c syncscope("device") unordered, align 4
  %c.add = add i32 %c.load, 1
  ; CHECK: st.relaxed.gpu.shared.b32 [%rd{{[0-9]+}}], %r{{[0-9]+}}
  store atomic i32 %c.add, ptr addrspace(3) %c syncscope("device") unordered, align 4

  ; CHECK: ld.relaxed.gpu.shared.b64 %rd{{[0-9]+}}, [%rd{{[0-9]+}}]
  %d.load = load atomic i64, ptr addrspace(3) %d syncscope("device") unordered, align 8
  %d.add = add i64 %d.load, 1
  ; CHECK: st.relaxed.gpu.shared.b64 [%rd{{[0-9]+}}], %rd{{[0-9]+}}
  store atomic i64 %d.add, ptr addrspace(3) %d syncscope("device") unordered, align 8

  ; CHECK: ld.relaxed.gpu.shared.b32 %f{{[0-9]+}}, [%rd{{[0-9]+}}]
  %e.load = load atomic float, ptr addrspace(3) %e syncscope("device") unordered, align 4
  %e.add = fadd float %e.load, 1.
  ; CHECK: st.relaxed.gpu.shared.b32 [%rd{{[0-9]+}}], %f{{[0-9]+}}
  store atomic float %e.add, ptr addrspace(3) %e syncscope("device") unordered, align 4

  ; CHECK: ld.relaxed.gpu.shared.b64 %fd{{[0-9]+}}, [%rd{{[0-9]+}}]
  %f.load = load atomic double, ptr addrspace(3) %e syncscope("device") unordered, align 8
  %f.add = fadd double %f.load, 1.
  ; CHECK: st.relaxed.gpu.shared.b64 [%rd{{[0-9]+}}], %fd{{[0-9]+}}
  store atomic double %f.add, ptr addrspace(3) %e syncscope("device") unordered, align 8

  ret void
}

; CHECK-LABEL: shared_unordered_volatile_gpu
define void @shared_unordered_volatile_gpu(ptr addrspace(3) %a, ptr addrspace(3) %b, ptr addrspace(3) %c, ptr addrspace(3) %d, ptr addrspace(3) %e) local_unnamed_addr {
  ; CHECK: ld.volatile.shared.b8 %rs{{[0-9]+}}, [%rd{{[0-9]+}}]
  %a.load = load atomic volatile i8, ptr addrspace(3) %a syncscope("device") unordered, align 1
  %a.add = add i8 %a.load, 1
  ; CHECK: st.volatile.shared.b8 [%rd{{[0-9]+}}], %rs{{[0-9]+}}
  store atomic volatile i8 %a.add, ptr addrspace(3) %a syncscope("device") unordered, align 1

  ; CHECK: ld.volatile.shared.b16 %rs{{[0-9]+}}, [%rd{{[0-9]+}}]
  %b.load = load atomic volatile i16, ptr addrspace(3) %b syncscope("device") unordered, align 2
  %b.add = add i16 %b.load, 1
  ; CHECK: st.volatile.shared.b16 [%rd{{[0-9]+}}], %rs{{[0-9]+}}
  store atomic volatile i16 %b.add, ptr addrspace(3) %b syncscope("device") unordered, align 2

  ; CHECK: ld.volatile.shared.b32 %r{{[0-9]+}}, [%rd{{[0-9]+}}]
  %c.load = load atomic volatile i32, ptr addrspace(3) %c syncscope("device") unordered, align 4
  %c.add = add i32 %c.load, 1
  ; CHECK: st.volatile.shared.b32 [%rd{{[0-9]+}}], %r{{[0-9]+}}
  store atomic volatile i32 %c.add, ptr addrspace(3) %c syncscope("device") unordered, align 4

  ; CHECK: ld.volatile.shared.b64 %rd{{[0-9]+}}, [%rd{{[0-9]+}}]
  %d.load = load atomic volatile i64, ptr addrspace(3) %d syncscope("device") unordered, align 8
  %d.add = add i64 %d.load, 1
  ; CHECK: st.volatile.shared.b64 [%rd{{[0-9]+}}], %rd{{[0-9]+}}
  store atomic volatile i64 %d.add, ptr addrspace(3) %d syncscope("device") unordered, align 8

  ; CHECK: ld.volatile.shared.b32 %f{{[0-9]+}}, [%rd{{[0-9]+}}]
  %e.load = load atomic volatile float, ptr addrspace(3) %e syncscope("device") unordered, align 4
  %e.add = fadd float %e.load, 1.
  ; CHECK: st.volatile.shared.b32 [%rd{{[0-9]+}}], %f{{[0-9]+}}
  store atomic volatile float %e.add, ptr addrspace(3) %e syncscope("device") unordered, align 4

  ; CHECK: ld.volatile.shared.b64 %fd{{[0-9]+}}, [%rd{{[0-9]+}}]
  %f.load = load atomic volatile double, ptr addrspace(3) %e syncscope("device") unordered, align 8
  %f.add = fadd double %f.load, 1.
  ; CHECK: st.volatile.shared.b64 [%rd{{[0-9]+}}], %fd{{[0-9]+}}
  store atomic volatile double %f.add, ptr addrspace(3) %e syncscope("device") unordered, align 8

  ret void
}

; CHECK-LABEL: shared_unordered_cta
define void @shared_unordered_cta(ptr addrspace(3) %a, ptr addrspace(3) %b, ptr addrspace(3) %c, ptr addrspace(3) %d, ptr addrspace(3) %e) local_unnamed_addr {
  ; CHECK: ld.relaxed.cta.shared.b8 %rs{{[0-9]+}}, [%rd{{[0-9]+}}]
  %a.load = load atomic i8, ptr addrspace(3) %a syncscope("block") unordered, align 1
  %a.add = add i8 %a.load, 1
  ; CHECK: st.relaxed.cta.shared.b8 [%rd{{[0-9]+}}], %rs{{[0-9]+}}
  store atomic i8 %a.add, ptr addrspace(3) %a syncscope("block") unordered, align 1

  ; CHECK: ld.relaxed.cta.shared.b16 %rs{{[0-9]+}}, [%rd{{[0-9]+}}]
  %b.load = load atomic i16, ptr addrspace(3) %b syncscope("block") unordered, align 2
  %b.add = add i16 %b.load, 1
  ; CHECK: st.relaxed.cta.shared.b16 [%rd{{[0-9]+}}], %rs{{[0-9]+}}
  store atomic i16 %b.add, ptr addrspace(3) %b syncscope("block") unordered, align 2

  ; CHECK: ld.relaxed.cta.shared.b32 %r{{[0-9]+}}, [%rd{{[0-9]+}}]
  %c.load = load atomic i32, ptr addrspace(3) %c syncscope("block") unordered, align 4
  %c.add = add i32 %c.load, 1
  ; CHECK: st.relaxed.cta.shared.b32 [%rd{{[0-9]+}}], %r{{[0-9]+}}
  store atomic i32 %c.add, ptr addrspace(3) %c syncscope("block") unordered, align 4

  ; CHECK: ld.relaxed.cta.shared.b64 %rd{{[0-9]+}}, [%rd{{[0-9]+}}]
  %d.load = load atomic i64, ptr addrspace(3) %d syncscope("block") unordered, align 8
  %d.add = add i64 %d.load, 1
  ; CHECK: st.relaxed.cta.shared.b64 [%rd{{[0-9]+}}], %rd{{[0-9]+}}
  store atomic i64 %d.add, ptr addrspace(3) %d syncscope("block") unordered, align 8

  ; CHECK: ld.relaxed.cta.shared.b32 %f{{[0-9]+}}, [%rd{{[0-9]+}}]
  %e.load = load atomic float, ptr addrspace(3) %e syncscope("block") unordered, align 4
  %e.add = fadd float %e.load, 1.
  ; CHECK: st.relaxed.cta.shared.b32 [%rd{{[0-9]+}}], %f{{[0-9]+}}
  store atomic float %e.add, ptr addrspace(3) %e syncscope("block") unordered, align 4

  ; CHECK: ld.relaxed.cta.shared.b64 %fd{{[0-9]+}}, [%rd{{[0-9]+}}]
  %f.load = load atomic double, ptr addrspace(3) %e syncscope("block") unordered, align 8
  %f.add = fadd double %f.load, 1.
  ; CHECK: st.relaxed.cta.shared.b64 [%rd{{[0-9]+}}], %fd{{[0-9]+}}
  store atomic double %f.add, ptr addrspace(3) %e syncscope("block") unordered, align 8

  ret void
}

; CHECK-LABEL: shared_unordered_volatile_cta
define void @shared_unordered_volatile_cta(ptr addrspace(3) %a, ptr addrspace(3) %b, ptr addrspace(3) %c, ptr addrspace(3) %d, ptr addrspace(3) %e) local_unnamed_addr {
  ; CHECK: ld.volatile.shared.b8 %rs{{[0-9]+}}, [%rd{{[0-9]+}}]
  %a.load = load atomic volatile i8, ptr addrspace(3) %a syncscope("block") unordered, align 1
  %a.add = add i8 %a.load, 1
  ; CHECK: st.volatile.shared.b8 [%rd{{[0-9]+}}], %rs{{[0-9]+}}
  store atomic volatile i8 %a.add, ptr addrspace(3) %a syncscope("block") unordered, align 1

  ; CHECK: ld.volatile.shared.b16 %rs{{[0-9]+}}, [%rd{{[0-9]+}}]
  %b.load = load atomic volatile i16, ptr addrspace(3) %b syncscope("block") unordered, align 2
  %b.add = add i16 %b.load, 1
  ; CHECK: st.volatile.shared.b16 [%rd{{[0-9]+}}], %rs{{[0-9]+}}
  store atomic volatile i16 %b.add, ptr addrspace(3) %b syncscope("block") unordered, align 2

  ; CHECK: ld.volatile.shared.b32 %r{{[0-9]+}}, [%rd{{[0-9]+}}]
  %c.load = load atomic volatile i32, ptr addrspace(3) %c syncscope("block") unordered, align 4
  %c.add = add i32 %c.load, 1
  ; CHECK: st.volatile.shared.b32 [%rd{{[0-9]+}}], %r{{[0-9]+}}
  store atomic volatile i32 %c.add, ptr addrspace(3) %c syncscope("block") unordered, align 4

  ; CHECK: ld.volatile.shared.b64 %rd{{[0-9]+}}, [%rd{{[0-9]+}}]
  %d.load = load atomic volatile i64, ptr addrspace(3) %d syncscope("block") unordered, align 8
  %d.add = add i64 %d.load, 1
  ; CHECK: st.volatile.shared.b64 [%rd{{[0-9]+}}], %rd{{[0-9]+}}
  store atomic volatile i64 %d.add, ptr addrspace(3) %d syncscope("block") unordered, align 8

  ; CHECK: ld.volatile.shared.b32 %f{{[0-9]+}}, [%rd{{[0-9]+}}]
  %e.load = load atomic volatile float, ptr addrspace(3) %e syncscope("block") unordered, align 4
  %e.add = fadd float %e.load, 1.
  ; CHECK: st.volatile.shared.b32 [%rd{{[0-9]+}}], %f{{[0-9]+}}
  store atomic volatile float %e.add, ptr addrspace(3) %e syncscope("block") unordered, align 4

  ; CHECK: ld.volatile.shared.b64 %fd{{[0-9]+}}, [%rd{{[0-9]+}}]
  %f.load = load atomic volatile double, ptr addrspace(3) %e syncscope("block") unordered, align 8
  %f.add = fadd double %f.load, 1.
  ; CHECK: st.volatile.shared.b64 [%rd{{[0-9]+}}], %fd{{[0-9]+}}
  store atomic volatile double %f.add, ptr addrspace(3) %e syncscope("block") unordered, align 8

  ret void
}

; CHECK-LABEL: shared_monotonic_gpu
define void @shared_monotonic_gpu(ptr addrspace(3) %a, ptr addrspace(3) %b, ptr addrspace(3) %c, ptr addrspace(3) %d, ptr addrspace(3) %e) local_unnamed_addr {
  ; CHECK: ld.relaxed.gpu.shared.b8 %rs{{[0-9]+}}, [%rd{{[0-9]+}}]
  %a.load = load atomic i8, ptr addrspace(3) %a syncscope("device") monotonic, align 1
  %a.add = add i8 %a.load, 1
  ; CHECK: st.relaxed.gpu.shared.b8 [%rd{{[0-9]+}}], %rs{{[0-9]+}}
  store atomic i8 %a.add, ptr addrspace(3) %a syncscope("device") monotonic, align 1

  ; CHECK: ld.relaxed.gpu.shared.b16 %rs{{[0-9]+}}, [%rd{{[0-9]+}}]
  %b.load = load atomic i16, ptr addrspace(3) %b syncscope("device") monotonic, align 2
  %b.add = add i16 %b.load, 1
  ; CHECK: st.relaxed.gpu.shared.b16 [%rd{{[0-9]+}}], %rs{{[0-9]+}}
  store atomic i16 %b.add, ptr addrspace(3) %b syncscope("device") monotonic, align 2

  ; CHECK: ld.relaxed.gpu.shared.b32 %r{{[0-9]+}}, [%rd{{[0-9]+}}]
  %c.load = load atomic i32, ptr addrspace(3) %c syncscope("device") monotonic, align 4
  %c.add = add i32 %c.load, 1
  ; CHECK: st.relaxed.gpu.shared.b32 [%rd{{[0-9]+}}], %r{{[0-9]+}}
  store atomic i32 %c.add, ptr addrspace(3) %c syncscope("device") monotonic, align 4

  ; CHECK: ld.relaxed.gpu.shared.b64 %rd{{[0-9]+}}, [%rd{{[0-9]+}}]
  %d.load = load atomic i64, ptr addrspace(3) %d syncscope("device") monotonic, align 8
  %d.add = add i64 %d.load, 1
  ; CHECK: st.relaxed.gpu.shared.b64 [%rd{{[0-9]+}}], %rd{{[0-9]+}}
  store atomic i64 %d.add, ptr addrspace(3) %d syncscope("device") monotonic, align 8

  ; CHECK: ld.relaxed.gpu.shared.b32 %f{{[0-9]+}}, [%rd{{[0-9]+}}]
  %e.load = load atomic float, ptr addrspace(3) %e syncscope("device") monotonic, align 4
  %e.add = fadd float %e.load, 1.
  ; CHECK: st.relaxed.gpu.shared.b32 [%rd{{[0-9]+}}], %f{{[0-9]+}}
  store atomic float %e.add, ptr addrspace(3) %e syncscope("device") monotonic, align 4

  ; CHECK: ld.relaxed.gpu.shared.b64 %fd{{[0-9]+}}, [%rd{{[0-9]+}}]
  %f.load = load atomic double, ptr addrspace(3) %e syncscope("device") monotonic, align 8
  %f.add = fadd double %f.load, 1.
  ; CHECK: st.relaxed.gpu.shared.b64 [%rd{{[0-9]+}}], %fd{{[0-9]+}}
  store atomic double %f.add, ptr addrspace(3) %e syncscope("device") monotonic, align 8

  ret void
}

; CHECK-LABEL: shared_monotonic_volatile_gpu
define void @shared_monotonic_volatile_gpu(ptr addrspace(3) %a, ptr addrspace(3) %b, ptr addrspace(3) %c, ptr addrspace(3) %d, ptr addrspace(3) %e) local_unnamed_addr {
  ; CHECK: ld.volatile.shared.b8 %rs{{[0-9]+}}, [%rd{{[0-9]+}}]
  %a.load = load atomic volatile i8, ptr addrspace(3) %a syncscope("device") monotonic, align 1
  %a.add = add i8 %a.load, 1
  ; CHECK: st.volatile.shared.b8 [%rd{{[0-9]+}}], %rs{{[0-9]+}}
  store atomic volatile i8 %a.add, ptr addrspace(3) %a syncscope("device") monotonic, align 1

  ; CHECK: ld.volatile.shared.b16 %rs{{[0-9]+}}, [%rd{{[0-9]+}}]
  %b.load = load atomic volatile i16, ptr addrspace(3) %b syncscope("device") monotonic, align 2
  %b.add = add i16 %b.load, 1
  ; CHECK: st.volatile.shared.b16 [%rd{{[0-9]+}}], %rs{{[0-9]+}}
  store atomic volatile i16 %b.add, ptr addrspace(3) %b syncscope("device") monotonic, align 2

  ; CHECK: ld.volatile.shared.b32 %r{{[0-9]+}}, [%rd{{[0-9]+}}]
  %c.load = load atomic volatile i32, ptr addrspace(3) %c syncscope("device") monotonic, align 4
  %c.add = add i32 %c.load, 1
  ; CHECK: st.volatile.shared.b32 [%rd{{[0-9]+}}], %r{{[0-9]+}}
  store atomic volatile i32 %c.add, ptr addrspace(3) %c syncscope("device") monotonic, align 4

  ; CHECK: ld.volatile.shared.b64 %rd{{[0-9]+}}, [%rd{{[0-9]+}}]
  %d.load = load atomic volatile i64, ptr addrspace(3) %d syncscope("device") monotonic, align 8
  %d.add = add i64 %d.load, 1
  ; CHECK: st.volatile.shared.b64 [%rd{{[0-9]+}}], %rd{{[0-9]+}}
  store atomic volatile i64 %d.add, ptr addrspace(3) %d syncscope("device") monotonic, align 8

  ; CHECK: ld.volatile.shared.b32 %f{{[0-9]+}}, [%rd{{[0-9]+}}]
  %e.load = load atomic volatile float, ptr addrspace(3) %e syncscope("device") monotonic, align 4
  %e.add = fadd float %e.load, 1.
  ; CHECK: st.volatile.shared.b32 [%rd{{[0-9]+}}], %f{{[0-9]+}}
  store atomic volatile float %e.add, ptr addrspace(3) %e syncscope("device") monotonic, align 4

  ; CHECK: ld.volatile.shared.b64 %fd{{[0-9]+}}, [%rd{{[0-9]+}}]
  %f.load = load atomic volatile double, ptr addrspace(3) %e syncscope("device") monotonic, align 8
  %f.add = fadd double %f.load, 1.
  ; CHECK: st.volatile.shared.b64 [%rd{{[0-9]+}}], %fd{{[0-9]+}}
  store atomic volatile double %f.add, ptr addrspace(3) %e syncscope("device") monotonic, align 8

  ret void
}

; CHECK-LABEL: shared_monotonic_cta
define void @shared_monotonic_cta(ptr addrspace(3) %a, ptr addrspace(3) %b, ptr addrspace(3) %c, ptr addrspace(3) %d, ptr addrspace(3) %e) local_unnamed_addr {
  ; CHECK: ld.relaxed.cta.shared.b8 %rs{{[0-9]+}}, [%rd{{[0-9]+}}]
  %a.load = load atomic i8, ptr addrspace(3) %a syncscope("block") monotonic, align 1
  %a.add = add i8 %a.load, 1
  ; CHECK: st.relaxed.cta.shared.b8 [%rd{{[0-9]+}}], %rs{{[0-9]+}}
  store atomic i8 %a.add, ptr addrspace(3) %a syncscope("block") monotonic, align 1

  ; CHECK: ld.relaxed.cta.shared.b16 %rs{{[0-9]+}}, [%rd{{[0-9]+}}]
  %b.load = load atomic i16, ptr addrspace(3) %b syncscope("block") monotonic, align 2
  %b.add = add i16 %b.load, 1
  ; CHECK: st.relaxed.cta.shared.b16 [%rd{{[0-9]+}}], %rs{{[0-9]+}}
  store atomic i16 %b.add, ptr addrspace(3) %b syncscope("block") monotonic, align 2

  ; CHECK: ld.relaxed.cta.shared.b32 %r{{[0-9]+}}, [%rd{{[0-9]+}}]
  %c.load = load atomic i32, ptr addrspace(3) %c syncscope("block") monotonic, align 4
  %c.add = add i32 %c.load, 1
  ; CHECK: st.relaxed.cta.shared.b32 [%rd{{[0-9]+}}], %r{{[0-9]+}}
  store atomic i32 %c.add, ptr addrspace(3) %c syncscope("block") monotonic, align 4

  ; CHECK: ld.relaxed.cta.shared.b64 %rd{{[0-9]+}}, [%rd{{[0-9]+}}]
  %d.load = load atomic i64, ptr addrspace(3) %d syncscope("block") monotonic, align 8
  %d.add = add i64 %d.load, 1
  ; CHECK: st.relaxed.cta.shared.b64 [%rd{{[0-9]+}}], %rd{{[0-9]+}}
  store atomic i64 %d.add, ptr addrspace(3) %d syncscope("block") monotonic, align 8

  ; CHECK: ld.relaxed.cta.shared.b32 %f{{[0-9]+}}, [%rd{{[0-9]+}}]
  %e.load = load atomic float, ptr addrspace(3) %e syncscope("block") monotonic, align 4
  %e.add = fadd float %e.load, 1.
  ; CHECK: st.relaxed.cta.shared.b32 [%rd{{[0-9]+}}], %f{{[0-9]+}}
  store atomic float %e.add, ptr addrspace(3) %e syncscope("block") monotonic, align 4

  ; CHECK: ld.relaxed.cta.shared.b64 %fd{{[0-9]+}}, [%rd{{[0-9]+}}]
  %f.load = load atomic double, ptr addrspace(3) %e syncscope("block") monotonic, align 8
  %f.add = fadd double %f.load, 1.
  ; CHECK: st.relaxed.cta.shared.b64 [%rd{{[0-9]+}}], %fd{{[0-9]+}}
  store atomic double %f.add, ptr addrspace(3) %e syncscope("block") monotonic, align 8

  ret void
}

; CHECK-LABEL: shared_monotonic_volatile_cta
define void @shared_monotonic_volatile_cta(ptr addrspace(3) %a, ptr addrspace(3) %b, ptr addrspace(3) %c, ptr addrspace(3) %d, ptr addrspace(3) %e) local_unnamed_addr {
  ; CHECK: ld.volatile.shared.b8 %rs{{[0-9]+}}, [%rd{{[0-9]+}}]
  %a.load = load atomic volatile i8, ptr addrspace(3) %a syncscope("block") monotonic, align 1
  %a.add = add i8 %a.load, 1
  ; CHECK: st.volatile.shared.b8 [%rd{{[0-9]+}}], %rs{{[0-9]+}}
  store atomic volatile i8 %a.add, ptr addrspace(3) %a syncscope("block") monotonic, align 1

  ; CHECK: ld.volatile.shared.b16 %rs{{[0-9]+}}, [%rd{{[0-9]+}}]
  %b.load = load atomic volatile i16, ptr addrspace(3) %b syncscope("block") monotonic, align 2
  %b.add = add i16 %b.load, 1
  ; CHECK: st.volatile.shared.b16 [%rd{{[0-9]+}}], %rs{{[0-9]+}}
  store atomic volatile i16 %b.add, ptr addrspace(3) %b syncscope("block") monotonic, align 2

  ; CHECK: ld.volatile.shared.b32 %r{{[0-9]+}}, [%rd{{[0-9]+}}]
  %c.load = load atomic volatile i32, ptr addrspace(3) %c syncscope("block") monotonic, align 4
  %c.add = add i32 %c.load, 1
  ; CHECK: st.volatile.shared.b32 [%rd{{[0-9]+}}], %r{{[0-9]+}}
  store atomic volatile i32 %c.add, ptr addrspace(3) %c syncscope("block") monotonic, align 4

  ; CHECK: ld.volatile.shared.b64 %rd{{[0-9]+}}, [%rd{{[0-9]+}}]
  %d.load = load atomic volatile i64, ptr addrspace(3) %d syncscope("block") monotonic, align 8
  %d.add = add i64 %d.load, 1
  ; CHECK: st.volatile.shared.b64 [%rd{{[0-9]+}}], %rd{{[0-9]+}}
  store atomic volatile i64 %d.add, ptr addrspace(3) %d syncscope("block") monotonic, align 8

  ; CHECK: ld.volatile.shared.b32 %f{{[0-9]+}}, [%rd{{[0-9]+}}]
  %e.load = load atomic volatile float, ptr addrspace(3) %e syncscope("block") monotonic, align 4
  %e.add = fadd float %e.load, 1.
  ; CHECK: st.volatile.shared.b32 [%rd{{[0-9]+}}], %f{{[0-9]+}}
  store atomic volatile float %e.add, ptr addrspace(3) %e syncscope("block") monotonic, align 4

  ; CHECK: ld.volatile.shared.b64 %fd{{[0-9]+}}, [%rd{{[0-9]+}}]
  %f.load = load atomic volatile double, ptr addrspace(3) %e syncscope("block") monotonic, align 8
  %f.add = fadd double %f.load, 1.
  ; CHECK: st.volatile.shared.b64 [%rd{{[0-9]+}}], %fd{{[0-9]+}}
  store atomic volatile double %f.add, ptr addrspace(3) %e syncscope("block") monotonic, align 8

  ret void
}

; CHECK-LABEL: shared_acq_rel_sys
define void @shared_acq_rel_sys(ptr addrspace(3) %a, ptr addrspace(3) %b, ptr addrspace(3) %c, ptr addrspace(3) %d, ptr addrspace(3) %e) local_unnamed_addr {
  ; CHECK: ld.acquire.sys.shared.b8 %rs{{[0-9]+}}, [%rd{{[0-9]+}}]
  %a.load = load atomic i8, ptr addrspace(3) %a acquire, align 1
  %a.add = add i8 %a.load, 1
  ; CHECK: st.release.sys.shared.b8 [%rd{{[0-9]+}}], %rs{{[0-9]+}}
  store atomic i8 %a.add, ptr addrspace(3) %a release, align 1

  ; CHECK: ld.acquire.sys.shared.b16 %rs{{[0-9]+}}, [%rd{{[0-9]+}}]
  %b.load = load atomic i16, ptr addrspace(3) %b acquire, align 2
  %b.add = add i16 %b.load, 1
  ; CHECK: st.release.sys.shared.b16 [%rd{{[0-9]+}}], %rs{{[0-9]+}}
  store atomic i16 %b.add, ptr addrspace(3) %b release, align 2

  ; CHECK: ld.acquire.sys.shared.b32 %r{{[0-9]+}}, [%rd{{[0-9]+}}]
  %c.load = load atomic i32, ptr addrspace(3) %c acquire, align 4
  %c.add = add i32 %c.load, 1
  ; CHECK: st.release.sys.shared.b32 [%rd{{[0-9]+}}], %r{{[0-9]+}}
  store atomic i32 %c.add, ptr addrspace(3) %c release, align 4

  ; CHECK: ld.acquire.sys.shared.b64 %rd{{[0-9]+}}, [%rd{{[0-9]+}}]
  %d.load = load atomic i64, ptr addrspace(3) %d acquire, align 8
  %d.add = add i64 %d.load, 1
  ; CHECK: st.release.sys.shared.b64 [%rd{{[0-9]+}}], %rd{{[0-9]+}}
  store atomic i64 %d.add, ptr addrspace(3) %d release, align 8

  ; CHECK: ld.acquire.sys.shared.b32 %f{{[0-9]+}}, [%rd{{[0-9]+}}]
  %e.load = load atomic float, ptr addrspace(3) %e acquire, align 4
  %e.add = fadd float %e.load, 1.
  ; CHECK: st.release.sys.shared.b32 [%rd{{[0-9]+}}], %f{{[0-9]+}}
  store atomic float %e.add, ptr addrspace(3) %e release, align 4

  ; CHECK: ld.acquire.sys.shared.b64 %fd{{[0-9]+}}, [%rd{{[0-9]+}}]
  %f.load = load atomic double, ptr addrspace(3) %e acquire, align 8
  %f.add = fadd double %f.load, 1.
  ; CHECK: st.release.sys.shared.b64 [%rd{{[0-9]+}}], %fd{{[0-9]+}}
  store atomic double %f.add, ptr addrspace(3) %e release, align 8

  ret void
}

; CHECK-LABEL: shared_acq_rel_volatile_sys
define void @shared_acq_rel_volatile_sys(ptr addrspace(3) %a, ptr addrspace(3) %b, ptr addrspace(3) %c, ptr addrspace(3) %d, ptr addrspace(3) %e) local_unnamed_addr {
  ; CHECK: ld.acquire.sys.shared.b8 %rs{{[0-9]+}}, [%rd{{[0-9]+}}]
  %a.load = load atomic volatile i8, ptr addrspace(3) %a acquire, align 1
  %a.add = add i8 %a.load, 1
  ; CHECK: st.release.sys.shared.b8 [%rd{{[0-9]+}}], %rs{{[0-9]+}}
  store atomic volatile i8 %a.add, ptr addrspace(3) %a release, align 1

  ; CHECK: ld.acquire.sys.shared.b16 %rs{{[0-9]+}}, [%rd{{[0-9]+}}]
  %b.load = load atomic volatile i16, ptr addrspace(3) %b acquire, align 2
  %b.add = add i16 %b.load, 1
  ; CHECK: st.release.sys.shared.b16 [%rd{{[0-9]+}}], %rs{{[0-9]+}}
  store atomic volatile i16 %b.add, ptr addrspace(3) %b release, align 2

  ; CHECK: ld.acquire.sys.shared.b32 %r{{[0-9]+}}, [%rd{{[0-9]+}}]
  %c.load = load atomic volatile i32, ptr addrspace(3) %c acquire, align 4
  %c.add = add i32 %c.load, 1
  ; CHECK: st.release.sys.shared.b32 [%rd{{[0-9]+}}], %r{{[0-9]+}}
  store atomic volatile i32 %c.add, ptr addrspace(3) %c release, align 4

  ; CHECK: ld.acquire.sys.shared.b64 %rd{{[0-9]+}}, [%rd{{[0-9]+}}]
  %d.load = load atomic volatile i64, ptr addrspace(3) %d acquire, align 8
  %d.add = add i64 %d.load, 1
  ; CHECK: st.release.sys.shared.b64 [%rd{{[0-9]+}}], %rd{{[0-9]+}}
  store atomic volatile i64 %d.add, ptr addrspace(3) %d release, align 8

  ; CHECK: ld.acquire.sys.shared.b32 %f{{[0-9]+}}, [%rd{{[0-9]+}}]
  %e.load = load atomic volatile float, ptr addrspace(3) %e acquire, align 4
  %e.add = fadd float %e.load, 1.
  ; CHECK: st.release.sys.shared.b32 [%rd{{[0-9]+}}], %f{{[0-9]+}}
  store atomic volatile float %e.add, ptr addrspace(3) %e release, align 4

  ; CHECK: ld.acquire.sys.shared.b64 %fd{{[0-9]+}}, [%rd{{[0-9]+}}]
  %f.load = load atomic volatile double, ptr addrspace(3) %e acquire, align 8
  %f.add = fadd double %f.load, 1.
  ; CHECK: st.release.sys.shared.b64 [%rd{{[0-9]+}}], %fd{{[0-9]+}}
  store atomic volatile double %f.add, ptr addrspace(3) %e release, align 8

  ret void
}

; CHECK-LABEL: shared_acq_rel_gpu
define void @shared_acq_rel_gpu(ptr addrspace(3) %a, ptr addrspace(3) %b, ptr addrspace(3) %c, ptr addrspace(3) %d, ptr addrspace(3) %e) local_unnamed_addr {
  ; CHECK: ld.acquire.gpu.shared.b8 %rs{{[0-9]+}}, [%rd{{[0-9]+}}]
  %a.load = load atomic i8, ptr addrspace(3) %a syncscope("device") acquire, align 1
  %a.add = add i8 %a.load, 1
  ; CHECK: st.release.gpu.shared.b8 [%rd{{[0-9]+}}], %rs{{[0-9]+}}
  store atomic i8 %a.add, ptr addrspace(3) %a syncscope("device") release, align 1

  ; CHECK: ld.acquire.gpu.shared.b16 %rs{{[0-9]+}}, [%rd{{[0-9]+}}]
  %b.load = load atomic i16, ptr addrspace(3) %b syncscope("device") acquire, align 2
  %b.add = add i16 %b.load, 1
  ; CHECK: st.release.gpu.shared.b16 [%rd{{[0-9]+}}], %rs{{[0-9]+}}
  store atomic i16 %b.add, ptr addrspace(3) %b syncscope("device") release, align 2

  ; CHECK: ld.acquire.gpu.shared.b32 %r{{[0-9]+}}, [%rd{{[0-9]+}}]
  %c.load = load atomic i32, ptr addrspace(3) %c syncscope("device") acquire, align 4
  %c.add = add i32 %c.load, 1
  ; CHECK: st.release.gpu.shared.b32 [%rd{{[0-9]+}}], %r{{[0-9]+}}
  store atomic i32 %c.add, ptr addrspace(3) %c syncscope("device") release, align 4

  ; CHECK: ld.acquire.gpu.shared.b64 %rd{{[0-9]+}}, [%rd{{[0-9]+}}]
  %d.load = load atomic i64, ptr addrspace(3) %d syncscope("device") acquire, align 8
  %d.add = add i64 %d.load, 1
  ; CHECK: st.release.gpu.shared.b64 [%rd{{[0-9]+}}], %rd{{[0-9]+}}
  store atomic i64 %d.add, ptr addrspace(3) %d syncscope("device") release, align 8

  ; CHECK: ld.acquire.gpu.shared.b32 %f{{[0-9]+}}, [%rd{{[0-9]+}}]
  %e.load = load atomic float, ptr addrspace(3) %e syncscope("device") acquire, align 4
  %e.add = fadd float %e.load, 1.
  ; CHECK: st.release.gpu.shared.b32 [%rd{{[0-9]+}}], %f{{[0-9]+}}
  store atomic float %e.add, ptr addrspace(3) %e syncscope("device") release, align 4

  ; CHECK: ld.acquire.gpu.shared.b64 %fd{{[0-9]+}}, [%rd{{[0-9]+}}]
  %f.load = load atomic double, ptr addrspace(3) %e syncscope("device") acquire, align 8
  %f.add = fadd double %f.load, 1.
  ; CHECK: st.release.gpu.shared.b64 [%rd{{[0-9]+}}], %fd{{[0-9]+}}
  store atomic double %f.add, ptr addrspace(3) %e syncscope("device") release, align 8

  ret void
}

; CHECK-LABEL: shared_acq_rel_volatile_gpu
define void @shared_acq_rel_volatile_gpu(ptr addrspace(3) %a, ptr addrspace(3) %b, ptr addrspace(3) %c, ptr addrspace(3) %d, ptr addrspace(3) %e) local_unnamed_addr {
  ; CHECK: ld.acquire.sys.shared.b8 %rs{{[0-9]+}}, [%rd{{[0-9]+}}]
  %a.load = load atomic volatile i8, ptr addrspace(3) %a syncscope("device") acquire, align 1
  %a.add = add i8 %a.load, 1
  ; CHECK: st.release.sys.shared.b8 [%rd{{[0-9]+}}], %rs{{[0-9]+}}
  store atomic volatile i8 %a.add, ptr addrspace(3) %a syncscope("device") release, align 1

  ; CHECK: ld.acquire.sys.shared.b16 %rs{{[0-9]+}}, [%rd{{[0-9]+}}]
  %b.load = load atomic volatile i16, ptr addrspace(3) %b syncscope("device") acquire, align 2
  %b.add = add i16 %b.load, 1
  ; CHECK: st.release.sys.shared.b16 [%rd{{[0-9]+}}], %rs{{[0-9]+}}
  store atomic volatile i16 %b.add, ptr addrspace(3) %b syncscope("device") release, align 2

  ; CHECK: ld.acquire.sys.shared.b32 %r{{[0-9]+}}, [%rd{{[0-9]+}}]
  %c.load = load atomic volatile i32, ptr addrspace(3) %c syncscope("device") acquire, align 4
  %c.add = add i32 %c.load, 1
  ; CHECK: st.release.sys.shared.b32 [%rd{{[0-9]+}}], %r{{[0-9]+}}
  store atomic volatile i32 %c.add, ptr addrspace(3) %c syncscope("device") release, align 4

  ; CHECK: ld.acquire.sys.shared.b64 %rd{{[0-9]+}}, [%rd{{[0-9]+}}]
  %d.load = load atomic volatile i64, ptr addrspace(3) %d syncscope("device") acquire, align 8
  %d.add = add i64 %d.load, 1
  ; CHECK: st.release.sys.shared.b64 [%rd{{[0-9]+}}], %rd{{[0-9]+}}
  store atomic volatile i64 %d.add, ptr addrspace(3) %d syncscope("device") release, align 8

  ; CHECK: ld.acquire.sys.shared.b32 %f{{[0-9]+}}, [%rd{{[0-9]+}}]
  %e.load = load atomic volatile float, ptr addrspace(3) %e syncscope("device") acquire, align 4
  %e.add = fadd float %e.load, 1.
  ; CHECK: st.release.sys.shared.b32 [%rd{{[0-9]+}}], %f{{[0-9]+}}
  store atomic volatile float %e.add, ptr addrspace(3) %e syncscope("device") release, align 4

  ; CHECK: ld.acquire.sys.shared.b64 %fd{{[0-9]+}}, [%rd{{[0-9]+}}]
  %f.load = load atomic volatile double, ptr addrspace(3) %e syncscope("device") acquire, align 8
  %f.add = fadd double %f.load, 1.
  ; CHECK: st.release.sys.shared.b64 [%rd{{[0-9]+}}], %fd{{[0-9]+}}
  store atomic volatile double %f.add, ptr addrspace(3) %e syncscope("device") release, align 8

  ret void
}

; CHECK-LABEL: shared_acq_rel_cta
define void @shared_acq_rel_cta(ptr addrspace(3) %a, ptr addrspace(3) %b, ptr addrspace(3) %c, ptr addrspace(3) %d, ptr addrspace(3) %e) local_unnamed_addr {
  ; CHECK: ld.acquire.cta.shared.b8 %rs{{[0-9]+}}, [%rd{{[0-9]+}}]
  %a.load = load atomic i8, ptr addrspace(3) %a syncscope("block") acquire, align 1
  %a.add = add i8 %a.load, 1
  ; CHECK: st.release.cta.shared.b8 [%rd{{[0-9]+}}], %rs{{[0-9]+}}
  store atomic i8 %a.add, ptr addrspace(3) %a syncscope("block") release, align 1

  ; CHECK: ld.acquire.cta.shared.b16 %rs{{[0-9]+}}, [%rd{{[0-9]+}}]
  %b.load = load atomic i16, ptr addrspace(3) %b syncscope("block") acquire, align 2
  %b.add = add i16 %b.load, 1
  ; CHECK: st.release.cta.shared.b16 [%rd{{[0-9]+}}], %rs{{[0-9]+}}
  store atomic i16 %b.add, ptr addrspace(3) %b syncscope("block") release, align 2

  ; CHECK: ld.acquire.cta.shared.b32 %r{{[0-9]+}}, [%rd{{[0-9]+}}]
  %c.load = load atomic i32, ptr addrspace(3) %c syncscope("block") acquire, align 4
  %c.add = add i32 %c.load, 1
  ; CHECK: st.release.cta.shared.b32 [%rd{{[0-9]+}}], %r{{[0-9]+}}
  store atomic i32 %c.add, ptr addrspace(3) %c syncscope("block") release, align 4

  ; CHECK: ld.acquire.cta.shared.b64 %rd{{[0-9]+}}, [%rd{{[0-9]+}}]
  %d.load = load atomic i64, ptr addrspace(3) %d syncscope("block") acquire, align 8
  %d.add = add i64 %d.load, 1
  ; CHECK: st.release.cta.shared.b64 [%rd{{[0-9]+}}], %rd{{[0-9]+}}
  store atomic i64 %d.add, ptr addrspace(3) %d syncscope("block") release, align 8

  ; CHECK: ld.acquire.cta.shared.b32 %f{{[0-9]+}}, [%rd{{[0-9]+}}]
  %e.load = load atomic float, ptr addrspace(3) %e syncscope("block") acquire, align 4
  %e.add = fadd float %e.load, 1.
  ; CHECK: st.release.cta.shared.b32 [%rd{{[0-9]+}}], %f{{[0-9]+}}
  store atomic float %e.add, ptr addrspace(3) %e syncscope("block") release, align 4

  ; CHECK: ld.acquire.cta.shared.b64 %fd{{[0-9]+}}, [%rd{{[0-9]+}}]
  %f.load = load atomic double, ptr addrspace(3) %e syncscope("block") acquire, align 8
  %f.add = fadd double %f.load, 1.
  ; CHECK: st.release.cta.shared.b64 [%rd{{[0-9]+}}], %fd{{[0-9]+}}
  store atomic double %f.add, ptr addrspace(3) %e syncscope("block") release, align 8

  ret void
}

; CHECK-LABEL: shared_acq_rel_volatile_cta
define void @shared_acq_rel_volatile_cta(ptr addrspace(3) %a, ptr addrspace(3) %b, ptr addrspace(3) %c, ptr addrspace(3) %d, ptr addrspace(3) %e) local_unnamed_addr {
  ; CHECK: ld.acquire.sys.shared.b8 %rs{{[0-9]+}}, [%rd{{[0-9]+}}]
  %a.load = load atomic volatile i8, ptr addrspace(3) %a syncscope("block") acquire, align 1
  %a.add = add i8 %a.load, 1
  ; CHECK: st.release.sys.shared.b8 [%rd{{[0-9]+}}], %rs{{[0-9]+}}
  store atomic volatile i8 %a.add, ptr addrspace(3) %a syncscope("block") release, align 1

  ; CHECK: ld.acquire.sys.shared.b16 %rs{{[0-9]+}}, [%rd{{[0-9]+}}]
  %b.load = load atomic volatile i16, ptr addrspace(3) %b syncscope("block") acquire, align 2
  %b.add = add i16 %b.load, 1
  ; CHECK: st.release.sys.shared.b16 [%rd{{[0-9]+}}], %rs{{[0-9]+}}
  store atomic volatile i16 %b.add, ptr addrspace(3) %b syncscope("block") release, align 2

  ; CHECK: ld.acquire.sys.shared.b32 %r{{[0-9]+}}, [%rd{{[0-9]+}}]
  %c.load = load atomic volatile i32, ptr addrspace(3) %c syncscope("block") acquire, align 4
  %c.add = add i32 %c.load, 1
  ; CHECK: st.release.sys.shared.b32 [%rd{{[0-9]+}}], %r{{[0-9]+}}
  store atomic volatile i32 %c.add, ptr addrspace(3) %c syncscope("block") release, align 4

  ; CHECK: ld.acquire.sys.shared.b64 %rd{{[0-9]+}}, [%rd{{[0-9]+}}]
  %d.load = load atomic volatile i64, ptr addrspace(3) %d syncscope("block") acquire, align 8
  %d.add = add i64 %d.load, 1
  ; CHECK: st.release.sys.shared.b64 [%rd{{[0-9]+}}], %rd{{[0-9]+}}
  store atomic volatile i64 %d.add, ptr addrspace(3) %d syncscope("block") release, align 8

  ; CHECK: ld.acquire.sys.shared.b32 %f{{[0-9]+}}, [%rd{{[0-9]+}}]
  %e.load = load atomic volatile float, ptr addrspace(3) %e syncscope("block") acquire, align 4
  %e.add = fadd float %e.load, 1.
  ; CHECK: st.release.sys.shared.b32 [%rd{{[0-9]+}}], %f{{[0-9]+}}
  store atomic volatile float %e.add, ptr addrspace(3) %e syncscope("block") release, align 4

  ; CHECK: ld.acquire.sys.shared.b64 %fd{{[0-9]+}}, [%rd{{[0-9]+}}]
  %f.load = load atomic volatile double, ptr addrspace(3) %e syncscope("block") acquire, align 8
  %f.add = fadd double %f.load, 1.
  ; CHECK: st.release.sys.shared.b64 [%rd{{[0-9]+}}], %fd{{[0-9]+}}
  store atomic volatile double %f.add, ptr addrspace(3) %e syncscope("block") release, align 8

  ret void
}

; CHECK-LABEL: shared_seq_cst_sys
define void @shared_seq_cst_sys(ptr addrspace(3) %a, ptr addrspace(3) %b, ptr addrspace(3) %c, ptr addrspace(3) %d, ptr addrspace(3) %e) local_unnamed_addr {
  ; CHECK: fence.sc.sys
  ; CHECK: ld.acquire.sys.shared.b8 %rs{{[0-9]+}}, [%rd{{[0-9]+}}]
  %a.load = load atomic i8, ptr addrspace(3) %a seq_cst, align 1
  %a.add = add i8 %a.load, 1
  ; CHECK: fence.sc.sys
  ; CHECK: st.release.sys.shared.b8 [%rd{{[0-9]+}}], %rs{{[0-9]+}}
  store atomic i8 %a.add, ptr addrspace(3) %a seq_cst, align 1

  ; CHECK: fence.sc.sys
  ; CHECK: ld.acquire.sys.shared.b16 %rs{{[0-9]+}}, [%rd{{[0-9]+}}]
  %b.load = load atomic i16, ptr addrspace(3) %b seq_cst, align 2
  %b.add = add i16 %b.load, 1
  ; CHECK: fence.sc.sys
  ; CHECK: st.release.sys.shared.b16 [%rd{{[0-9]+}}], %rs{{[0-9]+}}
  store atomic i16 %b.add, ptr addrspace(3) %b seq_cst, align 2

  ; CHECK: fence.sc.sys
  ; CHECK: ld.acquire.sys.shared.b32 %r{{[0-9]+}}, [%rd{{[0-9]+}}]
  %c.load = load atomic i32, ptr addrspace(3) %c seq_cst, align 4
  %c.add = add i32 %c.load, 1
  ; CHECK: fence.sc.sys
  ; CHECK: st.release.sys.shared.b32 [%rd{{[0-9]+}}], %r{{[0-9]+}}
  store atomic i32 %c.add, ptr addrspace(3) %c seq_cst, align 4

  ; CHECK: fence.sc.sys
  ; CHECK: ld.acquire.sys.shared.b64 %rd{{[0-9]+}}, [%rd{{[0-9]+}}]
  %d.load = load atomic i64, ptr addrspace(3) %d seq_cst, align 8
  %d.add = add i64 %d.load, 1
  ; CHECK: fence.sc.sys
  ; CHECK: st.release.sys.shared.b64 [%rd{{[0-9]+}}], %rd{{[0-9]+}}
  store atomic i64 %d.add, ptr addrspace(3) %d seq_cst, align 8

  ; CHECK: fence.sc.sys
  ; CHECK: ld.acquire.sys.shared.b32 %f{{[0-9]+}}, [%rd{{[0-9]+}}]
  %e.load = load atomic float, ptr addrspace(3) %e seq_cst, align 4
  %e.add = fadd float %e.load, 1.
  ; CHECK: fence.sc.sys
  ; CHECK: st.release.sys.shared.b32 [%rd{{[0-9]+}}], %f{{[0-9]+}}
  store atomic float %e.add, ptr addrspace(3) %e seq_cst, align 4

  ; CHECK: fence.sc.sys
  ; CHECK: ld.acquire.sys.shared.b64 %fd{{[0-9]+}}, [%rd{{[0-9]+}}]
  %f.load = load atomic double, ptr addrspace(3) %e seq_cst, align 8
  %f.add = fadd double %f.load, 1.
  ; CHECK: fence.sc.sys
  ; CHECK: st.release.sys.shared.b64 [%rd{{[0-9]+}}], %fd{{[0-9]+}}
  store atomic double %f.add, ptr addrspace(3) %e seq_cst, align 8

  ret void
}

; CHECK-LABEL: shared_seq_cst_volatile_sys
define void @shared_seq_cst_volatile_sys(ptr addrspace(3) %a, ptr addrspace(3) %b, ptr addrspace(3) %c, ptr addrspace(3) %d, ptr addrspace(3) %e) local_unnamed_addr {
  ; CHECK: fence.sc.sys
  ; CHECK: ld.acquire.sys.shared.b8 %rs{{[0-9]+}}, [%rd{{[0-9]+}}]
  %a.load = load atomic volatile i8, ptr addrspace(3) %a seq_cst, align 1
  %a.add = add i8 %a.load, 1
  ; CHECK: fence.sc.sys
  ; CHECK: st.release.sys.shared.b8 [%rd{{[0-9]+}}], %rs{{[0-9]+}}
  store atomic volatile i8 %a.add, ptr addrspace(3) %a seq_cst, align 1

  ; CHECK: fence.sc.sys
  ; CHECK: ld.acquire.sys.shared.b16 %rs{{[0-9]+}}, [%rd{{[0-9]+}}]
  %b.load = load atomic volatile i16, ptr addrspace(3) %b seq_cst, align 2
  %b.add = add i16 %b.load, 1
  ; CHECK: fence.sc.sys
  ; CHECK: st.release.sys.shared.b16 [%rd{{[0-9]+}}], %rs{{[0-9]+}}
  store atomic volatile i16 %b.add, ptr addrspace(3) %b seq_cst, align 2

  ; CHECK: fence.sc.sys
  ; CHECK: ld.acquire.sys.shared.b32 %r{{[0-9]+}}, [%rd{{[0-9]+}}]
  %c.load = load atomic volatile i32, ptr addrspace(3) %c seq_cst, align 4
  %c.add = add i32 %c.load, 1
  ; CHECK: fence.sc.sys
  ; CHECK: st.release.sys.shared.b32 [%rd{{[0-9]+}}], %r{{[0-9]+}}
  store atomic volatile i32 %c.add, ptr addrspace(3) %c seq_cst, align 4

  ; CHECK: fence.sc.sys
  ; CHECK: ld.acquire.sys.shared.b64 %rd{{[0-9]+}}, [%rd{{[0-9]+}}]
  %d.load = load atomic volatile i64, ptr addrspace(3) %d seq_cst, align 8
  %d.add = add i64 %d.load, 1
  ; CHECK: fence.sc.sys
  ; CHECK: st.release.sys.shared.b64 [%rd{{[0-9]+}}], %rd{{[0-9]+}}
  store atomic volatile i64 %d.add, ptr addrspace(3) %d seq_cst, align 8

  ; CHECK: fence.sc.sys
  ; CHECK: ld.acquire.sys.shared.b32 %f{{[0-9]+}}, [%rd{{[0-9]+}}]
  %e.load = load atomic volatile float, ptr addrspace(3) %e seq_cst, align 4
  %e.add = fadd float %e.load, 1.
  ; CHECK: fence.sc.sys
  ; CHECK: st.release.sys.shared.b32 [%rd{{[0-9]+}}], %f{{[0-9]+}}
  store atomic volatile float %e.add, ptr addrspace(3) %e seq_cst, align 4

  ; CHECK: fence.sc.sys
  ; CHECK: ld.acquire.sys.shared.b64 %fd{{[0-9]+}}, [%rd{{[0-9]+}}]
  %f.load = load atomic volatile double, ptr addrspace(3) %e seq_cst, align 8
  %f.add = fadd double %f.load, 1.
  ; CHECK: fence.sc.sys
  ; CHECK: st.release.sys.shared.b64 [%rd{{[0-9]+}}], %fd{{[0-9]+}}
  store atomic volatile double %f.add, ptr addrspace(3) %e seq_cst, align 8

  ret void
}

; CHECK-LABEL: shared_seq_cst_gpu
define void @shared_seq_cst_gpu(ptr addrspace(3) %a, ptr addrspace(3) %b, ptr addrspace(3) %c, ptr addrspace(3) %d, ptr addrspace(3) %e) local_unnamed_addr {
  ; CHECK: fence.sc.gpu
  ; CHECK: ld.acquire.gpu.shared.b8 %rs{{[0-9]+}}, [%rd{{[0-9]+}}]
  %a.load = load atomic i8, ptr addrspace(3) %a syncscope("device") seq_cst, align 1
  %a.add = add i8 %a.load, 1
  ; CHECK: fence.sc.gpu
  ; CHECK: st.release.gpu.shared.b8 [%rd{{[0-9]+}}], %rs{{[0-9]+}}
  store atomic i8 %a.add, ptr addrspace(3) %a syncscope("device") seq_cst, align 1

  ; CHECK: fence.sc.gpu
  ; CHECK: ld.acquire.gpu.shared.b16 %rs{{[0-9]+}}, [%rd{{[0-9]+}}]
  %b.load = load atomic i16, ptr addrspace(3) %b syncscope("device") seq_cst, align 2
  %b.add = add i16 %b.load, 1
  ; CHECK: fence.sc.gpu
  ; CHECK: st.release.gpu.shared.b16 [%rd{{[0-9]+}}], %rs{{[0-9]+}}
  store atomic i16 %b.add, ptr addrspace(3) %b syncscope("device") seq_cst, align 2

  ; CHECK: fence.sc.gpu
  ; CHECK: ld.acquire.gpu.shared.b32 %r{{[0-9]+}}, [%rd{{[0-9]+}}]
  %c.load = load atomic i32, ptr addrspace(3) %c syncscope("device") seq_cst, align 4
  %c.add = add i32 %c.load, 1
  ; CHECK: fence.sc.gpu
  ; CHECK: st.release.gpu.shared.b32 [%rd{{[0-9]+}}], %r{{[0-9]+}}
  store atomic i32 %c.add, ptr addrspace(3) %c syncscope("device") seq_cst, align 4

  ; CHECK: fence.sc.gpu
  ; CHECK: ld.acquire.gpu.shared.b64 %rd{{[0-9]+}}, [%rd{{[0-9]+}}]
  %d.load = load atomic i64, ptr addrspace(3) %d syncscope("device") seq_cst, align 8
  %d.add = add i64 %d.load, 1
  ; CHECK: fence.sc.gpu
  ; CHECK: st.release.gpu.shared.b64 [%rd{{[0-9]+}}], %rd{{[0-9]+}}
  store atomic i64 %d.add, ptr addrspace(3) %d syncscope("device") seq_cst, align 8

  ; CHECK: fence.sc.gpu
  ; CHECK: ld.acquire.gpu.shared.b32 %f{{[0-9]+}}, [%rd{{[0-9]+}}]
  %e.load = load atomic float, ptr addrspace(3) %e syncscope("device") seq_cst, align 4
  %e.add = fadd float %e.load, 1.
  ; CHECK: fence.sc.gpu
  ; CHECK: st.release.gpu.shared.b32 [%rd{{[0-9]+}}], %f{{[0-9]+}}
  store atomic float %e.add, ptr addrspace(3) %e syncscope("device") seq_cst, align 4

  ; CHECK: fence.sc.gpu
  ; CHECK: ld.acquire.gpu.shared.b64 %fd{{[0-9]+}}, [%rd{{[0-9]+}}]
  %f.load = load atomic double, ptr addrspace(3) %e syncscope("device") seq_cst, align 8
  %f.add = fadd double %f.load, 1.
  ; CHECK: fence.sc.gpu
  ; CHECK: st.release.gpu.shared.b64 [%rd{{[0-9]+}}], %fd{{[0-9]+}}
  store atomic double %f.add, ptr addrspace(3) %e syncscope("device") seq_cst, align 8

  ret void
}

; CHECK-LABEL: shared_seq_cst_volatile_gpu
define void @shared_seq_cst_volatile_gpu(ptr addrspace(3) %a, ptr addrspace(3) %b, ptr addrspace(3) %c, ptr addrspace(3) %d, ptr addrspace(3) %e) local_unnamed_addr {
  ; CHECK: fence.sc.sys
  ; CHECK: ld.acquire.sys.shared.b8 %rs{{[0-9]+}}, [%rd{{[0-9]+}}]
  %a.load = load atomic volatile i8, ptr addrspace(3) %a syncscope("device") seq_cst, align 1
  %a.add = add i8 %a.load, 1
  ; CHECK: fence.sc.sys
  ; CHECK: st.release.sys.shared.b8 [%rd{{[0-9]+}}], %rs{{[0-9]+}}
  store atomic volatile i8 %a.add, ptr addrspace(3) %a syncscope("device") seq_cst, align 1

  ; CHECK: fence.sc.sys
  ; CHECK: ld.acquire.sys.shared.b16 %rs{{[0-9]+}}, [%rd{{[0-9]+}}]
  %b.load = load atomic volatile i16, ptr addrspace(3) %b syncscope("device") seq_cst, align 2
  %b.add = add i16 %b.load, 1
  ; CHECK: fence.sc.sys
  ; CHECK: st.release.sys.shared.b16 [%rd{{[0-9]+}}], %rs{{[0-9]+}}
  store atomic volatile i16 %b.add, ptr addrspace(3) %b syncscope("device") seq_cst, align 2

  ; CHECK: fence.sc.sys
  ; CHECK: ld.acquire.sys.shared.b32 %r{{[0-9]+}}, [%rd{{[0-9]+}}]
  %c.load = load atomic volatile i32, ptr addrspace(3) %c syncscope("device") seq_cst, align 4
  %c.add = add i32 %c.load, 1
  ; CHECK: fence.sc.sys
  ; CHECK: st.release.sys.shared.b32 [%rd{{[0-9]+}}], %r{{[0-9]+}}
  store atomic volatile i32 %c.add, ptr addrspace(3) %c syncscope("device") seq_cst, align 4

  ; CHECK: fence.sc.sys
  ; CHECK: ld.acquire.sys.shared.b64 %rd{{[0-9]+}}, [%rd{{[0-9]+}}]
  %d.load = load atomic volatile i64, ptr addrspace(3) %d syncscope("device") seq_cst, align 8
  %d.add = add i64 %d.load, 1
  ; CHECK: fence.sc.sys
  ; CHECK: st.release.sys.shared.b64 [%rd{{[0-9]+}}], %rd{{[0-9]+}}
  store atomic volatile i64 %d.add, ptr addrspace(3) %d syncscope("device") seq_cst, align 8

  ; CHECK: fence.sc.sys
  ; CHECK: ld.acquire.sys.shared.b32 %f{{[0-9]+}}, [%rd{{[0-9]+}}]
  %e.load = load atomic volatile float, ptr addrspace(3) %e syncscope("device") seq_cst, align 4
  %e.add = fadd float %e.load, 1.
  ; CHECK: fence.sc.sys
  ; CHECK: st.release.sys.shared.b32 [%rd{{[0-9]+}}], %f{{[0-9]+}}
  store atomic volatile float %e.add, ptr addrspace(3) %e syncscope("device") seq_cst, align 4

  ; CHECK: fence.sc.sys
  ; CHECK: ld.acquire.sys.shared.b64 %fd{{[0-9]+}}, [%rd{{[0-9]+}}]
  %f.load = load atomic volatile double, ptr addrspace(3) %e syncscope("device") seq_cst, align 8
  %f.add = fadd double %f.load, 1.
  ; CHECK: fence.sc.sys
  ; CHECK: st.release.sys.shared.b64 [%rd{{[0-9]+}}], %fd{{[0-9]+}}
  store atomic volatile double %f.add, ptr addrspace(3) %e syncscope("device") seq_cst, align 8

  ret void
}

; CHECK-LABEL: shared_seq_cst_cta
define void @shared_seq_cst_cta(ptr addrspace(3) %a, ptr addrspace(3) %b, ptr addrspace(3) %c, ptr addrspace(3) %d, ptr addrspace(3) %e) local_unnamed_addr {
  ; CHECK: fence.sc.cta
  ; CHECK: ld.acquire.cta.shared.b8 %rs{{[0-9]+}}, [%rd{{[0-9]+}}]
  %a.load = load atomic i8, ptr addrspace(3) %a syncscope("block") seq_cst, align 1
  %a.add = add i8 %a.load, 1
  ; CHECK: fence.sc.cta
  ; CHECK: st.release.cta.shared.b8 [%rd{{[0-9]+}}], %rs{{[0-9]+}}
  store atomic i8 %a.add, ptr addrspace(3) %a syncscope("block") seq_cst, align 1

  ; CHECK: fence.sc.cta
  ; CHECK: ld.acquire.cta.shared.b16 %rs{{[0-9]+}}, [%rd{{[0-9]+}}]
  %b.load = load atomic i16, ptr addrspace(3) %b syncscope("block") seq_cst, align 2
  %b.add = add i16 %b.load, 1
  ; CHECK: fence.sc.cta
  ; CHECK: st.release.cta.shared.b16 [%rd{{[0-9]+}}], %rs{{[0-9]+}}
  store atomic i16 %b.add, ptr addrspace(3) %b syncscope("block") seq_cst, align 2

  ; CHECK: fence.sc.cta
  ; CHECK: ld.acquire.cta.shared.b32 %r{{[0-9]+}}, [%rd{{[0-9]+}}]
  %c.load = load atomic i32, ptr addrspace(3) %c syncscope("block") seq_cst, align 4
  %c.add = add i32 %c.load, 1
  ; CHECK: fence.sc.cta
  ; CHECK: st.release.cta.shared.b32 [%rd{{[0-9]+}}], %r{{[0-9]+}}
  store atomic i32 %c.add, ptr addrspace(3) %c syncscope("block") seq_cst, align 4

  ; CHECK: fence.sc.cta
  ; CHECK: ld.acquire.cta.shared.b64 %rd{{[0-9]+}}, [%rd{{[0-9]+}}]
  %d.load = load atomic i64, ptr addrspace(3) %d syncscope("block") seq_cst, align 8
  %d.add = add i64 %d.load, 1
  ; CHECK: fence.sc.cta
  ; CHECK: st.release.cta.shared.b64 [%rd{{[0-9]+}}], %rd{{[0-9]+}}
  store atomic i64 %d.add, ptr addrspace(3) %d syncscope("block") seq_cst, align 8

  ; CHECK: fence.sc.cta
  ; CHECK: ld.acquire.cta.shared.b32 %f{{[0-9]+}}, [%rd{{[0-9]+}}]
  %e.load = load atomic float, ptr addrspace(3) %e syncscope("block") seq_cst, align 4
  %e.add = fadd float %e.load, 1.
  ; CHECK: fence.sc.cta
  ; CHECK: st.release.cta.shared.b32 [%rd{{[0-9]+}}], %f{{[0-9]+}}
  store atomic float %e.add, ptr addrspace(3) %e syncscope("block") seq_cst, align 4

  ; CHECK: fence.sc.cta
  ; CHECK: ld.acquire.cta.shared.b64 %fd{{[0-9]+}}, [%rd{{[0-9]+}}]
  %f.load = load atomic double, ptr addrspace(3) %e syncscope("block") seq_cst, align 8
  %f.add = fadd double %f.load, 1.
  ; CHECK: fence.sc.cta
  ; CHECK: st.release.cta.shared.b64 [%rd{{[0-9]+}}], %fd{{[0-9]+}}
  store atomic double %f.add, ptr addrspace(3) %e syncscope("block") seq_cst, align 8

  ret void
}

; CHECK-LABEL: shared_seq_cst_volatile_cta
define void @shared_seq_cst_volatile_cta(ptr addrspace(3) %a, ptr addrspace(3) %b, ptr addrspace(3) %c, ptr addrspace(3) %d, ptr addrspace(3) %e) local_unnamed_addr {
  ; CHECK: fence.sc.sys
  ; CHECK: ld.acquire.sys.shared.b8 %rs{{[0-9]+}}, [%rd{{[0-9]+}}]
  %a.load = load atomic volatile i8, ptr addrspace(3) %a syncscope("block") seq_cst, align 1
  %a.add = add i8 %a.load, 1
  ; CHECK: fence.sc.sys
  ; CHECK: st.release.sys.shared.b8 [%rd{{[0-9]+}}], %rs{{[0-9]+}}
  store atomic volatile i8 %a.add, ptr addrspace(3) %a syncscope("block") seq_cst, align 1

  ; CHECK: fence.sc.sys
  ; CHECK: ld.acquire.sys.shared.b16 %rs{{[0-9]+}}, [%rd{{[0-9]+}}]
  %b.load = load atomic volatile i16, ptr addrspace(3) %b syncscope("block") seq_cst, align 2
  %b.add = add i16 %b.load, 1
  ; CHECK: fence.sc.sys
  ; CHECK: st.release.sys.shared.b16 [%rd{{[0-9]+}}], %rs{{[0-9]+}}
  store atomic volatile i16 %b.add, ptr addrspace(3) %b syncscope("block") seq_cst, align 2

  ; CHECK: fence.sc.sys
  ; CHECK: ld.acquire.sys.shared.b32 %r{{[0-9]+}}, [%rd{{[0-9]+}}]
  %c.load = load atomic volatile i32, ptr addrspace(3) %c syncscope("block") seq_cst, align 4
  %c.add = add i32 %c.load, 1
  ; CHECK: fence.sc.sys
  ; CHECK: st.release.sys.shared.b32 [%rd{{[0-9]+}}], %r{{[0-9]+}}
  store atomic volatile i32 %c.add, ptr addrspace(3) %c syncscope("block") seq_cst, align 4

  ; CHECK: fence.sc.sys
  ; CHECK: ld.acquire.sys.shared.b64 %rd{{[0-9]+}}, [%rd{{[0-9]+}}]
  %d.load = load atomic volatile i64, ptr addrspace(3) %d syncscope("block") seq_cst, align 8
  %d.add = add i64 %d.load, 1
  ; CHECK: fence.sc.sys
  ; CHECK: st.release.sys.shared.b64 [%rd{{[0-9]+}}], %rd{{[0-9]+}}
  store atomic volatile i64 %d.add, ptr addrspace(3) %d syncscope("block") seq_cst, align 8

  ; CHECK: fence.sc.sys
  ; CHECK: ld.acquire.sys.shared.b32 %f{{[0-9]+}}, [%rd{{[0-9]+}}]
  %e.load = load atomic volatile float, ptr addrspace(3) %e syncscope("block") seq_cst, align 4
  %e.add = fadd float %e.load, 1.
  ; CHECK: fence.sc.sys
  ; CHECK: st.release.sys.shared.b32 [%rd{{[0-9]+}}], %f{{[0-9]+}}
  store atomic volatile float %e.add, ptr addrspace(3) %e syncscope("block") seq_cst, align 4

  ; CHECK: fence.sc.sys
  ; CHECK: ld.acquire.sys.shared.b64 %fd{{[0-9]+}}, [%rd{{[0-9]+}}]
  %f.load = load atomic volatile double, ptr addrspace(3) %e syncscope("block") seq_cst, align 8
  %f.add = fadd double %f.load, 1.
  ; CHECK: fence.sc.sys
  ; CHECK: st.release.sys.shared.b64 [%rd{{[0-9]+}}], %fd{{[0-9]+}}
  store atomic volatile double %f.add, ptr addrspace(3) %e syncscope("block") seq_cst, align 8

  ret void
}

;; local statespace

; CHECK-LABEL: local_unordered_gpu
define void @local_unordered_gpu(ptr addrspace(5) %a, ptr addrspace(5) %b, ptr addrspace(5) %c, ptr addrspace(5) %d, ptr addrspace(5) %e) local_unnamed_addr {
  ; CHECK: ld.local.b8 %rs{{[0-9]+}}, [%rd{{[0-9]+}}]
  %a.load = load atomic i8, ptr addrspace(5) %a syncscope("device") unordered, align 1
  %a.add = add i8 %a.load, 1
  ; CHECK: st.local.b8 [%rd{{[0-9]+}}], %rs{{[0-9]+}}
  store atomic i8 %a.add, ptr addrspace(5) %a syncscope("device") unordered, align 1

  ; CHECK: ld.local.b16 %rs{{[0-9]+}}, [%rd{{[0-9]+}}]
  %b.load = load atomic i16, ptr addrspace(5) %b syncscope("device") unordered, align 2
  %b.add = add i16 %b.load, 1
  ; CHECK: st.local.b16 [%rd{{[0-9]+}}], %rs{{[0-9]+}}
  store atomic i16 %b.add, ptr addrspace(5) %b syncscope("device") unordered, align 2

  ; CHECK: ld.local.b32 %r{{[0-9]+}}, [%rd{{[0-9]+}}]
  %c.load = load atomic i32, ptr addrspace(5) %c syncscope("device") unordered, align 4
  %c.add = add i32 %c.load, 1
  ; CHECK: st.local.b32 [%rd{{[0-9]+}}], %r{{[0-9]+}}
  store atomic i32 %c.add, ptr addrspace(5) %c syncscope("device") unordered, align 4

  ; CHECK: ld.local.b64 %rd{{[0-9]+}}, [%rd{{[0-9]+}}]
  %d.load = load atomic i64, ptr addrspace(5) %d syncscope("device") unordered, align 8
  %d.add = add i64 %d.load, 1
  ; CHECK: st.local.b64 [%rd{{[0-9]+}}], %rd{{[0-9]+}}
  store atomic i64 %d.add, ptr addrspace(5) %d syncscope("device") unordered, align 8

  ; CHECK: ld.local.b32 %f{{[0-9]+}}, [%rd{{[0-9]+}}]
  %e.load = load atomic float, ptr addrspace(5) %e syncscope("device") unordered, align 4
  %e.add = fadd float %e.load, 1.
  ; CHECK: st.local.b32 [%rd{{[0-9]+}}], %f{{[0-9]+}}
  store atomic float %e.add, ptr addrspace(5) %e syncscope("device") unordered, align 4

  ; CHECK: ld.local.b64 %fd{{[0-9]+}}, [%rd{{[0-9]+}}]
  %f.load = load atomic double, ptr addrspace(5) %e syncscope("device") unordered, align 8
  %f.add = fadd double %f.load, 1.
  ; CHECK: st.local.b64 [%rd{{[0-9]+}}], %fd{{[0-9]+}}
  store atomic double %f.add, ptr addrspace(5) %e syncscope("device") unordered, align 8

  ret void
}

; CHECK-LABEL: local_unordered_volatile_gpu
define void @local_unordered_volatile_gpu(ptr addrspace(5) %a, ptr addrspace(5) %b, ptr addrspace(5) %c, ptr addrspace(5) %d, ptr addrspace(5) %e) local_unnamed_addr {
  ; CHECK: ld.local.b8 %rs{{[0-9]+}}, [%rd{{[0-9]+}}]
  %a.load = load atomic volatile i8, ptr addrspace(5) %a syncscope("device") unordered, align 1
  %a.add = add i8 %a.load, 1
  ; CHECK: st.local.b8 [%rd{{[0-9]+}}], %rs{{[0-9]+}}
  store atomic volatile i8 %a.add, ptr addrspace(5) %a syncscope("device") unordered, align 1

  ; CHECK: ld.local.b16 %rs{{[0-9]+}}, [%rd{{[0-9]+}}]
  %b.load = load atomic volatile i16, ptr addrspace(5) %b syncscope("device") unordered, align 2
  %b.add = add i16 %b.load, 1
  ; CHECK: st.local.b16 [%rd{{[0-9]+}}], %rs{{[0-9]+}}
  store atomic volatile i16 %b.add, ptr addrspace(5) %b syncscope("device") unordered, align 2

  ; CHECK: ld.local.b32 %r{{[0-9]+}}, [%rd{{[0-9]+}}]
  %c.load = load atomic volatile i32, ptr addrspace(5) %c syncscope("device") unordered, align 4
  %c.add = add i32 %c.load, 1
  ; CHECK: st.local.b32 [%rd{{[0-9]+}}], %r{{[0-9]+}}
  store atomic volatile i32 %c.add, ptr addrspace(5) %c syncscope("device") unordered, align 4

  ; CHECK: ld.local.b64 %rd{{[0-9]+}}, [%rd{{[0-9]+}}]
  %d.load = load atomic volatile i64, ptr addrspace(5) %d syncscope("device") unordered, align 8
  %d.add = add i64 %d.load, 1
  ; CHECK: st.local.b64 [%rd{{[0-9]+}}], %rd{{[0-9]+}}
  store atomic volatile i64 %d.add, ptr addrspace(5) %d syncscope("device") unordered, align 8

  ; CHECK: ld.local.b32 %f{{[0-9]+}}, [%rd{{[0-9]+}}]
  %e.load = load atomic volatile float, ptr addrspace(5) %e syncscope("device") unordered, align 4
  %e.add = fadd float %e.load, 1.
  ; CHECK: st.local.b32 [%rd{{[0-9]+}}], %f{{[0-9]+}}
  store atomic volatile float %e.add, ptr addrspace(5) %e syncscope("device") unordered, align 4

  ; CHECK: ld.local.b64 %fd{{[0-9]+}}, [%rd{{[0-9]+}}]
  %f.load = load atomic volatile double, ptr addrspace(5) %e syncscope("device") unordered, align 8
  %f.add = fadd double %f.load, 1.
  ; CHECK: st.local.b64 [%rd{{[0-9]+}}], %fd{{[0-9]+}}
  store atomic volatile double %f.add, ptr addrspace(5) %e syncscope("device") unordered, align 8

  ret void
}

; CHECK-LABEL: local_unordered_cta
define void @local_unordered_cta(ptr addrspace(5) %a, ptr addrspace(5) %b, ptr addrspace(5) %c, ptr addrspace(5) %d, ptr addrspace(5) %e) local_unnamed_addr {
  ; CHECK: ld.local.b8 %rs{{[0-9]+}}, [%rd{{[0-9]+}}]
  %a.load = load atomic i8, ptr addrspace(5) %a syncscope("block") unordered, align 1
  %a.add = add i8 %a.load, 1
  ; CHECK: st.local.b8 [%rd{{[0-9]+}}], %rs{{[0-9]+}}
  store atomic i8 %a.add, ptr addrspace(5) %a syncscope("block") unordered, align 1

  ; CHECK: ld.local.b16 %rs{{[0-9]+}}, [%rd{{[0-9]+}}]
  %b.load = load atomic i16, ptr addrspace(5) %b syncscope("block") unordered, align 2
  %b.add = add i16 %b.load, 1
  ; CHECK: st.local.b16 [%rd{{[0-9]+}}], %rs{{[0-9]+}}
  store atomic i16 %b.add, ptr addrspace(5) %b syncscope("block") unordered, align 2

  ; CHECK: ld.local.b32 %r{{[0-9]+}}, [%rd{{[0-9]+}}]
  %c.load = load atomic i32, ptr addrspace(5) %c syncscope("block") unordered, align 4
  %c.add = add i32 %c.load, 1
  ; CHECK: st.local.b32 [%rd{{[0-9]+}}], %r{{[0-9]+}}
  store atomic i32 %c.add, ptr addrspace(5) %c syncscope("block") unordered, align 4

  ; CHECK: ld.local.b64 %rd{{[0-9]+}}, [%rd{{[0-9]+}}]
  %d.load = load atomic i64, ptr addrspace(5) %d syncscope("block") unordered, align 8
  %d.add = add i64 %d.load, 1
  ; CHECK: st.local.b64 [%rd{{[0-9]+}}], %rd{{[0-9]+}}
  store atomic i64 %d.add, ptr addrspace(5) %d syncscope("block") unordered, align 8

  ; CHECK: ld.local.b32 %f{{[0-9]+}}, [%rd{{[0-9]+}}]
  %e.load = load atomic float, ptr addrspace(5) %e syncscope("block") unordered, align 4
  %e.add = fadd float %e.load, 1.
  ; CHECK: st.local.b32 [%rd{{[0-9]+}}], %f{{[0-9]+}}
  store atomic float %e.add, ptr addrspace(5) %e syncscope("block") unordered, align 4

  ; CHECK: ld.local.b64 %fd{{[0-9]+}}, [%rd{{[0-9]+}}]
  %f.load = load atomic double, ptr addrspace(5) %e syncscope("block") unordered, align 8
  %f.add = fadd double %f.load, 1.
  ; CHECK: st.local.b64 [%rd{{[0-9]+}}], %fd{{[0-9]+}}
  store atomic double %f.add, ptr addrspace(5) %e syncscope("block") unordered, align 8

  ret void
}

; CHECK-LABEL: local_unordered_volatile_cta
define void @local_unordered_volatile_cta(ptr addrspace(5) %a, ptr addrspace(5) %b, ptr addrspace(5) %c, ptr addrspace(5) %d, ptr addrspace(5) %e) local_unnamed_addr {
  ; CHECK: ld.local.b8 %rs{{[0-9]+}}, [%rd{{[0-9]+}}]
  %a.load = load atomic volatile i8, ptr addrspace(5) %a syncscope("block") unordered, align 1
  %a.add = add i8 %a.load, 1
  ; CHECK: st.local.b8 [%rd{{[0-9]+}}], %rs{{[0-9]+}}
  store atomic volatile i8 %a.add, ptr addrspace(5) %a syncscope("block") unordered, align 1

  ; CHECK: ld.local.b16 %rs{{[0-9]+}}, [%rd{{[0-9]+}}]
  %b.load = load atomic volatile i16, ptr addrspace(5) %b syncscope("block") unordered, align 2
  %b.add = add i16 %b.load, 1
  ; CHECK: st.local.b16 [%rd{{[0-9]+}}], %rs{{[0-9]+}}
  store atomic volatile i16 %b.add, ptr addrspace(5) %b syncscope("block") unordered, align 2

  ; CHECK: ld.local.b32 %r{{[0-9]+}}, [%rd{{[0-9]+}}]
  %c.load = load atomic volatile i32, ptr addrspace(5) %c syncscope("block") unordered, align 4
  %c.add = add i32 %c.load, 1
  ; CHECK: st.local.b32 [%rd{{[0-9]+}}], %r{{[0-9]+}}
  store atomic volatile i32 %c.add, ptr addrspace(5) %c syncscope("block") unordered, align 4

  ; CHECK: ld.local.b64 %rd{{[0-9]+}}, [%rd{{[0-9]+}}]
  %d.load = load atomic volatile i64, ptr addrspace(5) %d syncscope("block") unordered, align 8
  %d.add = add i64 %d.load, 1
  ; CHECK: st.local.b64 [%rd{{[0-9]+}}], %rd{{[0-9]+}}
  store atomic volatile i64 %d.add, ptr addrspace(5) %d syncscope("block") unordered, align 8

  ; CHECK: ld.local.b32 %f{{[0-9]+}}, [%rd{{[0-9]+}}]
  %e.load = load atomic volatile float, ptr addrspace(5) %e syncscope("block") unordered, align 4
  %e.add = fadd float %e.load, 1.
  ; CHECK: st.local.b32 [%rd{{[0-9]+}}], %f{{[0-9]+}}
  store atomic volatile float %e.add, ptr addrspace(5) %e syncscope("block") unordered, align 4

  ; CHECK: ld.local.b64 %fd{{[0-9]+}}, [%rd{{[0-9]+}}]
  %f.load = load atomic volatile double, ptr addrspace(5) %e syncscope("block") unordered, align 8
  %f.add = fadd double %f.load, 1.
  ; CHECK: st.local.b64 [%rd{{[0-9]+}}], %fd{{[0-9]+}}
  store atomic volatile double %f.add, ptr addrspace(5) %e syncscope("block") unordered, align 8

  ret void
}

; CHECK-LABEL: local_monotonic_gpu
define void @local_monotonic_gpu(ptr addrspace(5) %a, ptr addrspace(5) %b, ptr addrspace(5) %c, ptr addrspace(5) %d, ptr addrspace(5) %e) local_unnamed_addr {
  ; CHECK: ld.local.b8 %rs{{[0-9]+}}, [%rd{{[0-9]+}}]
  %a.load = load atomic i8, ptr addrspace(5) %a syncscope("device") monotonic, align 1
  %a.add = add i8 %a.load, 1
  ; CHECK: st.local.b8 [%rd{{[0-9]+}}], %rs{{[0-9]+}}
  store atomic i8 %a.add, ptr addrspace(5) %a syncscope("device") monotonic, align 1

  ; CHECK: ld.local.b16 %rs{{[0-9]+}}, [%rd{{[0-9]+}}]
  %b.load = load atomic i16, ptr addrspace(5) %b syncscope("device") monotonic, align 2
  %b.add = add i16 %b.load, 1
  ; CHECK: st.local.b16 [%rd{{[0-9]+}}], %rs{{[0-9]+}}
  store atomic i16 %b.add, ptr addrspace(5) %b syncscope("device") monotonic, align 2

  ; CHECK: ld.local.b32 %r{{[0-9]+}}, [%rd{{[0-9]+}}]
  %c.load = load atomic i32, ptr addrspace(5) %c syncscope("device") monotonic, align 4
  %c.add = add i32 %c.load, 1
  ; CHECK: st.local.b32 [%rd{{[0-9]+}}], %r{{[0-9]+}}
  store atomic i32 %c.add, ptr addrspace(5) %c syncscope("device") monotonic, align 4

  ; CHECK: ld.local.b64 %rd{{[0-9]+}}, [%rd{{[0-9]+}}]
  %d.load = load atomic i64, ptr addrspace(5) %d syncscope("device") monotonic, align 8
  %d.add = add i64 %d.load, 1
  ; CHECK: st.local.b64 [%rd{{[0-9]+}}], %rd{{[0-9]+}}
  store atomic i64 %d.add, ptr addrspace(5) %d syncscope("device") monotonic, align 8

  ; CHECK: ld.local.b32 %f{{[0-9]+}}, [%rd{{[0-9]+}}]
  %e.load = load atomic float, ptr addrspace(5) %e syncscope("device") monotonic, align 4
  %e.add = fadd float %e.load, 1.
  ; CHECK: st.local.b32 [%rd{{[0-9]+}}], %f{{[0-9]+}}
  store atomic float %e.add, ptr addrspace(5) %e syncscope("device") monotonic, align 4

  ; CHECK: ld.local.b64 %fd{{[0-9]+}}, [%rd{{[0-9]+}}]
  %f.load = load atomic double, ptr addrspace(5) %e syncscope("device") monotonic, align 8
  %f.add = fadd double %f.load, 1.
  ; CHECK: st.local.b64 [%rd{{[0-9]+}}], %fd{{[0-9]+}}
  store atomic double %f.add, ptr addrspace(5) %e syncscope("device") monotonic, align 8

  ret void
}

; CHECK-LABEL: local_monotonic_volatile_gpu
define void @local_monotonic_volatile_gpu(ptr addrspace(5) %a, ptr addrspace(5) %b, ptr addrspace(5) %c, ptr addrspace(5) %d, ptr addrspace(5) %e) local_unnamed_addr {
  ; CHECK: ld.local.b8 %rs{{[0-9]+}}, [%rd{{[0-9]+}}]
  %a.load = load atomic volatile i8, ptr addrspace(5) %a syncscope("device") monotonic, align 1
  %a.add = add i8 %a.load, 1
  ; CHECK: st.local.b8 [%rd{{[0-9]+}}], %rs{{[0-9]+}}
  store atomic volatile i8 %a.add, ptr addrspace(5) %a syncscope("device") monotonic, align 1

  ; CHECK: ld.local.b16 %rs{{[0-9]+}}, [%rd{{[0-9]+}}]
  %b.load = load atomic volatile i16, ptr addrspace(5) %b syncscope("device") monotonic, align 2
  %b.add = add i16 %b.load, 1
  ; CHECK: st.local.b16 [%rd{{[0-9]+}}], %rs{{[0-9]+}}
  store atomic volatile i16 %b.add, ptr addrspace(5) %b syncscope("device") monotonic, align 2

  ; CHECK: ld.local.b32 %r{{[0-9]+}}, [%rd{{[0-9]+}}]
  %c.load = load atomic volatile i32, ptr addrspace(5) %c syncscope("device") monotonic, align 4
  %c.add = add i32 %c.load, 1
  ; CHECK: st.local.b32 [%rd{{[0-9]+}}], %r{{[0-9]+}}
  store atomic volatile i32 %c.add, ptr addrspace(5) %c syncscope("device") monotonic, align 4

  ; CHECK: ld.local.b64 %rd{{[0-9]+}}, [%rd{{[0-9]+}}]
  %d.load = load atomic volatile i64, ptr addrspace(5) %d syncscope("device") monotonic, align 8
  %d.add = add i64 %d.load, 1
  ; CHECK: st.local.b64 [%rd{{[0-9]+}}], %rd{{[0-9]+}}
  store atomic volatile i64 %d.add, ptr addrspace(5) %d syncscope("device") monotonic, align 8

  ; CHECK: ld.local.b32 %f{{[0-9]+}}, [%rd{{[0-9]+}}]
  %e.load = load atomic volatile float, ptr addrspace(5) %e syncscope("device") monotonic, align 4
  %e.add = fadd float %e.load, 1.
  ; CHECK: st.local.b32 [%rd{{[0-9]+}}], %f{{[0-9]+}}
  store atomic volatile float %e.add, ptr addrspace(5) %e syncscope("device") monotonic, align 4

  ; CHECK: ld.local.b64 %fd{{[0-9]+}}, [%rd{{[0-9]+}}]
  %f.load = load atomic volatile double, ptr addrspace(5) %e syncscope("device") monotonic, align 8
  %f.add = fadd double %f.load, 1.
  ; CHECK: st.local.b64 [%rd{{[0-9]+}}], %fd{{[0-9]+}}
  store atomic volatile double %f.add, ptr addrspace(5) %e syncscope("device") monotonic, align 8

  ret void
}

; CHECK-LABEL: local_monotonic_cta
define void @local_monotonic_cta(ptr addrspace(5) %a, ptr addrspace(5) %b, ptr addrspace(5) %c, ptr addrspace(5) %d, ptr addrspace(5) %e) local_unnamed_addr {
  ; CHECK: ld.local.b8 %rs{{[0-9]+}}, [%rd{{[0-9]+}}]
  %a.load = load atomic i8, ptr addrspace(5) %a syncscope("block") monotonic, align 1
  %a.add = add i8 %a.load, 1
  ; CHECK: st.local.b8 [%rd{{[0-9]+}}], %rs{{[0-9]+}}
  store atomic i8 %a.add, ptr addrspace(5) %a syncscope("block") monotonic, align 1

  ; CHECK: ld.local.b16 %rs{{[0-9]+}}, [%rd{{[0-9]+}}]
  %b.load = load atomic i16, ptr addrspace(5) %b syncscope("block") monotonic, align 2
  %b.add = add i16 %b.load, 1
  ; CHECK: st.local.b16 [%rd{{[0-9]+}}], %rs{{[0-9]+}}
  store atomic i16 %b.add, ptr addrspace(5) %b syncscope("block") monotonic, align 2

  ; CHECK: ld.local.b32 %r{{[0-9]+}}, [%rd{{[0-9]+}}]
  %c.load = load atomic i32, ptr addrspace(5) %c syncscope("block") monotonic, align 4
  %c.add = add i32 %c.load, 1
  ; CHECK: st.local.b32 [%rd{{[0-9]+}}], %r{{[0-9]+}}
  store atomic i32 %c.add, ptr addrspace(5) %c syncscope("block") monotonic, align 4

  ; CHECK: ld.local.b64 %rd{{[0-9]+}}, [%rd{{[0-9]+}}]
  %d.load = load atomic i64, ptr addrspace(5) %d syncscope("block") monotonic, align 8
  %d.add = add i64 %d.load, 1
  ; CHECK: st.local.b64 [%rd{{[0-9]+}}], %rd{{[0-9]+}}
  store atomic i64 %d.add, ptr addrspace(5) %d syncscope("block") monotonic, align 8

  ; CHECK: ld.local.b32 %f{{[0-9]+}}, [%rd{{[0-9]+}}]
  %e.load = load atomic float, ptr addrspace(5) %e syncscope("block") monotonic, align 4
  %e.add = fadd float %e.load, 1.
  ; CHECK: st.local.b32 [%rd{{[0-9]+}}], %f{{[0-9]+}}
  store atomic float %e.add, ptr addrspace(5) %e syncscope("block") monotonic, align 4

  ; CHECK: ld.local.b64 %fd{{[0-9]+}}, [%rd{{[0-9]+}}]
  %f.load = load atomic double, ptr addrspace(5) %e syncscope("block") monotonic, align 8
  %f.add = fadd double %f.load, 1.
  ; CHECK: st.local.b64 [%rd{{[0-9]+}}], %fd{{[0-9]+}}
  store atomic double %f.add, ptr addrspace(5) %e syncscope("block") monotonic, align 8

  ret void
}

; CHECK-LABEL: local_monotonic_volatile_cta
define void @local_monotonic_volatile_cta(ptr addrspace(5) %a, ptr addrspace(5) %b, ptr addrspace(5) %c, ptr addrspace(5) %d, ptr addrspace(5) %e) local_unnamed_addr {
  ; CHECK: ld.local.b8 %rs{{[0-9]+}}, [%rd{{[0-9]+}}]
  %a.load = load atomic volatile i8, ptr addrspace(5) %a syncscope("block") monotonic, align 1
  %a.add = add i8 %a.load, 1
  ; CHECK: st.local.b8 [%rd{{[0-9]+}}], %rs{{[0-9]+}}
  store atomic volatile i8 %a.add, ptr addrspace(5) %a syncscope("block") monotonic, align 1

  ; CHECK: ld.local.b16 %rs{{[0-9]+}}, [%rd{{[0-9]+}}]
  %b.load = load atomic volatile i16, ptr addrspace(5) %b syncscope("block") monotonic, align 2
  %b.add = add i16 %b.load, 1
  ; CHECK: st.local.b16 [%rd{{[0-9]+}}], %rs{{[0-9]+}}
  store atomic volatile i16 %b.add, ptr addrspace(5) %b syncscope("block") monotonic, align 2

  ; CHECK: ld.local.b32 %r{{[0-9]+}}, [%rd{{[0-9]+}}]
  %c.load = load atomic volatile i32, ptr addrspace(5) %c syncscope("block") monotonic, align 4
  %c.add = add i32 %c.load, 1
  ; CHECK: st.local.b32 [%rd{{[0-9]+}}], %r{{[0-9]+}}
  store atomic volatile i32 %c.add, ptr addrspace(5) %c syncscope("block") monotonic, align 4

  ; CHECK: ld.local.b64 %rd{{[0-9]+}}, [%rd{{[0-9]+}}]
  %d.load = load atomic volatile i64, ptr addrspace(5) %d syncscope("block") monotonic, align 8
  %d.add = add i64 %d.load, 1
  ; CHECK: st.local.b64 [%rd{{[0-9]+}}], %rd{{[0-9]+}}
  store atomic volatile i64 %d.add, ptr addrspace(5) %d syncscope("block") monotonic, align 8

  ; CHECK: ld.local.b32 %f{{[0-9]+}}, [%rd{{[0-9]+}}]
  %e.load = load atomic volatile float, ptr addrspace(5) %e syncscope("block") monotonic, align 4
  %e.add = fadd float %e.load, 1.
  ; CHECK: st.local.b32 [%rd{{[0-9]+}}], %f{{[0-9]+}}
  store atomic volatile float %e.add, ptr addrspace(5) %e syncscope("block") monotonic, align 4

  ; CHECK: ld.local.b64 %fd{{[0-9]+}}, [%rd{{[0-9]+}}]
  %f.load = load atomic volatile double, ptr addrspace(5) %e syncscope("block") monotonic, align 8
  %f.add = fadd double %f.load, 1.
  ; CHECK: st.local.b64 [%rd{{[0-9]+}}], %fd{{[0-9]+}}
  store atomic volatile double %f.add, ptr addrspace(5) %e syncscope("block") monotonic, align 8

  ret void
}

; CHECK-LABEL: local_acq_rel_sys
define void @local_acq_rel_sys(ptr addrspace(5) %a, ptr addrspace(5) %b, ptr addrspace(5) %c, ptr addrspace(5) %d, ptr addrspace(5) %e) local_unnamed_addr {
  ; CHECK: ld.local.b8 %rs{{[0-9]+}}, [%rd{{[0-9]+}}]
  %a.load = load atomic i8, ptr addrspace(5) %a acquire, align 1
  %a.add = add i8 %a.load, 1
  ; CHECK: st.local.b8 [%rd{{[0-9]+}}], %rs{{[0-9]+}}
  store atomic i8 %a.add, ptr addrspace(5) %a release, align 1

  ; CHECK: ld.local.b16 %rs{{[0-9]+}}, [%rd{{[0-9]+}}]
  %b.load = load atomic i16, ptr addrspace(5) %b acquire, align 2
  %b.add = add i16 %b.load, 1
  ; CHECK: st.local.b16 [%rd{{[0-9]+}}], %rs{{[0-9]+}}
  store atomic i16 %b.add, ptr addrspace(5) %b release, align 2

  ; CHECK: ld.local.b32 %r{{[0-9]+}}, [%rd{{[0-9]+}}]
  %c.load = load atomic i32, ptr addrspace(5) %c acquire, align 4
  %c.add = add i32 %c.load, 1
  ; CHECK: st.local.b32 [%rd{{[0-9]+}}], %r{{[0-9]+}}
  store atomic i32 %c.add, ptr addrspace(5) %c release, align 4

  ; CHECK: ld.local.b64 %rd{{[0-9]+}}, [%rd{{[0-9]+}}]
  %d.load = load atomic i64, ptr addrspace(5) %d acquire, align 8
  %d.add = add i64 %d.load, 1
  ; CHECK: st.local.b64 [%rd{{[0-9]+}}], %rd{{[0-9]+}}
  store atomic i64 %d.add, ptr addrspace(5) %d release, align 8

  ; CHECK: ld.local.b32 %f{{[0-9]+}}, [%rd{{[0-9]+}}]
  %e.load = load atomic float, ptr addrspace(5) %e acquire, align 4
  %e.add = fadd float %e.load, 1.
  ; CHECK: st.local.b32 [%rd{{[0-9]+}}], %f{{[0-9]+}}
  store atomic float %e.add, ptr addrspace(5) %e release, align 4

  ; CHECK: ld.local.b64 %fd{{[0-9]+}}, [%rd{{[0-9]+}}]
  %f.load = load atomic double, ptr addrspace(5) %e acquire, align 8
  %f.add = fadd double %f.load, 1.
  ; CHECK: st.local.b64 [%rd{{[0-9]+}}], %fd{{[0-9]+}}
  store atomic double %f.add, ptr addrspace(5) %e release, align 8

  ret void
}

; CHECK-LABEL: local_acq_rel_volatile_sys
define void @local_acq_rel_volatile_sys(ptr addrspace(5) %a, ptr addrspace(5) %b, ptr addrspace(5) %c, ptr addrspace(5) %d, ptr addrspace(5) %e) local_unnamed_addr {
  ; CHECK: ld.local.b8 %rs{{[0-9]+}}, [%rd{{[0-9]+}}]
  %a.load = load atomic volatile i8, ptr addrspace(5) %a acquire, align 1
  %a.add = add i8 %a.load, 1
  ; CHECK: st.local.b8 [%rd{{[0-9]+}}], %rs{{[0-9]+}}
  store atomic volatile i8 %a.add, ptr addrspace(5) %a release, align 1

  ; CHECK: ld.local.b16 %rs{{[0-9]+}}, [%rd{{[0-9]+}}]
  %b.load = load atomic volatile i16, ptr addrspace(5) %b acquire, align 2
  %b.add = add i16 %b.load, 1
  ; CHECK: st.local.b16 [%rd{{[0-9]+}}], %rs{{[0-9]+}}
  store atomic volatile i16 %b.add, ptr addrspace(5) %b release, align 2

  ; CHECK: ld.local.b32 %r{{[0-9]+}}, [%rd{{[0-9]+}}]
  %c.load = load atomic volatile i32, ptr addrspace(5) %c acquire, align 4
  %c.add = add i32 %c.load, 1
  ; CHECK: st.local.b32 [%rd{{[0-9]+}}], %r{{[0-9]+}}
  store atomic volatile i32 %c.add, ptr addrspace(5) %c release, align 4

  ; CHECK: ld.local.b64 %rd{{[0-9]+}}, [%rd{{[0-9]+}}]
  %d.load = load atomic volatile i64, ptr addrspace(5) %d acquire, align 8
  %d.add = add i64 %d.load, 1
  ; CHECK: st.local.b64 [%rd{{[0-9]+}}], %rd{{[0-9]+}}
  store atomic volatile i64 %d.add, ptr addrspace(5) %d release, align 8

  ; CHECK: ld.local.b32 %f{{[0-9]+}}, [%rd{{[0-9]+}}]
  %e.load = load atomic volatile float, ptr addrspace(5) %e acquire, align 4
  %e.add = fadd float %e.load, 1.
  ; CHECK: st.local.b32 [%rd{{[0-9]+}}], %f{{[0-9]+}}
  store atomic volatile float %e.add, ptr addrspace(5) %e release, align 4

  ; CHECK: ld.local.b64 %fd{{[0-9]+}}, [%rd{{[0-9]+}}]
  %f.load = load atomic volatile double, ptr addrspace(5) %e acquire, align 8
  %f.add = fadd double %f.load, 1.
  ; CHECK: st.local.b64 [%rd{{[0-9]+}}], %fd{{[0-9]+}}
  store atomic volatile double %f.add, ptr addrspace(5) %e release, align 8

  ret void
}

; CHECK-LABEL: local_acq_rel_gpu
define void @local_acq_rel_gpu(ptr addrspace(5) %a, ptr addrspace(5) %b, ptr addrspace(5) %c, ptr addrspace(5) %d, ptr addrspace(5) %e) local_unnamed_addr {
  ; CHECK: ld.local.b8 %rs{{[0-9]+}}, [%rd{{[0-9]+}}]
  %a.load = load atomic i8, ptr addrspace(5) %a syncscope("device") acquire, align 1
  %a.add = add i8 %a.load, 1
  ; CHECK: st.local.b8 [%rd{{[0-9]+}}], %rs{{[0-9]+}}
  store atomic i8 %a.add, ptr addrspace(5) %a syncscope("device") release, align 1

  ; CHECK: ld.local.b16 %rs{{[0-9]+}}, [%rd{{[0-9]+}}]
  %b.load = load atomic i16, ptr addrspace(5) %b syncscope("device") acquire, align 2
  %b.add = add i16 %b.load, 1
  ; CHECK: st.local.b16 [%rd{{[0-9]+}}], %rs{{[0-9]+}}
  store atomic i16 %b.add, ptr addrspace(5) %b syncscope("device") release, align 2

  ; CHECK: ld.local.b32 %r{{[0-9]+}}, [%rd{{[0-9]+}}]
  %c.load = load atomic i32, ptr addrspace(5) %c syncscope("device") acquire, align 4
  %c.add = add i32 %c.load, 1
  ; CHECK: st.local.b32 [%rd{{[0-9]+}}], %r{{[0-9]+}}
  store atomic i32 %c.add, ptr addrspace(5) %c syncscope("device") release, align 4

  ; CHECK: ld.local.b64 %rd{{[0-9]+}}, [%rd{{[0-9]+}}]
  %d.load = load atomic i64, ptr addrspace(5) %d syncscope("device") acquire, align 8
  %d.add = add i64 %d.load, 1
  ; CHECK: st.local.b64 [%rd{{[0-9]+}}], %rd{{[0-9]+}}
  store atomic i64 %d.add, ptr addrspace(5) %d syncscope("device") release, align 8

  ; CHECK: ld.local.b32 %f{{[0-9]+}}, [%rd{{[0-9]+}}]
  %e.load = load atomic float, ptr addrspace(5) %e syncscope("device") acquire, align 4
  %e.add = fadd float %e.load, 1.
  ; CHECK: st.local.b32 [%rd{{[0-9]+}}], %f{{[0-9]+}}
  store atomic float %e.add, ptr addrspace(5) %e syncscope("device") release, align 4

  ; CHECK: ld.local.b64 %fd{{[0-9]+}}, [%rd{{[0-9]+}}]
  %f.load = load atomic double, ptr addrspace(5) %e syncscope("device") acquire, align 8
  %f.add = fadd double %f.load, 1.
  ; CHECK: st.local.b64 [%rd{{[0-9]+}}], %fd{{[0-9]+}}
  store atomic double %f.add, ptr addrspace(5) %e syncscope("device") release, align 8

  ret void
}

; CHECK-LABEL: local_acq_rel_volatile_gpu
define void @local_acq_rel_volatile_gpu(ptr addrspace(5) %a, ptr addrspace(5) %b, ptr addrspace(5) %c, ptr addrspace(5) %d, ptr addrspace(5) %e) local_unnamed_addr {
  ; CHECK: ld.local.b8 %rs{{[0-9]+}}, [%rd{{[0-9]+}}]
  %a.load = load atomic volatile i8, ptr addrspace(5) %a syncscope("device") acquire, align 1
  %a.add = add i8 %a.load, 1
  ; CHECK: st.local.b8 [%rd{{[0-9]+}}], %rs{{[0-9]+}}
  store atomic volatile i8 %a.add, ptr addrspace(5) %a syncscope("device") release, align 1

  ; CHECK: ld.local.b16 %rs{{[0-9]+}}, [%rd{{[0-9]+}}]
  %b.load = load atomic volatile i16, ptr addrspace(5) %b syncscope("device") acquire, align 2
  %b.add = add i16 %b.load, 1
  ; CHECK: st.local.b16 [%rd{{[0-9]+}}], %rs{{[0-9]+}}
  store atomic volatile i16 %b.add, ptr addrspace(5) %b syncscope("device") release, align 2

  ; CHECK: ld.local.b32 %r{{[0-9]+}}, [%rd{{[0-9]+}}]
  %c.load = load atomic volatile i32, ptr addrspace(5) %c syncscope("device") acquire, align 4
  %c.add = add i32 %c.load, 1
  ; CHECK: st.local.b32 [%rd{{[0-9]+}}], %r{{[0-9]+}}
  store atomic volatile i32 %c.add, ptr addrspace(5) %c syncscope("device") release, align 4

  ; CHECK: ld.local.b64 %rd{{[0-9]+}}, [%rd{{[0-9]+}}]
  %d.load = load atomic volatile i64, ptr addrspace(5) %d syncscope("device") acquire, align 8
  %d.add = add i64 %d.load, 1
  ; CHECK: st.local.b64 [%rd{{[0-9]+}}], %rd{{[0-9]+}}
  store atomic volatile i64 %d.add, ptr addrspace(5) %d syncscope("device") release, align 8

  ; CHECK: ld.local.b32 %f{{[0-9]+}}, [%rd{{[0-9]+}}]
  %e.load = load atomic volatile float, ptr addrspace(5) %e syncscope("device") acquire, align 4
  %e.add = fadd float %e.load, 1.
  ; CHECK: st.local.b32 [%rd{{[0-9]+}}], %f{{[0-9]+}}
  store atomic volatile float %e.add, ptr addrspace(5) %e syncscope("device") release, align 4

  ; CHECK: ld.local.b64 %fd{{[0-9]+}}, [%rd{{[0-9]+}}]
  %f.load = load atomic volatile double, ptr addrspace(5) %e syncscope("device") acquire, align 8
  %f.add = fadd double %f.load, 1.
  ; CHECK: st.local.b64 [%rd{{[0-9]+}}], %fd{{[0-9]+}}
  store atomic volatile double %f.add, ptr addrspace(5) %e syncscope("device") release, align 8

  ret void
}

; CHECK-LABEL: local_acq_rel_cta
define void @local_acq_rel_cta(ptr addrspace(5) %a, ptr addrspace(5) %b, ptr addrspace(5) %c, ptr addrspace(5) %d, ptr addrspace(5) %e) local_unnamed_addr {
  ; CHECK: ld.local.b8 %rs{{[0-9]+}}, [%rd{{[0-9]+}}]
  %a.load = load atomic i8, ptr addrspace(5) %a syncscope("block") acquire, align 1
  %a.add = add i8 %a.load, 1
  ; CHECK: st.local.b8 [%rd{{[0-9]+}}], %rs{{[0-9]+}}
  store atomic i8 %a.add, ptr addrspace(5) %a syncscope("block") release, align 1

  ; CHECK: ld.local.b16 %rs{{[0-9]+}}, [%rd{{[0-9]+}}]
  %b.load = load atomic i16, ptr addrspace(5) %b syncscope("block") acquire, align 2
  %b.add = add i16 %b.load, 1
  ; CHECK: st.local.b16 [%rd{{[0-9]+}}], %rs{{[0-9]+}}
  store atomic i16 %b.add, ptr addrspace(5) %b syncscope("block") release, align 2

  ; CHECK: ld.local.b32 %r{{[0-9]+}}, [%rd{{[0-9]+}}]
  %c.load = load atomic i32, ptr addrspace(5) %c syncscope("block") acquire, align 4
  %c.add = add i32 %c.load, 1
  ; CHECK: st.local.b32 [%rd{{[0-9]+}}], %r{{[0-9]+}}
  store atomic i32 %c.add, ptr addrspace(5) %c syncscope("block") release, align 4

  ; CHECK: ld.local.b64 %rd{{[0-9]+}}, [%rd{{[0-9]+}}]
  %d.load = load atomic i64, ptr addrspace(5) %d syncscope("block") acquire, align 8
  %d.add = add i64 %d.load, 1
  ; CHECK: st.local.b64 [%rd{{[0-9]+}}], %rd{{[0-9]+}}
  store atomic i64 %d.add, ptr addrspace(5) %d syncscope("block") release, align 8

  ; CHECK: ld.local.b32 %f{{[0-9]+}}, [%rd{{[0-9]+}}]
  %e.load = load atomic float, ptr addrspace(5) %e syncscope("block") acquire, align 4
  %e.add = fadd float %e.load, 1.
  ; CHECK: st.local.b32 [%rd{{[0-9]+}}], %f{{[0-9]+}}
  store atomic float %e.add, ptr addrspace(5) %e syncscope("block") release, align 4

  ; CHECK: ld.local.b64 %fd{{[0-9]+}}, [%rd{{[0-9]+}}]
  %f.load = load atomic double, ptr addrspace(5) %e syncscope("block") acquire, align 8
  %f.add = fadd double %f.load, 1.
  ; CHECK: st.local.b64 [%rd{{[0-9]+}}], %fd{{[0-9]+}}
  store atomic double %f.add, ptr addrspace(5) %e syncscope("block") release, align 8

  ret void
}

; CHECK-LABEL: local_acq_rel_volatile_cta
define void @local_acq_rel_volatile_cta(ptr addrspace(5) %a, ptr addrspace(5) %b, ptr addrspace(5) %c, ptr addrspace(5) %d, ptr addrspace(5) %e) local_unnamed_addr {
  ; CHECK: ld.local.b8 %rs{{[0-9]+}}, [%rd{{[0-9]+}}]
  %a.load = load atomic volatile i8, ptr addrspace(5) %a syncscope("block") acquire, align 1
  %a.add = add i8 %a.load, 1
  ; CHECK: st.local.b8 [%rd{{[0-9]+}}], %rs{{[0-9]+}}
  store atomic volatile i8 %a.add, ptr addrspace(5) %a syncscope("block") release, align 1

  ; CHECK: ld.local.b16 %rs{{[0-9]+}}, [%rd{{[0-9]+}}]
  %b.load = load atomic volatile i16, ptr addrspace(5) %b syncscope("block") acquire, align 2
  %b.add = add i16 %b.load, 1
  ; CHECK: st.local.b16 [%rd{{[0-9]+}}], %rs{{[0-9]+}}
  store atomic volatile i16 %b.add, ptr addrspace(5) %b syncscope("block") release, align 2

  ; CHECK: ld.local.b32 %r{{[0-9]+}}, [%rd{{[0-9]+}}]
  %c.load = load atomic volatile i32, ptr addrspace(5) %c syncscope("block") acquire, align 4
  %c.add = add i32 %c.load, 1
  ; CHECK: st.local.b32 [%rd{{[0-9]+}}], %r{{[0-9]+}}
  store atomic volatile i32 %c.add, ptr addrspace(5) %c syncscope("block") release, align 4

  ; CHECK: ld.local.b64 %rd{{[0-9]+}}, [%rd{{[0-9]+}}]
  %d.load = load atomic volatile i64, ptr addrspace(5) %d syncscope("block") acquire, align 8
  %d.add = add i64 %d.load, 1
  ; CHECK: st.local.b64 [%rd{{[0-9]+}}], %rd{{[0-9]+}}
  store atomic volatile i64 %d.add, ptr addrspace(5) %d syncscope("block") release, align 8

  ; CHECK: ld.local.b32 %f{{[0-9]+}}, [%rd{{[0-9]+}}]
  %e.load = load atomic volatile float, ptr addrspace(5) %e syncscope("block") acquire, align 4
  %e.add = fadd float %e.load, 1.
  ; CHECK: st.local.b32 [%rd{{[0-9]+}}], %f{{[0-9]+}}
  store atomic volatile float %e.add, ptr addrspace(5) %e syncscope("block") release, align 4

  ; CHECK: ld.local.b64 %fd{{[0-9]+}}, [%rd{{[0-9]+}}]
  %f.load = load atomic volatile double, ptr addrspace(5) %e syncscope("block") acquire, align 8
  %f.add = fadd double %f.load, 1.
  ; CHECK: st.local.b64 [%rd{{[0-9]+}}], %fd{{[0-9]+}}
  store atomic volatile double %f.add, ptr addrspace(5) %e syncscope("block") release, align 8

  ret void
}

; CHECK-LABEL: local_seq_cst_sys
define void @local_seq_cst_sys(ptr addrspace(5) %a, ptr addrspace(5) %b, ptr addrspace(5) %c, ptr addrspace(5) %d, ptr addrspace(5) %e) local_unnamed_addr {
  ; CHECK: ld.local.b8 %rs{{[0-9]+}}, [%rd{{[0-9]+}}]
  %a.load = load atomic i8, ptr addrspace(5) %a seq_cst, align 1
  %a.add = add i8 %a.load, 1
  ; CHECK: st.local.b8 [%rd{{[0-9]+}}], %rs{{[0-9]+}}
  store atomic i8 %a.add, ptr addrspace(5) %a seq_cst, align 1

  ; CHECK: ld.local.b16 %rs{{[0-9]+}}, [%rd{{[0-9]+}}]
  %b.load = load atomic i16, ptr addrspace(5) %b seq_cst, align 2
  %b.add = add i16 %b.load, 1
  ; CHECK: st.local.b16 [%rd{{[0-9]+}}], %rs{{[0-9]+}}
  store atomic i16 %b.add, ptr addrspace(5) %b seq_cst, align 2

  ; CHECK: ld.local.b32 %r{{[0-9]+}}, [%rd{{[0-9]+}}]
  %c.load = load atomic i32, ptr addrspace(5) %c seq_cst, align 4
  %c.add = add i32 %c.load, 1
  ; CHECK: st.local.b32 [%rd{{[0-9]+}}], %r{{[0-9]+}}
  store atomic i32 %c.add, ptr addrspace(5) %c seq_cst, align 4

  ; CHECK: ld.local.b64 %rd{{[0-9]+}}, [%rd{{[0-9]+}}]
  %d.load = load atomic i64, ptr addrspace(5) %d seq_cst, align 8
  %d.add = add i64 %d.load, 1
  ; CHECK: st.local.b64 [%rd{{[0-9]+}}], %rd{{[0-9]+}}
  store atomic i64 %d.add, ptr addrspace(5) %d seq_cst, align 8

  ; CHECK: ld.local.b32 %f{{[0-9]+}}, [%rd{{[0-9]+}}]
  %e.load = load atomic float, ptr addrspace(5) %e seq_cst, align 4
  %e.add = fadd float %e.load, 1.
  ; CHECK: st.local.b32 [%rd{{[0-9]+}}], %f{{[0-9]+}}
  store atomic float %e.add, ptr addrspace(5) %e seq_cst, align 4

  ; CHECK: ld.local.b64 %fd{{[0-9]+}}, [%rd{{[0-9]+}}]
  %f.load = load atomic double, ptr addrspace(5) %e seq_cst, align 8
  %f.add = fadd double %f.load, 1.
  ; CHECK: st.local.b64 [%rd{{[0-9]+}}], %fd{{[0-9]+}}
  store atomic double %f.add, ptr addrspace(5) %e seq_cst, align 8

  ret void
}

; CHECK-LABEL: local_seq_cst_volatile_sys
define void @local_seq_cst_volatile_sys(ptr addrspace(5) %a, ptr addrspace(5) %b, ptr addrspace(5) %c, ptr addrspace(5) %d, ptr addrspace(5) %e) local_unnamed_addr {
  ; CHECK: ld.local.b8 %rs{{[0-9]+}}, [%rd{{[0-9]+}}]
  %a.load = load atomic volatile i8, ptr addrspace(5) %a seq_cst, align 1
  %a.add = add i8 %a.load, 1
  ; CHECK: st.local.b8 [%rd{{[0-9]+}}], %rs{{[0-9]+}}
  store atomic volatile i8 %a.add, ptr addrspace(5) %a seq_cst, align 1

  ; CHECK: ld.local.b16 %rs{{[0-9]+}}, [%rd{{[0-9]+}}]
  %b.load = load atomic volatile i16, ptr addrspace(5) %b seq_cst, align 2
  %b.add = add i16 %b.load, 1
  ; CHECK: st.local.b16 [%rd{{[0-9]+}}], %rs{{[0-9]+}}
  store atomic volatile i16 %b.add, ptr addrspace(5) %b seq_cst, align 2

  ; CHECK: ld.local.b32 %r{{[0-9]+}}, [%rd{{[0-9]+}}]
  %c.load = load atomic volatile i32, ptr addrspace(5) %c seq_cst, align 4
  %c.add = add i32 %c.load, 1
  ; CHECK: st.local.b32 [%rd{{[0-9]+}}], %r{{[0-9]+}}
  store atomic volatile i32 %c.add, ptr addrspace(5) %c seq_cst, align 4

  ; CHECK: ld.local.b64 %rd{{[0-9]+}}, [%rd{{[0-9]+}}]
  %d.load = load atomic volatile i64, ptr addrspace(5) %d seq_cst, align 8
  %d.add = add i64 %d.load, 1
  ; CHECK: st.local.b64 [%rd{{[0-9]+}}], %rd{{[0-9]+}}
  store atomic volatile i64 %d.add, ptr addrspace(5) %d seq_cst, align 8

  ; CHECK: ld.local.b32 %f{{[0-9]+}}, [%rd{{[0-9]+}}]
  %e.load = load atomic volatile float, ptr addrspace(5) %e seq_cst, align 4
  %e.add = fadd float %e.load, 1.
  ; CHECK: st.local.b32 [%rd{{[0-9]+}}], %f{{[0-9]+}}
  store atomic volatile float %e.add, ptr addrspace(5) %e seq_cst, align 4

  ; CHECK: ld.local.b64 %fd{{[0-9]+}}, [%rd{{[0-9]+}}]
  %f.load = load atomic volatile double, ptr addrspace(5) %e seq_cst, align 8
  %f.add = fadd double %f.load, 1.
  ; CHECK: st.local.b64 [%rd{{[0-9]+}}], %fd{{[0-9]+}}
  store atomic volatile double %f.add, ptr addrspace(5) %e seq_cst, align 8

  ret void
}

; CHECK-LABEL: local_seq_cst_gpu
define void @local_seq_cst_gpu(ptr addrspace(5) %a, ptr addrspace(5) %b, ptr addrspace(5) %c, ptr addrspace(5) %d, ptr addrspace(5) %e) local_unnamed_addr {
  ; CHECK: ld.local.b8 %rs{{[0-9]+}}, [%rd{{[0-9]+}}]
  %a.load = load atomic i8, ptr addrspace(5) %a syncscope("device") seq_cst, align 1
  %a.add = add i8 %a.load, 1
  ; CHECK: st.local.b8 [%rd{{[0-9]+}}], %rs{{[0-9]+}}
  store atomic i8 %a.add, ptr addrspace(5) %a syncscope("device") seq_cst, align 1

  ; CHECK: ld.local.b16 %rs{{[0-9]+}}, [%rd{{[0-9]+}}]
  %b.load = load atomic i16, ptr addrspace(5) %b syncscope("device") seq_cst, align 2
  %b.add = add i16 %b.load, 1
  ; CHECK: st.local.b16 [%rd{{[0-9]+}}], %rs{{[0-9]+}}
  store atomic i16 %b.add, ptr addrspace(5) %b syncscope("device") seq_cst, align 2

  ; CHECK: ld.local.b32 %r{{[0-9]+}}, [%rd{{[0-9]+}}]
  %c.load = load atomic i32, ptr addrspace(5) %c syncscope("device") seq_cst, align 4
  %c.add = add i32 %c.load, 1
  ; CHECK: st.local.b32 [%rd{{[0-9]+}}], %r{{[0-9]+}}
  store atomic i32 %c.add, ptr addrspace(5) %c syncscope("device") seq_cst, align 4

  ; CHECK: ld.local.b64 %rd{{[0-9]+}}, [%rd{{[0-9]+}}]
  %d.load = load atomic i64, ptr addrspace(5) %d syncscope("device") seq_cst, align 8
  %d.add = add i64 %d.load, 1
  ; CHECK: st.local.b64 [%rd{{[0-9]+}}], %rd{{[0-9]+}}
  store atomic i64 %d.add, ptr addrspace(5) %d syncscope("device") seq_cst, align 8

  ; CHECK: ld.local.b32 %f{{[0-9]+}}, [%rd{{[0-9]+}}]
  %e.load = load atomic float, ptr addrspace(5) %e syncscope("device") seq_cst, align 4
  %e.add = fadd float %e.load, 1.
  ; CHECK: st.local.b32 [%rd{{[0-9]+}}], %f{{[0-9]+}}
  store atomic float %e.add, ptr addrspace(5) %e syncscope("device") seq_cst, align 4

  ; CHECK: ld.local.b64 %fd{{[0-9]+}}, [%rd{{[0-9]+}}]
  %f.load = load atomic double, ptr addrspace(5) %e syncscope("device") seq_cst, align 8
  %f.add = fadd double %f.load, 1.
  ; CHECK: st.local.b64 [%rd{{[0-9]+}}], %fd{{[0-9]+}}
  store atomic double %f.add, ptr addrspace(5) %e syncscope("device") seq_cst, align 8

  ret void
}

; CHECK-LABEL: local_seq_cst_volatile_gpu
define void @local_seq_cst_volatile_gpu(ptr addrspace(5) %a, ptr addrspace(5) %b, ptr addrspace(5) %c, ptr addrspace(5) %d, ptr addrspace(5) %e) local_unnamed_addr {
  ; CHECK: ld.local.b8 %rs{{[0-9]+}}, [%rd{{[0-9]+}}]
  %a.load = load atomic volatile i8, ptr addrspace(5) %a syncscope("device") seq_cst, align 1
  %a.add = add i8 %a.load, 1
  ; CHECK: st.local.b8 [%rd{{[0-9]+}}], %rs{{[0-9]+}}
  store atomic volatile i8 %a.add, ptr addrspace(5) %a syncscope("device") seq_cst, align 1

  ; CHECK: ld.local.b16 %rs{{[0-9]+}}, [%rd{{[0-9]+}}]
  %b.load = load atomic volatile i16, ptr addrspace(5) %b syncscope("device") seq_cst, align 2
  %b.add = add i16 %b.load, 1
  ; CHECK: st.local.b16 [%rd{{[0-9]+}}], %rs{{[0-9]+}}
  store atomic volatile i16 %b.add, ptr addrspace(5) %b syncscope("device") seq_cst, align 2

  ; CHECK: ld.local.b32 %r{{[0-9]+}}, [%rd{{[0-9]+}}]
  %c.load = load atomic volatile i32, ptr addrspace(5) %c syncscope("device") seq_cst, align 4
  %c.add = add i32 %c.load, 1
  ; CHECK: st.local.b32 [%rd{{[0-9]+}}], %r{{[0-9]+}}
  store atomic volatile i32 %c.add, ptr addrspace(5) %c syncscope("device") seq_cst, align 4

  ; CHECK: ld.local.b64 %rd{{[0-9]+}}, [%rd{{[0-9]+}}]
  %d.load = load atomic volatile i64, ptr addrspace(5) %d syncscope("device") seq_cst, align 8
  %d.add = add i64 %d.load, 1
  ; CHECK: st.local.b64 [%rd{{[0-9]+}}], %rd{{[0-9]+}}
  store atomic volatile i64 %d.add, ptr addrspace(5) %d syncscope("device") seq_cst, align 8

  ; CHECK: ld.local.b32 %f{{[0-9]+}}, [%rd{{[0-9]+}}]
  %e.load = load atomic volatile float, ptr addrspace(5) %e syncscope("device") seq_cst, align 4
  %e.add = fadd float %e.load, 1.
  ; CHECK: st.local.b32 [%rd{{[0-9]+}}], %f{{[0-9]+}}
  store atomic volatile float %e.add, ptr addrspace(5) %e syncscope("device") seq_cst, align 4

  ; CHECK: ld.local.b64 %fd{{[0-9]+}}, [%rd{{[0-9]+}}]
  %f.load = load atomic volatile double, ptr addrspace(5) %e syncscope("device") seq_cst, align 8
  %f.add = fadd double %f.load, 1.
  ; CHECK: st.local.b64 [%rd{{[0-9]+}}], %fd{{[0-9]+}}
  store atomic volatile double %f.add, ptr addrspace(5) %e syncscope("device") seq_cst, align 8

  ret void
}

; CHECK-LABEL: local_seq_cst_cta
define void @local_seq_cst_cta(ptr addrspace(5) %a, ptr addrspace(5) %b, ptr addrspace(5) %c, ptr addrspace(5) %d, ptr addrspace(5) %e) local_unnamed_addr {
  ; CHECK: ld.local.b8 %rs{{[0-9]+}}, [%rd{{[0-9]+}}]
  %a.load = load atomic i8, ptr addrspace(5) %a syncscope("block") seq_cst, align 1
  %a.add = add i8 %a.load, 1
  ; CHECK: st.local.b8 [%rd{{[0-9]+}}], %rs{{[0-9]+}}
  store atomic i8 %a.add, ptr addrspace(5) %a syncscope("block") seq_cst, align 1

  ; CHECK: ld.local.b16 %rs{{[0-9]+}}, [%rd{{[0-9]+}}]
  %b.load = load atomic i16, ptr addrspace(5) %b syncscope("block") seq_cst, align 2
  %b.add = add i16 %b.load, 1
  ; CHECK: st.local.b16 [%rd{{[0-9]+}}], %rs{{[0-9]+}}
  store atomic i16 %b.add, ptr addrspace(5) %b syncscope("block") seq_cst, align 2

  ; CHECK: ld.local.b32 %r{{[0-9]+}}, [%rd{{[0-9]+}}]
  %c.load = load atomic i32, ptr addrspace(5) %c syncscope("block") seq_cst, align 4
  %c.add = add i32 %c.load, 1
  ; CHECK: st.local.b32 [%rd{{[0-9]+}}], %r{{[0-9]+}}
  store atomic i32 %c.add, ptr addrspace(5) %c syncscope("block") seq_cst, align 4

  ; CHECK: ld.local.b64 %rd{{[0-9]+}}, [%rd{{[0-9]+}}]
  %d.load = load atomic i64, ptr addrspace(5) %d syncscope("block") seq_cst, align 8
  %d.add = add i64 %d.load, 1
  ; CHECK: st.local.b64 [%rd{{[0-9]+}}], %rd{{[0-9]+}}
  store atomic i64 %d.add, ptr addrspace(5) %d syncscope("block") seq_cst, align 8

  ; CHECK: ld.local.b32 %f{{[0-9]+}}, [%rd{{[0-9]+}}]
  %e.load = load atomic float, ptr addrspace(5) %e syncscope("block") seq_cst, align 4
  %e.add = fadd float %e.load, 1.
  ; CHECK: st.local.b32 [%rd{{[0-9]+}}], %f{{[0-9]+}}
  store atomic float %e.add, ptr addrspace(5) %e syncscope("block") seq_cst, align 4

  ; CHECK: ld.local.b64 %fd{{[0-9]+}}, [%rd{{[0-9]+}}]
  %f.load = load atomic double, ptr addrspace(5) %e syncscope("block") seq_cst, align 8
  %f.add = fadd double %f.load, 1.
  ; CHECK: st.local.b64 [%rd{{[0-9]+}}], %fd{{[0-9]+}}
  store atomic double %f.add, ptr addrspace(5) %e syncscope("block") seq_cst, align 8

  ret void
}

; CHECK-LABEL: local_seq_cst_volatile_cta
define void @local_seq_cst_volatile_cta(ptr addrspace(5) %a, ptr addrspace(5) %b, ptr addrspace(5) %c, ptr addrspace(5) %d, ptr addrspace(5) %e) local_unnamed_addr {
  ; CHECK: ld.local.b8 %rs{{[0-9]+}}, [%rd{{[0-9]+}}]
  %a.load = load atomic volatile i8, ptr addrspace(5) %a syncscope("block") seq_cst, align 1
  %a.add = add i8 %a.load, 1
  ; CHECK: st.local.b8 [%rd{{[0-9]+}}], %rs{{[0-9]+}}
  store atomic volatile i8 %a.add, ptr addrspace(5) %a syncscope("block") seq_cst, align 1

  ; CHECK: ld.local.b16 %rs{{[0-9]+}}, [%rd{{[0-9]+}}]
  %b.load = load atomic volatile i16, ptr addrspace(5) %b syncscope("block") seq_cst, align 2
  %b.add = add i16 %b.load, 1
  ; CHECK: st.local.b16 [%rd{{[0-9]+}}], %rs{{[0-9]+}}
  store atomic volatile i16 %b.add, ptr addrspace(5) %b syncscope("block") seq_cst, align 2

  ; CHECK: ld.local.b32 %r{{[0-9]+}}, [%rd{{[0-9]+}}]
  %c.load = load atomic volatile i32, ptr addrspace(5) %c syncscope("block") seq_cst, align 4
  %c.add = add i32 %c.load, 1
  ; CHECK: st.local.b32 [%rd{{[0-9]+}}], %r{{[0-9]+}}
  store atomic volatile i32 %c.add, ptr addrspace(5) %c syncscope("block") seq_cst, align 4

  ; CHECK: ld.local.b64 %rd{{[0-9]+}}, [%rd{{[0-9]+}}]
  %d.load = load atomic volatile i64, ptr addrspace(5) %d syncscope("block") seq_cst, align 8
  %d.add = add i64 %d.load, 1
  ; CHECK: st.local.b64 [%rd{{[0-9]+}}], %rd{{[0-9]+}}
  store atomic volatile i64 %d.add, ptr addrspace(5) %d syncscope("block") seq_cst, align 8

  ; CHECK: ld.local.b32 %f{{[0-9]+}}, [%rd{{[0-9]+}}]
  %e.load = load atomic volatile float, ptr addrspace(5) %e syncscope("block") seq_cst, align 4
  %e.add = fadd float %e.load, 1.
  ; CHECK: st.local.b32 [%rd{{[0-9]+}}], %f{{[0-9]+}}
  store atomic volatile float %e.add, ptr addrspace(5) %e syncscope("block") seq_cst, align 4

  ; CHECK: ld.local.b64 %fd{{[0-9]+}}, [%rd{{[0-9]+}}]
  %f.load = load atomic volatile double, ptr addrspace(5) %e syncscope("block") seq_cst, align 8
  %f.add = fadd double %f.load, 1.
  ; CHECK: st.local.b64 [%rd{{[0-9]+}}], %fd{{[0-9]+}}
  store atomic volatile double %f.add, ptr addrspace(5) %e syncscope("block") seq_cst, align 8

  ret void
}

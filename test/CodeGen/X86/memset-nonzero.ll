; NOTE: Assertions have been autogenerated by update_test_checks.py
; RUN: llc -mtriple=x86_64-unknown-unknown < %s -mattr=sse2 | FileCheck %s --check-prefix=ANY --check-prefix=SSE2
; RUN: llc -mtriple=x86_64-unknown-unknown < %s -mattr=avx | FileCheck %s --check-prefix=ANY --check-prefix=AVX --check-prefix=AVX1
; RUN: llc -mtriple=x86_64-unknown-unknown < %s -mattr=avx2 | FileCheck %s --check-prefix=ANY --check-prefix=AVX --check-prefix=AVX2

; https://llvm.org/bugs/show_bug.cgi?id=27100

define void @memset_16_nonzero_bytes(i8* %x) {
; SSE2-LABEL: memset_16_nonzero_bytes:
; SSE2:         movabsq $3038287259199220266, %rax # imm = 0x2A2A2A2A2A2A2A2A
; SSE2-NEXT:    movq %rax, 8(%rdi)
; SSE2-NEXT:    movq %rax, (%rdi)
; SSE2-NEXT:    retq
;
; AVX-LABEL: memset_16_nonzero_bytes:
; AVX:         vmovaps {{.*#+}} xmm0 = [42,42,42,42,42,42,42,42,42,42,42,42,42,42,42,42]
; AVX-NEXT:    vmovups %xmm0, (%rdi)
; AVX-NEXT:    retq
;
  %call = tail call i8* @__memset_chk(i8* %x, i32 42, i64 16, i64 -1)
  ret void
}

define void @memset_32_nonzero_bytes(i8* %x) {
; SSE2-LABEL: memset_32_nonzero_bytes:
; SSE2:         movabsq $3038287259199220266, %rax # imm = 0x2A2A2A2A2A2A2A2A
; SSE2-NEXT:    movq %rax, 24(%rdi)
; SSE2-NEXT:    movq %rax, 16(%rdi)
; SSE2-NEXT:    movq %rax, 8(%rdi)
; SSE2-NEXT:    movq %rax, (%rdi)
; SSE2-NEXT:    retq
;
; AVX-LABEL: memset_32_nonzero_bytes:
; AVX:         vmovaps {{.*#+}} ymm0 = [42,42,42,42,42,42,42,42,42,42,42,42,42,42,42,42,42,42,42,42,42,42,42,42,42,42,42,42,42,42,42,42]
; AVX-NEXT:    vmovups %ymm0, (%rdi)
; AVX-NEXT:    vzeroupper
; AVX-NEXT:    retq
;
  %call = tail call i8* @__memset_chk(i8* %x, i32 42, i64 32, i64 -1)
  ret void
}

define void @memset_64_nonzero_bytes(i8* %x) {
; SSE2-LABEL: memset_64_nonzero_bytes:
; SSE2:         movabsq $3038287259199220266, %rax # imm = 0x2A2A2A2A2A2A2A2A
; SSE2-NEXT:    movq %rax, 56(%rdi)
; SSE2-NEXT:    movq %rax, 48(%rdi)
; SSE2-NEXT:    movq %rax, 40(%rdi)
; SSE2-NEXT:    movq %rax, 32(%rdi)
; SSE2-NEXT:    movq %rax, 24(%rdi)
; SSE2-NEXT:    movq %rax, 16(%rdi)
; SSE2-NEXT:    movq %rax, 8(%rdi)
; SSE2-NEXT:    movq %rax, (%rdi)
; SSE2-NEXT:    retq
;
; AVX-LABEL: memset_64_nonzero_bytes:
; AVX:         vmovaps {{.*#+}} ymm0 = [42,42,42,42,42,42,42,42,42,42,42,42,42,42,42,42,42,42,42,42,42,42,42,42,42,42,42,42,42,42,42,42]
; AVX-NEXT:    vmovups %ymm0, 32(%rdi)
; AVX-NEXT:    vmovups %ymm0, (%rdi)
; AVX-NEXT:    vzeroupper
; AVX-NEXT:    retq
;
  %call = tail call i8* @__memset_chk(i8* %x, i32 42, i64 64, i64 -1)
  ret void
}

define void @memset_128_nonzero_bytes(i8* %x) {
; SSE2-LABEL: memset_128_nonzero_bytes:
; SSE2:         movabsq $3038287259199220266, %rax # imm = 0x2A2A2A2A2A2A2A2A
; SSE2-NEXT:    movq %rax, 120(%rdi)
; SSE2-NEXT:    movq %rax, 112(%rdi)
; SSE2-NEXT:    movq %rax, 104(%rdi)
; SSE2-NEXT:    movq %rax, 96(%rdi)
; SSE2-NEXT:    movq %rax, 88(%rdi)
; SSE2-NEXT:    movq %rax, 80(%rdi)
; SSE2-NEXT:    movq %rax, 72(%rdi)
; SSE2-NEXT:    movq %rax, 64(%rdi)
; SSE2-NEXT:    movq %rax, 56(%rdi)
; SSE2-NEXT:    movq %rax, 48(%rdi)
; SSE2-NEXT:    movq %rax, 40(%rdi)
; SSE2-NEXT:    movq %rax, 32(%rdi)
; SSE2-NEXT:    movq %rax, 24(%rdi)
; SSE2-NEXT:    movq %rax, 16(%rdi)
; SSE2-NEXT:    movq %rax, 8(%rdi)
; SSE2-NEXT:    movq %rax, (%rdi)
; SSE2-NEXT:    retq
;
; AVX-LABEL: memset_128_nonzero_bytes:
; AVX:         vmovaps {{.*#+}} ymm0 = [42,42,42,42,42,42,42,42,42,42,42,42,42,42,42,42,42,42,42,42,42,42,42,42,42,42,42,42,42,42,42,42]
; AVX-NEXT:    vmovups %ymm0, 96(%rdi)
; AVX-NEXT:    vmovups %ymm0, 64(%rdi)
; AVX-NEXT:    vmovups %ymm0, 32(%rdi)
; AVX-NEXT:    vmovups %ymm0, (%rdi)
; AVX-NEXT:    vzeroupper
; AVX-NEXT:    retq
;
  %call = tail call i8* @__memset_chk(i8* %x, i32 42, i64 128, i64 -1)
  ret void
}

define void @memset_256_nonzero_bytes(i8* %x) {
; SSE2-LABEL: memset_256_nonzero_bytes:
; SSE2:         pushq %rax
; SSE2-NEXT:  .Ltmp0:
; SSE2-NEXT:    .cfi_def_cfa_offset 16
; SSE2-NEXT:    movl $42, %esi
; SSE2-NEXT:    movl $256, %edx # imm = 0x100
; SSE2-NEXT:    callq memset
; SSE2-NEXT:    popq %rax
; SSE2-NEXT:    retq
;
; AVX-LABEL: memset_256_nonzero_bytes:
; AVX:         vmovaps {{.*#+}} ymm0 = [42,42,42,42,42,42,42,42,42,42,42,42,42,42,42,42,42,42,42,42,42,42,42,42,42,42,42,42,42,42,42,42]
; AVX-NEXT:    vmovups %ymm0, 224(%rdi)
; AVX-NEXT:    vmovups %ymm0, 192(%rdi)
; AVX-NEXT:    vmovups %ymm0, 160(%rdi)
; AVX-NEXT:    vmovups %ymm0, 128(%rdi)
; AVX-NEXT:    vmovups %ymm0, 96(%rdi)
; AVX-NEXT:    vmovups %ymm0, 64(%rdi)
; AVX-NEXT:    vmovups %ymm0, 32(%rdi)
; AVX-NEXT:    vmovups %ymm0, (%rdi)
; AVX-NEXT:    vzeroupper
; AVX-NEXT:    retq
;
  %call = tail call i8* @__memset_chk(i8* %x, i32 42, i64 256, i64 -1)
  ret void
}

declare i8* @__memset_chk(i8*, i32, i64, i64)

; Repeat with a non-constant value for the stores.

define void @memset_16_nonconst_bytes(i8* %x, i8 %c) {
; SSE2-LABEL: memset_16_nonconst_bytes:
; SSE2:         movzbl %sil, %eax
; SSE2-NEXT:    movabsq $72340172838076673, %rcx # imm = 0x101010101010101
; SSE2-NEXT:    imulq %rax, %rcx
; SSE2-NEXT:    movq %rcx, 8(%rdi)
; SSE2-NEXT:    movq %rcx, (%rdi)
; SSE2-NEXT:    retq
;
; AVX1-LABEL: memset_16_nonconst_bytes:
; AVX1:         vmovd %esi, %xmm0
; AVX1-NEXT:    vpxor %xmm1, %xmm1, %xmm1
; AVX1-NEXT:    vpshufb %xmm1, %xmm0, %xmm0
; AVX1-NEXT:    vmovdqu %xmm0, (%rdi)
; AVX1-NEXT:    retq
;
; AVX2-LABEL: memset_16_nonconst_bytes:
; AVX2:         vmovd %esi, %xmm0
; AVX2-NEXT:    vpbroadcastb %xmm0, %xmm0
; AVX2-NEXT:    vmovdqu %xmm0, (%rdi)
; AVX2-NEXT:    retq
;
  tail call void @llvm.memset.p0i8.i64(i8* %x, i8 %c, i64 16, i32 1, i1 false)
  ret void
}

define void @memset_32_nonconst_bytes(i8* %x, i8 %c) {
; SSE2-LABEL: memset_32_nonconst_bytes:
; SSE2:         movzbl %sil, %eax
; SSE2-NEXT:    movabsq $72340172838076673, %rcx # imm = 0x101010101010101
; SSE2-NEXT:    imulq %rax, %rcx
; SSE2-NEXT:    movq %rcx, 24(%rdi)
; SSE2-NEXT:    movq %rcx, 16(%rdi)
; SSE2-NEXT:    movq %rcx, 8(%rdi)
; SSE2-NEXT:    movq %rcx, (%rdi)
; SSE2-NEXT:    retq
;
; AVX1-LABEL: memset_32_nonconst_bytes:
; AVX1:         vmovd %esi, %xmm0
; AVX1-NEXT:    vpxor %xmm1, %xmm1, %xmm1
; AVX1-NEXT:    vpshufb %xmm1, %xmm0, %xmm0
; AVX1-NEXT:    vinsertf128 $1, %xmm0, %ymm0, %ymm0
; AVX1-NEXT:    vmovups %ymm0, (%rdi)
; AVX1-NEXT:    vzeroupper
; AVX1-NEXT:    retq
;
; AVX2-LABEL: memset_32_nonconst_bytes:
; AVX2:         vmovd %esi, %xmm0
; AVX2-NEXT:    vpbroadcastb %xmm0, %ymm0
; AVX2-NEXT:    vmovdqu %ymm0, (%rdi)
; AVX2-NEXT:    vzeroupper
; AVX2-NEXT:    retq
;
  tail call void @llvm.memset.p0i8.i64(i8* %x, i8 %c, i64 32, i32 1, i1 false)
  ret void
}

define void @memset_64_nonconst_bytes(i8* %x, i8 %c) {
; SSE2-LABEL: memset_64_nonconst_bytes:
; SSE2:         movzbl %sil, %eax
; SSE2-NEXT:    movabsq $72340172838076673, %rcx # imm = 0x101010101010101
; SSE2-NEXT:    imulq %rax, %rcx
; SSE2-NEXT:    movq %rcx, 56(%rdi)
; SSE2-NEXT:    movq %rcx, 48(%rdi)
; SSE2-NEXT:    movq %rcx, 40(%rdi)
; SSE2-NEXT:    movq %rcx, 32(%rdi)
; SSE2-NEXT:    movq %rcx, 24(%rdi)
; SSE2-NEXT:    movq %rcx, 16(%rdi)
; SSE2-NEXT:    movq %rcx, 8(%rdi)
; SSE2-NEXT:    movq %rcx, (%rdi)
; SSE2-NEXT:    retq
;
; AVX1-LABEL: memset_64_nonconst_bytes:
; AVX1:         vmovd %esi, %xmm0
; AVX1-NEXT:    vpxor %xmm1, %xmm1, %xmm1
; AVX1-NEXT:    vpshufb %xmm1, %xmm0, %xmm0
; AVX1-NEXT:    vinsertf128 $1, %xmm0, %ymm0, %ymm0
; AVX1-NEXT:    vmovups %ymm0, 32(%rdi)
; AVX1-NEXT:    vmovups %ymm0, (%rdi)
; AVX1-NEXT:    vzeroupper
; AVX1-NEXT:    retq
;
; AVX2-LABEL: memset_64_nonconst_bytes:
; AVX2:         vmovd %esi, %xmm0
; AVX2-NEXT:    vpbroadcastb %xmm0, %ymm0
; AVX2-NEXT:    vmovdqu %ymm0, 32(%rdi)
; AVX2-NEXT:    vmovdqu %ymm0, (%rdi)
; AVX2-NEXT:    vzeroupper
; AVX2-NEXT:    retq
;
  tail call void @llvm.memset.p0i8.i64(i8* %x, i8 %c, i64 64, i32 1, i1 false)
  ret void
}

define void @memset_128_nonconst_bytes(i8* %x, i8 %c) {
; SSE2-LABEL: memset_128_nonconst_bytes:
; SSE2:         movzbl %sil, %eax
; SSE2-NEXT:    movabsq $72340172838076673, %rcx # imm = 0x101010101010101
; SSE2-NEXT:    imulq %rax, %rcx
; SSE2-NEXT:    movq %rcx, 120(%rdi)
; SSE2-NEXT:    movq %rcx, 112(%rdi)
; SSE2-NEXT:    movq %rcx, 104(%rdi)
; SSE2-NEXT:    movq %rcx, 96(%rdi)
; SSE2-NEXT:    movq %rcx, 88(%rdi)
; SSE2-NEXT:    movq %rcx, 80(%rdi)
; SSE2-NEXT:    movq %rcx, 72(%rdi)
; SSE2-NEXT:    movq %rcx, 64(%rdi)
; SSE2-NEXT:    movq %rcx, 56(%rdi)
; SSE2-NEXT:    movq %rcx, 48(%rdi)
; SSE2-NEXT:    movq %rcx, 40(%rdi)
; SSE2-NEXT:    movq %rcx, 32(%rdi)
; SSE2-NEXT:    movq %rcx, 24(%rdi)
; SSE2-NEXT:    movq %rcx, 16(%rdi)
; SSE2-NEXT:    movq %rcx, 8(%rdi)
; SSE2-NEXT:    movq %rcx, (%rdi)
; SSE2-NEXT:    retq
;
; AVX1-LABEL: memset_128_nonconst_bytes:
; AVX1:         vmovd %esi, %xmm0
; AVX1-NEXT:    vpxor %xmm1, %xmm1, %xmm1
; AVX1-NEXT:    vpshufb %xmm1, %xmm0, %xmm0
; AVX1-NEXT:    vinsertf128 $1, %xmm0, %ymm0, %ymm0
; AVX1-NEXT:    vmovups %ymm0, 96(%rdi)
; AVX1-NEXT:    vmovups %ymm0, 64(%rdi)
; AVX1-NEXT:    vmovups %ymm0, 32(%rdi)
; AVX1-NEXT:    vmovups %ymm0, (%rdi)
; AVX1-NEXT:    vzeroupper
; AVX1-NEXT:    retq
;
; AVX2-LABEL: memset_128_nonconst_bytes:
; AVX2:         vmovd %esi, %xmm0
; AVX2-NEXT:    vpbroadcastb %xmm0, %ymm0
; AVX2-NEXT:    vmovdqu %ymm0, 96(%rdi)
; AVX2-NEXT:    vmovdqu %ymm0, 64(%rdi)
; AVX2-NEXT:    vmovdqu %ymm0, 32(%rdi)
; AVX2-NEXT:    vmovdqu %ymm0, (%rdi)
; AVX2-NEXT:    vzeroupper
; AVX2-NEXT:    retq
;
  tail call void @llvm.memset.p0i8.i64(i8* %x, i8 %c, i64 128, i32 1, i1 false)
  ret void
}

define void @memset_256_nonconst_bytes(i8* %x, i8 %c) {
; SSE2-LABEL: memset_256_nonconst_bytes:
; SSE2:         movl $256, %edx # imm = 0x100
; SSE2-NEXT:    jmp memset # TAILCALL
;
; AVX1-LABEL: memset_256_nonconst_bytes:
; AVX1:         vmovd %esi, %xmm0
; AVX1-NEXT:    vpxor %xmm1, %xmm1, %xmm1
; AVX1-NEXT:    vpshufb %xmm1, %xmm0, %xmm0
; AVX1-NEXT:    vinsertf128 $1, %xmm0, %ymm0, %ymm0
; AVX1-NEXT:    vmovups %ymm0, 224(%rdi)
; AVX1-NEXT:    vmovups %ymm0, 192(%rdi)
; AVX1-NEXT:    vmovups %ymm0, 160(%rdi)
; AVX1-NEXT:    vmovups %ymm0, 128(%rdi)
; AVX1-NEXT:    vmovups %ymm0, 96(%rdi)
; AVX1-NEXT:    vmovups %ymm0, 64(%rdi)
; AVX1-NEXT:    vmovups %ymm0, 32(%rdi)
; AVX1-NEXT:    vmovups %ymm0, (%rdi)
; AVX1-NEXT:    vzeroupper
; AVX1-NEXT:    retq
;
; AVX2-LABEL: memset_256_nonconst_bytes:
; AVX2:         vmovd %esi, %xmm0
; AVX2-NEXT:    vpbroadcastb %xmm0, %ymm0
; AVX2-NEXT:    vmovdqu %ymm0, 224(%rdi)
; AVX2-NEXT:    vmovdqu %ymm0, 192(%rdi)
; AVX2-NEXT:    vmovdqu %ymm0, 160(%rdi)
; AVX2-NEXT:    vmovdqu %ymm0, 128(%rdi)
; AVX2-NEXT:    vmovdqu %ymm0, 96(%rdi)
; AVX2-NEXT:    vmovdqu %ymm0, 64(%rdi)
; AVX2-NEXT:    vmovdqu %ymm0, 32(%rdi)
; AVX2-NEXT:    vmovdqu %ymm0, (%rdi)
; AVX2-NEXT:    vzeroupper
; AVX2-NEXT:    retq
;
  tail call void @llvm.memset.p0i8.i64(i8* %x, i8 %c, i64 256, i32 1, i1 false)
  ret void
}

declare void @llvm.memset.p0i8.i64(i8* nocapture, i8, i64, i32, i1) #1


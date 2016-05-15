; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc < %s -mtriple=x86_64-pc-linux -mattr=+sse2   | FileCheck %s --check-prefix=SSE --check-prefix=SSE2
; RUN: llc < %s -mtriple=x86_64-pc-linux -mattr=+sse4.1 | FileCheck %s --check-prefix=SSE --check-prefix=SSE41
; RUN: llc < %s -mtriple=x86_64-pc-linux -mattr=+avx    | FileCheck %s --check-prefix=AVX --check-prefix=AVX1
; RUN: llc < %s -mtriple=x86_64-pc-linux -mattr=+avx2   | FileCheck %s --check-prefix=AVX --check-prefix=AVX2

;
; ExtractElement - Constant Index
;

define i8 @extractelement_v32i8_1(<32 x i8> %a) nounwind {
; SSE2-LABEL: extractelement_v32i8_1:
; SSE2:       # BB#0:
; SSE2-NEXT:    movaps %xmm0, -{{[0-9]+}}(%rsp)
; SSE2-NEXT:    movb -{{[0-9]+}}(%rsp), %al
; SSE2-NEXT:    retq
;
; SSE41-LABEL: extractelement_v32i8_1:
; SSE41:       # BB#0:
; SSE41-NEXT:    pextrb $1, %xmm0, %eax
; SSE41-NEXT:    retq
;
; AVX-LABEL: extractelement_v32i8_1:
; AVX:       # BB#0:
; AVX-NEXT:    vpextrb $1, %xmm0, %eax
; AVX-NEXT:    vzeroupper
; AVX-NEXT:    retq
  %b = extractelement <32 x i8> %a, i256 1
  ret i8 %b
}

define i8 @extractelement_v32i8_17(<32 x i8> %a) nounwind {
; SSE2-LABEL: extractelement_v32i8_17:
; SSE2:       # BB#0:
; SSE2-NEXT:    movaps %xmm1, -{{[0-9]+}}(%rsp)
; SSE2-NEXT:    movb -{{[0-9]+}}(%rsp), %al
; SSE2-NEXT:    retq
;
; SSE41-LABEL: extractelement_v32i8_17:
; SSE41:       # BB#0:
; SSE41-NEXT:    pextrb $1, %xmm1, %eax
; SSE41-NEXT:    retq
;
; AVX1-LABEL: extractelement_v32i8_17:
; AVX1:       # BB#0:
; AVX1-NEXT:    vextractf128 $1, %ymm0, %xmm0
; AVX1-NEXT:    vpextrb $1, %xmm0, %eax
; AVX1-NEXT:    vzeroupper
; AVX1-NEXT:    retq
;
; AVX2-LABEL: extractelement_v32i8_17:
; AVX2:       # BB#0:
; AVX2-NEXT:    vextracti128 $1, %ymm0, %xmm0
; AVX2-NEXT:    vpextrb $1, %xmm0, %eax
; AVX2-NEXT:    vzeroupper
; AVX2-NEXT:    retq
  %b = extractelement <32 x i8> %a, i256 17
  ret i8 %b
}

define i16 @extractelement_v16i16_0(<16 x i16> %a, i256 %i) nounwind {
; SSE-LABEL: extractelement_v16i16_0:
; SSE:       # BB#0:
; SSE-NEXT:    movd %xmm0, %eax
; SSE-NEXT:    retq
;
; AVX-LABEL: extractelement_v16i16_0:
; AVX:       # BB#0:
; AVX-NEXT:    vmovd %xmm0, %eax
; AVX-NEXT:    vzeroupper
; AVX-NEXT:    retq
  %b = extractelement <16 x i16> %a, i256 0
  ret i16 %b
}

define i16 @extractelement_v16i16_13(<16 x i16> %a, i256 %i) nounwind {
; SSE-LABEL: extractelement_v16i16_13:
; SSE:       # BB#0:
; SSE-NEXT:    pextrw $5, %xmm1, %eax
; SSE-NEXT:    retq
;
; AVX1-LABEL: extractelement_v16i16_13:
; AVX1:       # BB#0:
; AVX1-NEXT:    vextractf128 $1, %ymm0, %xmm0
; AVX1-NEXT:    vpextrw $5, %xmm0, %eax
; AVX1-NEXT:    vzeroupper
; AVX1-NEXT:    retq
;
; AVX2-LABEL: extractelement_v16i16_13:
; AVX2:       # BB#0:
; AVX2-NEXT:    vextracti128 $1, %ymm0, %xmm0
; AVX2-NEXT:    vpextrw $5, %xmm0, %eax
; AVX2-NEXT:    vzeroupper
; AVX2-NEXT:    retq
  %b = extractelement <16 x i16> %a, i256 13
  ret i16 %b
}

define i32 @extractelement_v8i32_0(<8 x i32> %a) nounwind {
; SSE-LABEL: extractelement_v8i32_0:
; SSE:       # BB#0:
; SSE-NEXT:    movd %xmm1, %eax
; SSE-NEXT:    retq
;
; AVX-LABEL: extractelement_v8i32_0:
; AVX:       # BB#0:
; AVX-NEXT:    vextractf128 $1, %ymm0, %xmm0
; AVX-NEXT:    vmovd %xmm0, %eax
; AVX-NEXT:    vzeroupper
; AVX-NEXT:    retq
  %b = extractelement <8 x i32> %a, i256 4
  ret i32 %b
}

define i32 @extractelement_v8i32_4(<8 x i32> %a) nounwind {
; SSE-LABEL: extractelement_v8i32_4:
; SSE:       # BB#0:
; SSE-NEXT:    movd %xmm1, %eax
; SSE-NEXT:    retq
;
; AVX-LABEL: extractelement_v8i32_4:
; AVX:       # BB#0:
; AVX-NEXT:    vextractf128 $1, %ymm0, %xmm0
; AVX-NEXT:    vmovd %xmm0, %eax
; AVX-NEXT:    vzeroupper
; AVX-NEXT:    retq
  %b = extractelement <8 x i32> %a, i256 4
  ret i32 %b
}

define i32 @extractelement_v8i32_7(<8 x i32> %a) nounwind {
; SSE2-LABEL: extractelement_v8i32_7:
; SSE2:       # BB#0:
; SSE2-NEXT:    pshufd {{.*#+}} xmm0 = xmm1[3,1,2,3]
; SSE2-NEXT:    movd %xmm0, %eax
; SSE2-NEXT:    retq
;
; SSE41-LABEL: extractelement_v8i32_7:
; SSE41:       # BB#0:
; SSE41-NEXT:    pextrd $3, %xmm1, %eax
; SSE41-NEXT:    retq
;
; AVX1-LABEL: extractelement_v8i32_7:
; AVX1:       # BB#0:
; AVX1-NEXT:    vextractf128 $1, %ymm0, %xmm0
; AVX1-NEXT:    vpextrd $3, %xmm0, %eax
; AVX1-NEXT:    vzeroupper
; AVX1-NEXT:    retq
;
; AVX2-LABEL: extractelement_v8i32_7:
; AVX2:       # BB#0:
; AVX2-NEXT:    vextracti128 $1, %ymm0, %xmm0
; AVX2-NEXT:    vpextrd $3, %xmm0, %eax
; AVX2-NEXT:    vzeroupper
; AVX2-NEXT:    retq
  %b = extractelement <8 x i32> %a, i64 7
  ret i32 %b
}

define i64 @extractelement_v4i64_1(<4 x i64> %a, i256 %i) nounwind {
; SSE2-LABEL: extractelement_v4i64_1:
; SSE2:       # BB#0:
; SSE2-NEXT:    pshufd {{.*#+}} xmm0 = xmm0[2,3,0,1]
; SSE2-NEXT:    movd %xmm0, %rax
; SSE2-NEXT:    retq
;
; SSE41-LABEL: extractelement_v4i64_1:
; SSE41:       # BB#0:
; SSE41-NEXT:    pextrq $1, %xmm0, %rax
; SSE41-NEXT:    retq
;
; AVX-LABEL: extractelement_v4i64_1:
; AVX:       # BB#0:
; AVX-NEXT:    vpextrq $1, %xmm0, %rax
; AVX-NEXT:    vzeroupper
; AVX-NEXT:    retq
  %b = extractelement <4 x i64> %a, i256 1
  ret i64 %b
}

define i64 @extractelement_v4i64_3(<4 x i64> %a, i256 %i) nounwind {
; SSE2-LABEL: extractelement_v4i64_3:
; SSE2:       # BB#0:
; SSE2-NEXT:    pshufd {{.*#+}} xmm0 = xmm1[2,3,0,1]
; SSE2-NEXT:    movd %xmm0, %rax
; SSE2-NEXT:    retq
;
; SSE41-LABEL: extractelement_v4i64_3:
; SSE41:       # BB#0:
; SSE41-NEXT:    pextrq $1, %xmm1, %rax
; SSE41-NEXT:    retq
;
; AVX1-LABEL: extractelement_v4i64_3:
; AVX1:       # BB#0:
; AVX1-NEXT:    vextractf128 $1, %ymm0, %xmm0
; AVX1-NEXT:    vpextrq $1, %xmm0, %rax
; AVX1-NEXT:    vzeroupper
; AVX1-NEXT:    retq
;
; AVX2-LABEL: extractelement_v4i64_3:
; AVX2:       # BB#0:
; AVX2-NEXT:    vextracti128 $1, %ymm0, %xmm0
; AVX2-NEXT:    vpextrq $1, %xmm0, %rax
; AVX2-NEXT:    vzeroupper
; AVX2-NEXT:    retq
  %b = extractelement <4 x i64> %a, i256 3
  ret i64 %b
}

;
; ExtractElement - Variable Index
;

define i8 @extractelement_v32i8_var(<32 x i8> %a, i256 %i) nounwind {
; SSE-LABEL: extractelement_v32i8_var:
; SSE:       # BB#0:
; SSE-NEXT:    pushq %rbp
; SSE-NEXT:    movq %rsp, %rbp
; SSE-NEXT:    andq $-32, %rsp
; SSE-NEXT:    subq $64, %rsp
; SSE-NEXT:    movaps %xmm1, {{[0-9]+}}(%rsp)
; SSE-NEXT:    movaps %xmm0, (%rsp)
; SSE-NEXT:    leaq (%rsp), %rax
; SSE-NEXT:    movb (%rdi,%rax), %al
; SSE-NEXT:    movq %rbp, %rsp
; SSE-NEXT:    popq %rbp
; SSE-NEXT:    retq
;
; AVX-LABEL: extractelement_v32i8_var:
; AVX:       # BB#0:
; AVX-NEXT:    pushq %rbp
; AVX-NEXT:    movq %rsp, %rbp
; AVX-NEXT:    andq $-32, %rsp
; AVX-NEXT:    subq $64, %rsp
; AVX-NEXT:    vmovaps %ymm0, (%rsp)
; AVX-NEXT:    leaq (%rsp), %rax
; AVX-NEXT:    movb (%rdi,%rax), %al
; AVX-NEXT:    movq %rbp, %rsp
; AVX-NEXT:    popq %rbp
; AVX-NEXT:    vzeroupper
; AVX-NEXT:    retq
  %b = extractelement <32 x i8> %a, i256 %i
  ret i8 %b
}

define i16 @extractelement_v16i16_var(<16 x i16> %a, i256 %i) nounwind {
; SSE-LABEL: extractelement_v16i16_var:
; SSE:       # BB#0:
; SSE-NEXT:    pushq %rbp
; SSE-NEXT:    movq %rsp, %rbp
; SSE-NEXT:    andq $-32, %rsp
; SSE-NEXT:    subq $64, %rsp
; SSE-NEXT:    movaps %xmm1, {{[0-9]+}}(%rsp)
; SSE-NEXT:    movaps %xmm0, (%rsp)
; SSE-NEXT:    movzwl (%rsp,%rdi,2), %eax
; SSE-NEXT:    movq %rbp, %rsp
; SSE-NEXT:    popq %rbp
; SSE-NEXT:    retq
;
; AVX-LABEL: extractelement_v16i16_var:
; AVX:       # BB#0:
; AVX-NEXT:    pushq %rbp
; AVX-NEXT:    movq %rsp, %rbp
; AVX-NEXT:    andq $-32, %rsp
; AVX-NEXT:    subq $64, %rsp
; AVX-NEXT:    vmovaps %ymm0, (%rsp)
; AVX-NEXT:    movzwl (%rsp,%rdi,2), %eax
; AVX-NEXT:    movq %rbp, %rsp
; AVX-NEXT:    popq %rbp
; AVX-NEXT:    vzeroupper
; AVX-NEXT:    retq
  %b = extractelement <16 x i16> %a, i256 %i
  ret i16 %b
}

define i32 @extractelement_v8i32_var(<8 x i32> %a, i256 %i) nounwind {
; SSE-LABEL: extractelement_v8i32_var:
; SSE:       # BB#0:
; SSE-NEXT:    pushq %rbp
; SSE-NEXT:    movq %rsp, %rbp
; SSE-NEXT:    andq $-32, %rsp
; SSE-NEXT:    subq $64, %rsp
; SSE-NEXT:    movaps %xmm1, {{[0-9]+}}(%rsp)
; SSE-NEXT:    movaps %xmm0, (%rsp)
; SSE-NEXT:    movl (%rsp,%rdi,4), %eax
; SSE-NEXT:    movq %rbp, %rsp
; SSE-NEXT:    popq %rbp
; SSE-NEXT:    retq
;
; AVX1-LABEL: extractelement_v8i32_var:
; AVX1:       # BB#0:
; AVX1-NEXT:    pushq %rbp
; AVX1-NEXT:    movq %rsp, %rbp
; AVX1-NEXT:    andq $-32, %rsp
; AVX1-NEXT:    subq $64, %rsp
; AVX1-NEXT:    vmovaps %ymm0, (%rsp)
; AVX1-NEXT:    movl (%rsp,%rdi,4), %eax
; AVX1-NEXT:    movq %rbp, %rsp
; AVX1-NEXT:    popq %rbp
; AVX1-NEXT:    vzeroupper
; AVX1-NEXT:    retq
;
; AVX2-LABEL: extractelement_v8i32_var:
; AVX2:       # BB#0:
; AVX2-NEXT:    vmovd %edi, %xmm1
; AVX2-NEXT:    vpermd %ymm0, %ymm1, %ymm0
; AVX2-NEXT:    vmovd %xmm0, %eax
; AVX2-NEXT:    vzeroupper
; AVX2-NEXT:    retq
  %b = extractelement <8 x i32> %a, i256 %i
  ret i32 %b
}

define i64 @extractelement_v4i64_var(<4 x i64> %a, i256 %i) nounwind {
; SSE-LABEL: extractelement_v4i64_var:
; SSE:       # BB#0:
; SSE-NEXT:    pushq %rbp
; SSE-NEXT:    movq %rsp, %rbp
; SSE-NEXT:    andq $-32, %rsp
; SSE-NEXT:    subq $64, %rsp
; SSE-NEXT:    movaps %xmm1, {{[0-9]+}}(%rsp)
; SSE-NEXT:    movaps %xmm0, (%rsp)
; SSE-NEXT:    movq (%rsp,%rdi,8), %rax
; SSE-NEXT:    movq %rbp, %rsp
; SSE-NEXT:    popq %rbp
; SSE-NEXT:    retq
;
; AVX-LABEL: extractelement_v4i64_var:
; AVX:       # BB#0:
; AVX-NEXT:    pushq %rbp
; AVX-NEXT:    movq %rsp, %rbp
; AVX-NEXT:    andq $-32, %rsp
; AVX-NEXT:    subq $64, %rsp
; AVX-NEXT:    vmovaps %ymm0, (%rsp)
; AVX-NEXT:    movq (%rsp,%rdi,8), %rax
; AVX-NEXT:    movq %rbp, %rsp
; AVX-NEXT:    popq %rbp
; AVX-NEXT:    vzeroupper
; AVX-NEXT:    retq
  %b = extractelement <4 x i64> %a, i256 %i
  ret i64 %b
}

;
; ExtractElement - Constant (Out Of Range) Index
;

define i8 @extractelement_32i8_m1(<32 x i8> %a) nounwind {
; SSE-LABEL: extractelement_32i8_m1:
; SSE:       # BB#0:
; SSE-NEXT:    retq
;
; AVX-LABEL: extractelement_32i8_m1:
; AVX:       # BB#0:
; AVX-NEXT:    retq
  %b = extractelement <32 x i8> %a, i256 -1
  ret i8 %b
}

define i16 @extractelement_v16i16_m4(<16 x i16> %a, i256 %i) nounwind {
; SSE-LABEL: extractelement_v16i16_m4:
; SSE:       # BB#0:
; SSE-NEXT:    retq
;
; AVX-LABEL: extractelement_v16i16_m4:
; AVX:       # BB#0:
; AVX-NEXT:    retq
  %b = extractelement <16 x i16> %a, i256 -4
  ret i16 %b
}

define i32 @extractelement_v8i32_15(<8 x i32> %a) nounwind {
; SSE-LABEL: extractelement_v8i32_15:
; SSE:       # BB#0:
; SSE-NEXT:    retq
;
; AVX-LABEL: extractelement_v8i32_15:
; AVX:       # BB#0:
; AVX-NEXT:    retq
  %b = extractelement <8 x i32> %a, i64 15
  ret i32 %b
}

define i64 @extractelement_v4i64_4(<4 x i64> %a, i256 %i) nounwind {
; SSE-LABEL: extractelement_v4i64_4:
; SSE:       # BB#0:
; SSE-NEXT:    retq
;
; AVX-LABEL: extractelement_v4i64_4:
; AVX:       # BB#0:
; AVX-NEXT:    retq
  %b = extractelement <4 x i64> %a, i256 4
  ret i64 %b
}

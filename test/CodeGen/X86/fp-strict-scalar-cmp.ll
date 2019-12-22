; RUN: llc -disable-strictnode-mutation < %s -mtriple=i686-unknown-unknown -mattr=+sse2 -O3 | FileCheck %s --check-prefixes=CHECK-32
; RUN: llc -disable-strictnode-mutation < %s -mtriple=x86_64-unknown-unknown -mattr=+sse2 -O3 | FileCheck %s --check-prefixes=CHECK-64
; RUN: llc -disable-strictnode-mutation < %s -mtriple=i686-unknown-unknown -mattr=+avx -O3 | FileCheck %s --check-prefixes=CHECK-32
; RUN: llc -disable-strictnode-mutation < %s -mtriple=x86_64-unknown-unknown -mattr=+avx -O3 | FileCheck %s --check-prefixes=CHECK-64
; RUN: llc -disable-strictnode-mutation < %s -mtriple=i686-unknown-unknown -mattr=+avx512f -mattr=+avx512vl -O3 | FileCheck %s --check-prefixes=CHECK-32
; RUN: llc -disable-strictnode-mutation < %s -mtriple=x86_64-unknown-unknown -mattr=+avx512f -mattr=+avx512vl -O3 | FileCheck %s --check-prefixes=CHECK-64
; RUN: llc -disable-strictnode-mutation < %s -mtriple=i686-unknown-unknown -mattr=-sse -O3 | FileCheck %s --check-prefixes=X87
; RUN: llc -disable-strictnode-mutation < %s -mtriple=i686-unknown-unknown -mattr=-sse,+cmov -O3 | FileCheck %s --check-prefixes=X87-CMOV

define i32 @test_f32_oeq_q(i32 %a, i32 %b, float %f1, float %f2) #0 {
; CHECK-32-LABEL: test_f32_oeq_q:
; CHECK-32:       # %bb.0:
; CHECK-32-NEXT:    {{v?}}movss {{.*#+}} xmm0 = mem[0],zero,zero,zero
; CHECK-32-NEXT:    {{v?}}ucomiss {{[0-9]+}}(%esp), %xmm0
; CHECK-32-NEXT:    leal {{[0-9]+}}(%esp), %eax
; CHECK-32-NEXT:    leal {{[0-9]+}}(%esp), %ecx
; CHECK-32-NEXT:    cmovnel %eax, %ecx
; CHECK-32-NEXT:    cmovpl %eax, %ecx
; CHECK-32-NEXT:    movl (%ecx), %eax
; CHECK-32-NEXT:    retl
;
; CHECK-64-LABEL: test_f32_oeq_q:
; CHECK-64:       # %bb.0:
; CHECK-64-NEXT:    movl %edi, %eax
; CHECK-64-NEXT:    {{v?}}ucomiss %xmm1, %xmm0
; CHECK-64-NEXT:    cmovnel %esi, %eax
; CHECK-64-NEXT:    cmovpl %esi, %eax
; CHECK-64-NEXT:    retq
;
; X87-LABEL: test_f32_oeq_q:
; X87:       # %bb.0:
; X87-NEXT:    flds {{[0-9]+}}(%esp)
; X87-NEXT:    flds {{[0-9]+}}(%esp)
; X87-NEXT:    fucompp
; X87-NEXT:    fnstsw %ax
; X87-NEXT:    # kill: def $ah killed $ah killed $ax
; X87-NEXT:    sahf
; X87-NEXT:    leal {{[0-9]+}}(%esp), %eax
; X87-NEXT:    jne .LBB0_3
; X87-NEXT:  # %bb.1:
; X87-NEXT:    jp .LBB0_3
; X87-NEXT:  # %bb.2:
; X87-NEXT:    leal {{[0-9]+}}(%esp), %eax
; X87-NEXT:  .LBB0_3:
; X87-NEXT:    movl (%eax), %eax
; X87-NEXT:    retl
;
; X87-CMOV-LABEL: test_f32_oeq_q:
; X87-CMOV:       # %bb.0:
; X87-CMOV-NEXT:    flds {{[0-9]+}}(%esp)
; X87-CMOV-NEXT:    flds {{[0-9]+}}(%esp)
; X87-CMOV-NEXT:    fucompi %st(1), %st
; X87-CMOV-NEXT:    fstp %st(0)
; X87-CMOV-NEXT:    leal {{[0-9]+}}(%esp), %eax
; X87-CMOV-NEXT:    leal {{[0-9]+}}(%esp), %ecx
; X87-CMOV-NEXT:    cmovnel %eax, %ecx
; X87-CMOV-NEXT:    cmovpl %eax, %ecx
; X87-CMOV-NEXT:    movl (%ecx), %eax
; X87-CMOV-NEXT:    retl
  %cond = call i1 @llvm.experimental.constrained.fcmp.f32(
                                               float %f1, float %f2, metadata !"oeq",
                                               metadata !"fpexcept.strict") #0
  %res = select i1 %cond, i32 %a, i32 %b
  ret i32 %res
}

define i32 @test_f32_ogt_q(i32 %a, i32 %b, float %f1, float %f2) #0 {
; CHECK-32-LABEL: test_f32_ogt_q:
; CHECK-32:       # %bb.0:
; CHECK-32-NEXT:    {{v?}}movss {{.*#+}} xmm0 = mem[0],zero,zero,zero
; CHECK-32-NEXT:    {{v?}}ucomiss {{[0-9]+}}(%esp), %xmm0
; CHECK-32-NEXT:    leal {{[0-9]+}}(%esp), %eax
; CHECK-32-NEXT:    leal {{[0-9]+}}(%esp), %ecx
; CHECK-32-NEXT:    cmoval %eax, %ecx
; CHECK-32-NEXT:    movl (%ecx), %eax
; CHECK-32-NEXT:    retl
;
; CHECK-64-LABEL: test_f32_ogt_q:
; CHECK-64:       # %bb.0:
; CHECK-64-NEXT:    movl %edi, %eax
; CHECK-64-NEXT:    {{v?}}ucomiss %xmm1, %xmm0
; CHECK-64-NEXT:    cmovbel %esi, %eax
; CHECK-64-NEXT:    retq
;
; X87-LABEL: test_f32_ogt_q:
; X87:       # %bb.0:
; X87-NEXT:    flds {{[0-9]+}}(%esp)
; X87-NEXT:    flds {{[0-9]+}}(%esp)
; X87-NEXT:    fucompp
; X87-NEXT:    fnstsw %ax
; X87-NEXT:    # kill: def $ah killed $ah killed $ax
; X87-NEXT:    sahf
; X87-NEXT:    ja .LBB1_1
; X87-NEXT:  # %bb.2:
; X87-NEXT:    leal {{[0-9]+}}(%esp), %eax
; X87-NEXT:    movl (%eax), %eax
; X87-NEXT:    retl
; X87-NEXT:  .LBB1_1:
; X87-NEXT:    leal {{[0-9]+}}(%esp), %eax
; X87-NEXT:    movl (%eax), %eax
; X87-NEXT:    retl
;
; X87-CMOV-LABEL: test_f32_ogt_q:
; X87-CMOV:       # %bb.0:
; X87-CMOV-NEXT:    flds {{[0-9]+}}(%esp)
; X87-CMOV-NEXT:    flds {{[0-9]+}}(%esp)
; X87-CMOV-NEXT:    fucompi %st(1), %st
; X87-CMOV-NEXT:    fstp %st(0)
; X87-CMOV-NEXT:    leal {{[0-9]+}}(%esp), %eax
; X87-CMOV-NEXT:    leal {{[0-9]+}}(%esp), %ecx
; X87-CMOV-NEXT:    cmoval %eax, %ecx
; X87-CMOV-NEXT:    movl (%ecx), %eax
; X87-CMOV-NEXT:    retl
  %cond = call i1 @llvm.experimental.constrained.fcmp.f32(
                                               float %f1, float %f2, metadata !"ogt",
                                               metadata !"fpexcept.strict") #0
  %res = select i1 %cond, i32 %a, i32 %b
  ret i32 %res
}

define i32 @test_f32_oge_q(i32 %a, i32 %b, float %f1, float %f2) #0 {
; CHECK-32-LABEL: test_f32_oge_q:
; CHECK-32:       # %bb.0:
; CHECK-32-NEXT:    {{v?}}movss {{.*#+}} xmm0 = mem[0],zero,zero,zero
; CHECK-32-NEXT:    {{v?}}ucomiss {{[0-9]+}}(%esp), %xmm0
; CHECK-32-NEXT:    leal {{[0-9]+}}(%esp), %eax
; CHECK-32-NEXT:    leal {{[0-9]+}}(%esp), %ecx
; CHECK-32-NEXT:    cmovael %eax, %ecx
; CHECK-32-NEXT:    movl (%ecx), %eax
; CHECK-32-NEXT:    retl
;
; CHECK-64-LABEL: test_f32_oge_q:
; CHECK-64:       # %bb.0:
; CHECK-64-NEXT:    movl %edi, %eax
; CHECK-64-NEXT:    {{v?}}ucomiss %xmm1, %xmm0
; CHECK-64-NEXT:    cmovbl %esi, %eax
; CHECK-64-NEXT:    retq
;
; X87-LABEL: test_f32_oge_q:
; X87:       # %bb.0:
; X87-NEXT:    flds {{[0-9]+}}(%esp)
; X87-NEXT:    flds {{[0-9]+}}(%esp)
; X87-NEXT:    fucompp
; X87-NEXT:    fnstsw %ax
; X87-NEXT:    # kill: def $ah killed $ah killed $ax
; X87-NEXT:    sahf
; X87-NEXT:    jae .LBB2_1
; X87-NEXT:  # %bb.2:
; X87-NEXT:    leal {{[0-9]+}}(%esp), %eax
; X87-NEXT:    movl (%eax), %eax
; X87-NEXT:    retl
; X87-NEXT:  .LBB2_1:
; X87-NEXT:    leal {{[0-9]+}}(%esp), %eax
; X87-NEXT:    movl (%eax), %eax
; X87-NEXT:    retl
;
; X87-CMOV-LABEL: test_f32_oge_q:
; X87-CMOV:       # %bb.0:
; X87-CMOV-NEXT:    flds {{[0-9]+}}(%esp)
; X87-CMOV-NEXT:    flds {{[0-9]+}}(%esp)
; X87-CMOV-NEXT:    fucompi %st(1), %st
; X87-CMOV-NEXT:    fstp %st(0)
; X87-CMOV-NEXT:    leal {{[0-9]+}}(%esp), %eax
; X87-CMOV-NEXT:    leal {{[0-9]+}}(%esp), %ecx
; X87-CMOV-NEXT:    cmovael %eax, %ecx
; X87-CMOV-NEXT:    movl (%ecx), %eax
; X87-CMOV-NEXT:    retl
  %cond = call i1 @llvm.experimental.constrained.fcmp.f32(
                                               float %f1, float %f2, metadata !"oge",
                                               metadata !"fpexcept.strict") #0
  %res = select i1 %cond, i32 %a, i32 %b
  ret i32 %res
}

define i32 @test_f32_olt_q(i32 %a, i32 %b, float %f1, float %f2) #0 {
; CHECK-32-LABEL: test_f32_olt_q:
; CHECK-32:       # %bb.0:
; CHECK-32-NEXT:    {{v?}}movss {{.*#+}} xmm0 = mem[0],zero,zero,zero
; CHECK-32-NEXT:    {{v?}}ucomiss {{[0-9]+}}(%esp), %xmm0
; CHECK-32-NEXT:    leal {{[0-9]+}}(%esp), %eax
; CHECK-32-NEXT:    leal {{[0-9]+}}(%esp), %ecx
; CHECK-32-NEXT:    cmoval %eax, %ecx
; CHECK-32-NEXT:    movl (%ecx), %eax
; CHECK-32-NEXT:    retl
;
; CHECK-64-LABEL: test_f32_olt_q:
; CHECK-64:       # %bb.0:
; CHECK-64-NEXT:    movl %edi, %eax
; CHECK-64-NEXT:    {{v?}}ucomiss %xmm0, %xmm1
; CHECK-64-NEXT:    cmovbel %esi, %eax
; CHECK-64-NEXT:    retq
;
; X87-LABEL: test_f32_olt_q:
; X87:       # %bb.0:
; X87-NEXT:    flds {{[0-9]+}}(%esp)
; X87-NEXT:    flds {{[0-9]+}}(%esp)
; X87-NEXT:    fucompp
; X87-NEXT:    fnstsw %ax
; X87-NEXT:    # kill: def $ah killed $ah killed $ax
; X87-NEXT:    sahf
; X87-NEXT:    ja .LBB3_1
; X87-NEXT:  # %bb.2:
; X87-NEXT:    leal {{[0-9]+}}(%esp), %eax
; X87-NEXT:    movl (%eax), %eax
; X87-NEXT:    retl
; X87-NEXT:  .LBB3_1:
; X87-NEXT:    leal {{[0-9]+}}(%esp), %eax
; X87-NEXT:    movl (%eax), %eax
; X87-NEXT:    retl
;
; X87-CMOV-LABEL: test_f32_olt_q:
; X87-CMOV:       # %bb.0:
; X87-CMOV-NEXT:    flds {{[0-9]+}}(%esp)
; X87-CMOV-NEXT:    flds {{[0-9]+}}(%esp)
; X87-CMOV-NEXT:    fucompi %st(1), %st
; X87-CMOV-NEXT:    fstp %st(0)
; X87-CMOV-NEXT:    leal {{[0-9]+}}(%esp), %eax
; X87-CMOV-NEXT:    leal {{[0-9]+}}(%esp), %ecx
; X87-CMOV-NEXT:    cmoval %eax, %ecx
; X87-CMOV-NEXT:    movl (%ecx), %eax
; X87-CMOV-NEXT:    retl
  %cond = call i1 @llvm.experimental.constrained.fcmp.f32(
                                               float %f1, float %f2, metadata !"olt",
                                               metadata !"fpexcept.strict") #0
  %res = select i1 %cond, i32 %a, i32 %b
  ret i32 %res
}

define i32 @test_f32_ole_q(i32 %a, i32 %b, float %f1, float %f2) #0 {
; CHECK-32-LABEL: test_f32_ole_q:
; CHECK-32:       # %bb.0:
; CHECK-32-NEXT:    {{v?}}movss {{.*#+}} xmm0 = mem[0],zero,zero,zero
; CHECK-32-NEXT:    {{v?}}ucomiss {{[0-9]+}}(%esp), %xmm0
; CHECK-32-NEXT:    leal {{[0-9]+}}(%esp), %eax
; CHECK-32-NEXT:    leal {{[0-9]+}}(%esp), %ecx
; CHECK-32-NEXT:    cmovael %eax, %ecx
; CHECK-32-NEXT:    movl (%ecx), %eax
; CHECK-32-NEXT:    retl
;
; CHECK-64-LABEL: test_f32_ole_q:
; CHECK-64:       # %bb.0:
; CHECK-64-NEXT:    movl %edi, %eax
; CHECK-64-NEXT:    {{v?}}ucomiss %xmm0, %xmm1
; CHECK-64-NEXT:    cmovbl %esi, %eax
; CHECK-64-NEXT:    retq
;
; X87-LABEL: test_f32_ole_q:
; X87:       # %bb.0:
; X87-NEXT:    flds {{[0-9]+}}(%esp)
; X87-NEXT:    flds {{[0-9]+}}(%esp)
; X87-NEXT:    fucompp
; X87-NEXT:    fnstsw %ax
; X87-NEXT:    # kill: def $ah killed $ah killed $ax
; X87-NEXT:    sahf
; X87-NEXT:    jae .LBB4_1
; X87-NEXT:  # %bb.2:
; X87-NEXT:    leal {{[0-9]+}}(%esp), %eax
; X87-NEXT:    movl (%eax), %eax
; X87-NEXT:    retl
; X87-NEXT:  .LBB4_1:
; X87-NEXT:    leal {{[0-9]+}}(%esp), %eax
; X87-NEXT:    movl (%eax), %eax
; X87-NEXT:    retl
;
; X87-CMOV-LABEL: test_f32_ole_q:
; X87-CMOV:       # %bb.0:
; X87-CMOV-NEXT:    flds {{[0-9]+}}(%esp)
; X87-CMOV-NEXT:    flds {{[0-9]+}}(%esp)
; X87-CMOV-NEXT:    fucompi %st(1), %st
; X87-CMOV-NEXT:    fstp %st(0)
; X87-CMOV-NEXT:    leal {{[0-9]+}}(%esp), %eax
; X87-CMOV-NEXT:    leal {{[0-9]+}}(%esp), %ecx
; X87-CMOV-NEXT:    cmovael %eax, %ecx
; X87-CMOV-NEXT:    movl (%ecx), %eax
; X87-CMOV-NEXT:    retl
  %cond = call i1 @llvm.experimental.constrained.fcmp.f32(
                                               float %f1, float %f2, metadata !"ole",
                                               metadata !"fpexcept.strict") #0
  %res = select i1 %cond, i32 %a, i32 %b
  ret i32 %res
}

define i32 @test_f32_one_q(i32 %a, i32 %b, float %f1, float %f2) #0 {
; CHECK-32-LABEL: test_f32_one_q:
; CHECK-32:       # %bb.0:
; CHECK-32-NEXT:    {{v?}}movss {{.*#+}} xmm0 = mem[0],zero,zero,zero
; CHECK-32-NEXT:    {{v?}}ucomiss {{[0-9]+}}(%esp), %xmm0
; CHECK-32-NEXT:    leal {{[0-9]+}}(%esp), %eax
; CHECK-32-NEXT:    leal {{[0-9]+}}(%esp), %ecx
; CHECK-32-NEXT:    cmovnel %eax, %ecx
; CHECK-32-NEXT:    movl (%ecx), %eax
; CHECK-32-NEXT:    retl
;
; CHECK-64-LABEL: test_f32_one_q:
; CHECK-64:       # %bb.0:
; CHECK-64-NEXT:    movl %edi, %eax
; CHECK-64-NEXT:    {{v?}}ucomiss %xmm1, %xmm0
; CHECK-64-NEXT:    cmovel %esi, %eax
; CHECK-64-NEXT:    retq
;
; X87-LABEL: test_f32_one_q:
; X87:       # %bb.0:
; X87-NEXT:    flds {{[0-9]+}}(%esp)
; X87-NEXT:    flds {{[0-9]+}}(%esp)
; X87-NEXT:    fucompp
; X87-NEXT:    fnstsw %ax
; X87-NEXT:    # kill: def $ah killed $ah killed $ax
; X87-NEXT:    sahf
; X87-NEXT:    jne .LBB5_1
; X87-NEXT:  # %bb.2:
; X87-NEXT:    leal {{[0-9]+}}(%esp), %eax
; X87-NEXT:    movl (%eax), %eax
; X87-NEXT:    retl
; X87-NEXT:  .LBB5_1:
; X87-NEXT:    leal {{[0-9]+}}(%esp), %eax
; X87-NEXT:    movl (%eax), %eax
; X87-NEXT:    retl
;
; X87-CMOV-LABEL: test_f32_one_q:
; X87-CMOV:       # %bb.0:
; X87-CMOV-NEXT:    flds {{[0-9]+}}(%esp)
; X87-CMOV-NEXT:    flds {{[0-9]+}}(%esp)
; X87-CMOV-NEXT:    fucompi %st(1), %st
; X87-CMOV-NEXT:    fstp %st(0)
; X87-CMOV-NEXT:    leal {{[0-9]+}}(%esp), %eax
; X87-CMOV-NEXT:    leal {{[0-9]+}}(%esp), %ecx
; X87-CMOV-NEXT:    cmovnel %eax, %ecx
; X87-CMOV-NEXT:    movl (%ecx), %eax
; X87-CMOV-NEXT:    retl
  %cond = call i1 @llvm.experimental.constrained.fcmp.f32(
                                               float %f1, float %f2, metadata !"one",
                                               metadata !"fpexcept.strict") #0
  %res = select i1 %cond, i32 %a, i32 %b
  ret i32 %res
}

define i32 @test_f32_ord_q(i32 %a, i32 %b, float %f1, float %f2) #0 {
; CHECK-32-LABEL: test_f32_ord_q:
; CHECK-32:       # %bb.0:
; CHECK-32-NEXT:    {{v?}}movss {{.*#+}} xmm0 = mem[0],zero,zero,zero
; CHECK-32-NEXT:    {{v?}}ucomiss {{[0-9]+}}(%esp), %xmm0
; CHECK-32-NEXT:    leal {{[0-9]+}}(%esp), %eax
; CHECK-32-NEXT:    leal {{[0-9]+}}(%esp), %ecx
; CHECK-32-NEXT:    cmovnpl %eax, %ecx
; CHECK-32-NEXT:    movl (%ecx), %eax
; CHECK-32-NEXT:    retl
;
; CHECK-64-LABEL: test_f32_ord_q:
; CHECK-64:       # %bb.0:
; CHECK-64-NEXT:    movl %edi, %eax
; CHECK-64-NEXT:    {{v?}}ucomiss %xmm1, %xmm0
; CHECK-64-NEXT:    cmovpl %esi, %eax
; CHECK-64-NEXT:    retq
;
; X87-LABEL: test_f32_ord_q:
; X87:       # %bb.0:
; X87-NEXT:    flds {{[0-9]+}}(%esp)
; X87-NEXT:    flds {{[0-9]+}}(%esp)
; X87-NEXT:    fucompp
; X87-NEXT:    fnstsw %ax
; X87-NEXT:    # kill: def $ah killed $ah killed $ax
; X87-NEXT:    sahf
; X87-NEXT:    jnp .LBB6_1
; X87-NEXT:  # %bb.2:
; X87-NEXT:    leal {{[0-9]+}}(%esp), %eax
; X87-NEXT:    movl (%eax), %eax
; X87-NEXT:    retl
; X87-NEXT:  .LBB6_1:
; X87-NEXT:    leal {{[0-9]+}}(%esp), %eax
; X87-NEXT:    movl (%eax), %eax
; X87-NEXT:    retl
;
; X87-CMOV-LABEL: test_f32_ord_q:
; X87-CMOV:       # %bb.0:
; X87-CMOV-NEXT:    flds {{[0-9]+}}(%esp)
; X87-CMOV-NEXT:    flds {{[0-9]+}}(%esp)
; X87-CMOV-NEXT:    fucompi %st(1), %st
; X87-CMOV-NEXT:    fstp %st(0)
; X87-CMOV-NEXT:    leal {{[0-9]+}}(%esp), %eax
; X87-CMOV-NEXT:    leal {{[0-9]+}}(%esp), %ecx
; X87-CMOV-NEXT:    cmovnpl %eax, %ecx
; X87-CMOV-NEXT:    movl (%ecx), %eax
; X87-CMOV-NEXT:    retl
  %cond = call i1 @llvm.experimental.constrained.fcmp.f32(
                                               float %f1, float %f2, metadata !"ord",
                                               metadata !"fpexcept.strict") #0
  %res = select i1 %cond, i32 %a, i32 %b
  ret i32 %res
}

define i32 @test_f32_ueq_q(i32 %a, i32 %b, float %f1, float %f2) #0 {
; CHECK-32-LABEL: test_f32_ueq_q:
; CHECK-32:       # %bb.0:
; CHECK-32-NEXT:    {{v?}}movss {{.*#+}} xmm0 = mem[0],zero,zero,zero
; CHECK-32-NEXT:    {{v?}}ucomiss {{[0-9]+}}(%esp), %xmm0
; CHECK-32-NEXT:    leal {{[0-9]+}}(%esp), %eax
; CHECK-32-NEXT:    leal {{[0-9]+}}(%esp), %ecx
; CHECK-32-NEXT:    cmovel %eax, %ecx
; CHECK-32-NEXT:    movl (%ecx), %eax
; CHECK-32-NEXT:    retl
;
; CHECK-64-LABEL: test_f32_ueq_q:
; CHECK-64:       # %bb.0:
; CHECK-64-NEXT:    movl %edi, %eax
; CHECK-64-NEXT:    {{v?}}ucomiss %xmm1, %xmm0
; CHECK-64-NEXT:    cmovnel %esi, %eax
; CHECK-64-NEXT:    retq
;
; X87-LABEL: test_f32_ueq_q:
; X87:       # %bb.0:
; X87-NEXT:    flds {{[0-9]+}}(%esp)
; X87-NEXT:    flds {{[0-9]+}}(%esp)
; X87-NEXT:    fucompp
; X87-NEXT:    fnstsw %ax
; X87-NEXT:    # kill: def $ah killed $ah killed $ax
; X87-NEXT:    sahf
; X87-NEXT:    je .LBB7_1
; X87-NEXT:  # %bb.2:
; X87-NEXT:    leal {{[0-9]+}}(%esp), %eax
; X87-NEXT:    movl (%eax), %eax
; X87-NEXT:    retl
; X87-NEXT:  .LBB7_1:
; X87-NEXT:    leal {{[0-9]+}}(%esp), %eax
; X87-NEXT:    movl (%eax), %eax
; X87-NEXT:    retl
;
; X87-CMOV-LABEL: test_f32_ueq_q:
; X87-CMOV:       # %bb.0:
; X87-CMOV-NEXT:    flds {{[0-9]+}}(%esp)
; X87-CMOV-NEXT:    flds {{[0-9]+}}(%esp)
; X87-CMOV-NEXT:    fucompi %st(1), %st
; X87-CMOV-NEXT:    fstp %st(0)
; X87-CMOV-NEXT:    leal {{[0-9]+}}(%esp), %eax
; X87-CMOV-NEXT:    leal {{[0-9]+}}(%esp), %ecx
; X87-CMOV-NEXT:    cmovel %eax, %ecx
; X87-CMOV-NEXT:    movl (%ecx), %eax
; X87-CMOV-NEXT:    retl
  %cond = call i1 @llvm.experimental.constrained.fcmp.f32(
                                               float %f1, float %f2, metadata !"ueq",
                                               metadata !"fpexcept.strict") #0
  %res = select i1 %cond, i32 %a, i32 %b
  ret i32 %res
}

define i32 @test_f32_ugt_q(i32 %a, i32 %b, float %f1, float %f2) #0 {
; CHECK-32-LABEL: test_f32_ugt_q:
; CHECK-32:       # %bb.0:
; CHECK-32-NEXT:    {{v?}}movss {{.*#+}} xmm0 = mem[0],zero,zero,zero
; CHECK-32-NEXT:    {{v?}}ucomiss {{[0-9]+}}(%esp), %xmm0
; CHECK-32-NEXT:    leal {{[0-9]+}}(%esp), %eax
; CHECK-32-NEXT:    leal {{[0-9]+}}(%esp), %ecx
; CHECK-32-NEXT:    cmovbl %eax, %ecx
; CHECK-32-NEXT:    movl (%ecx), %eax
; CHECK-32-NEXT:    retl
;
; CHECK-64-LABEL: test_f32_ugt_q:
; CHECK-64:       # %bb.0:
; CHECK-64-NEXT:    movl %edi, %eax
; CHECK-64-NEXT:    {{v?}}ucomiss %xmm0, %xmm1
; CHECK-64-NEXT:    cmovael %esi, %eax
; CHECK-64-NEXT:    retq
;
; X87-LABEL: test_f32_ugt_q:
; X87:       # %bb.0:
; X87-NEXT:    flds {{[0-9]+}}(%esp)
; X87-NEXT:    flds {{[0-9]+}}(%esp)
; X87-NEXT:    fucompp
; X87-NEXT:    fnstsw %ax
; X87-NEXT:    # kill: def $ah killed $ah killed $ax
; X87-NEXT:    sahf
; X87-NEXT:    jb .LBB8_1
; X87-NEXT:  # %bb.2:
; X87-NEXT:    leal {{[0-9]+}}(%esp), %eax
; X87-NEXT:    movl (%eax), %eax
; X87-NEXT:    retl
; X87-NEXT:  .LBB8_1:
; X87-NEXT:    leal {{[0-9]+}}(%esp), %eax
; X87-NEXT:    movl (%eax), %eax
; X87-NEXT:    retl
;
; X87-CMOV-LABEL: test_f32_ugt_q:
; X87-CMOV:       # %bb.0:
; X87-CMOV-NEXT:    flds {{[0-9]+}}(%esp)
; X87-CMOV-NEXT:    flds {{[0-9]+}}(%esp)
; X87-CMOV-NEXT:    fucompi %st(1), %st
; X87-CMOV-NEXT:    fstp %st(0)
; X87-CMOV-NEXT:    leal {{[0-9]+}}(%esp), %eax
; X87-CMOV-NEXT:    leal {{[0-9]+}}(%esp), %ecx
; X87-CMOV-NEXT:    cmovbl %eax, %ecx
; X87-CMOV-NEXT:    movl (%ecx), %eax
; X87-CMOV-NEXT:    retl
  %cond = call i1 @llvm.experimental.constrained.fcmp.f32(
                                               float %f1, float %f2, metadata !"ugt",
                                               metadata !"fpexcept.strict") #0
  %res = select i1 %cond, i32 %a, i32 %b
  ret i32 %res
}

define i32 @test_f32_uge_q(i32 %a, i32 %b, float %f1, float %f2) #0 {
; CHECK-32-LABEL: test_f32_uge_q:
; CHECK-32:       # %bb.0:
; CHECK-32-NEXT:    {{v?}}movss {{.*#+}} xmm0 = mem[0],zero,zero,zero
; CHECK-32-NEXT:    {{v?}}ucomiss {{[0-9]+}}(%esp), %xmm0
; CHECK-32-NEXT:    leal {{[0-9]+}}(%esp), %eax
; CHECK-32-NEXT:    leal {{[0-9]+}}(%esp), %ecx
; CHECK-32-NEXT:    cmovbel %eax, %ecx
; CHECK-32-NEXT:    movl (%ecx), %eax
; CHECK-32-NEXT:    retl
;
; CHECK-64-LABEL: test_f32_uge_q:
; CHECK-64:       # %bb.0:
; CHECK-64-NEXT:    movl %edi, %eax
; CHECK-64-NEXT:    {{v?}}ucomiss %xmm0, %xmm1
; CHECK-64-NEXT:    cmoval %esi, %eax
; CHECK-64-NEXT:    retq
;
; X87-LABEL: test_f32_uge_q:
; X87:       # %bb.0:
; X87-NEXT:    flds {{[0-9]+}}(%esp)
; X87-NEXT:    flds {{[0-9]+}}(%esp)
; X87-NEXT:    fucompp
; X87-NEXT:    fnstsw %ax
; X87-NEXT:    # kill: def $ah killed $ah killed $ax
; X87-NEXT:    sahf
; X87-NEXT:    jbe .LBB9_1
; X87-NEXT:  # %bb.2:
; X87-NEXT:    leal {{[0-9]+}}(%esp), %eax
; X87-NEXT:    movl (%eax), %eax
; X87-NEXT:    retl
; X87-NEXT:  .LBB9_1:
; X87-NEXT:    leal {{[0-9]+}}(%esp), %eax
; X87-NEXT:    movl (%eax), %eax
; X87-NEXT:    retl
;
; X87-CMOV-LABEL: test_f32_uge_q:
; X87-CMOV:       # %bb.0:
; X87-CMOV-NEXT:    flds {{[0-9]+}}(%esp)
; X87-CMOV-NEXT:    flds {{[0-9]+}}(%esp)
; X87-CMOV-NEXT:    fucompi %st(1), %st
; X87-CMOV-NEXT:    fstp %st(0)
; X87-CMOV-NEXT:    leal {{[0-9]+}}(%esp), %eax
; X87-CMOV-NEXT:    leal {{[0-9]+}}(%esp), %ecx
; X87-CMOV-NEXT:    cmovbel %eax, %ecx
; X87-CMOV-NEXT:    movl (%ecx), %eax
; X87-CMOV-NEXT:    retl
  %cond = call i1 @llvm.experimental.constrained.fcmp.f32(
                                               float %f1, float %f2, metadata !"uge",
                                               metadata !"fpexcept.strict") #0
  %res = select i1 %cond, i32 %a, i32 %b
  ret i32 %res
}

define i32 @test_f32_ult_q(i32 %a, i32 %b, float %f1, float %f2) #0 {
; CHECK-32-LABEL: test_f32_ult_q:
; CHECK-32:       # %bb.0:
; CHECK-32-NEXT:    {{v?}}movss {{.*#+}} xmm0 = mem[0],zero,zero,zero
; CHECK-32-NEXT:    {{v?}}ucomiss {{[0-9]+}}(%esp), %xmm0
; CHECK-32-NEXT:    leal {{[0-9]+}}(%esp), %eax
; CHECK-32-NEXT:    leal {{[0-9]+}}(%esp), %ecx
; CHECK-32-NEXT:    cmovbl %eax, %ecx
; CHECK-32-NEXT:    movl (%ecx), %eax
; CHECK-32-NEXT:    retl
;
; CHECK-64-LABEL: test_f32_ult_q:
; CHECK-64:       # %bb.0:
; CHECK-64-NEXT:    movl %edi, %eax
; CHECK-64-NEXT:    {{v?}}ucomiss %xmm1, %xmm0
; CHECK-64-NEXT:    cmovael %esi, %eax
; CHECK-64-NEXT:    retq
;
; X87-LABEL: test_f32_ult_q:
; X87:       # %bb.0:
; X87-NEXT:    flds {{[0-9]+}}(%esp)
; X87-NEXT:    flds {{[0-9]+}}(%esp)
; X87-NEXT:    fucompp
; X87-NEXT:    fnstsw %ax
; X87-NEXT:    # kill: def $ah killed $ah killed $ax
; X87-NEXT:    sahf
; X87-NEXT:    jb .LBB10_1
; X87-NEXT:  # %bb.2:
; X87-NEXT:    leal {{[0-9]+}}(%esp), %eax
; X87-NEXT:    movl (%eax), %eax
; X87-NEXT:    retl
; X87-NEXT:  .LBB10_1:
; X87-NEXT:    leal {{[0-9]+}}(%esp), %eax
; X87-NEXT:    movl (%eax), %eax
; X87-NEXT:    retl
;
; X87-CMOV-LABEL: test_f32_ult_q:
; X87-CMOV:       # %bb.0:
; X87-CMOV-NEXT:    flds {{[0-9]+}}(%esp)
; X87-CMOV-NEXT:    flds {{[0-9]+}}(%esp)
; X87-CMOV-NEXT:    fucompi %st(1), %st
; X87-CMOV-NEXT:    fstp %st(0)
; X87-CMOV-NEXT:    leal {{[0-9]+}}(%esp), %eax
; X87-CMOV-NEXT:    leal {{[0-9]+}}(%esp), %ecx
; X87-CMOV-NEXT:    cmovbl %eax, %ecx
; X87-CMOV-NEXT:    movl (%ecx), %eax
; X87-CMOV-NEXT:    retl
  %cond = call i1 @llvm.experimental.constrained.fcmp.f32(
                                               float %f1, float %f2, metadata !"ult",
                                               metadata !"fpexcept.strict") #0
  %res = select i1 %cond, i32 %a, i32 %b
  ret i32 %res
}

define i32 @test_f32_ule_q(i32 %a, i32 %b, float %f1, float %f2) #0 {
; CHECK-32-LABEL: test_f32_ule_q:
; CHECK-32:       # %bb.0:
; CHECK-32-NEXT:    {{v?}}movss {{.*#+}} xmm0 = mem[0],zero,zero,zero
; CHECK-32-NEXT:    {{v?}}ucomiss {{[0-9]+}}(%esp), %xmm0
; CHECK-32-NEXT:    leal {{[0-9]+}}(%esp), %eax
; CHECK-32-NEXT:    leal {{[0-9]+}}(%esp), %ecx
; CHECK-32-NEXT:    cmovbel %eax, %ecx
; CHECK-32-NEXT:    movl (%ecx), %eax
; CHECK-32-NEXT:    retl
;
; CHECK-64-LABEL: test_f32_ule_q:
; CHECK-64:       # %bb.0:
; CHECK-64-NEXT:    movl %edi, %eax
; CHECK-64-NEXT:    {{v?}}ucomiss %xmm1, %xmm0
; CHECK-64-NEXT:    cmoval %esi, %eax
; CHECK-64-NEXT:    retq
;
; X87-LABEL: test_f32_ule_q:
; X87:       # %bb.0:
; X87-NEXT:    flds {{[0-9]+}}(%esp)
; X87-NEXT:    flds {{[0-9]+}}(%esp)
; X87-NEXT:    fucompp
; X87-NEXT:    fnstsw %ax
; X87-NEXT:    # kill: def $ah killed $ah killed $ax
; X87-NEXT:    sahf
; X87-NEXT:    jbe .LBB11_1
; X87-NEXT:  # %bb.2:
; X87-NEXT:    leal {{[0-9]+}}(%esp), %eax
; X87-NEXT:    movl (%eax), %eax
; X87-NEXT:    retl
; X87-NEXT:  .LBB11_1:
; X87-NEXT:    leal {{[0-9]+}}(%esp), %eax
; X87-NEXT:    movl (%eax), %eax
; X87-NEXT:    retl
;
; X87-CMOV-LABEL: test_f32_ule_q:
; X87-CMOV:       # %bb.0:
; X87-CMOV-NEXT:    flds {{[0-9]+}}(%esp)
; X87-CMOV-NEXT:    flds {{[0-9]+}}(%esp)
; X87-CMOV-NEXT:    fucompi %st(1), %st
; X87-CMOV-NEXT:    fstp %st(0)
; X87-CMOV-NEXT:    leal {{[0-9]+}}(%esp), %eax
; X87-CMOV-NEXT:    leal {{[0-9]+}}(%esp), %ecx
; X87-CMOV-NEXT:    cmovbel %eax, %ecx
; X87-CMOV-NEXT:    movl (%ecx), %eax
; X87-CMOV-NEXT:    retl
  %cond = call i1 @llvm.experimental.constrained.fcmp.f32(
                                               float %f1, float %f2, metadata !"ule",
                                               metadata !"fpexcept.strict") #0
  %res = select i1 %cond, i32 %a, i32 %b
  ret i32 %res
}

define i32 @test_f32_une_q(i32 %a, i32 %b, float %f1, float %f2) #0 {
; CHECK-32-LABEL: test_f32_une_q:
; CHECK-32:       # %bb.0:
; CHECK-32-NEXT:    {{v?}}movss {{.*#+}} xmm0 = mem[0],zero,zero,zero
; CHECK-32-NEXT:    {{v?}}ucomiss {{[0-9]+}}(%esp), %xmm0
; CHECK-32-NEXT:    leal {{[0-9]+}}(%esp), %eax
; CHECK-32-NEXT:    leal {{[0-9]+}}(%esp), %ecx
; CHECK-32-NEXT:    cmovnel %eax, %ecx
; CHECK-32-NEXT:    cmovpl %eax, %ecx
; CHECK-32-NEXT:    movl (%ecx), %eax
; CHECK-32-NEXT:    retl
;
; CHECK-64-LABEL: test_f32_une_q:
; CHECK-64:       # %bb.0:
; CHECK-64-NEXT:    movl %esi, %eax
; CHECK-64-NEXT:    {{v?}}ucomiss %xmm1, %xmm0
; CHECK-64-NEXT:    cmovnel %edi, %eax
; CHECK-64-NEXT:    cmovpl %edi, %eax
; CHECK-64-NEXT:    retq
;
; X87-LABEL: test_f32_une_q:
; X87:       # %bb.0:
; X87-NEXT:    flds {{[0-9]+}}(%esp)
; X87-NEXT:    flds {{[0-9]+}}(%esp)
; X87-NEXT:    fucompp
; X87-NEXT:    fnstsw %ax
; X87-NEXT:    # kill: def $ah killed $ah killed $ax
; X87-NEXT:    sahf
; X87-NEXT:    leal {{[0-9]+}}(%esp), %eax
; X87-NEXT:    jne .LBB12_3
; X87-NEXT:  # %bb.1:
; X87-NEXT:    jp .LBB12_3
; X87-NEXT:  # %bb.2:
; X87-NEXT:    leal {{[0-9]+}}(%esp), %eax
; X87-NEXT:  .LBB12_3:
; X87-NEXT:    movl (%eax), %eax
; X87-NEXT:    retl
;
; X87-CMOV-LABEL: test_f32_une_q:
; X87-CMOV:       # %bb.0:
; X87-CMOV-NEXT:    flds {{[0-9]+}}(%esp)
; X87-CMOV-NEXT:    flds {{[0-9]+}}(%esp)
; X87-CMOV-NEXT:    fucompi %st(1), %st
; X87-CMOV-NEXT:    fstp %st(0)
; X87-CMOV-NEXT:    leal {{[0-9]+}}(%esp), %eax
; X87-CMOV-NEXT:    leal {{[0-9]+}}(%esp), %ecx
; X87-CMOV-NEXT:    cmovnel %eax, %ecx
; X87-CMOV-NEXT:    cmovpl %eax, %ecx
; X87-CMOV-NEXT:    movl (%ecx), %eax
; X87-CMOV-NEXT:    retl
  %cond = call i1 @llvm.experimental.constrained.fcmp.f32(
                                               float %f1, float %f2, metadata !"une",
                                               metadata !"fpexcept.strict") #0
  %res = select i1 %cond, i32 %a, i32 %b
  ret i32 %res
}

define i32 @test_f32_uno_q(i32 %a, i32 %b, float %f1, float %f2) #0 {
; CHECK-32-LABEL: test_f32_uno_q:
; CHECK-32:       # %bb.0:
; CHECK-32-NEXT:    {{v?}}movss {{.*#+}} xmm0 = mem[0],zero,zero,zero
; CHECK-32-NEXT:    {{v?}}ucomiss {{[0-9]+}}(%esp), %xmm0
; CHECK-32-NEXT:    leal {{[0-9]+}}(%esp), %eax
; CHECK-32-NEXT:    leal {{[0-9]+}}(%esp), %ecx
; CHECK-32-NEXT:    cmovpl %eax, %ecx
; CHECK-32-NEXT:    movl (%ecx), %eax
; CHECK-32-NEXT:    retl
;
; CHECK-64-LABEL: test_f32_uno_q:
; CHECK-64:       # %bb.0:
; CHECK-64-NEXT:    movl %edi, %eax
; CHECK-64-NEXT:    {{v?}}ucomiss %xmm1, %xmm0
; CHECK-64-NEXT:    cmovnpl %esi, %eax
; CHECK-64-NEXT:    retq
;
; X87-LABEL: test_f32_uno_q:
; X87:       # %bb.0:
; X87-NEXT:    flds {{[0-9]+}}(%esp)
; X87-NEXT:    flds {{[0-9]+}}(%esp)
; X87-NEXT:    fucompp
; X87-NEXT:    fnstsw %ax
; X87-NEXT:    # kill: def $ah killed $ah killed $ax
; X87-NEXT:    sahf
; X87-NEXT:    jp .LBB13_1
; X87-NEXT:  # %bb.2:
; X87-NEXT:    leal {{[0-9]+}}(%esp), %eax
; X87-NEXT:    movl (%eax), %eax
; X87-NEXT:    retl
; X87-NEXT:  .LBB13_1:
; X87-NEXT:    leal {{[0-9]+}}(%esp), %eax
; X87-NEXT:    movl (%eax), %eax
; X87-NEXT:    retl
;
; X87-CMOV-LABEL: test_f32_uno_q:
; X87-CMOV:       # %bb.0:
; X87-CMOV-NEXT:    flds {{[0-9]+}}(%esp)
; X87-CMOV-NEXT:    flds {{[0-9]+}}(%esp)
; X87-CMOV-NEXT:    fucompi %st(1), %st
; X87-CMOV-NEXT:    fstp %st(0)
; X87-CMOV-NEXT:    leal {{[0-9]+}}(%esp), %eax
; X87-CMOV-NEXT:    leal {{[0-9]+}}(%esp), %ecx
; X87-CMOV-NEXT:    cmovpl %eax, %ecx
; X87-CMOV-NEXT:    movl (%ecx), %eax
; X87-CMOV-NEXT:    retl
  %cond = call i1 @llvm.experimental.constrained.fcmp.f32(
                                               float %f1, float %f2, metadata !"uno",
                                               metadata !"fpexcept.strict") #0
  %res = select i1 %cond, i32 %a, i32 %b
  ret i32 %res
}

define i32 @test_f64_oeq_q(i32 %a, i32 %b, double %f1, double %f2) #0 {
; CHECK-32-LABEL: test_f64_oeq_q:
; CHECK-32:       # %bb.0:
; CHECK-32-NEXT:    {{v?}}movsd {{.*#+}} xmm0 = mem[0],zero
; CHECK-32-NEXT:    {{v?}}ucomisd {{[0-9]+}}(%esp), %xmm0
; CHECK-32-NEXT:    leal {{[0-9]+}}(%esp), %eax
; CHECK-32-NEXT:    leal {{[0-9]+}}(%esp), %ecx
; CHECK-32-NEXT:    cmovnel %eax, %ecx
; CHECK-32-NEXT:    cmovpl %eax, %ecx
; CHECK-32-NEXT:    movl (%ecx), %eax
; CHECK-32-NEXT:    retl
;
; CHECK-64-LABEL: test_f64_oeq_q:
; CHECK-64:       # %bb.0:
; CHECK-64-NEXT:    movl %edi, %eax
; CHECK-64-NEXT:    {{v?}}ucomisd %xmm1, %xmm0
; CHECK-64-NEXT:    cmovnel %esi, %eax
; CHECK-64-NEXT:    cmovpl %esi, %eax
; CHECK-64-NEXT:    retq
;
; X87-LABEL: test_f64_oeq_q:
; X87:       # %bb.0:
; X87-NEXT:    fldl {{[0-9]+}}(%esp)
; X87-NEXT:    fldl {{[0-9]+}}(%esp)
; X87-NEXT:    fucompp
; X87-NEXT:    fnstsw %ax
; X87-NEXT:    # kill: def $ah killed $ah killed $ax
; X87-NEXT:    sahf
; X87-NEXT:    leal {{[0-9]+}}(%esp), %eax
; X87-NEXT:    jne .LBB14_3
; X87-NEXT:  # %bb.1:
; X87-NEXT:    jp .LBB14_3
; X87-NEXT:  # %bb.2:
; X87-NEXT:    leal {{[0-9]+}}(%esp), %eax
; X87-NEXT:  .LBB14_3:
; X87-NEXT:    movl (%eax), %eax
; X87-NEXT:    retl
;
; X87-CMOV-LABEL: test_f64_oeq_q:
; X87-CMOV:       # %bb.0:
; X87-CMOV-NEXT:    fldl {{[0-9]+}}(%esp)
; X87-CMOV-NEXT:    fldl {{[0-9]+}}(%esp)
; X87-CMOV-NEXT:    fucompi %st(1), %st
; X87-CMOV-NEXT:    fstp %st(0)
; X87-CMOV-NEXT:    leal {{[0-9]+}}(%esp), %eax
; X87-CMOV-NEXT:    leal {{[0-9]+}}(%esp), %ecx
; X87-CMOV-NEXT:    cmovnel %eax, %ecx
; X87-CMOV-NEXT:    cmovpl %eax, %ecx
; X87-CMOV-NEXT:    movl (%ecx), %eax
; X87-CMOV-NEXT:    retl
  %cond = call i1 @llvm.experimental.constrained.fcmp.f64(
                                               double %f1, double %f2, metadata !"oeq",
                                               metadata !"fpexcept.strict") #0
  %res = select i1 %cond, i32 %a, i32 %b
  ret i32 %res
}

define i32 @test_f64_ogt_q(i32 %a, i32 %b, double %f1, double %f2) #0 {
; CHECK-32-LABEL: test_f64_ogt_q:
; CHECK-32:       # %bb.0:
; CHECK-32-NEXT:    {{v?}}movsd {{.*#+}} xmm0 = mem[0],zero
; CHECK-32-NEXT:    {{v?}}ucomisd {{[0-9]+}}(%esp), %xmm0
; CHECK-32-NEXT:    leal {{[0-9]+}}(%esp), %eax
; CHECK-32-NEXT:    leal {{[0-9]+}}(%esp), %ecx
; CHECK-32-NEXT:    cmoval %eax, %ecx
; CHECK-32-NEXT:    movl (%ecx), %eax
; CHECK-32-NEXT:    retl
;
; CHECK-64-LABEL: test_f64_ogt_q:
; CHECK-64:       # %bb.0:
; CHECK-64-NEXT:    movl %edi, %eax
; CHECK-64-NEXT:    {{v?}}ucomisd %xmm1, %xmm0
; CHECK-64-NEXT:    cmovbel %esi, %eax
; CHECK-64-NEXT:    retq
;
; X87-LABEL: test_f64_ogt_q:
; X87:       # %bb.0:
; X87-NEXT:    fldl {{[0-9]+}}(%esp)
; X87-NEXT:    fldl {{[0-9]+}}(%esp)
; X87-NEXT:    fucompp
; X87-NEXT:    fnstsw %ax
; X87-NEXT:    # kill: def $ah killed $ah killed $ax
; X87-NEXT:    sahf
; X87-NEXT:    ja .LBB15_1
; X87-NEXT:  # %bb.2:
; X87-NEXT:    leal {{[0-9]+}}(%esp), %eax
; X87-NEXT:    movl (%eax), %eax
; X87-NEXT:    retl
; X87-NEXT:  .LBB15_1:
; X87-NEXT:    leal {{[0-9]+}}(%esp), %eax
; X87-NEXT:    movl (%eax), %eax
; X87-NEXT:    retl
;
; X87-CMOV-LABEL: test_f64_ogt_q:
; X87-CMOV:       # %bb.0:
; X87-CMOV-NEXT:    fldl {{[0-9]+}}(%esp)
; X87-CMOV-NEXT:    fldl {{[0-9]+}}(%esp)
; X87-CMOV-NEXT:    fucompi %st(1), %st
; X87-CMOV-NEXT:    fstp %st(0)
; X87-CMOV-NEXT:    leal {{[0-9]+}}(%esp), %eax
; X87-CMOV-NEXT:    leal {{[0-9]+}}(%esp), %ecx
; X87-CMOV-NEXT:    cmoval %eax, %ecx
; X87-CMOV-NEXT:    movl (%ecx), %eax
; X87-CMOV-NEXT:    retl
  %cond = call i1 @llvm.experimental.constrained.fcmp.f64(
                                               double %f1, double %f2, metadata !"ogt",
                                               metadata !"fpexcept.strict") #0
  %res = select i1 %cond, i32 %a, i32 %b
  ret i32 %res
}

define i32 @test_f64_oge_q(i32 %a, i32 %b, double %f1, double %f2) #0 {
; CHECK-32-LABEL: test_f64_oge_q:
; CHECK-32:       # %bb.0:
; CHECK-32-NEXT:    {{v?}}movsd {{.*#+}} xmm0 = mem[0],zero
; CHECK-32-NEXT:    {{v?}}ucomisd {{[0-9]+}}(%esp), %xmm0
; CHECK-32-NEXT:    leal {{[0-9]+}}(%esp), %eax
; CHECK-32-NEXT:    leal {{[0-9]+}}(%esp), %ecx
; CHECK-32-NEXT:    cmovael %eax, %ecx
; CHECK-32-NEXT:    movl (%ecx), %eax
; CHECK-32-NEXT:    retl
;
; CHECK-64-LABEL: test_f64_oge_q:
; CHECK-64:       # %bb.0:
; CHECK-64-NEXT:    movl %edi, %eax
; CHECK-64-NEXT:    {{v?}}ucomisd %xmm1, %xmm0
; CHECK-64-NEXT:    cmovbl %esi, %eax
; CHECK-64-NEXT:    retq
;
; X87-LABEL: test_f64_oge_q:
; X87:       # %bb.0:
; X87-NEXT:    fldl {{[0-9]+}}(%esp)
; X87-NEXT:    fldl {{[0-9]+}}(%esp)
; X87-NEXT:    fucompp
; X87-NEXT:    fnstsw %ax
; X87-NEXT:    # kill: def $ah killed $ah killed $ax
; X87-NEXT:    sahf
; X87-NEXT:    jae .LBB16_1
; X87-NEXT:  # %bb.2:
; X87-NEXT:    leal {{[0-9]+}}(%esp), %eax
; X87-NEXT:    movl (%eax), %eax
; X87-NEXT:    retl
; X87-NEXT:  .LBB16_1:
; X87-NEXT:    leal {{[0-9]+}}(%esp), %eax
; X87-NEXT:    movl (%eax), %eax
; X87-NEXT:    retl
;
; X87-CMOV-LABEL: test_f64_oge_q:
; X87-CMOV:       # %bb.0:
; X87-CMOV-NEXT:    fldl {{[0-9]+}}(%esp)
; X87-CMOV-NEXT:    fldl {{[0-9]+}}(%esp)
; X87-CMOV-NEXT:    fucompi %st(1), %st
; X87-CMOV-NEXT:    fstp %st(0)
; X87-CMOV-NEXT:    leal {{[0-9]+}}(%esp), %eax
; X87-CMOV-NEXT:    leal {{[0-9]+}}(%esp), %ecx
; X87-CMOV-NEXT:    cmovael %eax, %ecx
; X87-CMOV-NEXT:    movl (%ecx), %eax
; X87-CMOV-NEXT:    retl
  %cond = call i1 @llvm.experimental.constrained.fcmp.f64(
                                               double %f1, double %f2, metadata !"oge",
                                               metadata !"fpexcept.strict") #0
  %res = select i1 %cond, i32 %a, i32 %b
  ret i32 %res
}

define i32 @test_f64_olt_q(i32 %a, i32 %b, double %f1, double %f2) #0 {
; CHECK-32-LABEL: test_f64_olt_q:
; CHECK-32:       # %bb.0:
; CHECK-32-NEXT:    {{v?}}movsd {{.*#+}} xmm0 = mem[0],zero
; CHECK-32-NEXT:    {{v?}}ucomisd {{[0-9]+}}(%esp), %xmm0
; CHECK-32-NEXT:    leal {{[0-9]+}}(%esp), %eax
; CHECK-32-NEXT:    leal {{[0-9]+}}(%esp), %ecx
; CHECK-32-NEXT:    cmoval %eax, %ecx
; CHECK-32-NEXT:    movl (%ecx), %eax
; CHECK-32-NEXT:    retl
;
; CHECK-64-LABEL: test_f64_olt_q:
; CHECK-64:       # %bb.0:
; CHECK-64-NEXT:    movl %edi, %eax
; CHECK-64-NEXT:    {{v?}}ucomisd %xmm0, %xmm1
; CHECK-64-NEXT:    cmovbel %esi, %eax
; CHECK-64-NEXT:    retq
;
; X87-LABEL: test_f64_olt_q:
; X87:       # %bb.0:
; X87-NEXT:    fldl {{[0-9]+}}(%esp)
; X87-NEXT:    fldl {{[0-9]+}}(%esp)
; X87-NEXT:    fucompp
; X87-NEXT:    fnstsw %ax
; X87-NEXT:    # kill: def $ah killed $ah killed $ax
; X87-NEXT:    sahf
; X87-NEXT:    ja .LBB17_1
; X87-NEXT:  # %bb.2:
; X87-NEXT:    leal {{[0-9]+}}(%esp), %eax
; X87-NEXT:    movl (%eax), %eax
; X87-NEXT:    retl
; X87-NEXT:  .LBB17_1:
; X87-NEXT:    leal {{[0-9]+}}(%esp), %eax
; X87-NEXT:    movl (%eax), %eax
; X87-NEXT:    retl
;
; X87-CMOV-LABEL: test_f64_olt_q:
; X87-CMOV:       # %bb.0:
; X87-CMOV-NEXT:    fldl {{[0-9]+}}(%esp)
; X87-CMOV-NEXT:    fldl {{[0-9]+}}(%esp)
; X87-CMOV-NEXT:    fucompi %st(1), %st
; X87-CMOV-NEXT:    fstp %st(0)
; X87-CMOV-NEXT:    leal {{[0-9]+}}(%esp), %eax
; X87-CMOV-NEXT:    leal {{[0-9]+}}(%esp), %ecx
; X87-CMOV-NEXT:    cmoval %eax, %ecx
; X87-CMOV-NEXT:    movl (%ecx), %eax
; X87-CMOV-NEXT:    retl
  %cond = call i1 @llvm.experimental.constrained.fcmp.f64(
                                               double %f1, double %f2, metadata !"olt",
                                               metadata !"fpexcept.strict") #0
  %res = select i1 %cond, i32 %a, i32 %b
  ret i32 %res
}

define i32 @test_f64_ole_q(i32 %a, i32 %b, double %f1, double %f2) #0 {
; CHECK-32-LABEL: test_f64_ole_q:
; CHECK-32:       # %bb.0:
; CHECK-32-NEXT:    {{v?}}movsd {{.*#+}} xmm0 = mem[0],zero
; CHECK-32-NEXT:    {{v?}}ucomisd {{[0-9]+}}(%esp), %xmm0
; CHECK-32-NEXT:    leal {{[0-9]+}}(%esp), %eax
; CHECK-32-NEXT:    leal {{[0-9]+}}(%esp), %ecx
; CHECK-32-NEXT:    cmovael %eax, %ecx
; CHECK-32-NEXT:    movl (%ecx), %eax
; CHECK-32-NEXT:    retl
;
; CHECK-64-LABEL: test_f64_ole_q:
; CHECK-64:       # %bb.0:
; CHECK-64-NEXT:    movl %edi, %eax
; CHECK-64-NEXT:    {{v?}}ucomisd %xmm0, %xmm1
; CHECK-64-NEXT:    cmovbl %esi, %eax
; CHECK-64-NEXT:    retq
;
; X87-LABEL: test_f64_ole_q:
; X87:       # %bb.0:
; X87-NEXT:    fldl {{[0-9]+}}(%esp)
; X87-NEXT:    fldl {{[0-9]+}}(%esp)
; X87-NEXT:    fucompp
; X87-NEXT:    fnstsw %ax
; X87-NEXT:    # kill: def $ah killed $ah killed $ax
; X87-NEXT:    sahf
; X87-NEXT:    jae .LBB18_1
; X87-NEXT:  # %bb.2:
; X87-NEXT:    leal {{[0-9]+}}(%esp), %eax
; X87-NEXT:    movl (%eax), %eax
; X87-NEXT:    retl
; X87-NEXT:  .LBB18_1:
; X87-NEXT:    leal {{[0-9]+}}(%esp), %eax
; X87-NEXT:    movl (%eax), %eax
; X87-NEXT:    retl
;
; X87-CMOV-LABEL: test_f64_ole_q:
; X87-CMOV:       # %bb.0:
; X87-CMOV-NEXT:    fldl {{[0-9]+}}(%esp)
; X87-CMOV-NEXT:    fldl {{[0-9]+}}(%esp)
; X87-CMOV-NEXT:    fucompi %st(1), %st
; X87-CMOV-NEXT:    fstp %st(0)
; X87-CMOV-NEXT:    leal {{[0-9]+}}(%esp), %eax
; X87-CMOV-NEXT:    leal {{[0-9]+}}(%esp), %ecx
; X87-CMOV-NEXT:    cmovael %eax, %ecx
; X87-CMOV-NEXT:    movl (%ecx), %eax
; X87-CMOV-NEXT:    retl
  %cond = call i1 @llvm.experimental.constrained.fcmp.f64(
                                               double %f1, double %f2, metadata !"ole",
                                               metadata !"fpexcept.strict") #0
  %res = select i1 %cond, i32 %a, i32 %b
  ret i32 %res
}

define i32 @test_f64_one_q(i32 %a, i32 %b, double %f1, double %f2) #0 {
; CHECK-32-LABEL: test_f64_one_q:
; CHECK-32:       # %bb.0:
; CHECK-32-NEXT:    {{v?}}movsd {{.*#+}} xmm0 = mem[0],zero
; CHECK-32-NEXT:    {{v?}}ucomisd {{[0-9]+}}(%esp), %xmm0
; CHECK-32-NEXT:    leal {{[0-9]+}}(%esp), %eax
; CHECK-32-NEXT:    leal {{[0-9]+}}(%esp), %ecx
; CHECK-32-NEXT:    cmovnel %eax, %ecx
; CHECK-32-NEXT:    movl (%ecx), %eax
; CHECK-32-NEXT:    retl
;
; CHECK-64-LABEL: test_f64_one_q:
; CHECK-64:       # %bb.0:
; CHECK-64-NEXT:    movl %edi, %eax
; CHECK-64-NEXT:    {{v?}}ucomisd %xmm1, %xmm0
; CHECK-64-NEXT:    cmovel %esi, %eax
; CHECK-64-NEXT:    retq
;
; X87-LABEL: test_f64_one_q:
; X87:       # %bb.0:
; X87-NEXT:    fldl {{[0-9]+}}(%esp)
; X87-NEXT:    fldl {{[0-9]+}}(%esp)
; X87-NEXT:    fucompp
; X87-NEXT:    fnstsw %ax
; X87-NEXT:    # kill: def $ah killed $ah killed $ax
; X87-NEXT:    sahf
; X87-NEXT:    jne .LBB19_1
; X87-NEXT:  # %bb.2:
; X87-NEXT:    leal {{[0-9]+}}(%esp), %eax
; X87-NEXT:    movl (%eax), %eax
; X87-NEXT:    retl
; X87-NEXT:  .LBB19_1:
; X87-NEXT:    leal {{[0-9]+}}(%esp), %eax
; X87-NEXT:    movl (%eax), %eax
; X87-NEXT:    retl
;
; X87-CMOV-LABEL: test_f64_one_q:
; X87-CMOV:       # %bb.0:
; X87-CMOV-NEXT:    fldl {{[0-9]+}}(%esp)
; X87-CMOV-NEXT:    fldl {{[0-9]+}}(%esp)
; X87-CMOV-NEXT:    fucompi %st(1), %st
; X87-CMOV-NEXT:    fstp %st(0)
; X87-CMOV-NEXT:    leal {{[0-9]+}}(%esp), %eax
; X87-CMOV-NEXT:    leal {{[0-9]+}}(%esp), %ecx
; X87-CMOV-NEXT:    cmovnel %eax, %ecx
; X87-CMOV-NEXT:    movl (%ecx), %eax
; X87-CMOV-NEXT:    retl
  %cond = call i1 @llvm.experimental.constrained.fcmp.f64(
                                               double %f1, double %f2, metadata !"one",
                                               metadata !"fpexcept.strict") #0
  %res = select i1 %cond, i32 %a, i32 %b
  ret i32 %res
}

define i32 @test_f64_ord_q(i32 %a, i32 %b, double %f1, double %f2) #0 {
; CHECK-32-LABEL: test_f64_ord_q:
; CHECK-32:       # %bb.0:
; CHECK-32-NEXT:    {{v?}}movsd {{.*#+}} xmm0 = mem[0],zero
; CHECK-32-NEXT:    {{v?}}ucomisd {{[0-9]+}}(%esp), %xmm0
; CHECK-32-NEXT:    leal {{[0-9]+}}(%esp), %eax
; CHECK-32-NEXT:    leal {{[0-9]+}}(%esp), %ecx
; CHECK-32-NEXT:    cmovnpl %eax, %ecx
; CHECK-32-NEXT:    movl (%ecx), %eax
; CHECK-32-NEXT:    retl
;
; CHECK-64-LABEL: test_f64_ord_q:
; CHECK-64:       # %bb.0:
; CHECK-64-NEXT:    movl %edi, %eax
; CHECK-64-NEXT:    {{v?}}ucomisd %xmm1, %xmm0
; CHECK-64-NEXT:    cmovpl %esi, %eax
; CHECK-64-NEXT:    retq
;
; X87-LABEL: test_f64_ord_q:
; X87:       # %bb.0:
; X87-NEXT:    fldl {{[0-9]+}}(%esp)
; X87-NEXT:    fldl {{[0-9]+}}(%esp)
; X87-NEXT:    fucompp
; X87-NEXT:    fnstsw %ax
; X87-NEXT:    # kill: def $ah killed $ah killed $ax
; X87-NEXT:    sahf
; X87-NEXT:    jnp .LBB20_1
; X87-NEXT:  # %bb.2:
; X87-NEXT:    leal {{[0-9]+}}(%esp), %eax
; X87-NEXT:    movl (%eax), %eax
; X87-NEXT:    retl
; X87-NEXT:  .LBB20_1:
; X87-NEXT:    leal {{[0-9]+}}(%esp), %eax
; X87-NEXT:    movl (%eax), %eax
; X87-NEXT:    retl
;
; X87-CMOV-LABEL: test_f64_ord_q:
; X87-CMOV:       # %bb.0:
; X87-CMOV-NEXT:    fldl {{[0-9]+}}(%esp)
; X87-CMOV-NEXT:    fldl {{[0-9]+}}(%esp)
; X87-CMOV-NEXT:    fucompi %st(1), %st
; X87-CMOV-NEXT:    fstp %st(0)
; X87-CMOV-NEXT:    leal {{[0-9]+}}(%esp), %eax
; X87-CMOV-NEXT:    leal {{[0-9]+}}(%esp), %ecx
; X87-CMOV-NEXT:    cmovnpl %eax, %ecx
; X87-CMOV-NEXT:    movl (%ecx), %eax
; X87-CMOV-NEXT:    retl
  %cond = call i1 @llvm.experimental.constrained.fcmp.f64(
                                               double %f1, double %f2, metadata !"ord",
                                               metadata !"fpexcept.strict") #0
  %res = select i1 %cond, i32 %a, i32 %b
  ret i32 %res
}

define i32 @test_f64_ueq_q(i32 %a, i32 %b, double %f1, double %f2) #0 {
; CHECK-32-LABEL: test_f64_ueq_q:
; CHECK-32:       # %bb.0:
; CHECK-32-NEXT:    {{v?}}movsd {{.*#+}} xmm0 = mem[0],zero
; CHECK-32-NEXT:    {{v?}}ucomisd {{[0-9]+}}(%esp), %xmm0
; CHECK-32-NEXT:    leal {{[0-9]+}}(%esp), %eax
; CHECK-32-NEXT:    leal {{[0-9]+}}(%esp), %ecx
; CHECK-32-NEXT:    cmovel %eax, %ecx
; CHECK-32-NEXT:    movl (%ecx), %eax
; CHECK-32-NEXT:    retl
;
; CHECK-64-LABEL: test_f64_ueq_q:
; CHECK-64:       # %bb.0:
; CHECK-64-NEXT:    movl %edi, %eax
; CHECK-64-NEXT:    {{v?}}ucomisd %xmm1, %xmm0
; CHECK-64-NEXT:    cmovnel %esi, %eax
; CHECK-64-NEXT:    retq
;
; X87-LABEL: test_f64_ueq_q:
; X87:       # %bb.0:
; X87-NEXT:    fldl {{[0-9]+}}(%esp)
; X87-NEXT:    fldl {{[0-9]+}}(%esp)
; X87-NEXT:    fucompp
; X87-NEXT:    fnstsw %ax
; X87-NEXT:    # kill: def $ah killed $ah killed $ax
; X87-NEXT:    sahf
; X87-NEXT:    je .LBB21_1
; X87-NEXT:  # %bb.2:
; X87-NEXT:    leal {{[0-9]+}}(%esp), %eax
; X87-NEXT:    movl (%eax), %eax
; X87-NEXT:    retl
; X87-NEXT:  .LBB21_1:
; X87-NEXT:    leal {{[0-9]+}}(%esp), %eax
; X87-NEXT:    movl (%eax), %eax
; X87-NEXT:    retl
;
; X87-CMOV-LABEL: test_f64_ueq_q:
; X87-CMOV:       # %bb.0:
; X87-CMOV-NEXT:    fldl {{[0-9]+}}(%esp)
; X87-CMOV-NEXT:    fldl {{[0-9]+}}(%esp)
; X87-CMOV-NEXT:    fucompi %st(1), %st
; X87-CMOV-NEXT:    fstp %st(0)
; X87-CMOV-NEXT:    leal {{[0-9]+}}(%esp), %eax
; X87-CMOV-NEXT:    leal {{[0-9]+}}(%esp), %ecx
; X87-CMOV-NEXT:    cmovel %eax, %ecx
; X87-CMOV-NEXT:    movl (%ecx), %eax
; X87-CMOV-NEXT:    retl
  %cond = call i1 @llvm.experimental.constrained.fcmp.f64(
                                               double %f1, double %f2, metadata !"ueq",
                                               metadata !"fpexcept.strict") #0
  %res = select i1 %cond, i32 %a, i32 %b
  ret i32 %res
}

define i32 @test_f64_ugt_q(i32 %a, i32 %b, double %f1, double %f2) #0 {
; CHECK-32-LABEL: test_f64_ugt_q:
; CHECK-32:       # %bb.0:
; CHECK-32-NEXT:    {{v?}}movsd {{.*#+}} xmm0 = mem[0],zero
; CHECK-32-NEXT:    {{v?}}ucomisd {{[0-9]+}}(%esp), %xmm0
; CHECK-32-NEXT:    leal {{[0-9]+}}(%esp), %eax
; CHECK-32-NEXT:    leal {{[0-9]+}}(%esp), %ecx
; CHECK-32-NEXT:    cmovbl %eax, %ecx
; CHECK-32-NEXT:    movl (%ecx), %eax
; CHECK-32-NEXT:    retl
;
; CHECK-64-LABEL: test_f64_ugt_q:
; CHECK-64:       # %bb.0:
; CHECK-64-NEXT:    movl %edi, %eax
; CHECK-64-NEXT:    {{v?}}ucomisd %xmm0, %xmm1
; CHECK-64-NEXT:    cmovael %esi, %eax
; CHECK-64-NEXT:    retq
;
; X87-LABEL: test_f64_ugt_q:
; X87:       # %bb.0:
; X87-NEXT:    fldl {{[0-9]+}}(%esp)
; X87-NEXT:    fldl {{[0-9]+}}(%esp)
; X87-NEXT:    fucompp
; X87-NEXT:    fnstsw %ax
; X87-NEXT:    # kill: def $ah killed $ah killed $ax
; X87-NEXT:    sahf
; X87-NEXT:    jb .LBB22_1
; X87-NEXT:  # %bb.2:
; X87-NEXT:    leal {{[0-9]+}}(%esp), %eax
; X87-NEXT:    movl (%eax), %eax
; X87-NEXT:    retl
; X87-NEXT:  .LBB22_1:
; X87-NEXT:    leal {{[0-9]+}}(%esp), %eax
; X87-NEXT:    movl (%eax), %eax
; X87-NEXT:    retl
;
; X87-CMOV-LABEL: test_f64_ugt_q:
; X87-CMOV:       # %bb.0:
; X87-CMOV-NEXT:    fldl {{[0-9]+}}(%esp)
; X87-CMOV-NEXT:    fldl {{[0-9]+}}(%esp)
; X87-CMOV-NEXT:    fucompi %st(1), %st
; X87-CMOV-NEXT:    fstp %st(0)
; X87-CMOV-NEXT:    leal {{[0-9]+}}(%esp), %eax
; X87-CMOV-NEXT:    leal {{[0-9]+}}(%esp), %ecx
; X87-CMOV-NEXT:    cmovbl %eax, %ecx
; X87-CMOV-NEXT:    movl (%ecx), %eax
; X87-CMOV-NEXT:    retl
  %cond = call i1 @llvm.experimental.constrained.fcmp.f64(
                                               double %f1, double %f2, metadata !"ugt",
                                               metadata !"fpexcept.strict") #0
  %res = select i1 %cond, i32 %a, i32 %b
  ret i32 %res
}

define i32 @test_f64_uge_q(i32 %a, i32 %b, double %f1, double %f2) #0 {
; CHECK-32-LABEL: test_f64_uge_q:
; CHECK-32:       # %bb.0:
; CHECK-32-NEXT:    {{v?}}movsd {{.*#+}} xmm0 = mem[0],zero
; CHECK-32-NEXT:    {{v?}}ucomisd {{[0-9]+}}(%esp), %xmm0
; CHECK-32-NEXT:    leal {{[0-9]+}}(%esp), %eax
; CHECK-32-NEXT:    leal {{[0-9]+}}(%esp), %ecx
; CHECK-32-NEXT:    cmovbel %eax, %ecx
; CHECK-32-NEXT:    movl (%ecx), %eax
; CHECK-32-NEXT:    retl
;
; CHECK-64-LABEL: test_f64_uge_q:
; CHECK-64:       # %bb.0:
; CHECK-64-NEXT:    movl %edi, %eax
; CHECK-64-NEXT:    {{v?}}ucomisd %xmm0, %xmm1
; CHECK-64-NEXT:    cmoval %esi, %eax
; CHECK-64-NEXT:    retq
;
; X87-LABEL: test_f64_uge_q:
; X87:       # %bb.0:
; X87-NEXT:    fldl {{[0-9]+}}(%esp)
; X87-NEXT:    fldl {{[0-9]+}}(%esp)
; X87-NEXT:    fucompp
; X87-NEXT:    fnstsw %ax
; X87-NEXT:    # kill: def $ah killed $ah killed $ax
; X87-NEXT:    sahf
; X87-NEXT:    jbe .LBB23_1
; X87-NEXT:  # %bb.2:
; X87-NEXT:    leal {{[0-9]+}}(%esp), %eax
; X87-NEXT:    movl (%eax), %eax
; X87-NEXT:    retl
; X87-NEXT:  .LBB23_1:
; X87-NEXT:    leal {{[0-9]+}}(%esp), %eax
; X87-NEXT:    movl (%eax), %eax
; X87-NEXT:    retl
;
; X87-CMOV-LABEL: test_f64_uge_q:
; X87-CMOV:       # %bb.0:
; X87-CMOV-NEXT:    fldl {{[0-9]+}}(%esp)
; X87-CMOV-NEXT:    fldl {{[0-9]+}}(%esp)
; X87-CMOV-NEXT:    fucompi %st(1), %st
; X87-CMOV-NEXT:    fstp %st(0)
; X87-CMOV-NEXT:    leal {{[0-9]+}}(%esp), %eax
; X87-CMOV-NEXT:    leal {{[0-9]+}}(%esp), %ecx
; X87-CMOV-NEXT:    cmovbel %eax, %ecx
; X87-CMOV-NEXT:    movl (%ecx), %eax
; X87-CMOV-NEXT:    retl
  %cond = call i1 @llvm.experimental.constrained.fcmp.f64(
                                               double %f1, double %f2, metadata !"uge",
                                               metadata !"fpexcept.strict") #0
  %res = select i1 %cond, i32 %a, i32 %b
  ret i32 %res
}

define i32 @test_f64_ult_q(i32 %a, i32 %b, double %f1, double %f2) #0 {
; CHECK-32-LABEL: test_f64_ult_q:
; CHECK-32:       # %bb.0:
; CHECK-32-NEXT:    {{v?}}movsd {{.*#+}} xmm0 = mem[0],zero
; CHECK-32-NEXT:    {{v?}}ucomisd {{[0-9]+}}(%esp), %xmm0
; CHECK-32-NEXT:    leal {{[0-9]+}}(%esp), %eax
; CHECK-32-NEXT:    leal {{[0-9]+}}(%esp), %ecx
; CHECK-32-NEXT:    cmovbl %eax, %ecx
; CHECK-32-NEXT:    movl (%ecx), %eax
; CHECK-32-NEXT:    retl
;
; CHECK-64-LABEL: test_f64_ult_q:
; CHECK-64:       # %bb.0:
; CHECK-64-NEXT:    movl %edi, %eax
; CHECK-64-NEXT:    {{v?}}ucomisd %xmm1, %xmm0
; CHECK-64-NEXT:    cmovael %esi, %eax
; CHECK-64-NEXT:    retq
;
; X87-LABEL: test_f64_ult_q:
; X87:       # %bb.0:
; X87-NEXT:    fldl {{[0-9]+}}(%esp)
; X87-NEXT:    fldl {{[0-9]+}}(%esp)
; X87-NEXT:    fucompp
; X87-NEXT:    fnstsw %ax
; X87-NEXT:    # kill: def $ah killed $ah killed $ax
; X87-NEXT:    sahf
; X87-NEXT:    jb .LBB24_1
; X87-NEXT:  # %bb.2:
; X87-NEXT:    leal {{[0-9]+}}(%esp), %eax
; X87-NEXT:    movl (%eax), %eax
; X87-NEXT:    retl
; X87-NEXT:  .LBB24_1:
; X87-NEXT:    leal {{[0-9]+}}(%esp), %eax
; X87-NEXT:    movl (%eax), %eax
; X87-NEXT:    retl
;
; X87-CMOV-LABEL: test_f64_ult_q:
; X87-CMOV:       # %bb.0:
; X87-CMOV-NEXT:    fldl {{[0-9]+}}(%esp)
; X87-CMOV-NEXT:    fldl {{[0-9]+}}(%esp)
; X87-CMOV-NEXT:    fucompi %st(1), %st
; X87-CMOV-NEXT:    fstp %st(0)
; X87-CMOV-NEXT:    leal {{[0-9]+}}(%esp), %eax
; X87-CMOV-NEXT:    leal {{[0-9]+}}(%esp), %ecx
; X87-CMOV-NEXT:    cmovbl %eax, %ecx
; X87-CMOV-NEXT:    movl (%ecx), %eax
; X87-CMOV-NEXT:    retl
  %cond = call i1 @llvm.experimental.constrained.fcmp.f64(
                                               double %f1, double %f2, metadata !"ult",
                                               metadata !"fpexcept.strict") #0
  %res = select i1 %cond, i32 %a, i32 %b
  ret i32 %res
}

define i32 @test_f64_ule_q(i32 %a, i32 %b, double %f1, double %f2) #0 {
; CHECK-32-LABEL: test_f64_ule_q:
; CHECK-32:       # %bb.0:
; CHECK-32-NEXT:    {{v?}}movsd {{.*#+}} xmm0 = mem[0],zero
; CHECK-32-NEXT:    {{v?}}ucomisd {{[0-9]+}}(%esp), %xmm0
; CHECK-32-NEXT:    leal {{[0-9]+}}(%esp), %eax
; CHECK-32-NEXT:    leal {{[0-9]+}}(%esp), %ecx
; CHECK-32-NEXT:    cmovbel %eax, %ecx
; CHECK-32-NEXT:    movl (%ecx), %eax
; CHECK-32-NEXT:    retl
;
; CHECK-64-LABEL: test_f64_ule_q:
; CHECK-64:       # %bb.0:
; CHECK-64-NEXT:    movl %edi, %eax
; CHECK-64-NEXT:    {{v?}}ucomisd %xmm1, %xmm0
; CHECK-64-NEXT:    cmoval %esi, %eax
; CHECK-64-NEXT:    retq
;
; X87-LABEL: test_f64_ule_q:
; X87:       # %bb.0:
; X87-NEXT:    fldl {{[0-9]+}}(%esp)
; X87-NEXT:    fldl {{[0-9]+}}(%esp)
; X87-NEXT:    fucompp
; X87-NEXT:    fnstsw %ax
; X87-NEXT:    # kill: def $ah killed $ah killed $ax
; X87-NEXT:    sahf
; X87-NEXT:    jbe .LBB25_1
; X87-NEXT:  # %bb.2:
; X87-NEXT:    leal {{[0-9]+}}(%esp), %eax
; X87-NEXT:    movl (%eax), %eax
; X87-NEXT:    retl
; X87-NEXT:  .LBB25_1:
; X87-NEXT:    leal {{[0-9]+}}(%esp), %eax
; X87-NEXT:    movl (%eax), %eax
; X87-NEXT:    retl
;
; X87-CMOV-LABEL: test_f64_ule_q:
; X87-CMOV:       # %bb.0:
; X87-CMOV-NEXT:    fldl {{[0-9]+}}(%esp)
; X87-CMOV-NEXT:    fldl {{[0-9]+}}(%esp)
; X87-CMOV-NEXT:    fucompi %st(1), %st
; X87-CMOV-NEXT:    fstp %st(0)
; X87-CMOV-NEXT:    leal {{[0-9]+}}(%esp), %eax
; X87-CMOV-NEXT:    leal {{[0-9]+}}(%esp), %ecx
; X87-CMOV-NEXT:    cmovbel %eax, %ecx
; X87-CMOV-NEXT:    movl (%ecx), %eax
; X87-CMOV-NEXT:    retl
  %cond = call i1 @llvm.experimental.constrained.fcmp.f64(
                                               double %f1, double %f2, metadata !"ule",
                                               metadata !"fpexcept.strict") #0
  %res = select i1 %cond, i32 %a, i32 %b
  ret i32 %res
}

define i32 @test_f64_une_q(i32 %a, i32 %b, double %f1, double %f2) #0 {
; CHECK-32-LABEL: test_f64_une_q:
; CHECK-32:       # %bb.0:
; CHECK-32-NEXT:    {{v?}}movsd {{.*#+}} xmm0 = mem[0],zero
; CHECK-32-NEXT:    {{v?}}ucomisd {{[0-9]+}}(%esp), %xmm0
; CHECK-32-NEXT:    leal {{[0-9]+}}(%esp), %eax
; CHECK-32-NEXT:    leal {{[0-9]+}}(%esp), %ecx
; CHECK-32-NEXT:    cmovnel %eax, %ecx
; CHECK-32-NEXT:    cmovpl %eax, %ecx
; CHECK-32-NEXT:    movl (%ecx), %eax
; CHECK-32-NEXT:    retl
;
; CHECK-64-LABEL: test_f64_une_q:
; CHECK-64:       # %bb.0:
; CHECK-64-NEXT:    movl %esi, %eax
; CHECK-64-NEXT:    {{v?}}ucomisd %xmm1, %xmm0
; CHECK-64-NEXT:    cmovnel %edi, %eax
; CHECK-64-NEXT:    cmovpl %edi, %eax
; CHECK-64-NEXT:    retq
;
; X87-LABEL: test_f64_une_q:
; X87:       # %bb.0:
; X87-NEXT:    fldl {{[0-9]+}}(%esp)
; X87-NEXT:    fldl {{[0-9]+}}(%esp)
; X87-NEXT:    fucompp
; X87-NEXT:    fnstsw %ax
; X87-NEXT:    # kill: def $ah killed $ah killed $ax
; X87-NEXT:    sahf
; X87-NEXT:    leal {{[0-9]+}}(%esp), %eax
; X87-NEXT:    jne .LBB26_3
; X87-NEXT:  # %bb.1:
; X87-NEXT:    jp .LBB26_3
; X87-NEXT:  # %bb.2:
; X87-NEXT:    leal {{[0-9]+}}(%esp), %eax
; X87-NEXT:  .LBB26_3:
; X87-NEXT:    movl (%eax), %eax
; X87-NEXT:    retl
;
; X87-CMOV-LABEL: test_f64_une_q:
; X87-CMOV:       # %bb.0:
; X87-CMOV-NEXT:    fldl {{[0-9]+}}(%esp)
; X87-CMOV-NEXT:    fldl {{[0-9]+}}(%esp)
; X87-CMOV-NEXT:    fucompi %st(1), %st
; X87-CMOV-NEXT:    fstp %st(0)
; X87-CMOV-NEXT:    leal {{[0-9]+}}(%esp), %eax
; X87-CMOV-NEXT:    leal {{[0-9]+}}(%esp), %ecx
; X87-CMOV-NEXT:    cmovnel %eax, %ecx
; X87-CMOV-NEXT:    cmovpl %eax, %ecx
; X87-CMOV-NEXT:    movl (%ecx), %eax
; X87-CMOV-NEXT:    retl
  %cond = call i1 @llvm.experimental.constrained.fcmp.f64(
                                               double %f1, double %f2, metadata !"une",
                                               metadata !"fpexcept.strict") #0
  %res = select i1 %cond, i32 %a, i32 %b
  ret i32 %res
}

define i32 @test_f64_uno_q(i32 %a, i32 %b, double %f1, double %f2) #0 {
; CHECK-32-LABEL: test_f64_uno_q:
; CHECK-32:       # %bb.0:
; CHECK-32-NEXT:    {{v?}}movsd {{.*#+}} xmm0 = mem[0],zero
; CHECK-32-NEXT:    {{v?}}ucomisd {{[0-9]+}}(%esp), %xmm0
; CHECK-32-NEXT:    leal {{[0-9]+}}(%esp), %eax
; CHECK-32-NEXT:    leal {{[0-9]+}}(%esp), %ecx
; CHECK-32-NEXT:    cmovpl %eax, %ecx
; CHECK-32-NEXT:    movl (%ecx), %eax
; CHECK-32-NEXT:    retl
;
; CHECK-64-LABEL: test_f64_uno_q:
; CHECK-64:       # %bb.0:
; CHECK-64-NEXT:    movl %edi, %eax
; CHECK-64-NEXT:    {{v?}}ucomisd %xmm1, %xmm0
; CHECK-64-NEXT:    cmovnpl %esi, %eax
; CHECK-64-NEXT:    retq
;
; X87-LABEL: test_f64_uno_q:
; X87:       # %bb.0:
; X87-NEXT:    fldl {{[0-9]+}}(%esp)
; X87-NEXT:    fldl {{[0-9]+}}(%esp)
; X87-NEXT:    fucompp
; X87-NEXT:    fnstsw %ax
; X87-NEXT:    # kill: def $ah killed $ah killed $ax
; X87-NEXT:    sahf
; X87-NEXT:    jp .LBB27_1
; X87-NEXT:  # %bb.2:
; X87-NEXT:    leal {{[0-9]+}}(%esp), %eax
; X87-NEXT:    movl (%eax), %eax
; X87-NEXT:    retl
; X87-NEXT:  .LBB27_1:
; X87-NEXT:    leal {{[0-9]+}}(%esp), %eax
; X87-NEXT:    movl (%eax), %eax
; X87-NEXT:    retl
;
; X87-CMOV-LABEL: test_f64_uno_q:
; X87-CMOV:       # %bb.0:
; X87-CMOV-NEXT:    fldl {{[0-9]+}}(%esp)
; X87-CMOV-NEXT:    fldl {{[0-9]+}}(%esp)
; X87-CMOV-NEXT:    fucompi %st(1), %st
; X87-CMOV-NEXT:    fstp %st(0)
; X87-CMOV-NEXT:    leal {{[0-9]+}}(%esp), %eax
; X87-CMOV-NEXT:    leal {{[0-9]+}}(%esp), %ecx
; X87-CMOV-NEXT:    cmovpl %eax, %ecx
; X87-CMOV-NEXT:    movl (%ecx), %eax
; X87-CMOV-NEXT:    retl
  %cond = call i1 @llvm.experimental.constrained.fcmp.f64(
                                               double %f1, double %f2, metadata !"uno",
                                               metadata !"fpexcept.strict") #0
  %res = select i1 %cond, i32 %a, i32 %b
  ret i32 %res
}

define i32 @test_f32_oeq_s(i32 %a, i32 %b, float %f1, float %f2) #0 {
; CHECK-32-LABEL: test_f32_oeq_s:
; CHECK-32:       # %bb.0:
; CHECK-32-NEXT:    {{v?}}movss {{.*#+}} xmm0 = mem[0],zero,zero,zero
; CHECK-32-NEXT:    {{v?}}comiss {{[0-9]+}}(%esp), %xmm0
; CHECK-32-NEXT:    leal {{[0-9]+}}(%esp), %eax
; CHECK-32-NEXT:    leal {{[0-9]+}}(%esp), %ecx
; CHECK-32-NEXT:    cmovnel %eax, %ecx
; CHECK-32-NEXT:    cmovpl %eax, %ecx
; CHECK-32-NEXT:    movl (%ecx), %eax
; CHECK-32-NEXT:    retl
;
; CHECK-64-LABEL: test_f32_oeq_s:
; CHECK-64:       # %bb.0:
; CHECK-64-NEXT:    movl %edi, %eax
; CHECK-64-NEXT:    {{v?}}comiss %xmm1, %xmm0
; CHECK-64-NEXT:    cmovnel %esi, %eax
; CHECK-64-NEXT:    cmovpl %esi, %eax
; CHECK-64-NEXT:    retq
;
; X87-LABEL: test_f32_oeq_s:
; X87:       # %bb.0:
; X87-NEXT:    flds {{[0-9]+}}(%esp)
; X87-NEXT:    flds {{[0-9]+}}(%esp)
; X87-NEXT:    fcompp
; X87-NEXT:    fnstsw %ax
; X87-NEXT:    # kill: def $ah killed $ah killed $ax
; X87-NEXT:    sahf
; X87-NEXT:    leal {{[0-9]+}}(%esp), %eax
; X87-NEXT:    jne .LBB28_3
; X87-NEXT:  # %bb.1:
; X87-NEXT:    jp .LBB28_3
; X87-NEXT:  # %bb.2:
; X87-NEXT:    leal {{[0-9]+}}(%esp), %eax
; X87-NEXT:  .LBB28_3:
; X87-NEXT:    movl (%eax), %eax
; X87-NEXT:    retl
;
; X87-CMOV-LABEL: test_f32_oeq_s:
; X87-CMOV:       # %bb.0:
; X87-CMOV-NEXT:    flds {{[0-9]+}}(%esp)
; X87-CMOV-NEXT:    flds {{[0-9]+}}(%esp)
; X87-CMOV-NEXT:    fcompi %st(1), %st
; X87-CMOV-NEXT:    fstp %st(0)
; X87-CMOV-NEXT:    leal {{[0-9]+}}(%esp), %eax
; X87-CMOV-NEXT:    leal {{[0-9]+}}(%esp), %ecx
; X87-CMOV-NEXT:    cmovnel %eax, %ecx
; X87-CMOV-NEXT:    cmovpl %eax, %ecx
; X87-CMOV-NEXT:    movl (%ecx), %eax
; X87-CMOV-NEXT:    retl
  %cond = call i1 @llvm.experimental.constrained.fcmps.f32(
                                               float %f1, float %f2, metadata !"oeq",
                                               metadata !"fpexcept.strict") #0
  %res = select i1 %cond, i32 %a, i32 %b
  ret i32 %res
}

define i32 @test_f32_ogt_s(i32 %a, i32 %b, float %f1, float %f2) #0 {
; CHECK-32-LABEL: test_f32_ogt_s:
; CHECK-32:       # %bb.0:
; CHECK-32-NEXT:    {{v?}}movss {{.*#+}} xmm0 = mem[0],zero,zero,zero
; CHECK-32-NEXT:    {{v?}}comiss {{[0-9]+}}(%esp), %xmm0
; CHECK-32-NEXT:    leal {{[0-9]+}}(%esp), %eax
; CHECK-32-NEXT:    leal {{[0-9]+}}(%esp), %ecx
; CHECK-32-NEXT:    cmoval %eax, %ecx
; CHECK-32-NEXT:    movl (%ecx), %eax
; CHECK-32-NEXT:    retl
;
; CHECK-64-LABEL: test_f32_ogt_s:
; CHECK-64:       # %bb.0:
; CHECK-64-NEXT:    movl %edi, %eax
; CHECK-64-NEXT:    {{v?}}comiss %xmm1, %xmm0
; CHECK-64-NEXT:    cmovbel %esi, %eax
; CHECK-64-NEXT:    retq
;
; X87-LABEL: test_f32_ogt_s:
; X87:       # %bb.0:
; X87-NEXT:    flds {{[0-9]+}}(%esp)
; X87-NEXT:    flds {{[0-9]+}}(%esp)
; X87-NEXT:    fcompp
; X87-NEXT:    fnstsw %ax
; X87-NEXT:    # kill: def $ah killed $ah killed $ax
; X87-NEXT:    sahf
; X87-NEXT:    ja .LBB29_1
; X87-NEXT:  # %bb.2:
; X87-NEXT:    leal {{[0-9]+}}(%esp), %eax
; X87-NEXT:    movl (%eax), %eax
; X87-NEXT:    retl
; X87-NEXT:  .LBB29_1:
; X87-NEXT:    leal {{[0-9]+}}(%esp), %eax
; X87-NEXT:    movl (%eax), %eax
; X87-NEXT:    retl
;
; X87-CMOV-LABEL: test_f32_ogt_s:
; X87-CMOV:       # %bb.0:
; X87-CMOV-NEXT:    flds {{[0-9]+}}(%esp)
; X87-CMOV-NEXT:    flds {{[0-9]+}}(%esp)
; X87-CMOV-NEXT:    fcompi %st(1), %st
; X87-CMOV-NEXT:    fstp %st(0)
; X87-CMOV-NEXT:    leal {{[0-9]+}}(%esp), %eax
; X87-CMOV-NEXT:    leal {{[0-9]+}}(%esp), %ecx
; X87-CMOV-NEXT:    cmoval %eax, %ecx
; X87-CMOV-NEXT:    movl (%ecx), %eax
; X87-CMOV-NEXT:    retl
  %cond = call i1 @llvm.experimental.constrained.fcmps.f32(
                                               float %f1, float %f2, metadata !"ogt",
                                               metadata !"fpexcept.strict") #0
  %res = select i1 %cond, i32 %a, i32 %b
  ret i32 %res
}

define i32 @test_f32_oge_s(i32 %a, i32 %b, float %f1, float %f2) #0 {
; CHECK-32-LABEL: test_f32_oge_s:
; CHECK-32:       # %bb.0:
; CHECK-32-NEXT:    {{v?}}movss {{.*#+}} xmm0 = mem[0],zero,zero,zero
; CHECK-32-NEXT:    {{v?}}comiss {{[0-9]+}}(%esp), %xmm0
; CHECK-32-NEXT:    leal {{[0-9]+}}(%esp), %eax
; CHECK-32-NEXT:    leal {{[0-9]+}}(%esp), %ecx
; CHECK-32-NEXT:    cmovael %eax, %ecx
; CHECK-32-NEXT:    movl (%ecx), %eax
; CHECK-32-NEXT:    retl
;
; CHECK-64-LABEL: test_f32_oge_s:
; CHECK-64:       # %bb.0:
; CHECK-64-NEXT:    movl %edi, %eax
; CHECK-64-NEXT:    {{v?}}comiss %xmm1, %xmm0
; CHECK-64-NEXT:    cmovbl %esi, %eax
; CHECK-64-NEXT:    retq
;
; X87-LABEL: test_f32_oge_s:
; X87:       # %bb.0:
; X87-NEXT:    flds {{[0-9]+}}(%esp)
; X87-NEXT:    flds {{[0-9]+}}(%esp)
; X87-NEXT:    fcompp
; X87-NEXT:    fnstsw %ax
; X87-NEXT:    # kill: def $ah killed $ah killed $ax
; X87-NEXT:    sahf
; X87-NEXT:    jae .LBB30_1
; X87-NEXT:  # %bb.2:
; X87-NEXT:    leal {{[0-9]+}}(%esp), %eax
; X87-NEXT:    movl (%eax), %eax
; X87-NEXT:    retl
; X87-NEXT:  .LBB30_1:
; X87-NEXT:    leal {{[0-9]+}}(%esp), %eax
; X87-NEXT:    movl (%eax), %eax
; X87-NEXT:    retl
;
; X87-CMOV-LABEL: test_f32_oge_s:
; X87-CMOV:       # %bb.0:
; X87-CMOV-NEXT:    flds {{[0-9]+}}(%esp)
; X87-CMOV-NEXT:    flds {{[0-9]+}}(%esp)
; X87-CMOV-NEXT:    fcompi %st(1), %st
; X87-CMOV-NEXT:    fstp %st(0)
; X87-CMOV-NEXT:    leal {{[0-9]+}}(%esp), %eax
; X87-CMOV-NEXT:    leal {{[0-9]+}}(%esp), %ecx
; X87-CMOV-NEXT:    cmovael %eax, %ecx
; X87-CMOV-NEXT:    movl (%ecx), %eax
; X87-CMOV-NEXT:    retl
  %cond = call i1 @llvm.experimental.constrained.fcmps.f32(
                                               float %f1, float %f2, metadata !"oge",
                                               metadata !"fpexcept.strict") #0
  %res = select i1 %cond, i32 %a, i32 %b
  ret i32 %res
}

define i32 @test_f32_olt_s(i32 %a, i32 %b, float %f1, float %f2) #0 {
; CHECK-32-LABEL: test_f32_olt_s:
; CHECK-32:       # %bb.0:
; CHECK-32-NEXT:    {{v?}}movss {{.*#+}} xmm0 = mem[0],zero,zero,zero
; CHECK-32-NEXT:    {{v?}}comiss {{[0-9]+}}(%esp), %xmm0
; CHECK-32-NEXT:    leal {{[0-9]+}}(%esp), %eax
; CHECK-32-NEXT:    leal {{[0-9]+}}(%esp), %ecx
; CHECK-32-NEXT:    cmoval %eax, %ecx
; CHECK-32-NEXT:    movl (%ecx), %eax
; CHECK-32-NEXT:    retl
;
; CHECK-64-LABEL: test_f32_olt_s:
; CHECK-64:       # %bb.0:
; CHECK-64-NEXT:    movl %edi, %eax
; CHECK-64-NEXT:    {{v?}}comiss %xmm0, %xmm1
; CHECK-64-NEXT:    cmovbel %esi, %eax
; CHECK-64-NEXT:    retq
;
; X87-LABEL: test_f32_olt_s:
; X87:       # %bb.0:
; X87-NEXT:    flds {{[0-9]+}}(%esp)
; X87-NEXT:    flds {{[0-9]+}}(%esp)
; X87-NEXT:    fcompp
; X87-NEXT:    fnstsw %ax
; X87-NEXT:    # kill: def $ah killed $ah killed $ax
; X87-NEXT:    sahf
; X87-NEXT:    ja .LBB31_1
; X87-NEXT:  # %bb.2:
; X87-NEXT:    leal {{[0-9]+}}(%esp), %eax
; X87-NEXT:    movl (%eax), %eax
; X87-NEXT:    retl
; X87-NEXT:  .LBB31_1:
; X87-NEXT:    leal {{[0-9]+}}(%esp), %eax
; X87-NEXT:    movl (%eax), %eax
; X87-NEXT:    retl
;
; X87-CMOV-LABEL: test_f32_olt_s:
; X87-CMOV:       # %bb.0:
; X87-CMOV-NEXT:    flds {{[0-9]+}}(%esp)
; X87-CMOV-NEXT:    flds {{[0-9]+}}(%esp)
; X87-CMOV-NEXT:    fcompi %st(1), %st
; X87-CMOV-NEXT:    fstp %st(0)
; X87-CMOV-NEXT:    leal {{[0-9]+}}(%esp), %eax
; X87-CMOV-NEXT:    leal {{[0-9]+}}(%esp), %ecx
; X87-CMOV-NEXT:    cmoval %eax, %ecx
; X87-CMOV-NEXT:    movl (%ecx), %eax
; X87-CMOV-NEXT:    retl
  %cond = call i1 @llvm.experimental.constrained.fcmps.f32(
                                               float %f1, float %f2, metadata !"olt",
                                               metadata !"fpexcept.strict") #0
  %res = select i1 %cond, i32 %a, i32 %b
  ret i32 %res
}

define i32 @test_f32_ole_s(i32 %a, i32 %b, float %f1, float %f2) #0 {
; CHECK-32-LABEL: test_f32_ole_s:
; CHECK-32:       # %bb.0:
; CHECK-32-NEXT:    {{v?}}movss {{.*#+}} xmm0 = mem[0],zero,zero,zero
; CHECK-32-NEXT:    {{v?}}comiss {{[0-9]+}}(%esp), %xmm0
; CHECK-32-NEXT:    leal {{[0-9]+}}(%esp), %eax
; CHECK-32-NEXT:    leal {{[0-9]+}}(%esp), %ecx
; CHECK-32-NEXT:    cmovael %eax, %ecx
; CHECK-32-NEXT:    movl (%ecx), %eax
; CHECK-32-NEXT:    retl
;
; CHECK-64-LABEL: test_f32_ole_s:
; CHECK-64:       # %bb.0:
; CHECK-64-NEXT:    movl %edi, %eax
; CHECK-64-NEXT:    {{v?}}comiss %xmm0, %xmm1
; CHECK-64-NEXT:    cmovbl %esi, %eax
; CHECK-64-NEXT:    retq
;
; X87-LABEL: test_f32_ole_s:
; X87:       # %bb.0:
; X87-NEXT:    flds {{[0-9]+}}(%esp)
; X87-NEXT:    flds {{[0-9]+}}(%esp)
; X87-NEXT:    fcompp
; X87-NEXT:    fnstsw %ax
; X87-NEXT:    # kill: def $ah killed $ah killed $ax
; X87-NEXT:    sahf
; X87-NEXT:    jae .LBB32_1
; X87-NEXT:  # %bb.2:
; X87-NEXT:    leal {{[0-9]+}}(%esp), %eax
; X87-NEXT:    movl (%eax), %eax
; X87-NEXT:    retl
; X87-NEXT:  .LBB32_1:
; X87-NEXT:    leal {{[0-9]+}}(%esp), %eax
; X87-NEXT:    movl (%eax), %eax
; X87-NEXT:    retl
;
; X87-CMOV-LABEL: test_f32_ole_s:
; X87-CMOV:       # %bb.0:
; X87-CMOV-NEXT:    flds {{[0-9]+}}(%esp)
; X87-CMOV-NEXT:    flds {{[0-9]+}}(%esp)
; X87-CMOV-NEXT:    fcompi %st(1), %st
; X87-CMOV-NEXT:    fstp %st(0)
; X87-CMOV-NEXT:    leal {{[0-9]+}}(%esp), %eax
; X87-CMOV-NEXT:    leal {{[0-9]+}}(%esp), %ecx
; X87-CMOV-NEXT:    cmovael %eax, %ecx
; X87-CMOV-NEXT:    movl (%ecx), %eax
; X87-CMOV-NEXT:    retl
  %cond = call i1 @llvm.experimental.constrained.fcmps.f32(
                                               float %f1, float %f2, metadata !"ole",
                                               metadata !"fpexcept.strict") #0
  %res = select i1 %cond, i32 %a, i32 %b
  ret i32 %res
}

define i32 @test_f32_one_s(i32 %a, i32 %b, float %f1, float %f2) #0 {
; CHECK-32-LABEL: test_f32_one_s:
; CHECK-32:       # %bb.0:
; CHECK-32-NEXT:    {{v?}}movss {{.*#+}} xmm0 = mem[0],zero,zero,zero
; CHECK-32-NEXT:    {{v?}}comiss {{[0-9]+}}(%esp), %xmm0
; CHECK-32-NEXT:    leal {{[0-9]+}}(%esp), %eax
; CHECK-32-NEXT:    leal {{[0-9]+}}(%esp), %ecx
; CHECK-32-NEXT:    cmovnel %eax, %ecx
; CHECK-32-NEXT:    movl (%ecx), %eax
; CHECK-32-NEXT:    retl
;
; CHECK-64-LABEL: test_f32_one_s:
; CHECK-64:       # %bb.0:
; CHECK-64-NEXT:    movl %edi, %eax
; CHECK-64-NEXT:    {{v?}}comiss %xmm1, %xmm0
; CHECK-64-NEXT:    cmovel %esi, %eax
; CHECK-64-NEXT:    retq
;
; X87-LABEL: test_f32_one_s:
; X87:       # %bb.0:
; X87-NEXT:    flds {{[0-9]+}}(%esp)
; X87-NEXT:    flds {{[0-9]+}}(%esp)
; X87-NEXT:    fcompp
; X87-NEXT:    fnstsw %ax
; X87-NEXT:    # kill: def $ah killed $ah killed $ax
; X87-NEXT:    sahf
; X87-NEXT:    jne .LBB33_1
; X87-NEXT:  # %bb.2:
; X87-NEXT:    leal {{[0-9]+}}(%esp), %eax
; X87-NEXT:    movl (%eax), %eax
; X87-NEXT:    retl
; X87-NEXT:  .LBB33_1:
; X87-NEXT:    leal {{[0-9]+}}(%esp), %eax
; X87-NEXT:    movl (%eax), %eax
; X87-NEXT:    retl
;
; X87-CMOV-LABEL: test_f32_one_s:
; X87-CMOV:       # %bb.0:
; X87-CMOV-NEXT:    flds {{[0-9]+}}(%esp)
; X87-CMOV-NEXT:    flds {{[0-9]+}}(%esp)
; X87-CMOV-NEXT:    fcompi %st(1), %st
; X87-CMOV-NEXT:    fstp %st(0)
; X87-CMOV-NEXT:    leal {{[0-9]+}}(%esp), %eax
; X87-CMOV-NEXT:    leal {{[0-9]+}}(%esp), %ecx
; X87-CMOV-NEXT:    cmovnel %eax, %ecx
; X87-CMOV-NEXT:    movl (%ecx), %eax
; X87-CMOV-NEXT:    retl
  %cond = call i1 @llvm.experimental.constrained.fcmps.f32(
                                               float %f1, float %f2, metadata !"one",
                                               metadata !"fpexcept.strict") #0
  %res = select i1 %cond, i32 %a, i32 %b
  ret i32 %res
}

define i32 @test_f32_ord_s(i32 %a, i32 %b, float %f1, float %f2) #0 {
; CHECK-32-LABEL: test_f32_ord_s:
; CHECK-32:       # %bb.0:
; CHECK-32-NEXT:    {{v?}}movss {{.*#+}} xmm0 = mem[0],zero,zero,zero
; CHECK-32-NEXT:    {{v?}}comiss {{[0-9]+}}(%esp), %xmm0
; CHECK-32-NEXT:    leal {{[0-9]+}}(%esp), %eax
; CHECK-32-NEXT:    leal {{[0-9]+}}(%esp), %ecx
; CHECK-32-NEXT:    cmovnpl %eax, %ecx
; CHECK-32-NEXT:    movl (%ecx), %eax
; CHECK-32-NEXT:    retl
;
; CHECK-64-LABEL: test_f32_ord_s:
; CHECK-64:       # %bb.0:
; CHECK-64-NEXT:    movl %edi, %eax
; CHECK-64-NEXT:    {{v?}}comiss %xmm1, %xmm0
; CHECK-64-NEXT:    cmovpl %esi, %eax
; CHECK-64-NEXT:    retq
;
; X87-LABEL: test_f32_ord_s:
; X87:       # %bb.0:
; X87-NEXT:    flds {{[0-9]+}}(%esp)
; X87-NEXT:    flds {{[0-9]+}}(%esp)
; X87-NEXT:    fcompp
; X87-NEXT:    fnstsw %ax
; X87-NEXT:    # kill: def $ah killed $ah killed $ax
; X87-NEXT:    sahf
; X87-NEXT:    jnp .LBB34_1
; X87-NEXT:  # %bb.2:
; X87-NEXT:    leal {{[0-9]+}}(%esp), %eax
; X87-NEXT:    movl (%eax), %eax
; X87-NEXT:    retl
; X87-NEXT:  .LBB34_1:
; X87-NEXT:    leal {{[0-9]+}}(%esp), %eax
; X87-NEXT:    movl (%eax), %eax
; X87-NEXT:    retl
;
; X87-CMOV-LABEL: test_f32_ord_s:
; X87-CMOV:       # %bb.0:
; X87-CMOV-NEXT:    flds {{[0-9]+}}(%esp)
; X87-CMOV-NEXT:    flds {{[0-9]+}}(%esp)
; X87-CMOV-NEXT:    fcompi %st(1), %st
; X87-CMOV-NEXT:    fstp %st(0)
; X87-CMOV-NEXT:    leal {{[0-9]+}}(%esp), %eax
; X87-CMOV-NEXT:    leal {{[0-9]+}}(%esp), %ecx
; X87-CMOV-NEXT:    cmovnpl %eax, %ecx
; X87-CMOV-NEXT:    movl (%ecx), %eax
; X87-CMOV-NEXT:    retl
  %cond = call i1 @llvm.experimental.constrained.fcmps.f32(
                                               float %f1, float %f2, metadata !"ord",
                                               metadata !"fpexcept.strict") #0
  %res = select i1 %cond, i32 %a, i32 %b
  ret i32 %res
}

define i32 @test_f32_ueq_s(i32 %a, i32 %b, float %f1, float %f2) #0 {
; CHECK-32-LABEL: test_f32_ueq_s:
; CHECK-32:       # %bb.0:
; CHECK-32-NEXT:    {{v?}}movss {{.*#+}} xmm0 = mem[0],zero,zero,zero
; CHECK-32-NEXT:    {{v?}}comiss {{[0-9]+}}(%esp), %xmm0
; CHECK-32-NEXT:    leal {{[0-9]+}}(%esp), %eax
; CHECK-32-NEXT:    leal {{[0-9]+}}(%esp), %ecx
; CHECK-32-NEXT:    cmovel %eax, %ecx
; CHECK-32-NEXT:    movl (%ecx), %eax
; CHECK-32-NEXT:    retl
;
; CHECK-64-LABEL: test_f32_ueq_s:
; CHECK-64:       # %bb.0:
; CHECK-64-NEXT:    movl %edi, %eax
; CHECK-64-NEXT:    {{v?}}comiss %xmm1, %xmm0
; CHECK-64-NEXT:    cmovnel %esi, %eax
; CHECK-64-NEXT:    retq
;
; X87-LABEL: test_f32_ueq_s:
; X87:       # %bb.0:
; X87-NEXT:    flds {{[0-9]+}}(%esp)
; X87-NEXT:    flds {{[0-9]+}}(%esp)
; X87-NEXT:    fcompp
; X87-NEXT:    fnstsw %ax
; X87-NEXT:    # kill: def $ah killed $ah killed $ax
; X87-NEXT:    sahf
; X87-NEXT:    je .LBB35_1
; X87-NEXT:  # %bb.2:
; X87-NEXT:    leal {{[0-9]+}}(%esp), %eax
; X87-NEXT:    movl (%eax), %eax
; X87-NEXT:    retl
; X87-NEXT:  .LBB35_1:
; X87-NEXT:    leal {{[0-9]+}}(%esp), %eax
; X87-NEXT:    movl (%eax), %eax
; X87-NEXT:    retl
;
; X87-CMOV-LABEL: test_f32_ueq_s:
; X87-CMOV:       # %bb.0:
; X87-CMOV-NEXT:    flds {{[0-9]+}}(%esp)
; X87-CMOV-NEXT:    flds {{[0-9]+}}(%esp)
; X87-CMOV-NEXT:    fcompi %st(1), %st
; X87-CMOV-NEXT:    fstp %st(0)
; X87-CMOV-NEXT:    leal {{[0-9]+}}(%esp), %eax
; X87-CMOV-NEXT:    leal {{[0-9]+}}(%esp), %ecx
; X87-CMOV-NEXT:    cmovel %eax, %ecx
; X87-CMOV-NEXT:    movl (%ecx), %eax
; X87-CMOV-NEXT:    retl
  %cond = call i1 @llvm.experimental.constrained.fcmps.f32(
                                               float %f1, float %f2, metadata !"ueq",
                                               metadata !"fpexcept.strict") #0
  %res = select i1 %cond, i32 %a, i32 %b
  ret i32 %res
}

define i32 @test_f32_ugt_s(i32 %a, i32 %b, float %f1, float %f2) #0 {
; CHECK-32-LABEL: test_f32_ugt_s:
; CHECK-32:       # %bb.0:
; CHECK-32-NEXT:    {{v?}}movss {{.*#+}} xmm0 = mem[0],zero,zero,zero
; CHECK-32-NEXT:    {{v?}}comiss {{[0-9]+}}(%esp), %xmm0
; CHECK-32-NEXT:    leal {{[0-9]+}}(%esp), %eax
; CHECK-32-NEXT:    leal {{[0-9]+}}(%esp), %ecx
; CHECK-32-NEXT:    cmovbl %eax, %ecx
; CHECK-32-NEXT:    movl (%ecx), %eax
; CHECK-32-NEXT:    retl
;
; CHECK-64-LABEL: test_f32_ugt_s:
; CHECK-64:       # %bb.0:
; CHECK-64-NEXT:    movl %edi, %eax
; CHECK-64-NEXT:    {{v?}}comiss %xmm0, %xmm1
; CHECK-64-NEXT:    cmovael %esi, %eax
; CHECK-64-NEXT:    retq
;
; X87-LABEL: test_f32_ugt_s:
; X87:       # %bb.0:
; X87-NEXT:    flds {{[0-9]+}}(%esp)
; X87-NEXT:    flds {{[0-9]+}}(%esp)
; X87-NEXT:    fcompp
; X87-NEXT:    fnstsw %ax
; X87-NEXT:    # kill: def $ah killed $ah killed $ax
; X87-NEXT:    sahf
; X87-NEXT:    jb .LBB36_1
; X87-NEXT:  # %bb.2:
; X87-NEXT:    leal {{[0-9]+}}(%esp), %eax
; X87-NEXT:    movl (%eax), %eax
; X87-NEXT:    retl
; X87-NEXT:  .LBB36_1:
; X87-NEXT:    leal {{[0-9]+}}(%esp), %eax
; X87-NEXT:    movl (%eax), %eax
; X87-NEXT:    retl
;
; X87-CMOV-LABEL: test_f32_ugt_s:
; X87-CMOV:       # %bb.0:
; X87-CMOV-NEXT:    flds {{[0-9]+}}(%esp)
; X87-CMOV-NEXT:    flds {{[0-9]+}}(%esp)
; X87-CMOV-NEXT:    fcompi %st(1), %st
; X87-CMOV-NEXT:    fstp %st(0)
; X87-CMOV-NEXT:    leal {{[0-9]+}}(%esp), %eax
; X87-CMOV-NEXT:    leal {{[0-9]+}}(%esp), %ecx
; X87-CMOV-NEXT:    cmovbl %eax, %ecx
; X87-CMOV-NEXT:    movl (%ecx), %eax
; X87-CMOV-NEXT:    retl
  %cond = call i1 @llvm.experimental.constrained.fcmps.f32(
                                               float %f1, float %f2, metadata !"ugt",
                                               metadata !"fpexcept.strict") #0
  %res = select i1 %cond, i32 %a, i32 %b
  ret i32 %res
}

define i32 @test_f32_uge_s(i32 %a, i32 %b, float %f1, float %f2) #0 {
; CHECK-32-LABEL: test_f32_uge_s:
; CHECK-32:       # %bb.0:
; CHECK-32-NEXT:    {{v?}}movss {{.*#+}} xmm0 = mem[0],zero,zero,zero
; CHECK-32-NEXT:    {{v?}}comiss {{[0-9]+}}(%esp), %xmm0
; CHECK-32-NEXT:    leal {{[0-9]+}}(%esp), %eax
; CHECK-32-NEXT:    leal {{[0-9]+}}(%esp), %ecx
; CHECK-32-NEXT:    cmovbel %eax, %ecx
; CHECK-32-NEXT:    movl (%ecx), %eax
; CHECK-32-NEXT:    retl
;
; CHECK-64-LABEL: test_f32_uge_s:
; CHECK-64:       # %bb.0:
; CHECK-64-NEXT:    movl %edi, %eax
; CHECK-64-NEXT:    {{v?}}comiss %xmm0, %xmm1
; CHECK-64-NEXT:    cmoval %esi, %eax
; CHECK-64-NEXT:    retq
;
; X87-LABEL: test_f32_uge_s:
; X87:       # %bb.0:
; X87-NEXT:    flds {{[0-9]+}}(%esp)
; X87-NEXT:    flds {{[0-9]+}}(%esp)
; X87-NEXT:    fcompp
; X87-NEXT:    fnstsw %ax
; X87-NEXT:    # kill: def $ah killed $ah killed $ax
; X87-NEXT:    sahf
; X87-NEXT:    jbe .LBB37_1
; X87-NEXT:  # %bb.2:
; X87-NEXT:    leal {{[0-9]+}}(%esp), %eax
; X87-NEXT:    movl (%eax), %eax
; X87-NEXT:    retl
; X87-NEXT:  .LBB37_1:
; X87-NEXT:    leal {{[0-9]+}}(%esp), %eax
; X87-NEXT:    movl (%eax), %eax
; X87-NEXT:    retl
;
; X87-CMOV-LABEL: test_f32_uge_s:
; X87-CMOV:       # %bb.0:
; X87-CMOV-NEXT:    flds {{[0-9]+}}(%esp)
; X87-CMOV-NEXT:    flds {{[0-9]+}}(%esp)
; X87-CMOV-NEXT:    fcompi %st(1), %st
; X87-CMOV-NEXT:    fstp %st(0)
; X87-CMOV-NEXT:    leal {{[0-9]+}}(%esp), %eax
; X87-CMOV-NEXT:    leal {{[0-9]+}}(%esp), %ecx
; X87-CMOV-NEXT:    cmovbel %eax, %ecx
; X87-CMOV-NEXT:    movl (%ecx), %eax
; X87-CMOV-NEXT:    retl
  %cond = call i1 @llvm.experimental.constrained.fcmps.f32(
                                               float %f1, float %f2, metadata !"uge",
                                               metadata !"fpexcept.strict") #0
  %res = select i1 %cond, i32 %a, i32 %b
  ret i32 %res
}

define i32 @test_f32_ult_s(i32 %a, i32 %b, float %f1, float %f2) #0 {
; CHECK-32-LABEL: test_f32_ult_s:
; CHECK-32:       # %bb.0:
; CHECK-32-NEXT:    {{v?}}movss {{.*#+}} xmm0 = mem[0],zero,zero,zero
; CHECK-32-NEXT:    {{v?}}comiss {{[0-9]+}}(%esp), %xmm0
; CHECK-32-NEXT:    leal {{[0-9]+}}(%esp), %eax
; CHECK-32-NEXT:    leal {{[0-9]+}}(%esp), %ecx
; CHECK-32-NEXT:    cmovbl %eax, %ecx
; CHECK-32-NEXT:    movl (%ecx), %eax
; CHECK-32-NEXT:    retl
;
; CHECK-64-LABEL: test_f32_ult_s:
; CHECK-64:       # %bb.0:
; CHECK-64-NEXT:    movl %edi, %eax
; CHECK-64-NEXT:    {{v?}}comiss %xmm1, %xmm0
; CHECK-64-NEXT:    cmovael %esi, %eax
; CHECK-64-NEXT:    retq
;
; X87-LABEL: test_f32_ult_s:
; X87:       # %bb.0:
; X87-NEXT:    flds {{[0-9]+}}(%esp)
; X87-NEXT:    flds {{[0-9]+}}(%esp)
; X87-NEXT:    fcompp
; X87-NEXT:    fnstsw %ax
; X87-NEXT:    # kill: def $ah killed $ah killed $ax
; X87-NEXT:    sahf
; X87-NEXT:    jb .LBB38_1
; X87-NEXT:  # %bb.2:
; X87-NEXT:    leal {{[0-9]+}}(%esp), %eax
; X87-NEXT:    movl (%eax), %eax
; X87-NEXT:    retl
; X87-NEXT:  .LBB38_1:
; X87-NEXT:    leal {{[0-9]+}}(%esp), %eax
; X87-NEXT:    movl (%eax), %eax
; X87-NEXT:    retl
;
; X87-CMOV-LABEL: test_f32_ult_s:
; X87-CMOV:       # %bb.0:
; X87-CMOV-NEXT:    flds {{[0-9]+}}(%esp)
; X87-CMOV-NEXT:    flds {{[0-9]+}}(%esp)
; X87-CMOV-NEXT:    fcompi %st(1), %st
; X87-CMOV-NEXT:    fstp %st(0)
; X87-CMOV-NEXT:    leal {{[0-9]+}}(%esp), %eax
; X87-CMOV-NEXT:    leal {{[0-9]+}}(%esp), %ecx
; X87-CMOV-NEXT:    cmovbl %eax, %ecx
; X87-CMOV-NEXT:    movl (%ecx), %eax
; X87-CMOV-NEXT:    retl
  %cond = call i1 @llvm.experimental.constrained.fcmps.f32(
                                               float %f1, float %f2, metadata !"ult",
                                               metadata !"fpexcept.strict") #0
  %res = select i1 %cond, i32 %a, i32 %b
  ret i32 %res
}

define i32 @test_f32_ule_s(i32 %a, i32 %b, float %f1, float %f2) #0 {
; CHECK-32-LABEL: test_f32_ule_s:
; CHECK-32:       # %bb.0:
; CHECK-32-NEXT:    {{v?}}movss {{.*#+}} xmm0 = mem[0],zero,zero,zero
; CHECK-32-NEXT:    {{v?}}comiss {{[0-9]+}}(%esp), %xmm0
; CHECK-32-NEXT:    leal {{[0-9]+}}(%esp), %eax
; CHECK-32-NEXT:    leal {{[0-9]+}}(%esp), %ecx
; CHECK-32-NEXT:    cmovbel %eax, %ecx
; CHECK-32-NEXT:    movl (%ecx), %eax
; CHECK-32-NEXT:    retl
;
; CHECK-64-LABEL: test_f32_ule_s:
; CHECK-64:       # %bb.0:
; CHECK-64-NEXT:    movl %edi, %eax
; CHECK-64-NEXT:    {{v?}}comiss %xmm1, %xmm0
; CHECK-64-NEXT:    cmoval %esi, %eax
; CHECK-64-NEXT:    retq
;
; X87-LABEL: test_f32_ule_s:
; X87:       # %bb.0:
; X87-NEXT:    flds {{[0-9]+}}(%esp)
; X87-NEXT:    flds {{[0-9]+}}(%esp)
; X87-NEXT:    fcompp
; X87-NEXT:    fnstsw %ax
; X87-NEXT:    # kill: def $ah killed $ah killed $ax
; X87-NEXT:    sahf
; X87-NEXT:    jbe .LBB39_1
; X87-NEXT:  # %bb.2:
; X87-NEXT:    leal {{[0-9]+}}(%esp), %eax
; X87-NEXT:    movl (%eax), %eax
; X87-NEXT:    retl
; X87-NEXT:  .LBB39_1:
; X87-NEXT:    leal {{[0-9]+}}(%esp), %eax
; X87-NEXT:    movl (%eax), %eax
; X87-NEXT:    retl
;
; X87-CMOV-LABEL: test_f32_ule_s:
; X87-CMOV:       # %bb.0:
; X87-CMOV-NEXT:    flds {{[0-9]+}}(%esp)
; X87-CMOV-NEXT:    flds {{[0-9]+}}(%esp)
; X87-CMOV-NEXT:    fcompi %st(1), %st
; X87-CMOV-NEXT:    fstp %st(0)
; X87-CMOV-NEXT:    leal {{[0-9]+}}(%esp), %eax
; X87-CMOV-NEXT:    leal {{[0-9]+}}(%esp), %ecx
; X87-CMOV-NEXT:    cmovbel %eax, %ecx
; X87-CMOV-NEXT:    movl (%ecx), %eax
; X87-CMOV-NEXT:    retl
  %cond = call i1 @llvm.experimental.constrained.fcmps.f32(
                                               float %f1, float %f2, metadata !"ule",
                                               metadata !"fpexcept.strict") #0
  %res = select i1 %cond, i32 %a, i32 %b
  ret i32 %res
}

define i32 @test_f32_une_s(i32 %a, i32 %b, float %f1, float %f2) #0 {
; CHECK-32-LABEL: test_f32_une_s:
; CHECK-32:       # %bb.0:
; CHECK-32-NEXT:    {{v?}}movss {{.*#+}} xmm0 = mem[0],zero,zero,zero
; CHECK-32-NEXT:    {{v?}}comiss {{[0-9]+}}(%esp), %xmm0
; CHECK-32-NEXT:    leal {{[0-9]+}}(%esp), %eax
; CHECK-32-NEXT:    leal {{[0-9]+}}(%esp), %ecx
; CHECK-32-NEXT:    cmovnel %eax, %ecx
; CHECK-32-NEXT:    cmovpl %eax, %ecx
; CHECK-32-NEXT:    movl (%ecx), %eax
; CHECK-32-NEXT:    retl
;
; CHECK-64-LABEL: test_f32_une_s:
; CHECK-64:       # %bb.0:
; CHECK-64-NEXT:    movl %esi, %eax
; CHECK-64-NEXT:    {{v?}}comiss %xmm1, %xmm0
; CHECK-64-NEXT:    cmovnel %edi, %eax
; CHECK-64-NEXT:    cmovpl %edi, %eax
; CHECK-64-NEXT:    retq
;
; X87-LABEL: test_f32_une_s:
; X87:       # %bb.0:
; X87-NEXT:    flds {{[0-9]+}}(%esp)
; X87-NEXT:    flds {{[0-9]+}}(%esp)
; X87-NEXT:    fcompp
; X87-NEXT:    fnstsw %ax
; X87-NEXT:    # kill: def $ah killed $ah killed $ax
; X87-NEXT:    sahf
; X87-NEXT:    leal {{[0-9]+}}(%esp), %eax
; X87-NEXT:    jne .LBB40_3
; X87-NEXT:  # %bb.1:
; X87-NEXT:    jp .LBB40_3
; X87-NEXT:  # %bb.2:
; X87-NEXT:    leal {{[0-9]+}}(%esp), %eax
; X87-NEXT:  .LBB40_3:
; X87-NEXT:    movl (%eax), %eax
; X87-NEXT:    retl
;
; X87-CMOV-LABEL: test_f32_une_s:
; X87-CMOV:       # %bb.0:
; X87-CMOV-NEXT:    flds {{[0-9]+}}(%esp)
; X87-CMOV-NEXT:    flds {{[0-9]+}}(%esp)
; X87-CMOV-NEXT:    fcompi %st(1), %st
; X87-CMOV-NEXT:    fstp %st(0)
; X87-CMOV-NEXT:    leal {{[0-9]+}}(%esp), %eax
; X87-CMOV-NEXT:    leal {{[0-9]+}}(%esp), %ecx
; X87-CMOV-NEXT:    cmovnel %eax, %ecx
; X87-CMOV-NEXT:    cmovpl %eax, %ecx
; X87-CMOV-NEXT:    movl (%ecx), %eax
; X87-CMOV-NEXT:    retl
  %cond = call i1 @llvm.experimental.constrained.fcmps.f32(
                                               float %f1, float %f2, metadata !"une",
                                               metadata !"fpexcept.strict") #0
  %res = select i1 %cond, i32 %a, i32 %b
  ret i32 %res
}

define i32 @test_f32_uno_s(i32 %a, i32 %b, float %f1, float %f2) #0 {
; CHECK-32-LABEL: test_f32_uno_s:
; CHECK-32:       # %bb.0:
; CHECK-32-NEXT:    {{v?}}movss {{.*#+}} xmm0 = mem[0],zero,zero,zero
; CHECK-32-NEXT:    {{v?}}comiss {{[0-9]+}}(%esp), %xmm0
; CHECK-32-NEXT:    leal {{[0-9]+}}(%esp), %eax
; CHECK-32-NEXT:    leal {{[0-9]+}}(%esp), %ecx
; CHECK-32-NEXT:    cmovpl %eax, %ecx
; CHECK-32-NEXT:    movl (%ecx), %eax
; CHECK-32-NEXT:    retl
;
; CHECK-64-LABEL: test_f32_uno_s:
; CHECK-64:       # %bb.0:
; CHECK-64-NEXT:    movl %edi, %eax
; CHECK-64-NEXT:    {{v?}}comiss %xmm1, %xmm0
; CHECK-64-NEXT:    cmovnpl %esi, %eax
; CHECK-64-NEXT:    retq
;
; X87-LABEL: test_f32_uno_s:
; X87:       # %bb.0:
; X87-NEXT:    flds {{[0-9]+}}(%esp)
; X87-NEXT:    flds {{[0-9]+}}(%esp)
; X87-NEXT:    fcompp
; X87-NEXT:    fnstsw %ax
; X87-NEXT:    # kill: def $ah killed $ah killed $ax
; X87-NEXT:    sahf
; X87-NEXT:    jp .LBB41_1
; X87-NEXT:  # %bb.2:
; X87-NEXT:    leal {{[0-9]+}}(%esp), %eax
; X87-NEXT:    movl (%eax), %eax
; X87-NEXT:    retl
; X87-NEXT:  .LBB41_1:
; X87-NEXT:    leal {{[0-9]+}}(%esp), %eax
; X87-NEXT:    movl (%eax), %eax
; X87-NEXT:    retl
;
; X87-CMOV-LABEL: test_f32_uno_s:
; X87-CMOV:       # %bb.0:
; X87-CMOV-NEXT:    flds {{[0-9]+}}(%esp)
; X87-CMOV-NEXT:    flds {{[0-9]+}}(%esp)
; X87-CMOV-NEXT:    fcompi %st(1), %st
; X87-CMOV-NEXT:    fstp %st(0)
; X87-CMOV-NEXT:    leal {{[0-9]+}}(%esp), %eax
; X87-CMOV-NEXT:    leal {{[0-9]+}}(%esp), %ecx
; X87-CMOV-NEXT:    cmovpl %eax, %ecx
; X87-CMOV-NEXT:    movl (%ecx), %eax
; X87-CMOV-NEXT:    retl
  %cond = call i1 @llvm.experimental.constrained.fcmps.f32(
                                               float %f1, float %f2, metadata !"uno",
                                               metadata !"fpexcept.strict") #0
  %res = select i1 %cond, i32 %a, i32 %b
  ret i32 %res
}

define i32 @test_f64_oeq_s(i32 %a, i32 %b, double %f1, double %f2) #0 {
; CHECK-32-LABEL: test_f64_oeq_s:
; CHECK-32:       # %bb.0:
; CHECK-32-NEXT:    {{v?}}movsd {{.*#+}} xmm0 = mem[0],zero
; CHECK-32-NEXT:    {{v?}}comisd {{[0-9]+}}(%esp), %xmm0
; CHECK-32-NEXT:    leal {{[0-9]+}}(%esp), %eax
; CHECK-32-NEXT:    leal {{[0-9]+}}(%esp), %ecx
; CHECK-32-NEXT:    cmovnel %eax, %ecx
; CHECK-32-NEXT:    cmovpl %eax, %ecx
; CHECK-32-NEXT:    movl (%ecx), %eax
; CHECK-32-NEXT:    retl
;
; CHECK-64-LABEL: test_f64_oeq_s:
; CHECK-64:       # %bb.0:
; CHECK-64-NEXT:    movl %edi, %eax
; CHECK-64-NEXT:    {{v?}}comisd %xmm1, %xmm0
; CHECK-64-NEXT:    cmovnel %esi, %eax
; CHECK-64-NEXT:    cmovpl %esi, %eax
; CHECK-64-NEXT:    retq
;
; X87-LABEL: test_f64_oeq_s:
; X87:       # %bb.0:
; X87-NEXT:    fldl {{[0-9]+}}(%esp)
; X87-NEXT:    fldl {{[0-9]+}}(%esp)
; X87-NEXT:    fcompp
; X87-NEXT:    fnstsw %ax
; X87-NEXT:    # kill: def $ah killed $ah killed $ax
; X87-NEXT:    sahf
; X87-NEXT:    leal {{[0-9]+}}(%esp), %eax
; X87-NEXT:    jne .LBB42_3
; X87-NEXT:  # %bb.1:
; X87-NEXT:    jp .LBB42_3
; X87-NEXT:  # %bb.2:
; X87-NEXT:    leal {{[0-9]+}}(%esp), %eax
; X87-NEXT:  .LBB42_3:
; X87-NEXT:    movl (%eax), %eax
; X87-NEXT:    retl
;
; X87-CMOV-LABEL: test_f64_oeq_s:
; X87-CMOV:       # %bb.0:
; X87-CMOV-NEXT:    fldl {{[0-9]+}}(%esp)
; X87-CMOV-NEXT:    fldl {{[0-9]+}}(%esp)
; X87-CMOV-NEXT:    fcompi %st(1), %st
; X87-CMOV-NEXT:    fstp %st(0)
; X87-CMOV-NEXT:    leal {{[0-9]+}}(%esp), %eax
; X87-CMOV-NEXT:    leal {{[0-9]+}}(%esp), %ecx
; X87-CMOV-NEXT:    cmovnel %eax, %ecx
; X87-CMOV-NEXT:    cmovpl %eax, %ecx
; X87-CMOV-NEXT:    movl (%ecx), %eax
; X87-CMOV-NEXT:    retl
  %cond = call i1 @llvm.experimental.constrained.fcmps.f64(
                                               double %f1, double %f2, metadata !"oeq",
                                               metadata !"fpexcept.strict") #0
  %res = select i1 %cond, i32 %a, i32 %b
  ret i32 %res
}

define i32 @test_f64_ogt_s(i32 %a, i32 %b, double %f1, double %f2) #0 {
; CHECK-32-LABEL: test_f64_ogt_s:
; CHECK-32:       # %bb.0:
; CHECK-32-NEXT:    {{v?}}movsd {{.*#+}} xmm0 = mem[0],zero
; CHECK-32-NEXT:    {{v?}}comisd {{[0-9]+}}(%esp), %xmm0
; CHECK-32-NEXT:    leal {{[0-9]+}}(%esp), %eax
; CHECK-32-NEXT:    leal {{[0-9]+}}(%esp), %ecx
; CHECK-32-NEXT:    cmoval %eax, %ecx
; CHECK-32-NEXT:    movl (%ecx), %eax
; CHECK-32-NEXT:    retl
;
; CHECK-64-LABEL: test_f64_ogt_s:
; CHECK-64:       # %bb.0:
; CHECK-64-NEXT:    movl %edi, %eax
; CHECK-64-NEXT:    {{v?}}comisd %xmm1, %xmm0
; CHECK-64-NEXT:    cmovbel %esi, %eax
; CHECK-64-NEXT:    retq
;
; X87-LABEL: test_f64_ogt_s:
; X87:       # %bb.0:
; X87-NEXT:    fldl {{[0-9]+}}(%esp)
; X87-NEXT:    fldl {{[0-9]+}}(%esp)
; X87-NEXT:    fcompp
; X87-NEXT:    fnstsw %ax
; X87-NEXT:    # kill: def $ah killed $ah killed $ax
; X87-NEXT:    sahf
; X87-NEXT:    ja .LBB43_1
; X87-NEXT:  # %bb.2:
; X87-NEXT:    leal {{[0-9]+}}(%esp), %eax
; X87-NEXT:    movl (%eax), %eax
; X87-NEXT:    retl
; X87-NEXT:  .LBB43_1:
; X87-NEXT:    leal {{[0-9]+}}(%esp), %eax
; X87-NEXT:    movl (%eax), %eax
; X87-NEXT:    retl
;
; X87-CMOV-LABEL: test_f64_ogt_s:
; X87-CMOV:       # %bb.0:
; X87-CMOV-NEXT:    fldl {{[0-9]+}}(%esp)
; X87-CMOV-NEXT:    fldl {{[0-9]+}}(%esp)
; X87-CMOV-NEXT:    fcompi %st(1), %st
; X87-CMOV-NEXT:    fstp %st(0)
; X87-CMOV-NEXT:    leal {{[0-9]+}}(%esp), %eax
; X87-CMOV-NEXT:    leal {{[0-9]+}}(%esp), %ecx
; X87-CMOV-NEXT:    cmoval %eax, %ecx
; X87-CMOV-NEXT:    movl (%ecx), %eax
; X87-CMOV-NEXT:    retl
  %cond = call i1 @llvm.experimental.constrained.fcmps.f64(
                                               double %f1, double %f2, metadata !"ogt",
                                               metadata !"fpexcept.strict") #0
  %res = select i1 %cond, i32 %a, i32 %b
  ret i32 %res
}

define i32 @test_f64_oge_s(i32 %a, i32 %b, double %f1, double %f2) #0 {
; CHECK-32-LABEL: test_f64_oge_s:
; CHECK-32:       # %bb.0:
; CHECK-32-NEXT:    {{v?}}movsd {{.*#+}} xmm0 = mem[0],zero
; CHECK-32-NEXT:    {{v?}}comisd {{[0-9]+}}(%esp), %xmm0
; CHECK-32-NEXT:    leal {{[0-9]+}}(%esp), %eax
; CHECK-32-NEXT:    leal {{[0-9]+}}(%esp), %ecx
; CHECK-32-NEXT:    cmovael %eax, %ecx
; CHECK-32-NEXT:    movl (%ecx), %eax
; CHECK-32-NEXT:    retl
;
; CHECK-64-LABEL: test_f64_oge_s:
; CHECK-64:       # %bb.0:
; CHECK-64-NEXT:    movl %edi, %eax
; CHECK-64-NEXT:    {{v?}}comisd %xmm1, %xmm0
; CHECK-64-NEXT:    cmovbl %esi, %eax
; CHECK-64-NEXT:    retq
;
; X87-LABEL: test_f64_oge_s:
; X87:       # %bb.0:
; X87-NEXT:    fldl {{[0-9]+}}(%esp)
; X87-NEXT:    fldl {{[0-9]+}}(%esp)
; X87-NEXT:    fcompp
; X87-NEXT:    fnstsw %ax
; X87-NEXT:    # kill: def $ah killed $ah killed $ax
; X87-NEXT:    sahf
; X87-NEXT:    jae .LBB44_1
; X87-NEXT:  # %bb.2:
; X87-NEXT:    leal {{[0-9]+}}(%esp), %eax
; X87-NEXT:    movl (%eax), %eax
; X87-NEXT:    retl
; X87-NEXT:  .LBB44_1:
; X87-NEXT:    leal {{[0-9]+}}(%esp), %eax
; X87-NEXT:    movl (%eax), %eax
; X87-NEXT:    retl
;
; X87-CMOV-LABEL: test_f64_oge_s:
; X87-CMOV:       # %bb.0:
; X87-CMOV-NEXT:    fldl {{[0-9]+}}(%esp)
; X87-CMOV-NEXT:    fldl {{[0-9]+}}(%esp)
; X87-CMOV-NEXT:    fcompi %st(1), %st
; X87-CMOV-NEXT:    fstp %st(0)
; X87-CMOV-NEXT:    leal {{[0-9]+}}(%esp), %eax
; X87-CMOV-NEXT:    leal {{[0-9]+}}(%esp), %ecx
; X87-CMOV-NEXT:    cmovael %eax, %ecx
; X87-CMOV-NEXT:    movl (%ecx), %eax
; X87-CMOV-NEXT:    retl
  %cond = call i1 @llvm.experimental.constrained.fcmps.f64(
                                               double %f1, double %f2, metadata !"oge",
                                               metadata !"fpexcept.strict") #0
  %res = select i1 %cond, i32 %a, i32 %b
  ret i32 %res
}

define i32 @test_f64_olt_s(i32 %a, i32 %b, double %f1, double %f2) #0 {
; CHECK-32-LABEL: test_f64_olt_s:
; CHECK-32:       # %bb.0:
; CHECK-32-NEXT:    {{v?}}movsd {{.*#+}} xmm0 = mem[0],zero
; CHECK-32-NEXT:    {{v?}}comisd {{[0-9]+}}(%esp), %xmm0
; CHECK-32-NEXT:    leal {{[0-9]+}}(%esp), %eax
; CHECK-32-NEXT:    leal {{[0-9]+}}(%esp), %ecx
; CHECK-32-NEXT:    cmoval %eax, %ecx
; CHECK-32-NEXT:    movl (%ecx), %eax
; CHECK-32-NEXT:    retl
;
; CHECK-64-LABEL: test_f64_olt_s:
; CHECK-64:       # %bb.0:
; CHECK-64-NEXT:    movl %edi, %eax
; CHECK-64-NEXT:    {{v?}}comisd %xmm0, %xmm1
; CHECK-64-NEXT:    cmovbel %esi, %eax
; CHECK-64-NEXT:    retq
;
; X87-LABEL: test_f64_olt_s:
; X87:       # %bb.0:
; X87-NEXT:    fldl {{[0-9]+}}(%esp)
; X87-NEXT:    fldl {{[0-9]+}}(%esp)
; X87-NEXT:    fcompp
; X87-NEXT:    fnstsw %ax
; X87-NEXT:    # kill: def $ah killed $ah killed $ax
; X87-NEXT:    sahf
; X87-NEXT:    ja .LBB45_1
; X87-NEXT:  # %bb.2:
; X87-NEXT:    leal {{[0-9]+}}(%esp), %eax
; X87-NEXT:    movl (%eax), %eax
; X87-NEXT:    retl
; X87-NEXT:  .LBB45_1:
; X87-NEXT:    leal {{[0-9]+}}(%esp), %eax
; X87-NEXT:    movl (%eax), %eax
; X87-NEXT:    retl
;
; X87-CMOV-LABEL: test_f64_olt_s:
; X87-CMOV:       # %bb.0:
; X87-CMOV-NEXT:    fldl {{[0-9]+}}(%esp)
; X87-CMOV-NEXT:    fldl {{[0-9]+}}(%esp)
; X87-CMOV-NEXT:    fcompi %st(1), %st
; X87-CMOV-NEXT:    fstp %st(0)
; X87-CMOV-NEXT:    leal {{[0-9]+}}(%esp), %eax
; X87-CMOV-NEXT:    leal {{[0-9]+}}(%esp), %ecx
; X87-CMOV-NEXT:    cmoval %eax, %ecx
; X87-CMOV-NEXT:    movl (%ecx), %eax
; X87-CMOV-NEXT:    retl
  %cond = call i1 @llvm.experimental.constrained.fcmps.f64(
                                               double %f1, double %f2, metadata !"olt",
                                               metadata !"fpexcept.strict") #0
  %res = select i1 %cond, i32 %a, i32 %b
  ret i32 %res
}

define i32 @test_f64_ole_s(i32 %a, i32 %b, double %f1, double %f2) #0 {
; CHECK-32-LABEL: test_f64_ole_s:
; CHECK-32:       # %bb.0:
; CHECK-32-NEXT:    {{v?}}movsd {{.*#+}} xmm0 = mem[0],zero
; CHECK-32-NEXT:    {{v?}}comisd {{[0-9]+}}(%esp), %xmm0
; CHECK-32-NEXT:    leal {{[0-9]+}}(%esp), %eax
; CHECK-32-NEXT:    leal {{[0-9]+}}(%esp), %ecx
; CHECK-32-NEXT:    cmovael %eax, %ecx
; CHECK-32-NEXT:    movl (%ecx), %eax
; CHECK-32-NEXT:    retl
;
; CHECK-64-LABEL: test_f64_ole_s:
; CHECK-64:       # %bb.0:
; CHECK-64-NEXT:    movl %edi, %eax
; CHECK-64-NEXT:    {{v?}}comisd %xmm0, %xmm1
; CHECK-64-NEXT:    cmovbl %esi, %eax
; CHECK-64-NEXT:    retq
;
; X87-LABEL: test_f64_ole_s:
; X87:       # %bb.0:
; X87-NEXT:    fldl {{[0-9]+}}(%esp)
; X87-NEXT:    fldl {{[0-9]+}}(%esp)
; X87-NEXT:    fcompp
; X87-NEXT:    fnstsw %ax
; X87-NEXT:    # kill: def $ah killed $ah killed $ax
; X87-NEXT:    sahf
; X87-NEXT:    jae .LBB46_1
; X87-NEXT:  # %bb.2:
; X87-NEXT:    leal {{[0-9]+}}(%esp), %eax
; X87-NEXT:    movl (%eax), %eax
; X87-NEXT:    retl
; X87-NEXT:  .LBB46_1:
; X87-NEXT:    leal {{[0-9]+}}(%esp), %eax
; X87-NEXT:    movl (%eax), %eax
; X87-NEXT:    retl
;
; X87-CMOV-LABEL: test_f64_ole_s:
; X87-CMOV:       # %bb.0:
; X87-CMOV-NEXT:    fldl {{[0-9]+}}(%esp)
; X87-CMOV-NEXT:    fldl {{[0-9]+}}(%esp)
; X87-CMOV-NEXT:    fcompi %st(1), %st
; X87-CMOV-NEXT:    fstp %st(0)
; X87-CMOV-NEXT:    leal {{[0-9]+}}(%esp), %eax
; X87-CMOV-NEXT:    leal {{[0-9]+}}(%esp), %ecx
; X87-CMOV-NEXT:    cmovael %eax, %ecx
; X87-CMOV-NEXT:    movl (%ecx), %eax
; X87-CMOV-NEXT:    retl
  %cond = call i1 @llvm.experimental.constrained.fcmps.f64(
                                               double %f1, double %f2, metadata !"ole",
                                               metadata !"fpexcept.strict") #0
  %res = select i1 %cond, i32 %a, i32 %b
  ret i32 %res
}

define i32 @test_f64_one_s(i32 %a, i32 %b, double %f1, double %f2) #0 {
; CHECK-32-LABEL: test_f64_one_s:
; CHECK-32:       # %bb.0:
; CHECK-32-NEXT:    {{v?}}movsd {{.*#+}} xmm0 = mem[0],zero
; CHECK-32-NEXT:    {{v?}}comisd {{[0-9]+}}(%esp), %xmm0
; CHECK-32-NEXT:    leal {{[0-9]+}}(%esp), %eax
; CHECK-32-NEXT:    leal {{[0-9]+}}(%esp), %ecx
; CHECK-32-NEXT:    cmovnel %eax, %ecx
; CHECK-32-NEXT:    movl (%ecx), %eax
; CHECK-32-NEXT:    retl
;
; CHECK-64-LABEL: test_f64_one_s:
; CHECK-64:       # %bb.0:
; CHECK-64-NEXT:    movl %edi, %eax
; CHECK-64-NEXT:    {{v?}}comisd %xmm1, %xmm0
; CHECK-64-NEXT:    cmovel %esi, %eax
; CHECK-64-NEXT:    retq
;
; X87-LABEL: test_f64_one_s:
; X87:       # %bb.0:
; X87-NEXT:    fldl {{[0-9]+}}(%esp)
; X87-NEXT:    fldl {{[0-9]+}}(%esp)
; X87-NEXT:    fcompp
; X87-NEXT:    fnstsw %ax
; X87-NEXT:    # kill: def $ah killed $ah killed $ax
; X87-NEXT:    sahf
; X87-NEXT:    jne .LBB47_1
; X87-NEXT:  # %bb.2:
; X87-NEXT:    leal {{[0-9]+}}(%esp), %eax
; X87-NEXT:    movl (%eax), %eax
; X87-NEXT:    retl
; X87-NEXT:  .LBB47_1:
; X87-NEXT:    leal {{[0-9]+}}(%esp), %eax
; X87-NEXT:    movl (%eax), %eax
; X87-NEXT:    retl
;
; X87-CMOV-LABEL: test_f64_one_s:
; X87-CMOV:       # %bb.0:
; X87-CMOV-NEXT:    fldl {{[0-9]+}}(%esp)
; X87-CMOV-NEXT:    fldl {{[0-9]+}}(%esp)
; X87-CMOV-NEXT:    fcompi %st(1), %st
; X87-CMOV-NEXT:    fstp %st(0)
; X87-CMOV-NEXT:    leal {{[0-9]+}}(%esp), %eax
; X87-CMOV-NEXT:    leal {{[0-9]+}}(%esp), %ecx
; X87-CMOV-NEXT:    cmovnel %eax, %ecx
; X87-CMOV-NEXT:    movl (%ecx), %eax
; X87-CMOV-NEXT:    retl
  %cond = call i1 @llvm.experimental.constrained.fcmps.f64(
                                               double %f1, double %f2, metadata !"one",
                                               metadata !"fpexcept.strict") #0
  %res = select i1 %cond, i32 %a, i32 %b
  ret i32 %res
}

define i32 @test_f64_ord_s(i32 %a, i32 %b, double %f1, double %f2) #0 {
; CHECK-32-LABEL: test_f64_ord_s:
; CHECK-32:       # %bb.0:
; CHECK-32-NEXT:    {{v?}}movsd {{.*#+}} xmm0 = mem[0],zero
; CHECK-32-NEXT:    {{v?}}comisd {{[0-9]+}}(%esp), %xmm0
; CHECK-32-NEXT:    leal {{[0-9]+}}(%esp), %eax
; CHECK-32-NEXT:    leal {{[0-9]+}}(%esp), %ecx
; CHECK-32-NEXT:    cmovnpl %eax, %ecx
; CHECK-32-NEXT:    movl (%ecx), %eax
; CHECK-32-NEXT:    retl
;
; CHECK-64-LABEL: test_f64_ord_s:
; CHECK-64:       # %bb.0:
; CHECK-64-NEXT:    movl %edi, %eax
; CHECK-64-NEXT:    {{v?}}comisd %xmm1, %xmm0
; CHECK-64-NEXT:    cmovpl %esi, %eax
; CHECK-64-NEXT:    retq
;
; X87-LABEL: test_f64_ord_s:
; X87:       # %bb.0:
; X87-NEXT:    fldl {{[0-9]+}}(%esp)
; X87-NEXT:    fldl {{[0-9]+}}(%esp)
; X87-NEXT:    fcompp
; X87-NEXT:    fnstsw %ax
; X87-NEXT:    # kill: def $ah killed $ah killed $ax
; X87-NEXT:    sahf
; X87-NEXT:    jnp .LBB48_1
; X87-NEXT:  # %bb.2:
; X87-NEXT:    leal {{[0-9]+}}(%esp), %eax
; X87-NEXT:    movl (%eax), %eax
; X87-NEXT:    retl
; X87-NEXT:  .LBB48_1:
; X87-NEXT:    leal {{[0-9]+}}(%esp), %eax
; X87-NEXT:    movl (%eax), %eax
; X87-NEXT:    retl
;
; X87-CMOV-LABEL: test_f64_ord_s:
; X87-CMOV:       # %bb.0:
; X87-CMOV-NEXT:    fldl {{[0-9]+}}(%esp)
; X87-CMOV-NEXT:    fldl {{[0-9]+}}(%esp)
; X87-CMOV-NEXT:    fcompi %st(1), %st
; X87-CMOV-NEXT:    fstp %st(0)
; X87-CMOV-NEXT:    leal {{[0-9]+}}(%esp), %eax
; X87-CMOV-NEXT:    leal {{[0-9]+}}(%esp), %ecx
; X87-CMOV-NEXT:    cmovnpl %eax, %ecx
; X87-CMOV-NEXT:    movl (%ecx), %eax
; X87-CMOV-NEXT:    retl
  %cond = call i1 @llvm.experimental.constrained.fcmps.f64(
                                               double %f1, double %f2, metadata !"ord",
                                               metadata !"fpexcept.strict") #0
  %res = select i1 %cond, i32 %a, i32 %b
  ret i32 %res
}

define i32 @test_f64_ueq_s(i32 %a, i32 %b, double %f1, double %f2) #0 {
; CHECK-32-LABEL: test_f64_ueq_s:
; CHECK-32:       # %bb.0:
; CHECK-32-NEXT:    {{v?}}movsd {{.*#+}} xmm0 = mem[0],zero
; CHECK-32-NEXT:    {{v?}}comisd {{[0-9]+}}(%esp), %xmm0
; CHECK-32-NEXT:    leal {{[0-9]+}}(%esp), %eax
; CHECK-32-NEXT:    leal {{[0-9]+}}(%esp), %ecx
; CHECK-32-NEXT:    cmovel %eax, %ecx
; CHECK-32-NEXT:    movl (%ecx), %eax
; CHECK-32-NEXT:    retl
;
; CHECK-64-LABEL: test_f64_ueq_s:
; CHECK-64:       # %bb.0:
; CHECK-64-NEXT:    movl %edi, %eax
; CHECK-64-NEXT:    {{v?}}comisd %xmm1, %xmm0
; CHECK-64-NEXT:    cmovnel %esi, %eax
; CHECK-64-NEXT:    retq
;
; X87-LABEL: test_f64_ueq_s:
; X87:       # %bb.0:
; X87-NEXT:    fldl {{[0-9]+}}(%esp)
; X87-NEXT:    fldl {{[0-9]+}}(%esp)
; X87-NEXT:    fcompp
; X87-NEXT:    fnstsw %ax
; X87-NEXT:    # kill: def $ah killed $ah killed $ax
; X87-NEXT:    sahf
; X87-NEXT:    je .LBB49_1
; X87-NEXT:  # %bb.2:
; X87-NEXT:    leal {{[0-9]+}}(%esp), %eax
; X87-NEXT:    movl (%eax), %eax
; X87-NEXT:    retl
; X87-NEXT:  .LBB49_1:
; X87-NEXT:    leal {{[0-9]+}}(%esp), %eax
; X87-NEXT:    movl (%eax), %eax
; X87-NEXT:    retl
;
; X87-CMOV-LABEL: test_f64_ueq_s:
; X87-CMOV:       # %bb.0:
; X87-CMOV-NEXT:    fldl {{[0-9]+}}(%esp)
; X87-CMOV-NEXT:    fldl {{[0-9]+}}(%esp)
; X87-CMOV-NEXT:    fcompi %st(1), %st
; X87-CMOV-NEXT:    fstp %st(0)
; X87-CMOV-NEXT:    leal {{[0-9]+}}(%esp), %eax
; X87-CMOV-NEXT:    leal {{[0-9]+}}(%esp), %ecx
; X87-CMOV-NEXT:    cmovel %eax, %ecx
; X87-CMOV-NEXT:    movl (%ecx), %eax
; X87-CMOV-NEXT:    retl
  %cond = call i1 @llvm.experimental.constrained.fcmps.f64(
                                               double %f1, double %f2, metadata !"ueq",
                                               metadata !"fpexcept.strict") #0
  %res = select i1 %cond, i32 %a, i32 %b
  ret i32 %res
}

define i32 @test_f64_ugt_s(i32 %a, i32 %b, double %f1, double %f2) #0 {
; CHECK-32-LABEL: test_f64_ugt_s:
; CHECK-32:       # %bb.0:
; CHECK-32-NEXT:    {{v?}}movsd {{.*#+}} xmm0 = mem[0],zero
; CHECK-32-NEXT:    {{v?}}comisd {{[0-9]+}}(%esp), %xmm0
; CHECK-32-NEXT:    leal {{[0-9]+}}(%esp), %eax
; CHECK-32-NEXT:    leal {{[0-9]+}}(%esp), %ecx
; CHECK-32-NEXT:    cmovbl %eax, %ecx
; CHECK-32-NEXT:    movl (%ecx), %eax
; CHECK-32-NEXT:    retl
;
; CHECK-64-LABEL: test_f64_ugt_s:
; CHECK-64:       # %bb.0:
; CHECK-64-NEXT:    movl %edi, %eax
; CHECK-64-NEXT:    {{v?}}comisd %xmm0, %xmm1
; CHECK-64-NEXT:    cmovael %esi, %eax
; CHECK-64-NEXT:    retq
;
; X87-LABEL: test_f64_ugt_s:
; X87:       # %bb.0:
; X87-NEXT:    fldl {{[0-9]+}}(%esp)
; X87-NEXT:    fldl {{[0-9]+}}(%esp)
; X87-NEXT:    fcompp
; X87-NEXT:    fnstsw %ax
; X87-NEXT:    # kill: def $ah killed $ah killed $ax
; X87-NEXT:    sahf
; X87-NEXT:    jb .LBB50_1
; X87-NEXT:  # %bb.2:
; X87-NEXT:    leal {{[0-9]+}}(%esp), %eax
; X87-NEXT:    movl (%eax), %eax
; X87-NEXT:    retl
; X87-NEXT:  .LBB50_1:
; X87-NEXT:    leal {{[0-9]+}}(%esp), %eax
; X87-NEXT:    movl (%eax), %eax
; X87-NEXT:    retl
;
; X87-CMOV-LABEL: test_f64_ugt_s:
; X87-CMOV:       # %bb.0:
; X87-CMOV-NEXT:    fldl {{[0-9]+}}(%esp)
; X87-CMOV-NEXT:    fldl {{[0-9]+}}(%esp)
; X87-CMOV-NEXT:    fcompi %st(1), %st
; X87-CMOV-NEXT:    fstp %st(0)
; X87-CMOV-NEXT:    leal {{[0-9]+}}(%esp), %eax
; X87-CMOV-NEXT:    leal {{[0-9]+}}(%esp), %ecx
; X87-CMOV-NEXT:    cmovbl %eax, %ecx
; X87-CMOV-NEXT:    movl (%ecx), %eax
; X87-CMOV-NEXT:    retl
  %cond = call i1 @llvm.experimental.constrained.fcmps.f64(
                                               double %f1, double %f2, metadata !"ugt",
                                               metadata !"fpexcept.strict") #0
  %res = select i1 %cond, i32 %a, i32 %b
  ret i32 %res
}

define i32 @test_f64_uge_s(i32 %a, i32 %b, double %f1, double %f2) #0 {
; CHECK-32-LABEL: test_f64_uge_s:
; CHECK-32:       # %bb.0:
; CHECK-32-NEXT:    {{v?}}movsd {{.*#+}} xmm0 = mem[0],zero
; CHECK-32-NEXT:    {{v?}}comisd {{[0-9]+}}(%esp), %xmm0
; CHECK-32-NEXT:    leal {{[0-9]+}}(%esp), %eax
; CHECK-32-NEXT:    leal {{[0-9]+}}(%esp), %ecx
; CHECK-32-NEXT:    cmovbel %eax, %ecx
; CHECK-32-NEXT:    movl (%ecx), %eax
; CHECK-32-NEXT:    retl
;
; CHECK-64-LABEL: test_f64_uge_s:
; CHECK-64:       # %bb.0:
; CHECK-64-NEXT:    movl %edi, %eax
; CHECK-64-NEXT:    {{v?}}comisd %xmm0, %xmm1
; CHECK-64-NEXT:    cmoval %esi, %eax
; CHECK-64-NEXT:    retq
;
; X87-LABEL: test_f64_uge_s:
; X87:       # %bb.0:
; X87-NEXT:    fldl {{[0-9]+}}(%esp)
; X87-NEXT:    fldl {{[0-9]+}}(%esp)
; X87-NEXT:    fcompp
; X87-NEXT:    fnstsw %ax
; X87-NEXT:    # kill: def $ah killed $ah killed $ax
; X87-NEXT:    sahf
; X87-NEXT:    jbe .LBB51_1
; X87-NEXT:  # %bb.2:
; X87-NEXT:    leal {{[0-9]+}}(%esp), %eax
; X87-NEXT:    movl (%eax), %eax
; X87-NEXT:    retl
; X87-NEXT:  .LBB51_1:
; X87-NEXT:    leal {{[0-9]+}}(%esp), %eax
; X87-NEXT:    movl (%eax), %eax
; X87-NEXT:    retl
;
; X87-CMOV-LABEL: test_f64_uge_s:
; X87-CMOV:       # %bb.0:
; X87-CMOV-NEXT:    fldl {{[0-9]+}}(%esp)
; X87-CMOV-NEXT:    fldl {{[0-9]+}}(%esp)
; X87-CMOV-NEXT:    fcompi %st(1), %st
; X87-CMOV-NEXT:    fstp %st(0)
; X87-CMOV-NEXT:    leal {{[0-9]+}}(%esp), %eax
; X87-CMOV-NEXT:    leal {{[0-9]+}}(%esp), %ecx
; X87-CMOV-NEXT:    cmovbel %eax, %ecx
; X87-CMOV-NEXT:    movl (%ecx), %eax
; X87-CMOV-NEXT:    retl
  %cond = call i1 @llvm.experimental.constrained.fcmps.f64(
                                               double %f1, double %f2, metadata !"uge",
                                               metadata !"fpexcept.strict") #0
  %res = select i1 %cond, i32 %a, i32 %b
  ret i32 %res
}

define i32 @test_f64_ult_s(i32 %a, i32 %b, double %f1, double %f2) #0 {
; CHECK-32-LABEL: test_f64_ult_s:
; CHECK-32:       # %bb.0:
; CHECK-32-NEXT:    {{v?}}movsd {{.*#+}} xmm0 = mem[0],zero
; CHECK-32-NEXT:    {{v?}}comisd {{[0-9]+}}(%esp), %xmm0
; CHECK-32-NEXT:    leal {{[0-9]+}}(%esp), %eax
; CHECK-32-NEXT:    leal {{[0-9]+}}(%esp), %ecx
; CHECK-32-NEXT:    cmovbl %eax, %ecx
; CHECK-32-NEXT:    movl (%ecx), %eax
; CHECK-32-NEXT:    retl
;
; CHECK-64-LABEL: test_f64_ult_s:
; CHECK-64:       # %bb.0:
; CHECK-64-NEXT:    movl %edi, %eax
; CHECK-64-NEXT:    {{v?}}comisd %xmm1, %xmm0
; CHECK-64-NEXT:    cmovael %esi, %eax
; CHECK-64-NEXT:    retq
;
; X87-LABEL: test_f64_ult_s:
; X87:       # %bb.0:
; X87-NEXT:    fldl {{[0-9]+}}(%esp)
; X87-NEXT:    fldl {{[0-9]+}}(%esp)
; X87-NEXT:    fcompp
; X87-NEXT:    fnstsw %ax
; X87-NEXT:    # kill: def $ah killed $ah killed $ax
; X87-NEXT:    sahf
; X87-NEXT:    jb .LBB52_1
; X87-NEXT:  # %bb.2:
; X87-NEXT:    leal {{[0-9]+}}(%esp), %eax
; X87-NEXT:    movl (%eax), %eax
; X87-NEXT:    retl
; X87-NEXT:  .LBB52_1:
; X87-NEXT:    leal {{[0-9]+}}(%esp), %eax
; X87-NEXT:    movl (%eax), %eax
; X87-NEXT:    retl
;
; X87-CMOV-LABEL: test_f64_ult_s:
; X87-CMOV:       # %bb.0:
; X87-CMOV-NEXT:    fldl {{[0-9]+}}(%esp)
; X87-CMOV-NEXT:    fldl {{[0-9]+}}(%esp)
; X87-CMOV-NEXT:    fcompi %st(1), %st
; X87-CMOV-NEXT:    fstp %st(0)
; X87-CMOV-NEXT:    leal {{[0-9]+}}(%esp), %eax
; X87-CMOV-NEXT:    leal {{[0-9]+}}(%esp), %ecx
; X87-CMOV-NEXT:    cmovbl %eax, %ecx
; X87-CMOV-NEXT:    movl (%ecx), %eax
; X87-CMOV-NEXT:    retl
  %cond = call i1 @llvm.experimental.constrained.fcmps.f64(
                                               double %f1, double %f2, metadata !"ult",
                                               metadata !"fpexcept.strict") #0
  %res = select i1 %cond, i32 %a, i32 %b
  ret i32 %res
}

define i32 @test_f64_ule_s(i32 %a, i32 %b, double %f1, double %f2) #0 {
; CHECK-32-LABEL: test_f64_ule_s:
; CHECK-32:       # %bb.0:
; CHECK-32-NEXT:    {{v?}}movsd {{.*#+}} xmm0 = mem[0],zero
; CHECK-32-NEXT:    {{v?}}comisd {{[0-9]+}}(%esp), %xmm0
; CHECK-32-NEXT:    leal {{[0-9]+}}(%esp), %eax
; CHECK-32-NEXT:    leal {{[0-9]+}}(%esp), %ecx
; CHECK-32-NEXT:    cmovbel %eax, %ecx
; CHECK-32-NEXT:    movl (%ecx), %eax
; CHECK-32-NEXT:    retl
;
; CHECK-64-LABEL: test_f64_ule_s:
; CHECK-64:       # %bb.0:
; CHECK-64-NEXT:    movl %edi, %eax
; CHECK-64-NEXT:    {{v?}}comisd %xmm1, %xmm0
; CHECK-64-NEXT:    cmoval %esi, %eax
; CHECK-64-NEXT:    retq
;
; X87-LABEL: test_f64_ule_s:
; X87:       # %bb.0:
; X87-NEXT:    fldl {{[0-9]+}}(%esp)
; X87-NEXT:    fldl {{[0-9]+}}(%esp)
; X87-NEXT:    fcompp
; X87-NEXT:    fnstsw %ax
; X87-NEXT:    # kill: def $ah killed $ah killed $ax
; X87-NEXT:    sahf
; X87-NEXT:    jbe .LBB53_1
; X87-NEXT:  # %bb.2:
; X87-NEXT:    leal {{[0-9]+}}(%esp), %eax
; X87-NEXT:    movl (%eax), %eax
; X87-NEXT:    retl
; X87-NEXT:  .LBB53_1:
; X87-NEXT:    leal {{[0-9]+}}(%esp), %eax
; X87-NEXT:    movl (%eax), %eax
; X87-NEXT:    retl
;
; X87-CMOV-LABEL: test_f64_ule_s:
; X87-CMOV:       # %bb.0:
; X87-CMOV-NEXT:    fldl {{[0-9]+}}(%esp)
; X87-CMOV-NEXT:    fldl {{[0-9]+}}(%esp)
; X87-CMOV-NEXT:    fcompi %st(1), %st
; X87-CMOV-NEXT:    fstp %st(0)
; X87-CMOV-NEXT:    leal {{[0-9]+}}(%esp), %eax
; X87-CMOV-NEXT:    leal {{[0-9]+}}(%esp), %ecx
; X87-CMOV-NEXT:    cmovbel %eax, %ecx
; X87-CMOV-NEXT:    movl (%ecx), %eax
; X87-CMOV-NEXT:    retl
  %cond = call i1 @llvm.experimental.constrained.fcmps.f64(
                                               double %f1, double %f2, metadata !"ule",
                                               metadata !"fpexcept.strict") #0
  %res = select i1 %cond, i32 %a, i32 %b
  ret i32 %res
}

define i32 @test_f64_une_s(i32 %a, i32 %b, double %f1, double %f2) #0 {
; CHECK-32-LABEL: test_f64_une_s:
; CHECK-32:       # %bb.0:
; CHECK-32-NEXT:    {{v?}}movsd {{.*#+}} xmm0 = mem[0],zero
; CHECK-32-NEXT:    {{v?}}comisd {{[0-9]+}}(%esp), %xmm0
; CHECK-32-NEXT:    leal {{[0-9]+}}(%esp), %eax
; CHECK-32-NEXT:    leal {{[0-9]+}}(%esp), %ecx
; CHECK-32-NEXT:    cmovnel %eax, %ecx
; CHECK-32-NEXT:    cmovpl %eax, %ecx
; CHECK-32-NEXT:    movl (%ecx), %eax
; CHECK-32-NEXT:    retl
;
; CHECK-64-LABEL: test_f64_une_s:
; CHECK-64:       # %bb.0:
; CHECK-64-NEXT:    movl %esi, %eax
; CHECK-64-NEXT:    {{v?}}comisd %xmm1, %xmm0
; CHECK-64-NEXT:    cmovnel %edi, %eax
; CHECK-64-NEXT:    cmovpl %edi, %eax
; CHECK-64-NEXT:    retq
;
; X87-LABEL: test_f64_une_s:
; X87:       # %bb.0:
; X87-NEXT:    fldl {{[0-9]+}}(%esp)
; X87-NEXT:    fldl {{[0-9]+}}(%esp)
; X87-NEXT:    fcompp
; X87-NEXT:    fnstsw %ax
; X87-NEXT:    # kill: def $ah killed $ah killed $ax
; X87-NEXT:    sahf
; X87-NEXT:    leal {{[0-9]+}}(%esp), %eax
; X87-NEXT:    jne .LBB54_3
; X87-NEXT:  # %bb.1:
; X87-NEXT:    jp .LBB54_3
; X87-NEXT:  # %bb.2:
; X87-NEXT:    leal {{[0-9]+}}(%esp), %eax
; X87-NEXT:  .LBB54_3:
; X87-NEXT:    movl (%eax), %eax
; X87-NEXT:    retl
;
; X87-CMOV-LABEL: test_f64_une_s:
; X87-CMOV:       # %bb.0:
; X87-CMOV-NEXT:    fldl {{[0-9]+}}(%esp)
; X87-CMOV-NEXT:    fldl {{[0-9]+}}(%esp)
; X87-CMOV-NEXT:    fcompi %st(1), %st
; X87-CMOV-NEXT:    fstp %st(0)
; X87-CMOV-NEXT:    leal {{[0-9]+}}(%esp), %eax
; X87-CMOV-NEXT:    leal {{[0-9]+}}(%esp), %ecx
; X87-CMOV-NEXT:    cmovnel %eax, %ecx
; X87-CMOV-NEXT:    cmovpl %eax, %ecx
; X87-CMOV-NEXT:    movl (%ecx), %eax
; X87-CMOV-NEXT:    retl
  %cond = call i1 @llvm.experimental.constrained.fcmps.f64(
                                               double %f1, double %f2, metadata !"une",
                                               metadata !"fpexcept.strict") #0
  %res = select i1 %cond, i32 %a, i32 %b
  ret i32 %res
}

define i32 @test_f64_uno_s(i32 %a, i32 %b, double %f1, double %f2) #0 {
; CHECK-32-LABEL: test_f64_uno_s:
; CHECK-32:       # %bb.0:
; CHECK-32-NEXT:    {{v?}}movsd {{.*#+}} xmm0 = mem[0],zero
; CHECK-32-NEXT:    {{v?}}comisd {{[0-9]+}}(%esp), %xmm0
; CHECK-32-NEXT:    leal {{[0-9]+}}(%esp), %eax
; CHECK-32-NEXT:    leal {{[0-9]+}}(%esp), %ecx
; CHECK-32-NEXT:    cmovpl %eax, %ecx
; CHECK-32-NEXT:    movl (%ecx), %eax
; CHECK-32-NEXT:    retl
;
; CHECK-64-LABEL: test_f64_uno_s:
; CHECK-64:       # %bb.0:
; CHECK-64-NEXT:    movl %edi, %eax
; CHECK-64-NEXT:    {{v?}}comisd %xmm1, %xmm0
; CHECK-64-NEXT:    cmovnpl %esi, %eax
; CHECK-64-NEXT:    retq
;
; X87-LABEL: test_f64_uno_s:
; X87:       # %bb.0:
; X87-NEXT:    fldl {{[0-9]+}}(%esp)
; X87-NEXT:    fldl {{[0-9]+}}(%esp)
; X87-NEXT:    fcompp
; X87-NEXT:    fnstsw %ax
; X87-NEXT:    # kill: def $ah killed $ah killed $ax
; X87-NEXT:    sahf
; X87-NEXT:    jp .LBB55_1
; X87-NEXT:  # %bb.2:
; X87-NEXT:    leal {{[0-9]+}}(%esp), %eax
; X87-NEXT:    movl (%eax), %eax
; X87-NEXT:    retl
; X87-NEXT:  .LBB55_1:
; X87-NEXT:    leal {{[0-9]+}}(%esp), %eax
; X87-NEXT:    movl (%eax), %eax
; X87-NEXT:    retl
;
; X87-CMOV-LABEL: test_f64_uno_s:
; X87-CMOV:       # %bb.0:
; X87-CMOV-NEXT:    fldl {{[0-9]+}}(%esp)
; X87-CMOV-NEXT:    fldl {{[0-9]+}}(%esp)
; X87-CMOV-NEXT:    fcompi %st(1), %st
; X87-CMOV-NEXT:    fstp %st(0)
; X87-CMOV-NEXT:    leal {{[0-9]+}}(%esp), %eax
; X87-CMOV-NEXT:    leal {{[0-9]+}}(%esp), %ecx
; X87-CMOV-NEXT:    cmovpl %eax, %ecx
; X87-CMOV-NEXT:    movl (%ecx), %eax
; X87-CMOV-NEXT:    retl
  %cond = call i1 @llvm.experimental.constrained.fcmps.f64(
                                               double %f1, double %f2, metadata !"uno",
                                               metadata !"fpexcept.strict") #0
  %res = select i1 %cond, i32 %a, i32 %b
  ret i32 %res
}

attributes #0 = { strictfp }

declare i1 @llvm.experimental.constrained.fcmp.f32(float, float, metadata, metadata)
declare i1 @llvm.experimental.constrained.fcmp.f64(double, double, metadata, metadata)
declare i1 @llvm.experimental.constrained.fcmps.f32(float, float, metadata, metadata)
declare i1 @llvm.experimental.constrained.fcmps.f64(double, double, metadata, metadata)

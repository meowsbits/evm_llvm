; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc < %s -mtriple=thumbv7m-none-eabi | FileCheck %s --check-prefix=CHECK-T2 --check-prefix=CHECK-T2NODSP
; RUN: llc < %s -mtriple=thumbv7em-none-eabi | FileCheck %s --check-prefix=CHECK-T2 --check-prefix=CHECK-T2DSP
; RUN: llc < %s -mtriple=armv5te-none-none-eabi | FileCheck %s --check-prefix=CHECK-ARM --check-prefix=CHECK-ARM6
; RUN: llc < %s -mtriple=armv8a-none-eabi | FileCheck %s --check-prefix=CHECK-ARM --check-prefix=CHECK-ARM8

define i32 @qdadd(i32 %x, i32 %y) nounwind {
; CHECK-T2-LABEL: qdadd:
; CHECK-T2:       @ %bb.0:
; CHECK-T2-NEXT:    .save {r7, lr}
; CHECK-T2-NEXT:    push {r7, lr}
; CHECK-T2-NEXT:    movs r3, #0
; CHECK-T2-NEXT:    adds.w r12, r0, r0
; CHECK-T2-NEXT:    it mi
; CHECK-T2-NEXT:    movmi r3, #1
; CHECK-T2-NEXT:    cmp r3, #0
; CHECK-T2-NEXT:    mov.w r3, #-2147483648
; CHECK-T2-NEXT:    mov.w lr, #0
; CHECK-T2-NEXT:    it ne
; CHECK-T2-NEXT:    mvnne r3, #-2147483648
; CHECK-T2-NEXT:    cmp r12, r0
; CHECK-T2-NEXT:    it vc
; CHECK-T2-NEXT:    movvc r3, r12
; CHECK-T2-NEXT:    adds r0, r3, r1
; CHECK-T2-NEXT:    mov.w r2, #-2147483648
; CHECK-T2-NEXT:    it mi
; CHECK-T2-NEXT:    movmi.w lr, #1
; CHECK-T2-NEXT:    cmp.w lr, #0
; CHECK-T2-NEXT:    it ne
; CHECK-T2-NEXT:    mvnne r2, #-2147483648
; CHECK-T2-NEXT:    cmp r0, r3
; CHECK-T2-NEXT:    it vc
; CHECK-T2-NEXT:    movvc r2, r0
; CHECK-T2-NEXT:    mov r0, r2
; CHECK-T2-NEXT:    pop {r7, pc}
;
; CHECK-ARM6-LABEL: qdadd:
; CHECK-ARM6:       @ %bb.0:
; CHECK-ARM6-NEXT:    .save {r11, lr}
; CHECK-ARM6-NEXT:    push {r11, lr}
; CHECK-ARM6-NEXT:    adds r12, r0, r0
; CHECK-ARM6-NEXT:    mov r3, #0
; CHECK-ARM6-NEXT:    movmi r3, #1
; CHECK-ARM6-NEXT:    cmp r3, #0
; CHECK-ARM6-NEXT:    mov r3, #-2147483648
; CHECK-ARM6-NEXT:    mov lr, #0
; CHECK-ARM6-NEXT:    mvnne r3, #-2147483648
; CHECK-ARM6-NEXT:    cmp r12, r0
; CHECK-ARM6-NEXT:    movvc r3, r12
; CHECK-ARM6-NEXT:    adds r0, r3, r1
; CHECK-ARM6-NEXT:    movmi lr, #1
; CHECK-ARM6-NEXT:    mov r2, #-2147483648
; CHECK-ARM6-NEXT:    cmp lr, #0
; CHECK-ARM6-NEXT:    mvnne r2, #-2147483648
; CHECK-ARM6-NEXT:    cmp r0, r3
; CHECK-ARM6-NEXT:    movvc r2, r0
; CHECK-ARM6-NEXT:    mov r0, r2
; CHECK-ARM6-NEXT:    pop {r11, pc}
;
; CHECK-ARM8-LABEL: qdadd:
; CHECK-ARM8:       @ %bb.0:
; CHECK-ARM8-NEXT:    .save {r11, lr}
; CHECK-ARM8-NEXT:    push {r11, lr}
; CHECK-ARM8-NEXT:    adds r12, r0, r0
; CHECK-ARM8-NEXT:    mov r3, #0
; CHECK-ARM8-NEXT:    movwmi r3, #1
; CHECK-ARM8-NEXT:    cmp r3, #0
; CHECK-ARM8-NEXT:    mov r3, #-2147483648
; CHECK-ARM8-NEXT:    mov lr, #0
; CHECK-ARM8-NEXT:    mvnne r3, #-2147483648
; CHECK-ARM8-NEXT:    cmp r12, r0
; CHECK-ARM8-NEXT:    movvc r3, r12
; CHECK-ARM8-NEXT:    adds r0, r3, r1
; CHECK-ARM8-NEXT:    movwmi lr, #1
; CHECK-ARM8-NEXT:    mov r2, #-2147483648
; CHECK-ARM8-NEXT:    cmp lr, #0
; CHECK-ARM8-NEXT:    mvnne r2, #-2147483648
; CHECK-ARM8-NEXT:    cmp r0, r3
; CHECK-ARM8-NEXT:    movvc r2, r0
; CHECK-ARM8-NEXT:    mov r0, r2
; CHECK-ARM8-NEXT:    pop {r11, pc}
  %z = call i32 @llvm.sadd.sat.i32(i32 %x, i32 %x)
  %tmp = call i32 @llvm.sadd.sat.i32(i32 %z, i32 %y)
  ret i32 %tmp
}

define i32 @qdadd_c(i32 %x, i32 %y) nounwind {
; CHECK-T2-LABEL: qdadd_c:
; CHECK-T2:       @ %bb.0:
; CHECK-T2-NEXT:    .save {r7, lr}
; CHECK-T2-NEXT:    push {r7, lr}
; CHECK-T2-NEXT:    movs r3, #0
; CHECK-T2-NEXT:    adds.w r12, r0, r0
; CHECK-T2-NEXT:    it mi
; CHECK-T2-NEXT:    movmi r3, #1
; CHECK-T2-NEXT:    cmp r3, #0
; CHECK-T2-NEXT:    mov.w r3, #-2147483648
; CHECK-T2-NEXT:    mov.w lr, #0
; CHECK-T2-NEXT:    it ne
; CHECK-T2-NEXT:    mvnne r3, #-2147483648
; CHECK-T2-NEXT:    cmp r12, r0
; CHECK-T2-NEXT:    it vc
; CHECK-T2-NEXT:    movvc r3, r12
; CHECK-T2-NEXT:    adds r0, r1, r3
; CHECK-T2-NEXT:    mov.w r2, #-2147483648
; CHECK-T2-NEXT:    it mi
; CHECK-T2-NEXT:    movmi.w lr, #1
; CHECK-T2-NEXT:    cmp.w lr, #0
; CHECK-T2-NEXT:    it ne
; CHECK-T2-NEXT:    mvnne r2, #-2147483648
; CHECK-T2-NEXT:    cmp r0, r1
; CHECK-T2-NEXT:    it vc
; CHECK-T2-NEXT:    movvc r2, r0
; CHECK-T2-NEXT:    mov r0, r2
; CHECK-T2-NEXT:    pop {r7, pc}
;
; CHECK-ARM6-LABEL: qdadd_c:
; CHECK-ARM6:       @ %bb.0:
; CHECK-ARM6-NEXT:    .save {r11, lr}
; CHECK-ARM6-NEXT:    push {r11, lr}
; CHECK-ARM6-NEXT:    adds r12, r0, r0
; CHECK-ARM6-NEXT:    mov r3, #0
; CHECK-ARM6-NEXT:    movmi r3, #1
; CHECK-ARM6-NEXT:    cmp r3, #0
; CHECK-ARM6-NEXT:    mov r3, #-2147483648
; CHECK-ARM6-NEXT:    mov lr, #0
; CHECK-ARM6-NEXT:    mvnne r3, #-2147483648
; CHECK-ARM6-NEXT:    cmp r12, r0
; CHECK-ARM6-NEXT:    movvc r3, r12
; CHECK-ARM6-NEXT:    adds r0, r1, r3
; CHECK-ARM6-NEXT:    movmi lr, #1
; CHECK-ARM6-NEXT:    mov r2, #-2147483648
; CHECK-ARM6-NEXT:    cmp lr, #0
; CHECK-ARM6-NEXT:    mvnne r2, #-2147483648
; CHECK-ARM6-NEXT:    cmp r0, r1
; CHECK-ARM6-NEXT:    movvc r2, r0
; CHECK-ARM6-NEXT:    mov r0, r2
; CHECK-ARM6-NEXT:    pop {r11, pc}
;
; CHECK-ARM8-LABEL: qdadd_c:
; CHECK-ARM8:       @ %bb.0:
; CHECK-ARM8-NEXT:    .save {r11, lr}
; CHECK-ARM8-NEXT:    push {r11, lr}
; CHECK-ARM8-NEXT:    adds r12, r0, r0
; CHECK-ARM8-NEXT:    mov r3, #0
; CHECK-ARM8-NEXT:    movwmi r3, #1
; CHECK-ARM8-NEXT:    cmp r3, #0
; CHECK-ARM8-NEXT:    mov r3, #-2147483648
; CHECK-ARM8-NEXT:    mov lr, #0
; CHECK-ARM8-NEXT:    mvnne r3, #-2147483648
; CHECK-ARM8-NEXT:    cmp r12, r0
; CHECK-ARM8-NEXT:    movvc r3, r12
; CHECK-ARM8-NEXT:    adds r0, r1, r3
; CHECK-ARM8-NEXT:    movwmi lr, #1
; CHECK-ARM8-NEXT:    mov r2, #-2147483648
; CHECK-ARM8-NEXT:    cmp lr, #0
; CHECK-ARM8-NEXT:    mvnne r2, #-2147483648
; CHECK-ARM8-NEXT:    cmp r0, r1
; CHECK-ARM8-NEXT:    movvc r2, r0
; CHECK-ARM8-NEXT:    mov r0, r2
; CHECK-ARM8-NEXT:    pop {r11, pc}
  %z = call i32 @llvm.sadd.sat.i32(i32 %x, i32 %x)
  %tmp = call i32 @llvm.sadd.sat.i32(i32 %y, i32 %z)
  ret i32 %tmp
}

define i32 @qdsub(i32 %x, i32 %y) nounwind {
; CHECK-T2-LABEL: qdsub:
; CHECK-T2:       @ %bb.0:
; CHECK-T2-NEXT:    .save {r7, lr}
; CHECK-T2-NEXT:    push {r7, lr}
; CHECK-T2-NEXT:    movs r3, #0
; CHECK-T2-NEXT:    adds.w r12, r0, r0
; CHECK-T2-NEXT:    it mi
; CHECK-T2-NEXT:    movmi r3, #1
; CHECK-T2-NEXT:    cmp r3, #0
; CHECK-T2-NEXT:    mov.w r3, #-2147483648
; CHECK-T2-NEXT:    mov.w lr, #0
; CHECK-T2-NEXT:    it ne
; CHECK-T2-NEXT:    mvnne r3, #-2147483648
; CHECK-T2-NEXT:    cmp r12, r0
; CHECK-T2-NEXT:    it vc
; CHECK-T2-NEXT:    movvc r3, r12
; CHECK-T2-NEXT:    subs r0, r1, r3
; CHECK-T2-NEXT:    mov.w r2, #-2147483648
; CHECK-T2-NEXT:    it mi
; CHECK-T2-NEXT:    movmi.w lr, #1
; CHECK-T2-NEXT:    cmp.w lr, #0
; CHECK-T2-NEXT:    it ne
; CHECK-T2-NEXT:    mvnne r2, #-2147483648
; CHECK-T2-NEXT:    cmp r1, r3
; CHECK-T2-NEXT:    it vc
; CHECK-T2-NEXT:    movvc r2, r0
; CHECK-T2-NEXT:    mov r0, r2
; CHECK-T2-NEXT:    pop {r7, pc}
;
; CHECK-ARM6-LABEL: qdsub:
; CHECK-ARM6:       @ %bb.0:
; CHECK-ARM6-NEXT:    .save {r11, lr}
; CHECK-ARM6-NEXT:    push {r11, lr}
; CHECK-ARM6-NEXT:    adds r12, r0, r0
; CHECK-ARM6-NEXT:    mov r3, #0
; CHECK-ARM6-NEXT:    movmi r3, #1
; CHECK-ARM6-NEXT:    cmp r3, #0
; CHECK-ARM6-NEXT:    mov r3, #-2147483648
; CHECK-ARM6-NEXT:    mov lr, #0
; CHECK-ARM6-NEXT:    mvnne r3, #-2147483648
; CHECK-ARM6-NEXT:    cmp r12, r0
; CHECK-ARM6-NEXT:    movvc r3, r12
; CHECK-ARM6-NEXT:    subs r0, r1, r3
; CHECK-ARM6-NEXT:    movmi lr, #1
; CHECK-ARM6-NEXT:    mov r2, #-2147483648
; CHECK-ARM6-NEXT:    cmp lr, #0
; CHECK-ARM6-NEXT:    mvnne r2, #-2147483648
; CHECK-ARM6-NEXT:    cmp r1, r3
; CHECK-ARM6-NEXT:    movvc r2, r0
; CHECK-ARM6-NEXT:    mov r0, r2
; CHECK-ARM6-NEXT:    pop {r11, pc}
;
; CHECK-ARM8-LABEL: qdsub:
; CHECK-ARM8:       @ %bb.0:
; CHECK-ARM8-NEXT:    .save {r11, lr}
; CHECK-ARM8-NEXT:    push {r11, lr}
; CHECK-ARM8-NEXT:    adds r12, r0, r0
; CHECK-ARM8-NEXT:    mov r3, #0
; CHECK-ARM8-NEXT:    movwmi r3, #1
; CHECK-ARM8-NEXT:    cmp r3, #0
; CHECK-ARM8-NEXT:    mov r3, #-2147483648
; CHECK-ARM8-NEXT:    mov lr, #0
; CHECK-ARM8-NEXT:    mvnne r3, #-2147483648
; CHECK-ARM8-NEXT:    cmp r12, r0
; CHECK-ARM8-NEXT:    movvc r3, r12
; CHECK-ARM8-NEXT:    subs r0, r1, r3
; CHECK-ARM8-NEXT:    movwmi lr, #1
; CHECK-ARM8-NEXT:    mov r2, #-2147483648
; CHECK-ARM8-NEXT:    cmp lr, #0
; CHECK-ARM8-NEXT:    mvnne r2, #-2147483648
; CHECK-ARM8-NEXT:    cmp r1, r3
; CHECK-ARM8-NEXT:    movvc r2, r0
; CHECK-ARM8-NEXT:    mov r0, r2
; CHECK-ARM8-NEXT:    pop {r11, pc}
  %z = call i32 @llvm.sadd.sat.i32(i32 %x, i32 %x)
  %tmp = call i32 @llvm.ssub.sat.i32(i32 %y, i32 %z)
  ret i32 %tmp
}

define i32 @qdsub_c(i32 %x, i32 %y) nounwind {
; CHECK-T2-LABEL: qdsub_c:
; CHECK-T2:       @ %bb.0:
; CHECK-T2-NEXT:    .save {r7, lr}
; CHECK-T2-NEXT:    push {r7, lr}
; CHECK-T2-NEXT:    movs r3, #0
; CHECK-T2-NEXT:    adds.w r12, r0, r0
; CHECK-T2-NEXT:    it mi
; CHECK-T2-NEXT:    movmi r3, #1
; CHECK-T2-NEXT:    cmp r3, #0
; CHECK-T2-NEXT:    mov.w r3, #-2147483648
; CHECK-T2-NEXT:    mov.w lr, #0
; CHECK-T2-NEXT:    it ne
; CHECK-T2-NEXT:    mvnne r3, #-2147483648
; CHECK-T2-NEXT:    cmp r12, r0
; CHECK-T2-NEXT:    it vc
; CHECK-T2-NEXT:    movvc r3, r12
; CHECK-T2-NEXT:    subs r0, r3, r1
; CHECK-T2-NEXT:    mov.w r2, #-2147483648
; CHECK-T2-NEXT:    it mi
; CHECK-T2-NEXT:    movmi.w lr, #1
; CHECK-T2-NEXT:    cmp.w lr, #0
; CHECK-T2-NEXT:    it ne
; CHECK-T2-NEXT:    mvnne r2, #-2147483648
; CHECK-T2-NEXT:    cmp r3, r1
; CHECK-T2-NEXT:    it vc
; CHECK-T2-NEXT:    movvc r2, r0
; CHECK-T2-NEXT:    mov r0, r2
; CHECK-T2-NEXT:    pop {r7, pc}
;
; CHECK-ARM6-LABEL: qdsub_c:
; CHECK-ARM6:       @ %bb.0:
; CHECK-ARM6-NEXT:    .save {r11, lr}
; CHECK-ARM6-NEXT:    push {r11, lr}
; CHECK-ARM6-NEXT:    adds r12, r0, r0
; CHECK-ARM6-NEXT:    mov r3, #0
; CHECK-ARM6-NEXT:    movmi r3, #1
; CHECK-ARM6-NEXT:    cmp r3, #0
; CHECK-ARM6-NEXT:    mov r3, #-2147483648
; CHECK-ARM6-NEXT:    mov lr, #0
; CHECK-ARM6-NEXT:    mvnne r3, #-2147483648
; CHECK-ARM6-NEXT:    cmp r12, r0
; CHECK-ARM6-NEXT:    movvc r3, r12
; CHECK-ARM6-NEXT:    subs r0, r3, r1
; CHECK-ARM6-NEXT:    movmi lr, #1
; CHECK-ARM6-NEXT:    mov r2, #-2147483648
; CHECK-ARM6-NEXT:    cmp lr, #0
; CHECK-ARM6-NEXT:    mvnne r2, #-2147483648
; CHECK-ARM6-NEXT:    cmp r3, r1
; CHECK-ARM6-NEXT:    movvc r2, r0
; CHECK-ARM6-NEXT:    mov r0, r2
; CHECK-ARM6-NEXT:    pop {r11, pc}
;
; CHECK-ARM8-LABEL: qdsub_c:
; CHECK-ARM8:       @ %bb.0:
; CHECK-ARM8-NEXT:    .save {r11, lr}
; CHECK-ARM8-NEXT:    push {r11, lr}
; CHECK-ARM8-NEXT:    adds r12, r0, r0
; CHECK-ARM8-NEXT:    mov r3, #0
; CHECK-ARM8-NEXT:    movwmi r3, #1
; CHECK-ARM8-NEXT:    cmp r3, #0
; CHECK-ARM8-NEXT:    mov r3, #-2147483648
; CHECK-ARM8-NEXT:    mov lr, #0
; CHECK-ARM8-NEXT:    mvnne r3, #-2147483648
; CHECK-ARM8-NEXT:    cmp r12, r0
; CHECK-ARM8-NEXT:    movvc r3, r12
; CHECK-ARM8-NEXT:    subs r0, r3, r1
; CHECK-ARM8-NEXT:    movwmi lr, #1
; CHECK-ARM8-NEXT:    mov r2, #-2147483648
; CHECK-ARM8-NEXT:    cmp lr, #0
; CHECK-ARM8-NEXT:    mvnne r2, #-2147483648
; CHECK-ARM8-NEXT:    cmp r3, r1
; CHECK-ARM8-NEXT:    movvc r2, r0
; CHECK-ARM8-NEXT:    mov r0, r2
; CHECK-ARM8-NEXT:    pop {r11, pc}
  %z = call i32 @llvm.sadd.sat.i32(i32 %x, i32 %x)
  %tmp = call i32 @llvm.ssub.sat.i32(i32 %z, i32 %y)
  ret i32 %tmp
}

declare i32 @llvm.sadd.sat.i32(i32, i32)
declare i32 @llvm.ssub.sat.i32(i32, i32)

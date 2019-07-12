; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc -mcpu=pwr9 -mtriple=powerpc64le-unknown-unknown \
; RUN:   -ppc-asm-full-reg-names -verify-machineinstrs -O2 < %s | FileCheck %s \
; RUN:   --check-prefix=CHECK-P9

define i32 @t(i32 %n, i32 %delta, i32 %a) {
; CHECK-P9-LABEL: t:
; CHECK-P9:       # %bb.0: # %entry
; CHECK-P9-NEXT:    lis r7, 0
; CHECK-P9-NEXT:    li r6, 0
; CHECK-P9-NEXT:    li r9, 0
; CHECK-P9-NEXT:    li r10, 0
; CHECK-P9-NEXT:    ori r7, r7, 65535
; CHECK-P9-NEXT:    .p2align 5
; CHECK-P9-NEXT:  .LBB0_1: # %header
; CHECK-P9-NEXT:    #
; CHECK-P9-NEXT:    addi r10, r10, 1
; CHECK-P9-NEXT:    cmpw r10, r3
; CHECK-P9-NEXT:    addi r8, r5, 1024
; CHECK-P9-NEXT:    blt cr0, .LBB0_4
; CHECK-P9-NEXT:  # %bb.2: # %cont
; CHECK-P9-NEXT:    #
; CHECK-P9-NEXT:    add r9, r9, r4
; CHECK-P9-NEXT:    cmpw r9, r7
; CHECK-P9-NEXT:    bgt cr0, .LBB0_1
; CHECK-P9-NEXT:  # %bb.3: # %cont.1
; CHECK-P9-NEXT:    mr r6, r8
; CHECK-P9-NEXT:  .LBB0_4: # %return
; CHECK-P9-NEXT:    mullw r3, r6, r8
; CHECK-P9-NEXT:    blr
entry:
  br label %header

header:
  %sum = phi i32 [ 0, %entry ], [ %sum.1, %cont ]
  %i = phi i32 [ 0, %entry ], [ %i.1, %cont ]
  %i.1 = add nsw i32 %i, 1
  %lt = icmp slt i32 %i.1, %n
  br i1 %lt, label %return, label %cont

cont:
  %sum.1 = add nsw i32 %sum, %delta
  %lt.1 = icmp slt i32 %sum.1, 65536
  br i1 %lt.1, label %cont.1, label %header

cont.1:
  %delta.1 = add nsw i32 %a, 1024
  br label %return

return:
  %delta.2 = phi i32 [ %delta.1, %cont.1 ], [ 0, %header ]
  %delta.3 = add nsw i32 %a, 1024
  %ret = mul i32 %delta.2, %delta.3
  ret i32 %ret
}

define dso_local signext i32 @foo(i32 signext %x, i32 signext %y) local_unnamed_addr #0 {
; CHECK-P9-LABEL: foo:
; CHECK-P9:       # %bb.0: # %entry
; CHECK-P9-NEXT:    mflr r0
; CHECK-P9-NEXT:    .cfi_def_cfa_offset 80
; CHECK-P9-NEXT:    .cfi_offset lr, 16
; CHECK-P9-NEXT:    .cfi_offset r27, -40
; CHECK-P9-NEXT:    .cfi_offset r28, -32
; CHECK-P9-NEXT:    .cfi_offset r29, -24
; CHECK-P9-NEXT:    .cfi_offset r30, -16
; CHECK-P9-NEXT:    std r27, -40(r1) # 8-byte Folded Spill
; CHECK-P9-NEXT:    std r28, -32(r1) # 8-byte Folded Spill
; CHECK-P9-NEXT:    std r29, -24(r1) # 8-byte Folded Spill
; CHECK-P9-NEXT:    std r30, -16(r1) # 8-byte Folded Spill
; CHECK-P9-NEXT:    std r0, 16(r1)
; CHECK-P9-NEXT:    stdu r1, -80(r1)
; CHECK-P9-NEXT:    mr r30, r4
; CHECK-P9-NEXT:    mr r29, r3
; CHECK-P9-NEXT:    lis r3, 21845
; CHECK-P9-NEXT:    add r28, r30, r29
; CHECK-P9-NEXT:    ori r27, r3, 21846
; CHECK-P9-NEXT:    b .LBB1_3
; CHECK-P9-NEXT:    .p2align 4
; CHECK-P9-NEXT:  .LBB1_1: # %sw.bb3
; CHECK-P9-NEXT:    #
; CHECK-P9-NEXT:    add r28, r3, r28
; CHECK-P9-NEXT:  .LBB1_2: # %sw.epilog
; CHECK-P9-NEXT:    #
; CHECK-P9-NEXT:    cmpwi r28, 1025
; CHECK-P9-NEXT:    bge cr0, .LBB1_6
; CHECK-P9-NEXT:  .LBB1_3: # %while.cond
; CHECK-P9-NEXT:    #
; CHECK-P9-NEXT:    extsw r3, r29
; CHECK-P9-NEXT:    bl bar
; CHECK-P9-NEXT:    nop
; CHECK-P9-NEXT:    mr r29, r3
; CHECK-P9-NEXT:    extsw r3, r30
; CHECK-P9-NEXT:    bl bar
; CHECK-P9-NEXT:    nop
; CHECK-P9-NEXT:    mr r30, r3
; CHECK-P9-NEXT:    extsw r3, r28
; CHECK-P9-NEXT:    mulld r4, r3, r27
; CHECK-P9-NEXT:    rldicl r5, r4, 1, 63
; CHECK-P9-NEXT:    rldicl r4, r4, 32, 32
; CHECK-P9-NEXT:    add r4, r4, r5
; CHECK-P9-NEXT:    slwi r5, r4, 1
; CHECK-P9-NEXT:    add r4, r4, r5
; CHECK-P9-NEXT:    subf r5, r4, r3
; CHECK-P9-NEXT:    mulli r4, r29, 13
; CHECK-P9-NEXT:    mulli r3, r30, 23
; CHECK-P9-NEXT:    cmplwi r5, 1
; CHECK-P9-NEXT:    beq cr0, .LBB1_1
; CHECK-P9-NEXT:  # %bb.4: # %while.cond
; CHECK-P9-NEXT:    #
; CHECK-P9-NEXT:    cmplwi r5, 0
; CHECK-P9-NEXT:    bne cr0, .LBB1_2
; CHECK-P9-NEXT:  # %bb.5: # %sw.bb
; CHECK-P9-NEXT:    #
; CHECK-P9-NEXT:    add r28, r4, r28
; CHECK-P9-NEXT:    cmpwi r28, 1025
; CHECK-P9-NEXT:    blt cr0, .LBB1_3
; CHECK-P9-NEXT:  .LBB1_6: # %while.end
; CHECK-P9-NEXT:    lis r5, -13108
; CHECK-P9-NEXT:    ori r5, r5, 52429
; CHECK-P9-NEXT:    mullw r5, r28, r5
; CHECK-P9-NEXT:    lis r6, 13107
; CHECK-P9-NEXT:    ori r6, r6, 13108
; CHECK-P9-NEXT:    cmplw r5, r6
; CHECK-P9-NEXT:    blt cr0, .LBB1_8
; CHECK-P9-NEXT:  # %bb.7: # %if.then8
; CHECK-P9-NEXT:    extsw r4, r4
; CHECK-P9-NEXT:    extsw r5, r28
; CHECK-P9-NEXT:    extsw r3, r3
; CHECK-P9-NEXT:    sub r4, r5, r4
; CHECK-P9-NEXT:    sub r3, r3, r5
; CHECK-P9-NEXT:    rldicl r4, r4, 1, 63
; CHECK-P9-NEXT:    rldicl r3, r3, 1, 63
; CHECK-P9-NEXT:    or r3, r4, r3
; CHECK-P9-NEXT:    b .LBB1_9
; CHECK-P9-NEXT:  .LBB1_8: # %cleanup20
; CHECK-P9-NEXT:    li r3, 0
; CHECK-P9-NEXT:  .LBB1_9: # %cleanup20
; CHECK-P9-NEXT:    addi r1, r1, 80
; CHECK-P9-NEXT:    ld r0, 16(r1)
; CHECK-P9-NEXT:    mtlr r0
; CHECK-P9-NEXT:    ld r30, -16(r1) # 8-byte Folded Reload
; CHECK-P9-NEXT:    ld r29, -24(r1) # 8-byte Folded Reload
; CHECK-P9-NEXT:    ld r28, -32(r1) # 8-byte Folded Reload
; CHECK-P9-NEXT:    ld r27, -40(r1) # 8-byte Folded Reload
; CHECK-P9-NEXT:    blr
entry:
  %add = add nsw i32 %y, %x
  br label %while.cond

while.cond:                                       ; preds = %sw.epilog, %entry
  %sum.0 = phi i32 [ %add, %entry ], [ %sum.1, %sw.epilog ]
  %y.addr.0 = phi i32 [ %y, %entry ], [ %call1, %sw.epilog ]
  %x.addr.0 = phi i32 [ %x, %entry ], [ %call, %sw.epilog ]
  %call = tail call signext i32 @bar(i32 signext %x.addr.0) #2
  %call1 = tail call signext i32 @bar(i32 signext %y.addr.0) #2
  %rem = srem i32 %sum.0, 3
  switch i32 %rem, label %sw.epilog [
    i32 0, label %sw.bb
    i32 1, label %sw.bb3
  ]

sw.bb:                                            ; preds = %while.cond
  %mul = mul nsw i32 %call, 13
  %add2 = add nsw i32 %mul, %sum.0
  br label %sw.epilog

sw.bb3:                                           ; preds = %while.cond
  %mul4 = mul nsw i32 %call1, 23
  %add5 = add nsw i32 %mul4, %sum.0
  br label %sw.epilog

sw.epilog:                                        ; preds = %while.cond, %sw.bb3, %sw.bb
  %sum.1 = phi i32 [ %sum.0, %while.cond ], [ %add5, %sw.bb3 ], [ %add2, %sw.bb ]
  %cmp = icmp slt i32 %sum.1, 1025
  br i1 %cmp, label %while.cond, label %while.end

while.end:                                        ; preds = %sw.epilog
  %rem739 = urem i32 %sum.1, 5
  %tobool = icmp eq i32 %rem739, 0
  br i1 %tobool, label %cleanup20, label %if.then8

if.then8:                                         ; preds = %while.end
  %mul9 = mul nsw i32 %call, 13
  %cmp11 = icmp slt i32 %sum.1, %mul9
  %mul10 = mul nsw i32 %call1, 23
  %cmp12 = icmp sgt i32 %sum.1, %mul10
  %or.cond = or i1 %cmp11, %cmp12
  %spec.select = zext i1 %or.cond to i32
  ret i32 %spec.select

cleanup20:                                        ; preds = %while.end
  ret i32 0
}

declare signext i32 @bar(i32 signext) local_unnamed_addr #1

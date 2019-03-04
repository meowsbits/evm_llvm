//===-- EVMISelLowering.cpp - EVM DAG Lowering Implementation  --------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This file defines the interfaces that EVM uses to lower LLVM code into a
// selection DAG.
//
//===----------------------------------------------------------------------===//

#include "EVMISelLowering.h"
#include "EVM.h"
#include "EVMMachineFunctionInfo.h"
#include "EVMRegisterInfo.h"
#include "EVMSubtarget.h"
#include "EVMTargetMachine.h"
#include "llvm/ADT/Statistic.h"
#include "llvm/CodeGen/CallingConvLower.h"
#include "llvm/CodeGen/MachineFrameInfo.h"
#include "llvm/CodeGen/MachineFunction.h"
#include "llvm/CodeGen/MachineInstrBuilder.h"
#include "llvm/CodeGen/MachineRegisterInfo.h"
#include "llvm/CodeGen/SelectionDAGISel.h"
#include "llvm/CodeGen/TargetLoweringObjectFileImpl.h"
#include "llvm/CodeGen/ValueTypes.h"
#include "llvm/IR/DiagnosticInfo.h"
#include "llvm/IR/DiagnosticPrinter.h"
#include "llvm/Support/Debug.h"
#include "llvm/Support/ErrorHandling.h"
#include "llvm/Support/raw_ostream.h"

using namespace llvm;

#define DEBUG_TYPE "evm-lower"

STATISTIC(NumTailCalls, "Number of tail calls");

EVMTargetLowering::EVMTargetLowering(const TargetMachine &TM,
                                         const EVMSubtarget &STI)
    : TargetLowering(TM), Subtarget(STI) {

  // Legal register classes:
  addRegisterClass(MVT::i256, &EVM::GPRRegClass);

  // Compute derived properties from the register classes.
  computeRegisterProperties(Subtarget.getRegisterInfo());

  setBooleanContents(ZeroOrOneBooleanContent);
  setBooleanVectorContents(ZeroOrOneBooleanContent);
  setSchedulingPreference(Sched::RegPressure);
  setStackPointerRegisterToSaveRestore(EVM::SP);

  setOperationAction(ISD::BR_CC, MVT::i64, Custom);
  setOperationAction(ISD::BR_JT, MVT::Other, Expand);
  setOperationAction(ISD::BRIND, MVT::Other, Expand);
  setOperationAction(ISD::BRCOND, MVT::Other, Expand);

  // TODO: set type legalization actions
  for (auto VT : { MVT::i1, MVT::i8, MVT::i16, MVT::i32,
                   MVT::i64, MVT::i128 }) {
    setOperationAction(ISD::SDIVREM, VT, Expand);
    setOperationAction(ISD::UDIVREM, VT, Expand);
    setOperationAction(ISD::SREM, VT, Expand);
    setOperationAction(ISD::UREM, VT, Expand);
    setOperationAction(ISD::MULHU, VT, Expand);
    setOperationAction(ISD::MULHS, VT, Expand);
    setOperationAction(ISD::UMUL_LOHI, VT, Expand);
    setOperationAction(ISD::SMUL_LOHI, VT, Expand);
    setOperationAction(ISD::ROTR, VT, Expand);
    setOperationAction(ISD::ROTL, VT, Expand);
    setOperationAction(ISD::SHL_PARTS, VT, Expand);
    setOperationAction(ISD::SRL_PARTS, VT, Expand);
    setOperationAction(ISD::SRA_PARTS, VT, Expand);
    setOperationAction(ISD::CTPOP, VT, Expand);

    setOperationAction(ISD::SETCC, VT, Expand);
    setOperationAction(ISD::SELECT, VT, Expand);

    // have to do custom for SELECT_CC
    setOperationAction(ISD::SELECT_CC, VT, Custom);

    setOperationAction(ISD::CTTZ, VT, Expand);
    setOperationAction(ISD::CTLZ, VT, Expand);
    setOperationAction(ISD::CTTZ_ZERO_UNDEF, VT, Expand);
    setOperationAction(ISD::SIGN_EXTEND_INREG, VT, Expand);


  }

  for (MVT VT : MVT::integer_valuetypes()) {
    for (auto N : {ISD::EXTLOAD, ISD::SEXTLOAD, ISD::ZEXTLOAD}) {
      setLoadExtAction(N, VT, MVT::i1, Expand);
      setLoadExtAction(N, VT, MVT::i8, Expand);
      setLoadExtAction(N, VT, MVT::i16, Expand);
      setLoadExtAction(N, VT, MVT::i32, Expand);
      setLoadExtAction(N, VT, MVT::i64, Expand);
      setLoadExtAction(N, VT, MVT::i128, Expand);
    }
  }


  llvm_unreachable("unfinished implementation.");
}

EVT EVMTargetLowering::getSetCCResultType(const DataLayout &DL, LLVMContext &,
                                            EVT VT) const {
  llvm_unreachable("unimplemented.");
}

bool EVMTargetLowering::getTgtMemIntrinsic(IntrinsicInfo &Info,
                                             const CallInst &I,
                                             MachineFunction &MF,
                                             unsigned Intrinsic) const {
  llvm_unreachable("unimplemented.");
}

bool EVMTargetLowering::isLegalAddressingMode(const DataLayout &DL,
                                                const AddrMode &AM, Type *Ty,
                                                unsigned AS,
                                                Instruction *I) const {
  llvm_unreachable("unimplemented.");
}

bool EVMTargetLowering::isLegalICmpImmediate(int64_t Imm) const {
  llvm_unreachable("unimplemented.");
}

bool EVMTargetLowering::isLegalAddImmediate(int64_t Imm) const {
  llvm_unreachable("unimplemented.");
}

bool EVMTargetLowering::isTruncateFree(Type *SrcTy, Type *DstTy) const {
  llvm_unreachable("unimplemented.");
}

bool EVMTargetLowering::isTruncateFree(EVT SrcVT, EVT DstVT) const {
  llvm_unreachable("unimplemented.");
}

bool EVMTargetLowering::isZExtFree(SDValue Val, EVT VT2) const {
  llvm_unreachable("unimplemented.");
}

bool EVMTargetLowering::isSExtCheaperThanZExt(EVT SrcVT, EVT DstVT) const {
  llvm_unreachable("unimplemented.");
}

SDValue EVMTargetLowering::LowerOperation(SDValue Op,
                                            SelectionDAG &DAG) const {
  llvm_unreachable("unimplemented.");
}


void EVMTargetLowering::ReplaceNodeResults(SDNode *N,
                                           SmallVectorImpl<SDValue> &Results,
                                           SelectionDAG &DAG) const {
  llvm_unreachable("unimplemented.");
}

SDValue EVMTargetLowering::PerformDAGCombine(SDNode *N,
                                             DAGCombinerInfo &DCI) const {

  llvm_unreachable("unimplemented.");
  return SDValue();
}


MachineBasicBlock *
EVMTargetLowering::EmitInstrWithCustomInserter(MachineInstr &MI,
                                               MachineBasicBlock *BB) const {
  llvm_unreachable("unimplemented.");
}

// Convert Val to a ValVT. Should not be called for CCValAssign::Indirect
// values.
static SDValue convertLocVTToValVT(SelectionDAG &DAG, SDValue Val,
                                   const CCValAssign &VA, const SDLoc &DL) {
  llvm_unreachable("unimplemented.");
}

// Transform physical registers into virtual registers.
SDValue EVMTargetLowering::LowerFormalArguments(
    SDValue Chain, CallingConv::ID CallConv, bool IsVarArg,
    const SmallVectorImpl<ISD::InputArg> &Ins, const SDLoc &DL,
    SelectionDAG &DAG, SmallVectorImpl<SDValue> &InVals) const {
  llvm_unreachable("unimplemented.");
}

/// IsEligibleForTailCallOptimization - Check whether the call is eligible
/// for tail call optimization.
/// Note: This is modelled after ARM's IsEligibleForTailCallOptimization.
bool EVMTargetLowering::IsEligibleForTailCallOptimization(
  CCState &CCInfo, CallLoweringInfo &CLI, MachineFunction &MF,
  const SmallVector<CCValAssign, 16> &ArgLocs) const {

  llvm_unreachable("unimplemented.");
  return false;
}

// Lower a call to a callseq_start + CALL + callseq_end chain, and add input
// and output parameter nodes.
SDValue EVMTargetLowering::LowerCall(CallLoweringInfo &CLI,
                                     SmallVectorImpl<SDValue> &InVals) const {
  llvm_unreachable("unimplemented.");
}

bool EVMTargetLowering::CanLowerReturn(
    CallingConv::ID CallConv, MachineFunction &MF, bool IsVarArg,
    const SmallVectorImpl<ISD::OutputArg> &Outs, LLVMContext &Context) const {
  llvm_unreachable("unimplemented.");
}

SDValue
EVMTargetLowering::LowerReturn(SDValue Chain, CallingConv::ID CallConv,
                               bool IsVarArg,
                               const SmallVectorImpl<ISD::OutputArg> &Outs,
                               const SmallVectorImpl<SDValue> &OutVals,
                               const SDLoc &DL, SelectionDAG &DAG) const {
  llvm_unreachable("unimplemented.");
}

const char *EVMTargetLowering::getTargetNodeName(unsigned Opcode) const {
  llvm_unreachable("unimplemented.");
  return nullptr;
}

std::pair<unsigned, const TargetRegisterClass *>
EVMTargetLowering::getRegForInlineAsmConstraint(const TargetRegisterInfo *TRI,
                                                  StringRef Constraint,
                                                  MVT VT) const {
  llvm_unreachable("unimplemented.");
}

Instruction *EVMTargetLowering::emitLeadingFence(IRBuilder<> &Builder,
                                                   Instruction *Inst,
                                                   AtomicOrdering Ord) const {
  llvm_unreachable("unimplemented.");
  return nullptr;
}

Instruction *EVMTargetLowering::emitTrailingFence(IRBuilder<> &Builder,
                                                    Instruction *Inst,
                                                    AtomicOrdering Ord) const {
  llvm_unreachable("unimplemented.");
  return nullptr;
}

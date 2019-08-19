//===-- EVMUtilities - EVM Utility Functions ---*- C++ -*-====//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
///
/// \file
/// This file contains the declaration of the EVM-specific
/// utility functions.
///
//===----------------------------------------------------------------------===//

#ifndef LLVM_LIB_TARGET_EVM_EVMUTILITIES_H
#define LLVM_LIB_TARGET_EVM_EVMUTILITIES_H

#include "llvm/ADT/BitVector.h"
#include "llvm/IR/Function.h"
#include "llvm/IR/Type.h"

namespace llvm {

namespace EVM {

uint32_t getFunctionSignature(Function* F);

std::string getCanonicalName(Type* input);

} // end namespace WebAssembly

} // end namespace llvm

#endif




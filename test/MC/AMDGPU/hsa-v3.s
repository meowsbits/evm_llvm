// RUN: llvm-mc -mattr=+code-object-v3 -triple amdgcn-amd-amdhsa -mcpu=gfx900 -mattr=+xnack < %s | FileCheck --check-prefix=ASM %s
// RUN: llvm-mc -mattr=+code-object-v3 -triple amdgcn-amd-amdhsa -mcpu=gfx900 -mattr=+xnack -filetype=obj < %s > %t
// RUN: llvm-readobj -elf-output-style=GNU -sections -symbols -relocations %t | FileCheck --check-prefix=READOBJ %s
// RUN: llvm-objdump -s -j .rodata %t | FileCheck --check-prefix=OBJDUMP %s

// READOBJ: Section Headers
// READOBJ: .text   PROGBITS {{[0-9a-f]+}} {{[0-9a-f]+}} {{[0-9a-f]+}} {{[0-9]+}} AX {{[0-9]+}} {{[0-9]+}} 256
// READOBJ: .rodata PROGBITS {{[0-9a-f]+}} {{[0-9a-f]+}}        0000c0 {{[0-9]+}}  A {{[0-9]+}} {{[0-9]+}} 64

// READOBJ: Relocation section '.rela.rodata' at offset
// READOBJ: 0000000000000010 {{[0-9a-f]+}}00000005 R_AMDGPU_REL64 0000000000000000 .text + 10
// READOBJ: 0000000000000050 {{[0-9a-f]+}}00000005 R_AMDGPU_REL64 0000000000000000 .text + 110
// READOBJ: 0000000000000090 {{[0-9a-f]+}}00000005 R_AMDGPU_REL64 0000000000000000 .text + 210

// READOBJ: Symbol table '.symtab' contains {{[0-9]+}} entries:
// READOBJ: {{[0-9]+}}: 0000000000000100  0 FUNC    LOCAL  DEFAULT 2 complete
// READOBJ: {{[0-9]+}}: 0000000000000000  0 FUNC    LOCAL  DEFAULT 2 minimal
// READOBJ: {{[0-9]+}}: 0000000000000200  0 FUNC    LOCAL  DEFAULT 2 special_sgpr
// READOBJ: {{[0-9]+}}: 0000000000000040 64 OBJECT  GLOBAL DEFAULT 3 complete.kd
// READOBJ: {{[0-9]+}}: 0000000000000000 64 OBJECT  GLOBAL DEFAULT 3 minimal.kd
// READOBJ: {{[0-9]+}}: 0000000000000080 64 OBJECT  GLOBAL DEFAULT 3 special_sgpr.kd

// OBJDUMP: Contents of section .rodata
// Note, relocation for KERNEL_CODE_ENTRY_BYTE_OFFSET is not resolved here.
// minimal
// OBJDUMP-NEXT: 0000 00000000 00000000 00000000 00000000
// OBJDUMP-NEXT: 0010 00000000 00000000 00000000 00000000
// OBJDUMP-NEXT: 0020 00000000 00000000 00000000 00000000
// OBJDUMP-NEXT: 0030 0000ac00 80000000 00000000 00000000
// complete
// OBJDUMP-NEXT: 0040 01000000 01000000 00000000 00000000
// OBJDUMP-NEXT: 0050 00000000 00000000 00000000 00000000
// OBJDUMP-NEXT: 0060 00000000 00000000 00000000 00000000
// OBJDUMP-NEXT: 0070 c2500104 0f0f007f 7f000000 00000000
// special_sgpr
// OBJDUMP-NEXT: 0080 00000000 00000000 00000000 00000000
// OBJDUMP-NEXT: 0090 00000000 00000000 00000000 00000000
// OBJDUMP-NEXT: 00a0 00000000 00000000 00000000 00000000
// OBJDUMP-NEXT: 00b0 00010000 80000000 00000000 00000000

.text
// ASM: .text

.amdgcn_target "amdgcn-amd-amdhsa--gfx900+xnack"
// ASM: .amdgcn_target "amdgcn-amd-amdhsa--gfx900+xnack"

.p2align 8
.type minimal,@function
minimal:
  s_endpgm

.p2align 8
.type complete,@function
complete:
  s_endpgm

.p2align 8
.type special_sgpr,@function
special_sgpr:
  s_endpgm

.rodata
// ASM: .rodata

// Test that only specifying required directives is allowed, and that defaulted
// values are omitted.
.p2align 6
.amdhsa_kernel minimal
  .amdhsa_next_free_vgpr 0
  .amdhsa_next_free_sgpr 0
.end_amdhsa_kernel

// ASM: .amdhsa_kernel minimal
// ASM-NEXT: .amdhsa_next_free_vgpr 0
// ASM-NEXT: .amdhsa_next_free_sgpr 0
// ASM-NEXT: .end_amdhsa_kernel

// Test that we can specify all available directives with non-default values.
.p2align 6
.amdhsa_kernel complete
  .amdhsa_group_segment_fixed_size 1
  .amdhsa_private_segment_fixed_size 1
  .amdhsa_user_sgpr_private_segment_buffer 1
  .amdhsa_user_sgpr_dispatch_ptr 1
  .amdhsa_user_sgpr_queue_ptr 1
  .amdhsa_user_sgpr_kernarg_segment_ptr 1
  .amdhsa_user_sgpr_dispatch_id 1
  .amdhsa_user_sgpr_flat_scratch_init 1
  .amdhsa_user_sgpr_private_segment_size 1
  .amdhsa_system_sgpr_private_segment_wavefront_offset 1
  .amdhsa_system_sgpr_workgroup_id_x 0
  .amdhsa_system_sgpr_workgroup_id_y 1
  .amdhsa_system_sgpr_workgroup_id_z 1
  .amdhsa_system_sgpr_workgroup_info 1
  .amdhsa_system_vgpr_workitem_id 1
  .amdhsa_next_free_vgpr 9
  .amdhsa_next_free_sgpr 27
  .amdhsa_reserve_vcc 0
  .amdhsa_reserve_flat_scratch 0
  .amdhsa_reserve_xnack_mask 0
  .amdhsa_float_round_mode_32 1
  .amdhsa_float_round_mode_16_64 1
  .amdhsa_float_denorm_mode_32 1
  .amdhsa_float_denorm_mode_16_64 0
  .amdhsa_dx10_clamp 0
  .amdhsa_ieee_mode 0
  .amdhsa_fp16_overflow 1
  .amdhsa_exception_fp_ieee_invalid_op 1
  .amdhsa_exception_fp_denorm_src 1
  .amdhsa_exception_fp_ieee_div_zero 1
  .amdhsa_exception_fp_ieee_overflow 1
  .amdhsa_exception_fp_ieee_underflow 1
  .amdhsa_exception_fp_ieee_inexact 1
  .amdhsa_exception_int_div_zero 1
.end_amdhsa_kernel

// ASM: .amdhsa_kernel complete
// ASM-NEXT: .amdhsa_group_segment_fixed_size 1
// ASM-NEXT: .amdhsa_private_segment_fixed_size 1
// ASM-NEXT: .amdhsa_user_sgpr_private_segment_buffer 1
// ASM-NEXT: .amdhsa_user_sgpr_dispatch_ptr 1
// ASM-NEXT: .amdhsa_user_sgpr_queue_ptr 1
// ASM-NEXT: .amdhsa_user_sgpr_kernarg_segment_ptr 1
// ASM-NEXT: .amdhsa_user_sgpr_dispatch_id 1
// ASM-NEXT: .amdhsa_user_sgpr_flat_scratch_init 1
// ASM-NEXT: .amdhsa_user_sgpr_private_segment_size 1
// ASM-NEXT: .amdhsa_system_sgpr_private_segment_wavefront_offset 1
// ASM-NEXT: .amdhsa_system_sgpr_workgroup_id_x 0
// ASM-NEXT: .amdhsa_system_sgpr_workgroup_id_y 1
// ASM-NEXT: .amdhsa_system_sgpr_workgroup_id_z 1
// ASM-NEXT: .amdhsa_system_sgpr_workgroup_info 1
// ASM-NEXT: .amdhsa_system_vgpr_workitem_id 1
// ASM-NEXT: .amdhsa_next_free_vgpr 9
// ASM-NEXT: .amdhsa_next_free_sgpr 27
// ASM-NEXT: .amdhsa_reserve_vcc 0
// ASM-NEXT: .amdhsa_reserve_flat_scratch 0
// ASM-NEXT: .amdhsa_reserve_xnack_mask 0
// ASM-NEXT: .amdhsa_float_round_mode_32 1
// ASM-NEXT: .amdhsa_float_round_mode_16_64 1
// ASM-NEXT: .amdhsa_float_denorm_mode_32 1
// ASM-NEXT: .amdhsa_float_denorm_mode_16_64 0
// ASM-NEXT: .amdhsa_dx10_clamp 0
// ASM-NEXT: .amdhsa_ieee_mode 0
// ASM-NEXT: .amdhsa_fp16_overflow 1
// ASM-NEXT: .amdhsa_exception_fp_ieee_invalid_op 1
// ASM-NEXT: .amdhsa_exception_fp_denorm_src 1
// ASM-NEXT: .amdhsa_exception_fp_ieee_div_zero 1
// ASM-NEXT: .amdhsa_exception_fp_ieee_overflow 1
// ASM-NEXT: .amdhsa_exception_fp_ieee_underflow 1
// ASM-NEXT: .amdhsa_exception_fp_ieee_inexact 1
// ASM-NEXT: .amdhsa_exception_int_div_zero 1
// ASM-NEXT: .end_amdhsa_kernel

// Test that we are including special SGPR usage in the granulated count.
.p2align 6
.amdhsa_kernel special_sgpr
  // Same next_free_sgpr as "complete", but...
  .amdhsa_next_free_sgpr 27
  // ...on GFX9 this should require an additional 6 SGPRs, pushing us from
  // 3 granules to 4
  .amdhsa_reserve_flat_scratch 1

  .amdhsa_reserve_vcc 0
  .amdhsa_reserve_xnack_mask 0

  .amdhsa_float_denorm_mode_16_64 0
  .amdhsa_dx10_clamp 0
  .amdhsa_ieee_mode 0
  .amdhsa_next_free_vgpr 0
.end_amdhsa_kernel

// ASM: .amdhsa_kernel special_sgpr
// ASM-NEXT: .amdhsa_next_free_vgpr 0
// ASM-NEXT: .amdhsa_next_free_sgpr 27
// ASM-NEXT: .amdhsa_reserve_vcc 0
// ASM-NEXT: .amdhsa_reserve_xnack_mask 0
// ASM-NEXT: .amdhsa_float_denorm_mode_16_64 0
// ASM-NEXT: .amdhsa_dx10_clamp 0
// ASM-NEXT: .amdhsa_ieee_mode 0
// ASM-NEXT: .end_amdhsa_kernel

.section .foo

.byte .amdgcn.gfx_generation_number
// ASM: .byte 9

.byte .amdgcn.next_free_vgpr
// ASM: .byte 0
.byte .amdgcn.next_free_sgpr
// ASM: .byte 0

v_mov_b32_e32 v7, s10

.byte .amdgcn.next_free_vgpr
// ASM: .byte 8
.byte .amdgcn.next_free_sgpr
// ASM: .byte 11

.set .amdgcn.next_free_vgpr, 0
.set .amdgcn.next_free_sgpr, 0

.byte .amdgcn.next_free_vgpr
// ASM: .byte 0
.byte .amdgcn.next_free_sgpr
// ASM: .byte 0

v_mov_b32_e32 v16, s3

.byte .amdgcn.next_free_vgpr
// ASM: .byte 17
.byte .amdgcn.next_free_sgpr
// ASM: .byte 4

; Check to make sure that Value Numbering doesn't merge casts of different
; flavors.
; RUN: llvm-as < %s | opt -load-vn -gcse | llvm-dis | grep '[sz]ext' | wc -l | grep 2

declare void %external(int)

int %test_casts(short %x) {
  %a = sext short %x to int
  %b = zext short %x to int
  call void %external(int %a)
  ret int %b
}

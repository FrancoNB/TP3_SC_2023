/*Macros definition*/

.macro PUSH_ADX
    push %ax
    push %bx
    push %cx
    push %dx
.endm

.macro POP_DAX
    pop %dx
    pop %cx
    pop %bx
    pop %ax
.endm

.macro PUSH_EADX
    push %eax
    push %ebx
    push %ecx
    push %edx
.endm

.macro POP_EDAX
    pop %edx
    pop %ecx
    pop %ebx
    pop %eax
.endm

.macro CURSOR_POSITION x=$0, y=$0
    PUSH_ADX
    mov $0x02, %ah
    mov $0x00, %bh
    mov \x, %dh
    mov \y, %dl
    int $0x10
    POP_DAX
.endm

/*BEGIN*/
    .code16
    cli
    ljmp $0, $1f
    1:
    xor %ax, %ax
    mov %ax, %ds
    mov %ax, %es
    mov %ax, %fs
    mov %ax, %gs
    mov %ax, %bp
    mov %ax, %ss
    mov %bp, %sp
    mov %dl, initial_dl
    jmp after_locals
    initial_dl: .byte 0
after_locals:

    PUSH_ADX
    mov $0x0600, %ax
    mov $0x7, %bh
    mov $0x0, %cx
    mov $0x184f, %dx
    int $0x10
    CURSOR_POSITION
    POP_DAX

    .equ CODE_SEG, 8
    .equ DATA_SEG, gdt_data - gdt_start

    lgdt gdt_descriptor

    mov %cr0, %eax
    orl $0x1, %eax
    mov %eax, %cr0

    ljmp $CODE_SEG, $protected_mode

    gdt_start:
    gdt_null:
        .long 0x0
        .long 0x0
    gdt_code:
        .word 0xffff
        .word 0x0
        .byte 0x0
        .byte 0b10011010
        .byte 0b11001111
        .byte 0x0
    gdt_data:
        .word 0xffff
        .word 0x0
        .byte 0x0
        .byte 0b10010000
        .byte 0b11001111
        .byte 0x0
    gdt_end:
    gdt_descriptor:
        .word gdt_end - gdt_start
        .long gdt_start
    vga_current_line:
        .long 0
    .code32
    protected_mode:
        mov $DATA_SEG, %ax
        mov %ax, %ds
        mov %ax, %es
        mov %ax, %fs
        mov %ax, %gs
        mov %ax, %ss
        mov $0X7000, %ebp
        mov %ebp, %esp

    PUSH_EADX
    mov $message, %ecx
    mov vga_current_line, %eax
    mov $0, %edx
    mov $25, %ebx
    div %ebx
    mov %edx, %eax
    mov $160, %edx
    mul %edx
    lea 0xb8000(%eax), %edx
    mov $0x0f, %ah
loop:
    mov (%ecx), %al
    cmp $0, %al
    je end
    mov %ax, (%edx)
    add $1, %ecx
    add $2, %edx
    jmp loop
end:
    incl vga_current_line
    POP_EDAX

    jmp .
message:
    .asciz "hello world"

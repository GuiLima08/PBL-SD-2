
.text
.extern send_instruction
@///////////////////////////////////////////////////////////////////
@/////////////////////////BLOCK AVERAGING///////////////////////////
@///////////////////////////////////////////////////////////////////
.global block_averaging
.type block_averaging, %function

block_averaging:
    push {lr}
    and r0, r0, #0xF    @ fator vem em r0
    mov r3, #0b000          @ opcode 000

    lsl r3, r3, #23         @ opcode em 25:23
    lsl r0, r0, #19         @ factor em 22:19
    orr r1, r0, r3          @ opcode + factor 

    mov r0, r9              @ lw_virtual

    bl send_instruction     @ base em r0, instrucao montada em r1
    pop {lr}
    bx lr

@///////////////////////////////////////////////////////////////////
@/////////////////////////NN_ZOOM_IN////////////////////////////////
@///////////////////////////////////////////////////////////////////
.global nn_zoom_in
.type nn_zoom_in, %function

nn_zoom_in:
    push {lr}
    and r0, r0, #0xF        @ fator vem em r0
    mov r3, #0b001          @ opcode 001

    lsl r3, r3, #23         @ opcode em 25:23
    lsl r0, r0, #19         @ factor em 22:19
    orr r1, r0, r3          @ opcode + factor 

    mov r0, r9              @ lw_virtual

    bl send_instruction     @ base em r0, instrucao montada em r1
    pop {lr}
    bx lr

@///////////////////////////////////////////////////////////////////
@////////////////////////NN_ZOOM_OUT////////////////////////////////
@///////////////////////////////////////////////////////////////////
.global nn_zoom_out
.type nn_zoom_out, %function

nn_zoom_out:
    push {lr}
    and r0, r0, #0xF        @ fator vem em r0
    mov r3, #0b010          @ opcode 010

    lsl r3, r3, #23         @ opcode em 25:23
    lsl r0, r0, #19         @ factor em 22:19
    orr r1, r0, r3          @ opcode + factor 

    mov r0, r9              @ lw_virtual

    bl send_instruction     @ base em r0, instrucao montada em r1
    pop {lr}
    bx lr

@///////////////////////////////////////////////////////////////////
@/////////////////////////PIXEL REP/////////////////////////////////
@///////////////////////////////////////////////////////////////////
.global pixel_rep
.type pixel_rep, %function

pixel_rep:
    push {lr}
    and r0, r0, #0xF        @ fator vem em r0
    mov r3, #0b011          @ opcode 011

    lsl r3, r3, #23         @ opcode em 25:23
    lsl r0, r0, #19         @ factor em 22:19
    orr r1, r0, r3          @ opcode + factor 

    mov r0, r9              @ lw_virtual

    bl send_instruction     @ base em r0, instrucao montada em r1
    pop {lr}
    bx lr

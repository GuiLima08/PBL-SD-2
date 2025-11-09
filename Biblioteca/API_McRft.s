.section .text

@///////////////////////////////////////////////////////////////////
@/////////////////////////ORIGINAL//////////////////////////////////
@///////////////////////////////////////////////////////////////////
.global original
.type original, %function

@ Mostra a imagem sem quaisquer algoritmos de ampliação
original:
    push {lr}                       @ Salva o registrador de link (lr) para retornar depois
    mov r0, #1                      @ Fator = 1x (zoom padrão)
    mov r3, #0b100                  @ Operação 100 (original)

    lsl r3, r3, #23                 @ Opcode em 25:23
    lsl r0, r0, #19                 @ Fator em 22:19
    orr r1, r0, r3                  @ Combina opcode + fator para formar a instrução

    ldr r0, =LW_virtual             @ Carrega o endereço reservado do LW_virtual
    ldr r0, [r0]                    @ Carrega o valor real de LW_virtual (ponteiro base)

    bl send_instruction             @ Chama função para enviar a instrução montada
    
    mov r0, #0                      @ Retorna 0 (flags da original = 0b0000000)
    
    pop {lr}                      
    bx lr                           
.size original, .-original


@///////////////////////////////////////////////////////////////////
@/////////////////////////BLOCK AVERAGING///////////////////////////
@///////////////////////////////////////////////////////////////////
.global block_averaging
.type block_averaging, %function

@ Algoritmo de média de blocos
block_averaging:
    push {lr}                       @ Salva o registrador de link
    and r0, r0, #0xF                @ Fator vem em r0 (mantém só 4 bits)
    mov r3, #0b000                  @ Operação 000 (block averaging)

    push {r0}                       @ Salva o fator para formar flags depois

    lsl r3, r3, #23                 @ Opcode em 25:23
    lsl r0, r0, #19                 @ Fator em 22:19
    orr r1, r0, r3                  @ Monta a instrução (opcode + fator)

    ldr r0, =LW_virtual             @ Carrega o endereço do LW_virtual
    ldr r0, [r0]                    @ Carrega valor real (base)

    bl send_instruction             @ Envia instrução ao barramento

    pop {r0}                        @ Recupera o fator original
    orr r0, r0, #0b0110000          @ Define flags de retorno

    pop {lr}                        @ Restaura lr
    bx lr                           
.size block_averaging, .-block_averaging


@///////////////////////////////////////////////////////////////////
@/////////////////////////NN_ZOOM_IN////////////////////////////////
@///////////////////////////////////////////////////////////////////
.global nn_zoom_in
.type nn_zoom_in, %function

@ Algoritmo de vizinho mais próximo (zoom in)
nn_zoom_in:
    push {lr}                       
    and r0, r0, #0xF                @ Garante que o fator tem 4 bits
    mov r3, #0b001                  @ Operação 001 (zoom in)

    push {r0}                       @ Salva o fator

    lsl r3, r3, #23                 @ Opcode em 25:23
    lsl r0, r0, #19                 @ Fator em 22:19
    orr r1, r0, r3                  @ Monta instrução (opcode + fator)

    ldr r0, =LW_virtual             @ Carrega endereço base
    ldr r0, [r0]                    @ Obtém valor real da base

    bl send_instruction             @ Envia a instrução
    
    pop {r0}                        @ Recupera fator original
    orr r0, r0, #0b0010000          @ Define flags de retorno
    
    pop {lr}                        
    bx lr                           
.size nn_zoom_in, .-nn_zoom_in


@///////////////////////////////////////////////////////////////////
@////////////////////////NN_ZOOM_OUT////////////////////////////////
@///////////////////////////////////////////////////////////////////
.global nn_zoom_out
.type nn_zoom_out, %function

@ Algoritmo de decimação (zoom out)
nn_zoom_out:
    push {lr}                       
    and r0, r0, #0xF                @ Fator de 4 bits
    mov r3, #0b010                  @ Operação 010 (zoom out)

    push {r0}                       @ Salva o fator

    lsl r3, r3, #23                 @ Opcode em 25:23
    lsl r0, r0, #19                 @ Fator em 22:19
    orr r1, r0, r3                  @ Monta instrução

    ldr r0, =LW_virtual             @ Carrega base
    ldr r0, [r0]                    @ Carrega valor real

    bl send_instruction             @ Envia instrução

    pop {r0}                        @ Recupera fator
    orr r0, r0, #0b0100000          @ Define flags

    pop {lr}                        
    bx lr                           
.size nn_zoom_out, .-nn_zoom_out


@///////////////////////////////////////////////////////////////////
@/////////////////////////PIXEL REP/////////////////////////////////
@///////////////////////////////////////////////////////////////////
.global pixel_rep
.type pixel_rep, %function

@ Algoritmo de replicação de pixel
pixel_rep:
    push {lr}                       
    and r0, r0, #0xF                @ Fator em 4 bits
    mov r3, #0b011                  @ Operação 011 (pixel replication)

    push {r0}                       @ Salva o fator

    lsl r3, r3, #23                 @ Opcode em 25:23
    lsl r0, r0, #19                 @ Fator em 22:19
    orr r1, r0, r3                  @ Monta instrução (opcode + fator)

    ldr r0, =LW_virtual             @ Carrega endereço base
    ldr r0, [r0]                    @ Obtém valor real da base

    bl send_instruction             @ Envia instrução para FPGA

    pop {r0}                        @ Recupera fator
    orr r0, r0, #0b1000000          @ Define flags de retorno

    pop {lr}                        
    bx lr                           
.size pixel_rep, .-pixel_rep


@//////////////////////////////////////////////////////////////////
@//////////////////////////OPEN MAPPING////////////////////////////
@//////////////////////////////////////////////////////////////////
.global open_mapping
.type open_mapping, %function

@ Faz o mapeamento de memória HPS-FPGA
@ Abre /dev/mem e chama mmap2()
open_mapping:
    push {r4, r5, r6, r7, lr}       @ Salva registradores callee-saved (convenção da arq.)

    ldr r0, =PATH                   @ Caminho /dev/mem
    mov r1, #2                      @ O_RDWR
    mov r2, #0                      @ flags = 0

    mov r7, #5                      @ syscall open()
    svc 0
    after_open:                     @ Label para debug

    mov r4, r0                      @ Guarda o file descriptor no espaço reservado
    ldr r1, =FD
    str r4, [r1]                    @ Armazena o fd

    @ Configuração do mmap
    mov r0, #0                      @ NULL
    ldr r1, =LW_BRIDGE_SPAN         @ Endereço do tamanho
    ldr r1, [r1]                    @ Valor do tamanho

    mov r2, #3                      @ PROT_READ | PROT_WRITE
    mov r3, #1                      @ MAP_SHARED
    ldr r5, =LW_BRIDGE_BASE         @ Endereço base
    ldr r5, [r5]                    @ Valor base

    mov r7, #192                    @ syscall mmap2()
    svc 0
    after_mmap:                     @ Label para debug
    mov r9, r0                      @ Guarda o ponteiro retornado (debug)

    ldr r1, =LW_virtual             @ Guarda o endereço retornado no espaço reservado
    str r0, [r1]

    pop {r4, r5, r6, r7, lr}        @ Restaura registradores
    bx lr                           
.size open_mapping, .-open_mapping


@//////////////////////////////////////////////////////////////////
@//////////////////////////CLOSE MAPPING///////////////////////////
@//////////////////////////////////////////////////////////////////
.global close_mapping
.type close_mapping, %function

@ Fecha o mapeamento de memória HPS-FPGA
close_mapping:
    push {r7, lr}                   @ Salva registradores

    ldr r0, =LW_virtual             @ Carrega base
    ldr r0, [r0]                    @ Valor da base
    ldr r1, =LW_BRIDGE_SPAN         @ Carrega tamanho
    ldr r1, [r1]                    @ Valor do tamanho

    mov r7, #91                     @ syscall munmap()
    svc 0

    ldr r0, =FD                     @ Carrega file descriptor
    mov r7, #6                      @ syscall close()
    svc 0

    pop {r7, lr}                    @ Restaura registradores
    bx lr                           
.size close_mapping, .-close_mapping


@//////////////////////////////////////////////////////////////////
@//////////////////////////SEND INSTRUCTION////////////////////////
@//////////////////////////////////////////////////////////////////
.global send_instruction
.type send_instruction, %function

@ Envia instruções montadas ao barramento da FPGA
send_instruction:
    @ r0 = endereço base
    @ r1 = instrução já montada

    push {r4, r5, r6, lr}           @ Salva registradores necessários

    ldr r2, =OFFSET_FLAG_FPGA       @ Offset da flag FPGA (done)
    ldr r2, [r2]
    add r2, r0, r2                  @ Endereço completo da flag done

    ldr r3, =OFFSET_FLAG_HPS        @ Offset da flag HPS (enable)
    ldr r3, [r3]
    add r3, r0, r3                  @ Endereço completo da flag enable

    ldr r4, =OFFSET_INSTR           @ Offset da instrução
    ldr r4, [r4]
    add r4, r0, r4                  @ Endereço completo da instrução

    str r1, [r4, #0]                @ Escreve instrução no barramento
    mov r6, #1                      @ Valor 1 para enable
    str r6, [r3, #0]                @ Ativa enable

wait_done:
    ldr r5, [r2, #0]                @ Lê flag done
    cmp r5, #0                      @ Verifica se done == 0
    beq wait_done                   @ Espera done ir para 1

    mov r6, #0                      @ Desativa enable
    str r6, [r3, #0]

    pop {r4, r5, r6, lr}            @ Restaura registradores
    bx lr                           
.size send_instruction, .-send_instruction


@//////////////////////////////////////////////////////////////////
@//////////////////////////////STORE///////////////////////////////
@//////////////////////////////////////////////////////////////////
.global store
.type store, %function

@ Monta e envia instrução de armazenamento (STORE)
store:
    @ r0 = Valor do pixel
    @ r1 = Endereço
    
    push {lr}                       

    ldr r3, =0x7FFF                 @ Máscara 15 bits
    and r1, r1, r3                  @ Aplica máscara ao endereço
    and r0, r0, #0xFF               @ Mantém pixel em 8 bits
    mov r2, #0b111                  @ Opcode 111 (STORE)

    lsl r2, #23                     @ Opcode em 25:23
    lsl r0, #15                     @ Dado/pixel em 22:15
    orr r1, r0, r1                  @ Junta dado + endereço
    orr r1, r1, r2                  @ Junta opcode + anterior

    ldr r0, =LW_virtual             @ Carrega endereço base
    ldr r0, [r0]                    @ Valor real

    bl send_instruction             @ Envia instrução
    pop {lr}                        
    bx lr                           
.size store, .-store


@//////////////////////////////////////////////////////////////////
@//////////////////////////////LOAD IMAGE//////////////////////////
@//////////////////////////////////////////////////////////////////
.global load_image
.type load_image, %function

@ Carrega o bitmap com imagem para memória da FPGA
load_image:
    @ r0 = Ponteiro do bitmap

    push {r4, r5, r6, lr}           @ Salva registradores

    mov r4, r0                      @ r4 = base do bitmap
    mov r5, #0                      @ Contador = 0

bitmap_loop:
    cmp r5, #19200                  @ 160x120 pixels
    beq end                         @ Se chegou ao fim, sai

    add r6, r4, r5                  @ Endereço base_bitmap + i
    ldrb r3, [r6]                   @ Lê pixel (8 bits)

    mov r0, r3                      @ Pixel em r0
    mov r1, r5                      @ Endereço em r1

    bl store                        @ Envia pixel
    add r5, r5, #1                  @ Próximo pixel
    b bitmap_loop                   @ Loop

end:
    pop {r4, r5, r6, lr}            @ Restaura registradores
    bx lr                           
.size load_image, .-load_image


.section .data
PATH: .asciz "/dev/mem"             @ Caminho do device
O_RDWR: .word 2                      @ Constante
O_SYNC: .word 1052672               @ Constante
PROT_READ: .word 1                  @ Constante
PROT_WRITE: .word 2                 @ Constante
MAP_SHARED: .word 1                 @ Constante
LW_BRIDGE_BASE: .word 0xFF200       @ Base da bridge lightweight
LW_BRIDGE_SPAN: .word 0x1000        @ Tamanho da bridge
OFFSET_FLAG_FPGA: .word 0x10        @ Offset da flag FPGA (done)
OFFSET_INSTR: .word 0x00            @ Offset da instrução
OFFSET_FLAG_HPS: .word 0x20         @ Offset da flag HPS (enable)
FD: .space 4                        @ Espaço p/ fd
LW_virtual: .space 4                @ Espaço p/ endereço virtual

#include <stdio.h>
#include <fcntl.h>
#include <sys/mman.h>    //Precisa gerar e incluir
#include <unistd.h>
#include "./hps_0.h"     //Precisa gerar e incluir

#define LW_BRIDGE_BASE 0xFF200000   //FIXO
#define LW_BRIDGE_SPAN 0x00005000   //FIXO

int main(void) {
    
    volatile int *flag_hps_PIO_ptr;    // Ponteiro para nosso pio
    volatile int *flag_fpga_PIO_ptr;    // Ponteiro para nosso pio
    volatile int *instruction_PIO_ptr;    // Ponteiro para nosso pio

    int fd = -1;               // FIXO: Usado para abrir /dev/mem
    void *LW_virtual;          // FIXO: Endereço virtual para o lightweight bridge

    //FIXO: Abre /dev/mem para dar acesso aos endereços físicos
    if ((fd = open("/dev/mem", (O_RDWR | O_SYNC))) == -1) {
        printf("ERROR: could not open \"/dev/mem\"...\n");
        return -1;
    }

    //FIXO: Faz o mapeamento de endereços físicos para virtuais
    LW_virtual = mmap(NULL, LW_BRIDGE_SPAN, (PROT_READ | PROT_WRITE),
                      MAP_SHARED, fd, LW_BRIDGE_BASE);
    if (LW_virtual == MAP_FAILED) {
        printf("ERROR: mmap() failed...\n");
        close(fd);
        return -1;
    }

    //////////////////////////////////////////////////////////
    //////////////// AREA MODIFICAVEL ////////////////////////
    //////////////////////////////////////////////////////////

    //
    unsigned int addr = 1;
    unsigned int data = 255;
    data = data << 15;
    unsigned int opcode = 1;
    opcode = opcode << 23;
    unsigned int factor = 4;
    factor = factor << 19;
    
    // 
    // opcode: 00000 00000 00000 00000 000 111; << 23
    // 

    //

    // Define o ponteiro virtual para o nosso PIO
    flag_hps_PIO_ptr = (int *)(LW_virtual + PIO_FLAG_HPS_BASE);    //PIO_BASE a defin
    *flag_hps_PIO_ptr = 0;
    usleep(1000);

    flag_fpga_PIO_ptr = (int *)(LW_virtual + PIO_FLAG_FPGA_BASE);
    
    instruction_PIO_ptr = (int *)(LW_virtual + PIO_INSTRUCTION_BASE);    //PIO_BASE a definir
    *instruction_PIO_ptr = opcode + factor;

    usleep(1000);

    *flag_hps_PIO_ptr = 1;  // Instrucao vai aqui

    
    usleep(3000);

    /*
    while (!*flag_fpga_PIO_ptr)
    {
        
    }
    
    factor = 2;
    factor = factor << 19;

    *flag_hps_PIO_ptr = 0;
    *instruction_PIO_ptr = opcode + factor;
    *flag_hps_PIO_ptr = 1;  // Instrucao vai aqui
    */



    //////////////////////////////////////////////////////////
    //////////////// AREA MODIFICAVEL ////////////////////////
    //////////////////////////////////////////////////////////

    //FIXO: Desfaz o mapeamento de memória
    if (munmap(LW_virtual, LW_BRIDGE_SPAN) != 0) {
        printf("ERROR: munmap() failed...\n");
        return -1;
    }

    //FIXO: Fecha o /dev/mem
    close(fd);

    return 0;
}


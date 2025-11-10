#include <stdio.h>
#include <stdlib.h>
#include <fcntl.h>
#include <sys/mman.h>    //Precisa gerar e incluir
#include <unistd.h>
#include "./hps_0.h"     //Precisa gerar e incluir

#define LW_BRIDGE_BASE 0xFF200000   //FIXO
#define LW_BRIDGE_SPAN 0x00005000   //FIXO

int main(void) {
    
    volatile int *flag_fpga_PIO_ptr;    // Ponteiro para nosso pio
    volatile int *flag_hps_PIO_ptr;    // Ponteiro para nosso pio
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

    const char *filename = "gatinho1_convertido.bmp"; // Nome do arquivo
    FILE *file = fopen(filename, "rb");
    
    if (file == NULL) {
        perror("Erro ao abrir o arquivo");
        return 1;
    }

    // Pula o cabeçalho e a paleta
    if (fseek(file, 1078, SEEK_SET) != 0) {
        perror("Erro ao mover o ponteiro do arquivo");
        fclose(file);
        return 1;
    }

    unsigned char *bitmap_data = (unsigned char *)malloc(19200);
    if (bitmap_data == NULL) {
        fprintf(stderr, "Erro ao alocar memória.\n");
        fclose(file);
        return 1;
    }

    size_t read = fread(bitmap_data, 1, 19200, file);
    if (read != 19200) {
        fprintf(stderr, "Erro: esperava %d bytes, mas leu %zu.\n", 19200, read);
        free(bitmap_data);
        fclose(file);
        return 1;
    }

    flag_fpga_PIO_ptr = (int *)(LW_virtual + PIO_FLAG_FPGA_BASE);    //PIO_BASE a defin
    flag_hps_PIO_ptr = (int *)(LW_virtual + PIO_FLAG_HPS_BASE);    
    instruction_PIO_ptr = (int *)(LW_virtual + PIO_INSTRUCTION_BASE);    //PIO_BASE a definir

    //////////////////////////////////////////////////////////
    //////////////// AREA MODIFICAVEL ////////////////////////
    //////////////////////////////////////////////////////////

    bitmap_data = bitmap_data - 160;
    int x, y;
    

    for(y = 0; y < 120; y++){
        for(x = 0; x < 160; x++){
            unsigned char pixel = bitmap_data[(120 - y)*160 + x];
            *instruction_PIO_ptr = build_instruction_store(pixel, x, y);
            *flag_hps_PIO_ptr = 0b1;
    
            while(!*flag_fpga_PIO_ptr){

            }

            *flag_hps_PIO_ptr = 0b0;
            
        }
    }


/*
    *flag_hps_PIO_ptr = 0;

    *instruction_PIO_ptr = 0b011;
    printf("%d\n", *instruction_PIO_ptr);
    *flag_hps_PIO_ptr = 1;
    printf("%d\n", *flag_hps_PIO_ptr);
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

    free(bitmap_data + 160);
    fclose(file);

    return 0;
}


int build_instruction_store (int data, int x, int y){

    int opcode = 0b111 << 23;
    data       = data << 15;
    int addr   = y * 160 + x;

    return opcode + data + addr;

}

#include <stdio.h>
#include <stdlib.h>

void open_mapping();
void close_mapping();
int original();
int block_averaging(int factor);
int nn_zoom_in(int factor);
int nn_zoom_out(int factor);
int pixel_rep(int factor);
void load_image(unsigned char* bitmap);
void store(int data);

void invert_bitmap(unsigned char* bitmap) {
    // Tamanho da imagem: 120 linhas e 160 colunas
    int num_lines = 120;
    int num_cols = 160;
    int line_size = num_cols; // Cada linha tem 160 pixels

    unsigned char temp[line_size]; // Buffer para troca de linhas

    // Troca as linhas de cima para baixo
    for (int y = 0; y < num_lines / 2; y++) {
        int opposite_y = num_lines - 1 - y;

        // Copia a linha de cima para o buffer
        for (int x = 0; x < num_cols; x++) {
            temp[x] = bitmap[y * line_size + x];
        }

        // Copia a linha de baixo para a linha de cima
        for (int x = 0; x < num_cols; x++) {
            bitmap[y * line_size + x] = bitmap[opposite_y * line_size + x];
        }

        // Copia a linha do buffer para a linha de baixo
        for (int x = 0; x < num_cols; x++) {
            bitmap[opposite_y * line_size + x] = temp[x];
        }
    }
}

int get_valid_int() {
    int num;
    int result;

    // Keep asking for input until a valid integer is entered
    while (1) {
        printf("Digite sua escolha: ");
        result = scanf("%d", &num);

        if (result == 1) {
            // Valid input
            return num;
        } else {
            // Invalid input
            while (getchar() != '\n'); // Clear the input buffer
            printf("Entrada inválida, digite um número.\n");
        }
    }

    // Return -1 if we exit the loop (although we won't reach here due to the loop condition)
    return -1;
}

void print_status(int last_alg){

    int fac = last_alg & 0b0001111;
    int alg = (last_alg & 0b1110000) >> 4;
    printf("Estado: ");
    switch(alg){
        case 0:
        printf("Imagem original\n");
        return;
        break;

        case 1:
        printf("Zoom in (vizinho mais pŕoximo ");
        break;

        case 2:
        printf("Zoom out (vizinho mais pŕoximo ");
        break;

        case 3:
        printf("Zoom out (média de blocos ");
        break;

        case 4:
        printf("Zoom in (replicação de pixel ");
        break;
    }
    printf("%dx)\n", fac);
}

int handle_nn_in(int last_alg){
    int opcao;
    do {
        printf("\n=== NEAREST NEIGHBOR ZOOM IN ===\n");
        print_status(last_alg);
        printf("0 - Voltar\n");
        printf("Digite um fator entre 2 e 4.\n");
        opcao = get_valid_int();
        
        if(opcao == 0){
            printf("Voltando...\n");
            return last_alg;
        }else
        if(opcao >= 2 && opcao <= 4){
            last_alg = nn_zoom_in(opcao);
            printf("Zoom in de %dx aplicado!\n", opcao);
        }else{
            printf("Opção invalida!\n");
        }
        
    } while (opcao != 0);

    return last_alg;
}

int handle_nn_out(int last_alg){
    int opcao;
    do {
        printf("\n=== NEAREST NEIGHBOR ZOOM OUT ===\n");
        print_status(last_alg);
        printf("0 - Voltar\n");
        printf("Digite um fator entre 2 e 15.\n");
        opcao = get_valid_int();
        
        if(opcao == 0){
            printf("Voltando...\n");
            return last_alg;
        }else
        if(opcao >= 2 && opcao <= 15){
            last_alg = nn_zoom_out(opcao);
            printf("Zoom out de %dx aplicado!\n", opcao);
        }else{
            printf("Opção invalida!\n");
        }
        
    } while (opcao != 0);

    return last_alg;
}

int handle_block_avg(int last_alg){
    int opcao;
    do {
        printf("\n=== MÉDIA DE BLOCOS ===\n");
        print_status(last_alg);
        printf("0 - Voltar\n");
        printf("Digite um fator entre 2 e 15.\n");
        opcao = get_valid_int();

        if(opcao == 0){
            printf("Voltando...\n");
            return last_alg;
        }else
        if(opcao >= 2 && opcao <= 15){
            last_alg = block_averaging(opcao);
            printf("Zoom out de %dx aplicado!\n", opcao);
        }else{
            printf("Opção invalida!\n");
        }
    } while (opcao != 0);

    return last_alg;
}

int handle_pixel_rep(int last_alg){
    int opcao;
    do {
        printf("\n=== REPLICAÇÃO DE PIXEL ===\n");
        print_status(last_alg);
        printf("0 - Voltar\n");
        printf("Digite um fator entre 2 e 4.\n");
        opcao = get_valid_int();

        if(opcao == 0){
            printf("Voltando...\n");
            return last_alg;
        }else
        if(opcao >= 2 && opcao <= 4){
            last_alg = pixel_rep(opcao);
            printf("Zoom in de %dx aplicado!\n", opcao);
        }else{
            printf("Opção invalida!\n");
        }
    } while (opcao != 0);

    return last_alg;
}

int main() {

    const char *filename = "gatinho1_convertido.bmp"; // Nome do arquivo
    FILE *file = fopen(filename, "rb");

    if (file == NULL) {
        perror("Erro ao abrir o arquivo\n");
        return 1;
    }

    // Pula o cabeçalho e a paleta
    if (fseek(file, 1078, SEEK_SET) != 0) {
        perror("Erro ao mover o ponteiro do arquivo\n");
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

    invert_bitmap(bitmap_data);
    int opcao;
    int last_alg = 0;
    int image = 0;
    open_mapping();
    
    do{
        printf("\n=== MENU DE ZOOM ===\n");
        if(image) print_status(last_alg);
        else printf("Estado: Imagem não carregada!\n");
        printf("1 - Carregar imagem\n");
        if(image){
            printf("2 - Mostrar Imagem Original\n");
            printf("3 - Vizinho Mais Próximo (Zoom In)\n");
            printf("4 - Vizinho Mais Próximo (Zoom Out)\n");
            printf("5 - Média de Blocos\n");
            printf("6 - Replicação de Pixel\n");
        }
        printf("0 - Sair\n");
        opcao = get_valid_int();

        switch (opcao){
            case 1:
                load_image(bitmap_data);
                image = 1;
                last_alg = original();
                printf("Imagem carregada!\n");
            break;

            case 2:
                if(image) last_alg = original();
                
                else printf("Imagem não carregada!\n");
            break;
            
            case 3:
                if(image) last_alg = handle_nn_in(last_alg);
                else printf("Imagem não carregada!\n");
            break;

            case 4:
                if(image) last_alg = handle_nn_out(last_alg);
                else printf("Imagem não carregada!\n");
            break;

            case 5:
                if(image) last_alg = handle_block_avg(last_alg);
                else printf("Imagem não carregada!\n");
            break;

            case 6:
                if(image) last_alg = handle_pixel_rep(last_alg);
                else printf("Imagem não carregada!\n");
            break;

            case 0:
                printf("Saindo...\n");
            break;

            default:
                printf("Opção invalida!\n");
            break;
        }
    }while(opcao != 0);

    close_mapping();
    free(bitmap_data);
    return 0;
}
# PBL-SD-2
Projeto PBL do grupo: Guilherme de Oliveira Lima, Davi Medeiros Rocha e Nycolas de Lima Oliveira Silva


# Adição de PIOs

<ul>
  <li> <b> Foram adicionados 3 PIOs (Parallel Input/Output) no Platform Designer: </b>
       <ul>
         <li> Instrução: 26 bits (3 bits opcode, 8 bits pixel e 15 bits endereço ou 3 bits opcode, 4 bits fator e 9 bits vazios) </li>
         <li> Flag Enable do HPS (1 bit, informa o FPGA quando o HPS enviou a instrução propriamente) </li>
         <li> Flag Done do FPGA (1 bit, informa o HPS para enviar a próxima instrução) </li>
       </ul>
  </li>
  <p></p>
  <p> Foram utilizados PIOs diferentes para cada item, com o objetivo de simplificar o fluxo de dados e evitar multiplexadores e decodificadores redundantes </p>
</ul>


# Protocolo de Comunicação

![diagrama_pio](https://github.com/user-attachments/assets/94b80923-8698-45d9-89ec-341d49eb459b)

O HPS aguarda o sinal de Done do FPGA, para então montar e enviar através do PIO a instrução e a flag Enable. O FPGA, ao receber o sinal Enable, decodifica a instrução e realiza o procedimento especificado, para então enviar através do PIO o sinal de Done para o HPS.

Esse fluxo de informações através do PIO prevém que o FPGA decodifique a mesma instrução mais de uma vez, e impede que o HPS envie uma nova instrução até que o procedimento (execução de algoritmo ou carregamento de pixel) seja concluído.


# ISA

<ul>
  <li> <b> As instruções utilizadas podem ser separadas em dois grupos: </b>
       <ul>
         <li> Tipo G: Instruções de aplicação de algoritmo (3 bits opcode, 4 bits fator de zoom e 9 bits vazios) </li>
         <li> Tipo S: Instrução "store", que envia um pixel para ser escrito em um endereço (3 bits opcode, 8 bits pixel e 15 bits endereço) </li>
       </ul>
  </li>
</ul>

<img width="913" height="173" alt="Captura de tela 2025-11-09 185515" src="https://github.com/user-attachments/assets/f1058a8d-8752-4446-aa44-27026c268038" />

Estrutura de instrução do tipo G.

<img width="917" height="171" alt="Captura de tela 2025-11-09 185528" src="https://github.com/user-attachments/assets/9ca8ba15-b3ec-4e64-8554-d8733f16853a" />

Estrutura de instrução do tipo S.

# API Assembly
A biblioteca foi implementada usando a arquitetura ARMv7. Ela possui as seguintes funções:

<ul>
  <li> <b> Abrir e fechar o mapeamento de memória </b> </li>
  <p> O programador deve mapear a memória antes de usar quaisquer outras funções da biblioteca. De modo similar, ele é responsável por fechar o mapeamento após finalizar a execução do programa. </p>
  <li> <b> Algoritmos de redimensionamento de imagem </b>
       <ul>
         <li> Interpolação (Vizinho Mais Próximo Zoom In) </li>
         <li> Replicação de Pixel </li>
         <li> Decimação (Vizinho Mais Próximo Zoom Out) </li>
         <li> Média de Blocos </li>
         <li> Original </li>
       </ul>
  </li>

  <p> Essas funções, com exceção da original, tem como parâmetro o fator de ampliação/redução (2x a 4x/2x a 15x). Elas retornam um inteiro de 7 bits que é desempacotado em duas flags, de 3 e 4 bits. Elas são: 
  
  <ul>
    <li> Último algoritmo : bits 6 a 4</li>
    <li> Último fator : bits 3 a 0
  </ul>

  Eles são usados para informar ao usuário qual foi o último algoritmo de redimensionamento aplicado e seu fator.
  </p>
  
  <li> <b> Escrita na memória (STORE) </b> </li>
  <li> <b> Carregar bitmap na memória </b> </li>
  <p> Esta função utiliza uma série de instruções de STORE, mais especificamente 19200 (tamanho do bitmap). Ela recebe como argumento o ponteiro do bitmap, que deve ser carregado em C. </p>
</ul>

# PBL-SD-2
Projeto PBL do grupo: Guilherme de Oliveira Lima, Davi Medeiros Rocha e Nycolas de Lima Oliveira Silva


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

# STM32 Project Template

Template para projetos usando microcontroladores da ST e o STM32CubeMX.
Consiste numa estrutura especifica de pastas, um Makefile e
alguns arquivos de configuração.

## Requisitos

* [STM32CubeMX](https://www.st.com/en/development-tools/stm32cubemx.html)
  > É necessário colocar o local de instalação na varíavel de ambiente `CUBE_PATH`

* make
  > Linux: `sudo apt install make`
  >
  > Windows: `msys2> pacman -S make`

* CMake
  > Linux: `sudo apt install cmake`
  >
  > Windows: Baixe o zip ou o instalador no [Installing CMake](https://cmake.org/download/)
  >
  > É necessário que a pasta `bin` dessa instalação esteja no `PATH`.
  > No instalador do Windows, isso é feito automaticamente

* [GNU Arm Embedded Toolchain](https://developer.arm.com/open-source/gnu-toolchain/gnu-rm/downloads)
  > É necessário que a pasta `bin` dessa instalação esteja no `PATH`

* uncrustify
  > Linux: `sudo apt install uncrustify`
  >
  > Windows: Baixe o .zip no [SourceForge](https://sourceforge.net/projects/uncrustify/files/). Adicione o local do executável na variável de ambiente `PATH`.

* [Visual Studio Code](https://code.visualstudio.com/)
  * [EditorConfig](https://marketplace.visualstudio.com/items?itemName=EditorConfig.EditorConfig)
  * [C/C++](https://marketplace.visualstudio.com/items?itemName=ms-vscode.cpptools)
  * [Cortex-Debug](https://marketplace.visualstudio.com/items?itemName=marus25.cortex-debug)

* [STM32 Cube Programmer](https://www.st.com/en/development-tools/stm32cubeprog.html) ou [J-Link](https://www.segger.com/downloads/jlink/)
  > É necessário que o executável também esteja no `PATH`

## Preparando

### Projeto

Primeiro é necessário criar um projeto do Cube na pasta `cube/` com o nome desejado,
que deve ter as seguintes opções de projeto:

Project:

* Application Structure: *Basic*
* [x] Do not generate the main()
* Toolchain / IDE: *Makefile*

Code Generator:

* STM32Cube Firmware Library Package: *Copy all used libraries into the project folder*
* Generated files:
  * *Generate peripheral initialization as a pair of .c/.h files per peripheral*
  * *Delete previously generated files when not re-generated*

Um arquivo de exemplo se encontra em `cube/stm32_project_template.ioc` com todas as configurações necessárias.

Para projetos existentes, basta mover o arquivo `.ioc` para a pasta `cube/`.

### Compilação

O arquivo `CMakeLists.txt` deve ser editado de acordo com o projeto.

Para isso é necessário mudar o nome do projeto, o qual deve ter o mesmo do arquivo do Cube (por exemplo, `stm32_project_template.ioc`), porém sem a extensão `.ioc`.

```c
# Cube file name without .ioc extension
project(stm32_project_template C CXX ASM)
```

> Os argumentos `C` e `ASM` estão relacionados ao tipo de linguagem que o projeto utiliza (C e Assembly).

Também é necessário alterar as seguintes configurações:

```c
# Device Configuration
set(DEVICE_CORTEX F3)
set(DEVICE_FAMILY STM32F3xx)
set(DEVICE_TYPE STM32F303xx)
set(DEVICE_DEF STM32F303xE)
set(DEVICE STM32F303RE)
```

Basta pegar o nome completo do microcontrolador e colocar nessas configurações, seguindo o padrão, fazendo as substituições que forem precisas por x.

> Em caso de dúvida, veja o nome do arquivo .ld gerado na pasta cube, ele contém o nome completo do microcontrolador.

## Gerando arquivos

Com as configurações realizadas corretamente, você deve se direcionar para a pasta `build`. Estando lá, basta rodar o seguinte comando:

```bash
cmake ..
```

Esse comando é de extrema importância, pois nenhum dos outros comandos de compilação funcionarão sem ele ter sido rodado antes.

> Todos os comandos que envolvam `make` devem ser rodados dentro da pasta `build`, após o comando `cmake ..` ter sido feito.

Basicamente, ele configura o ambiente do CMake e gera os arquivos do cube, caso a pasta `cube` esteja vazia. Todavia, caso você queira apenas gerar os arquivos do cube, também é possível rodar o comando

```bash
make cube
```

## Compilando

Para compilar os arquivos, após ter rodado `cmake ..`, ainda dentro da pasta `build`, rode:

```bash
make
```

O comando `make` apenas compilará o código principal, não compilando nenhum teste. Para compilar um teste, cujo arquivo se chama **nome_do_teste.c**, rode:

```bash
make nome_do_teste
```

## Limpando Arquivos compilados

Se acontecer algum erro, pode ser necessário limpar os arquivos já compilados. Para isso, dentro da pasta `build`,  faça:

```bash
make clean
```

Isso apaga todos os arquivos de compilação gerados, exceto aqueles que vêm das bibliotecas da ST geradas pelo Cube. Isso é feito para agilizar um novo build, já que raramente será necessário recompilar esses arquivos. Todavia, caso seja necessário, é possível limpá-los com o comando:

```bash
make clean_cube
```

Além disso, caso seja necessário limpar todos os arquivos de compilação, você pode rodar o comando:

```bash
make clean_all
```

## Recompilando

Caso você queira apagar os arquivos compilados e recompilá-los, é possível fazer isso com um comando só, rodando, dentro da pasta `build`, o comando:

```bash
make rebuild
```

E, caso você queira apagar e recompilar todos os arquivos compilados, incluindo os do cube, rode o comando:

```bash
make rebuild_all
```

## Gravando

Para gravar os arquivos na placa, rode

```bash
make flash
```

Ou, caso use um gravador com J-Link:

```bash
make jflash
```

Além disso, para gravar um teste, cujo nome do arquivo é **nome_do_teste.c**, deve-se rodar:

```bash
make flash_nome_do_teste
```

Ou, caso use um gravador com J-Link:

```bash
make jflash_nome_do_teste
```

## Formatando

Para garantir que o código está formatado, utilize o atalho `CTRL`+`S` para salvar e formatar o arquivo em que se está mexendo ou, para formatar todos os arquivos do repositório de uma vez, rode:

```bash
make format
```

## Submódulos

### Adicionando um submódulo

Crie um diretório chamado `lib` e adicione o submódulo nele.

Exemplo:

```bash
mkdir lib
git submodule add --name STMSensors git@github.com:ThundeRatz/STMSensors.git lib/STMSensors
```

### Inicializando um submódulo já existente

Ao clonar um repositório que já tem submódulos, é necessário clonar os repositórios desse submódulo. Isso pode ser feito de duas formas, clonando junto com o repositório do projeto ou depois de já ter clonado.

Exemplo:

Para se clonar junto, deve-se fazer:

```bash
git clone --recurse-submodules git@github.com:ThundeRatz/STM32ProjectTemplate.git
```

Para se clonar depois de já ter clonado o repositório do projeto:

```bash
git submodule update --init
```

## Diretório de testes

O diretório `test` contém arquivos para testes de partes específicas do projeto, separando isso do código do projeto em si. Esses arquivos devem ser implementados de acordo com as necessidades dos desenvolvedores.

Para compilar e gravar um teste, siga as instruções [na seção de compilação](#compilando) e [na seção para gravação](#gravando).

Cada arquivo de teste no diretório de testes funciona de forma independente, ou seja, cada um deve ter uma função `main()`, sendo cada um compilado, gravado e executado separadamente.

## Debug

> Em breve

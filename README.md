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

* [GNU Arm Embedded Toolchain](https://developer.arm.com/open-source/gnu-toolchain/gnu-rm/downloads)
  > É necessário que a pasta `bin` dessa instalação esteja no `PATH`

* clang-format
  > Linux: `sudo apt install clang-format`
  >
  > Windows: `msys2> pacman -S clang`

* [Visual Studio Code](https://code.visualstudio.com/)
  * [EditorConfig](https://github.com/editorconfig/editorconfig-vscode)

* [ST-Util](https://github.com/texane/stlink)
  > É necessário que o executável também esteja no `PATH`

## Preparando
### Projeto

Primeiro é necessário criar um projeto `board` do Cube na pasta `cube/`, ele deve ter as seguintes opções de projeto:

Project:
* Project Name: *board*
* Application Structure: *Basic*
* Toolchain / IDE: *Makefile*

Code Generator:
* STM32Cube Firmware Library Package: *Copy only the necessary library files*
* Generated files:
  * *Generate peripheral initialization as a pair of .c/.h files per peripheral*
  * *Delete previously generated files when not re-generated*

Um arquivo de exemplo se encontra em `cube/board.ioc` com todas as configurações necessárias.

Para projetos existentes, basta mover o arquivo `.ioc` para a pasta `cube/`, mudar o nome para `board.ioc` e conferir se as configurações estão como acima.

### Gerando arquivos

Com o arquivo do projeto na pasta correta, os seguintes comandos devem ser executados (necessário apenas após dar checkout no repositório ou mudar o cube):

```bash
$ make cube     # Gera os arquivos do cube
$ make prepare  # Apaga os arquivos do cube desnecessários
```

## Compilando

Para compilar os arquivos rode
```bash
$ make
```

~~só isso mesmo~~

## Gravando

Para gravar os arquivos na placa, rode
```bash
$ make flash
```

~~só isso mesmo também~~

## Tasks

No Visual Studio Code, pode pressionar `CTRL`+`SHIFT`+`B` e escolher uma das opções da lista para executar os comandos de compilação e gravação mais rapidamente.

* Clean Project
* Build Project
* Rebuild Project
* Flash Program
* Build and Flash

## Debug

> Em breve

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
  > e numa variável de ambiente `ARM_GCC_PATH`

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

* STM32Cube Firmware Library Package: *Copy only the necessary library files*
* Generated files:
  * *Generate peripheral initialization as a pair of .c/.h files per peripheral*
  * *Delete previously generated files when not re-generated*

Um arquivo de exemplo se encontra em `cube/stm32_project_template.ioc` com todas as configurações necessárias.

Para projetos existentes, basta mover o arquivo `.ioc` para a pasta `cube/`.

### Gerando arquivos

Com o arquivo do projeto na pasta correta, os seguintes comandos devem ser 
executados (necessário apenas após dar checkout no repositório ou mudar o cube):

```bash
make cube     # Gera arquivos do cube
make prepare  # Apaga os arquivos do cube desnecessários e gera arquivos de configuração do VS Code
```

Se, após modificar os arquivos do cube, ocorrer algum erro nos comandos acima,
pode rodar `make clean_cube` para apagar os arquivos gerados e então tentar 
novamente para que eles sejam gerados do zero.

### [config.mk](config.mk)

O arquivo [config.mk](config.mk) deve ser alterado de acordo com o projeto. 

Para isso é necessário mudar o nome do projeto, o qual deve ter o mesmo do arquivo do Cube (por exemplo, `stm32_project_template.ioc`), porém sem a extensão `.ioc` (no caso de não se utilizar o versionamento dos arquivos do Cube).

```Makefile
PROJECT_NAME = stm32_project_template
```

Também é necessário alterar as seguintes configuraões:

```Makefile
DEVICE_FAMILY  := STM32F3xx
DEVICE_TYPE    := STM32F303xx
DEVICE_DEF     := STM32F303xE
DEVICE         := STM32F303RE
```

Basta pegar o nome completo do microcontrolador e colocar nessas configurações, seguindo o padrão, fazendo as substituições que forem precisas por `x`.

> Em caso de dúvida, veja o nome do arquivo `.ld` gerado na pasta `cube`,
> ele contém o nome completo do microcontrolador.

> Se estiver usando a família STM32G0, a variável `DEVICE_DEF` deverá ser igual à `DEVICE_TYPE`.

Além disso, deve-se colocar o nome completo do arquivo com extensão `.ld` em `DEVICE_LD_FILE`.

```Makefile
# Linker script file without .ld extension
# Find it on cube folder after code generation
DEVICE_LD_FILE := STM32F303RETx_FLASH
```

As seguintes configurações não precisam ser alteradas, elas definem nomes de diretórios e opções de compilação, sendo o sugerido permanecerem com seus valores padrão:

```Makefile
# Lib dir
LIB_DIR  := lib

# Cube Directory
CUBE_DIR := cube

# Config Files Directory
CFG_DIR :=

# Tests Directory
TEST_DIR := tests

# Default values, can be set on the command line or here
DEBUG   ?= 1
VERBOSE ?= 0
TEST    ?= 0
```

## Compilando

Para compilar os arquivos rode

```bash
make
```

Às vezes, é necessário limpar os arquivos já compilados, se algum erro estiver 
acontecendo, para isso faça:

```bash
make clean
```

Isso apaga todos os arquivos de compilação gerados, exceto aqueles gerados a partir 
das bibliotecas da ST geradas pelo Cube, isso ocorre para agilizar um novo build,
já que raramente será necessário recompilar esses arquivos, mas caso seja necessário,
é possível limpar todos os arquivos de compilação com

```bash
make clean_all
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

## Tasks

No Visual Studio Code, pode pressionar `CTRL`+`SHIFT`+`B` e escolher uma das 
opções da lista para executar os comandos de compilação e gravação mais rapidamente.

* Clean Project (_make clean_)
* Build Project (_make_)
* Rebuild Project (_make clean && make_)
* Flash Program (_make flash_)
* Build and Flash (_make && make flash_)

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

O diretório definido pela variável `TEST_DIR` contém arquivos para testes de partes específicas do projeto, separando isso do código do projeto em si. Esses arquivos devem ser implementados de acordo com as necessidades dos desenvolvedores.

Para se habilitar a compilação e gravação dos testes, deve-se definir o valor da variável `TEST_NAME` para o nome do arquivo de teste que se quer utilizar, isso pode ser feito tanto no arquivo `config.mk`, quanto pela linha de comando ao rodar o `make`, como por exemplo:

```bash
make flash TEST_NAME=test_digital_sensors
```

Caso o valor da variável `TEST_NAME` seja vazio, não se utilizará o modo de teste.

Uma observação é que o comando `make clean`, quando `TEST_NAME` não for vazio, irá apagar os arquivos de compilação referentes aos arquivos de teste.

Cada arquivo de teste no diretório de testes funciona de forma independente, ou seja, cada um deve ter uma função `main()`, sendo cada um compilado, gravado e executado separadamente.

Note que o nome do teste não inclui a extensão do arquivo.

## Debug

> Em breve

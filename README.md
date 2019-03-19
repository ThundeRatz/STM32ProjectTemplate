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

* clang-format
  > Linux: `sudo apt install clang-format`
  >
  > Windows: `msys2> pacman -S clang`

* [Visual Studio Code](https://code.visualstudio.com/)
  * [EditorConfig](https://marketplace.visualstudio.com/items?itemName=EditorConfig.EditorConfig)
  * [C/C++](https://marketplace.visualstudio.com/items?itemName=ms-vscode.cpptools)

* [STM32 Cube Programmer](https://www.st.com/en/development-tools/stm32cubeprog.html) ou [J-Link](https://www.segger.com/downloads/jlink/)
  > É necessário que o executável também esteja no `PATH`

## Preparando
### Projeto

Primeiro é necessário criar um projeto `board` do Cube na pasta `cube/`,
ele deve ter as seguintes opções de projeto:

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

Para projetos existentes, basta mover o arquivo `.ioc` para a pasta `cube/`,
mudar o nome para `board.ioc` e conferir se as configurações estão como acima.

### Gerando arquivos

Com o arquivo do projeto na pasta correta, os seguintes comandos devem ser 
executados (necessário apenas após dar checkout no repositório ou mudar o cube):
```bash
$ make cube     # Gera os arquivos do cube
$ make prepare  # Apaga os arquivos do cube desnecessários
```

Se, após modificar os arquivos do cube, ocorrer algum erro nos comandos acima,
pode rodar `make clean_cube` para apagar os arquivos gerados e então tentar 
novamente para que eles sejam gerados do zero.

### Makefile

As primeiras linhas do Makefile devem ser alteradas de acordo com o projeto:

```Makefile
PROJECT_NAME = stm32_project_template

DEVICE_FAMILY := STM32F3xx
DEVICE_TYPE   := STM32F303xx
DEVICE        := STM32F303RE
DEVICE_LD     := STM32F303RETx
DEVICE_DEF    := STM32F303xE
```

Basta mudar o nome do projeto e pegar o nome completo do processador e colocar nessas configurações, seguindo o padrão. O nome do projeto deve ser o mesmo nome do arquivo do Cube (por exemplo, `stm32_project_template.ioc`).

> Em caso de dúvida, basta ver o nome do arquivo `.ld` gerado na pasta `cube`,
> ele contém o nome completo, que deve ir na variável `DEVICE_LD`,
> para as outras basta substituir por `x`)

Também é necessário mudar o arquivo `.vscode/c_cpp_properties.json` e colocar o
`DEVICE_DEF` nele, para que o IntelliSense possa encontrar as configurações corretas:
```json
"defines": [
    "STM32F303xE",
    "USE_HAL_DRIVER"
],
```

## Compilando

Para compilar os arquivos rode
```bash
$ make
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
$ make flash
```

Ou, caso use um gravador com J-Link:
```bash
$ make jflash
```

## Tasks

No Visual Studio Code, pode pressionar `CTRL`+`SHIFT`+`B` e escolher uma das 
opções da lista para executar os comandos de compilação e gravação mais rapidamente.

* Clean Project (_make clean_)
* Build Project (_make_)
* Rebuild Project (_make clean && make_)
* Flash Program (_make flash_)
* Build and Flash (_make && make flash_)

## Adding a submodule

Create a directory called lib and add the submodules there.

Example:

```
mkdir lib
git submodule add --name STMSensors git@github.com:ThundeRatz/STMSensors.git lib/
```

## Debug

> Em breve

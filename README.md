<!-- markdownlint-disable -->
<div align="center">

# Template para Projetos STM32

Template para projetos com microcontroladores STM32 usando STM32CubeMX e CMake

</div>

<div align="center">
  <a href="https://www.st.com/en/development-tools/stm32cubemx.html"><img alt="Usa STM32CubeMX" src="https://img.shields.io/badge/usa-stm32cubemx-blue?style=for-the-badge&labelColor=38c1d0&color=45a4b8" height="30"></a>
  <a href="https://en.wikipedia.org/wiki/Embedded_system"><img alt="Para Sistemas Embarcados" src="https://img.shields.io/badge/para-sistemas_embarcados-blue?style=for-the-badge&labelColor=adec37&color=27a744" height="30"></a>
  <a href="LICENSE"><img alt="Licença MIT" src="https://img.shields.io/badge/licença-MIT-blue?style=for-the-badge&labelColor=ef4041&color=c1282d" height="30"></a>
</div>
<!-- markdownlint-restore -->

## 📑 Sumário

- [📑 Sumário](#-sumário)
- [📁 Estrutura de Pastas](#-estrutura-de-pastas)
- [🛠 Configuração](#-configuração)
- [🔨 Compilação](#-compilação)
- [🚀 Execução](#-execução)
- [🧪 Testes](#-testes)
- [🐛 Depuração](#-depuração)
- [💄 Formatação](#-formatação)
- [📦 Submódulos](#-submódulos)
- [🐋 Docker](#-docker)
- [👥 Contribuição](#-contribuição)
- [🙌 Agradecimentos](#-agradecimentos)

## 📁 Estrutura de Pastas

- **.github/** - Configurações do GitHub Actions
- **.vscode/** - Configurações do Visual Studio Code
- **build/** - Arquivos gerados durante a compilação (não versionado)
- **cmake/** - Funções customizadas para CMake
- **config/** - Configurações do projeto
- **cube/** - Projeto do STM32CubeMX (.ioc e arquivos gerados)
- **docker/** - Configurações e scripts do Docker
- **include/** - Cabeçalhos
- **docs/** - Documentação gerada (não versionado)
- **lib/** - Submódulos e bibliotecas externas
- **src/** - Código fonte principal da aplicação
- **test/** - Testes

## 🛠 Configuração

### 1. Projeto CubeMX

1. Crie um novo projeto na pasta `cube/`
2. Configurações:
    - **Project > Application Structure:** Basic
    - **Project > Toolchain/IDE:** CMake
    - **Code Generator > Generate peripheral initialization:** Pair of .c/.h
    - **Code Generator > Delete previous generated files:** Ativado

### 2. CMakeLists.txt

Edite o arquivo principal `CMakeLists.txt` com as informações do seu projeto:

```cmake
# Nome do projeto (igual ao arquivo .ioc sem extensão)
set(CMAKE_PROJECT_NAME meu_projeto)

# Versão da placa (opcional)
set(BOARD_VERSION "")
```

## 🔨 Compilação

Antes de iniciar, crie uma pasta `build/` na raiz do projeto

```bash
mkdir build
cd build
```

Dentro dela, configure o ambiente com

```bash
cmake ..
```

Depois, compile o projeto

```bash
make -j
```

> O parâmetro `-j` ativa a compilação paralela, usando mais núcleos do seu processador

### Limpar arquivos

```bash
make clear       # Código do usuário
make clear_cube  # Bibliotecas Cube
make clear_all   # Tudo
```

### Manual

Para obter uma lista completa de comandos, use

```bash
make help
```

## 🚀 Execução

### Gravando via [STM32CubeProgrammer](https://www.st.com/en/development-tools/stm32cubeprog.html)

```bash
make flash
```

### Gravando via J-Link

```bash
make jflash
```

## 🧪 Testes

Cada teste deve ser um arquivo independente na pasta `test/` com sua própria função `main()`

Para compilar um teste específico, use `make meu_teste`. Por exemplo, para compilar o teste `test/test_led.c`:

```bash
make test_led
```

Para gravar um teste específico, use `make flash_meu_teste`:

```bash
make flash_test_led
```

Para compilar todos os testes, use `make test_all`:

```bash
make test_all
```

## 🐛 Depuração

Para debugar o projeto usando o [`gdb`](https://www.gnu.org/software/gdb), primeiro instale o `gdb-multiarch`, no Ubuntu, execute:

```bash
sudo apt install gdb-multiarch
```

1. Configure o build para debug:

```bash
cmake .. -DBUILD_TYPE=Debug
```

2. Gerar configurações de debug:

```bash
make debug
```

Para debugar um teste, use `make debug_meu_teste`:

```bash
make debug_test_led
```

3. Use a extensão Cortex-Debug no VS Code com uma das configurações:

- [J-Link](https://www.segger.com/downloads/jlink/)
- [OpenOCD](https://openocd.org/) (`sudo apt install openocd`)
- [ST-Util](https://github.com/stlink-org/stlink) (`sudo apt install stlink-tools`)

## 💄 Formatação

### Formatação Automática

Para formatar o projeto, usamos o `clang-format`. As configurações estão no arquivo `.clang-format`. Para instalar, no Ubuntu, execute:

```bash
sudo apt install clang-format
```

Para formatar o projeto, execute o seguinte comando na pasta `build`:

```bash
make format
```

Usamos o `clang-tidy` para seguir as melhores práticas de código. As regras de linting estão no arquivo `.clang-tidy`. Para instalar, no Ubuntu, execute:

```bash
sudo apt install clang-tidy
```

Para rodar o linter é preciso compilar o projeto com a variável `LINTER_MODE` do CMake. Para habilitar o linter, execute:

```
cmake .. -DLINTER_MODE=ON
```

Para desabilitar o linter, execute:

```
cmake .. -DLINTER_MODE=OFF
```

Também é possível rodar o linter e deixar ele corrigir automaticamente o código:

```
cmake .. -DLINTER_MODE=FIX
```

E então basta compilar o projeto normalmente:

```bash
make -j
```

## 📦 Submódulos

### Adicionar novo submódulo

```bash
git submodule add --name lib_nome git@github.com:usuario/lib_nome.git lib/lib_nome
```

### Atualizar submódulos

```bash
git submodule update --init --recursive
```

## 🐋 Docker

Para configuração do Docker no seu projeto, veja https://github.com/ThundeRatz/stm32cubemx_docker

### Compilar usando container

```bash
docker compose run build
```

### Ambiente de desenvolvimento

```bash
docker compose run dev
# Dentro do container:
mkdir build
cd build
cmake ..
make -j
```

## 👥 Contribuição

1. Commits devem usar emojis descritivos:
    - 🐛 Correções de bugs
    - ✨ Novas funcionalidades
    - 📝 Documentação
    - 🎨 Formatação de código
2. Siga o [GitHub Flow](https://guides.github.com/introduction/flow/)
3. Mantenha a coesão do código e documentação
4. Teste suas alterações antes de submeter pull requests


## 🙌 Agradecimentos

Este projeto não teria sido possível sem o suporte e colaboração da equipe **ThundeRatz** como um todo.  
As decisões de arquitetura e organização foram fortemente baseadas nas boas práticas adotadas nos projetos da equipe, garantindo um código mais modular, eficiente e escalável.


Também gostaríamos de reconhecer o projeto **[Micras](https://github.com/Team-Micras/MicrasFirmware)**, cujo desenvolvimento serviu de base para diversas decisões adotadas aqui.  
As discussões técnicas e desafios enfrentados no Micras ajudaram a moldar a estrutura e as boas práticas deste template.


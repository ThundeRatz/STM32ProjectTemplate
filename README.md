<!-- markdownlint-disable -->
<div align="center">

# Template para Projetos STM32

Template para projetos com microcontroladores STM32 usando STM32CubeMX, Makefile e CMake

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
- [⚙️ Requisitos](#-requisitos)
- [🛠 Configuração](#-configuração)
- [🔨 Compilação](#-compilação)
- [🚀 Execução](#-execução)
- [🧪 Testes](#-testes)
- [🐛 Depuração](#-depuração)
- [💄 Formatação](#-formatação)
- [📦 Submódulos](#-submódulos)
- [🐋 Docker](#-docker)
- [👥 Contribuição](#-contribuição)

## 📁 Estrutura de Pastas

- **.vscode/** - Configurações do Visual Studio Code
- **build/** - Arquivos gerados durante a compilação (não versionado)
- **cmake/** - Funções customizadas para CMake
- **cube/** - Projeto do STM32CubeMX (.ioc e arquivos gerados)
- **docs/** - Documentação gerada (não versionado)
- **lib/** - Submódulos e bibliotecas externas
- **src/** - Código fonte principal da aplicação
- **test/** - Testes

## Requisitos

### Ferramentas Essenciais

- [STM32CubeMX](https://www.st.com/en/development-tools/stm32cubemx.html)

    > Configure a variável de ambiente `CUBE_PATH` com o caminho de instalação

- **Compilação**

    ```bash
    sudo apt install cmake make gcc-arm-none-eabi
    ```

### Ferramentas Opcionais

- **Programação**

    - [STM32CubeProgrammer](https://www.st.com/en/development-tools/stm32cubeprog.html)
    - [J-Link](https://www.segger.com/downloads/jlink/) (para gravadores Segger)

- **Desenvolvimento**

    ```bash
    sudo apt install clang-format
    ```

## 🛠 Configuração

### 1. Projeto CubeMX

1. Crie um novo projeto na pasta `cube/`
2. Configurações recomendadas:
    - **Project > Application Structure:** Basic
    - **Project > Toolchain/IDE:** CMake
    - **Code Generator > Generate peripheral initialization:** Pair of .c/.h
    - **Code Generator > Delete previous generated files:** Ativado

### 2. CMakeLists.txt

Edite o arquivo principal `CMakeLists.txt` com as informações do seu microcontrolador:

```cmake
# Nome do projeto (igual ao arquivo .ioc sem extensão)
set(CMAKE_PROJECT_NAME meu_projeto)

# Versão da placa (opcional)
set(BOARD_VERSION "")
```

## 🔨 Compilação

```bash
# Configurar ambiente (dentro da pasta build)
cmake ..

# Compilar projeto principal
make -j

# Compilar e gravar
make flash

# Compilar teste específico
make meu_teste
make flash_meu_teste

# Limpar arquivos
make clear       # Código do usuário
make clear_cube  # Bibliotecas Cube
make clear_all   # Tudo
```

## 🚀 Execução

### Gravando via STM32CubeProgrammer

```bash
make flash
```

### Gravando via J-Link

```bash
make jflash
```

## 🧪 Testes

Cada teste deve ser um arquivo independente na pasta `test/` com sua própria função `main()`

```bash
# Compilar todos os testes
make test_all

# Compilar e gravar teste específico
make flash_meu_teste
```

## 🐛 Depuração

1. Configure o build para debug:

```bash
cmake .. -DBUILD_TYPE=Debug
```

2. Gerar configurações de debug:

```bash
make debug
```

3. Use a extensão Cortex-Debug no VS Code com uma das configurações:

- J-Link
- OpenOCD
- ST-Util

## 💄 Formatação

### Formatação Automática

```bash
# Formatar todo o projeto
make format

# Configurações:
# - .clang-format
```

### Linting

```bash
# Ativar verificação durante a compilação
cmake .. -DLINTER_MODE=ON

# Corrigir problemas automaticamente
cmake .. -DLINTER_MODE=FIX
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

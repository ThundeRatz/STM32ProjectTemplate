<!-- markdownlint-disable -->
<div align="center">

# Template para Projetos STM32

Template para projetos com microcontroladores STM32 usando STM32CubeMX e CMake

</div>

<div align="center">
  <a href="https://cplusplus.com/"><img alt="Made with C++" src="https://img.shields.io/badge/made_with-c%2B%2B-blue?style=for-the-badge&labelColor=ef4041&color=c1282d" height="30"></a>
  <a href="https://www.st.com/en/development-tools/stm32cubemx.html"><img alt="Usa STM32CubeMX" src="https://img.shields.io/badge/usa-stm32cubemx-blue?style=for-the-badge&labelColor=38c1d0&color=45a4b8" height="30"></a>
  <a href="https://en.wikipedia.org/wiki/Embedded_system"><img alt="Para Sistemas Embarcados" src="https://img.shields.io/badge/para-sistemas_embarcados-blue?style=for-the-badge&labelColor=adec37&color=27a744" height="30"></a>
  <a href="LICENSE"><img alt="Licença MIT" src="https://img.shields.io/badge/licença-MIT-blue?style=for-the-badge&labelColor=ef4041&color=c1282d" height="30"></a>
    <br>
    <a href="README.en.md"><img alt="Read in English" src="https://img.shields.io/badge/Read%20in-English-blue?style=for-the-badge&labelColor=555555&color=007ec6" height="30"></a>
</div>
</div>
<!-- markdownlint-restore -->

## 📑 Sumário

- [📑 Sumário](#-sumário)
- [📁 Estrutura de Pastas](#-estrutura-de-pastas)
- [🛠 Configuração](#-configuração)
  - [Dependências](#dependências)
  - [Projeto CubeMX](#1-projeto-cubemx)
  - [CMakeLists.txt](#2-cmakeliststxt)
- [🔨 Compilação](#-compilação)
- [🚀 Execução](#-execução)
- [🧪 Testes](#-testes)
- [🐛 Debug](#-debug)
- [💄 Estilo de Código](#-estilo-de-código)
  - [🎨 Formatação](#-formatação)
  - [🚨 Linter](#-linter)
- [📦 Submódulos](#-submódulos)
- [🐋 Docker](#-docker)
- [📝 Documentação](#-documentação)
- [🛠️ Ambiente de Desenvolvimento Windows (WSL)](#️-ambiente-de-desenvolvimento-windows-wsl)
- [👥 Diretrizes de Contribuição](#-diretrizes-de-contribuição)
  - [💬 Mensagens de Commit Git](#-mensagens-de-commit-git)
  - [🔀 GitHub Flow](#-github-flow)
- [🙌 Agradecimentos](#-agradecimentos)

## 📁 Estrutura de Pastas

- **.docker/** - Configurações e scripts do Docker
- **.github/** - Configurações do GitHub Actions
- **.vscode/** - Configurações do Visual Studio Code
- **cmake/** - Funções customizadas para CMake
- **config/** - Configurações do projeto
- **cube/** - Projeto do STM32CubeMX (.ioc e arquivos gerados)
- **include/** - Cabeçalhos
- **lib/** - Submódulos e bibliotecas externas
- **src/** - Código fonte principal da aplicação
- **test/** - Testes

Além disso, as seguintes pastas contém arquivos gerados e não são versionadas:

- **build/** - Arquivos gerados durante a compilação
- **docs/** - Documentação gerada

## 🛠 Configuração

### Dependências

Para aproveitar ao máximo este template, desde a compilação básica até debug e gravação, algumas ferramentas são essenciais e outras opcionais, dependendo do seu fluxo de trabalho. Abaixo descrevemos as principais, com comandos de exemplo para instalação em sistemas Debian/Ubuntu (como Ubuntu, Mint). Se você usa outra distribuição Linux (Fedora, Arch) ou macOS, adapte os comandos para seu gerenciador de pacotes (`dnf`, `pacman`, `brew`, etc.).

#### Essenciais para Começar

Você precisará destas ferramentas para simplesmente clonar e compilar o projeto:

*   **`git`**: O sistema de controle de versão fundamental para baixar este template, gerenciar suas alterações e lidar com quaisquer bibliotecas externas incluídas como submódulos.
    ```bash
    sudo apt install git
    ```
*   **`cmake`**: O coração do sistema de build. Ele interpreta as instruções do arquivo `CMakeLists.txt` e gera os arquivos necessários (Makefiles) para que a compilação ocorra no seu ambiente específico.
    ```bash
    sudo apt install cmake
    ```
*   **`make`**: Esta ferramenta lê os Makefiles gerados pelo CMake e executa os comandos de compilação na ordem correta. É o que você geralmente invoca para compilar (`make -j`).
    ```bash
    sudo apt install make
    ```
*   **`gcc-arm-none-eabi` Toolchain**: Este é o conjunto de ferramentas de compilação cruzada (compilador C/C++, linker, etc.) que transforma seu código fonte em código binário executável para os microcontroladores STM32 (baseados em ARM Cortex-M).
    ```bash
    sudo apt install gcc-arm-none-eabi
    ```
*   **`STM32CubeMX`**: Para configurar visualmente os periféricos do seu STM32, sistema de clock e gerar o código de inicialização base (incluindo o arquivo `.ioc`), você precisará desta ferramenta gráfica da ST. Baixe o instalador diretamente do [site da STMicroelectronics](https://www.st.com/en/development-tools/stm32cubemx.html). Para que o CMake possa interagir com ele (útil para gerar código), certifique-se de que o executável esteja no `PATH` do seu sistema ou que a variável de ambiente `CUBE_CMD` aponte para ele. *(Instalação manual via download)*.

> [!WARNING]
> No momento esse template não suporta versões acima da 6.13 do CubeMX

*   **`STM32CubeProgrammer`**: Essencial para gravar o firmware compilado no seu microcontrolador usando um programador ST-LINK. É necessário para usar o comando `make flash`. Baixe o instalador no [site da STMicroelectronics](https://www.st.com/en/development-tools/stm32cubeprog.html) e garanta que o executável de linha de comando (`STM32_Programmer_CLI`) esteja no seu `PATH`. *(Instalação manual via download)*.

#### Ferramentas Adicionais para Funcionalidades Extras

Estas ferramentas habilitam funcionalidades como configuração gráfica, gravação, debug avançado, padronização de código e documentação. Instale as que forem relevantes para você:

*   **`Software J-Link da Segger`**: Se você utiliza um programador/debugger J-Link, precisará do pacote de software da Segger. Ele fornece os drivers e o servidor GDB (`JLinkGDBServer`) necessários para debug e para o comando `make jflash`. Obtenha o "J-Link Software and Documentation Pack" no [site da Segger](https://www.segger.com/downloads/jlink/). O servidor GDB precisa estar acessível (via `PATH` ou variável `JLINK_CMD`). *(Instalação manual via download)*.
*   **`openocd`**: Uma alternativa open-source popular como servidor de debug (GDB Server). O Open On-Chip Debugger suporta diversos adaptadores, incluindo ST-LINK, e é uma das opções configuradas para debug neste template.
    ```bash
    sudo apt install openocd
    ```
*   **`stlink-tools`**: Um conjunto de ferramentas de linha de comando específicas para adaptadores ST-LINK. Inclui `st-flash` para gravação e `st-util` que pode atuar como um servidor GDB simples, sendo outra opção para debug.
    ```bash
    sudo apt install stlink-tools
    ```
*   **`gdb-multiarch`**: O cliente depurador GNU Debugger, capaz de entender múltiplas arquiteturas como ARM. É ele que você usa para se conectar aos servidores GDB (JLinkGDBServer, OpenOCD, st-util) e controlar a execução do programa passo a passo, inspecionar variáveis, etc. Frequentemente instalado junto com a toolchain `gcc-arm-none-eabi`, mas caso contrário, instale com:
    ```bash
    sudo apt install gdb-multiarch
    ```
*   **`clang-format`**: Para manter o código formatado de maneira consistente e automática, usamos o `clang-format`. Ele aplica as regras definidas no arquivo `.clang-format` ao seu código quando você executa `make format`.
    ```bash
    sudo apt install clang-format
    ```
*   **`clang-tidy`**: Uma ferramenta de análise estática (linter) que ajuda a identificar potenciais problemas, bugs e desvios de boas práticas no código C/C++. Ele usa as regras do arquivo `.clang-tidy` e é executado durante a compilação se você configurar o CMake com `-DLINTER_MODE=ON` ou `-DLINTER_MODE=FIX`.
    ```bash
    sudo apt install clang-tidy
    ```
*   **`doxygen` & Cia**: Para gerar documentação automaticamente a partir dos comentários no código, usamos o `doxygen`. Para gerar diagramas (como grafos de chamadas), ele pode usar o `graphviz`. E se você quiser a documentação também em PDF, ele utiliza `LaTeX` (provido pelo `texlive`). Execute `make docs` para gerar a documentação. Instale o necessário com:
    ```bash
    sudo apt install doxygen graphviz texlive-latex-extra texlive-fonts-extra
    ```
    *(Note que a instalação do `texlive` pode ocupar um espaço considerável).*

> [!TIP]
> Lembre-se de consultar as seções específicas deste README (Compilação, Execução, Debug, Estilo de Código, Documentação) para entender melhor como e quando cada uma dessas ferramentas opcionais entra em ação no fluxo de trabalho proporcionado pelo template.

### 1. Projeto CubeMX

O início de um projeto STM32 é feito no STM32CubeMX. Para isso, é necessário instalar o [STM32CubeMX](https://www.st.com/en/development-tools/stm32cubemx.html) e configurar o projeto:

> [!IMPORTANT]
> Para que o CMake encontre e utilize o STM32CubeMX automaticamente (por exemplo, ao gerar código), certifique-se de que o executável do CubeMX esteja no `PATH` do seu sistema ou defina a variável de ambiente `CUBE_CMD` com o caminho completo para o executável.

1. Crie um novo projeto na pasta `cube/`
2. Configurações:
    - **Project Manager > Project > Application Structure:** Basic
    - **Project Manager > Project > Toolchain/IDE:** CMake
    - **Project Manager > Code Generator > Generate peripheral initialization:** Pair of .c/.h files per peripheral
    - **Project Manager > Code Generator > Delete previous generated files when not regenerated:** Ativado

### 2. CMakeLists.txt

Edite o arquivo principal `CMakeLists.txt` com as informações do seu projeto:

```cmake
# Nome do projeto (igual ao arquivo .ioc sem extensão)
set(CMAKE_PROJECT_NAME meu_projeto)

# Versão da placa (opcional)
set(BOARD_VERSION "")
```

## 🔨 Compilação

Antes de compilar pela primeira vez, certifique-se de que os submódulos Git (se houver) foram inicializados:

```bash
git submodule update --init --recursive
```

Agora, crie uma pasta `build/` na raiz do projeto (se ainda não existir) e entre nela:

```bash
mkdir -p build
cd build
```

Dentro dela, configure o ambiente com CMake:

```bash
cmake ..
```

Depois, compile o projeto:

```bash
make -j
```

> O parâmetro `-j` ativa a compilação paralela, usando mais núcleos do seu processador para acelerar o processo.

### Limpar arquivos

```bash
make clear       # Código do usuário
make clear_cube  # Bibliotecas Cube
make clear_all   # Tudo
```

### Manual

Para obter uma lista completa de comandos `make` disponíveis (definidos no CMake), use:

```bash
make helpme
```

## 🚀 Execução

Para gravar o firmware principal no microcontrolador, você pode usar um dos seguintes comandos (requer a ferramenta correspondente instalada):

### Gravando via [STM32CubeProgrammer](https://www.st.com/en/development-tools/stm32cubeprog.html)

> [!IMPORTANT]
> O executável `STM32_Programmer_CLI` precisa estar no `PATH` do seu sistema para este comando funcionar.

```bash
make flash
```

### Gravando via J-Link

> [!IMPORTANT]
> O `JLinkExe` precisa estar no `PATH` ou a variável de ambiente `JLINK_CMD` precisa ser definida com o caminho para o executável.

```bash
make jflash
```

Se o projeto ainda não foi compilado, esses comandos irão compilá-lo automaticamente antes de gravar.

## 🧪 Testes

Cada teste deve ser um arquivo independente na pasta `test/` com sua própria função `main()`.

Para compilar um teste específico, use `make <nome_do_teste>`. Por exemplo, para compilar o teste `test/test_gpio.c`:

```bash
make test_gpio -j
```

Para gravar um teste específico, use `make flash_<nome_do_teste>` ou `make jflash_<nome_do_teste>`:

```bash
make flash_test_gpio
```

ou 

```bash
make jflash_test_gpio
```

Para compilar todos os testes definidos no projeto, use `make test_all`:

```bash
make test_all -j
```

## 🐛 Debug

1.  **Configure o build para Debug:**
    Execute o CMake com a variável `BUILD_TYPE` definida como `Debug` (inclui símbolos de debug, sem otimizações) ou `RelWithDebInfo` (inclui símbolos, com otimizações).

    ```bash
    # Dentro da pasta build/
    cmake .. -DBUILD_TYPE=Debug
    ```

    ou

    ```bash
    cmake .. -DBUILD_TYPE=RelWithDebInfo
    ```

2.  **Compile o projeto:**

    ```bash
    make -j
    ```

3.  **Gere configurações de debug (Opcional, para VS Code):**
    Se estiver usando o VS Code com a extensão Cortex-Debug, gere os arquivos de configuração `launch.json`:

    ```bash
    make debug # Para o executável principal
    ```

    Para gerar configurações para um teste específico:

    ```bash
    make debug_test_gpio
    ```

4.  **Inicie a Sessão de Debug:**
    Use a extensão [Cortex-Debug](https://marketplace.visualstudio.com/items?marus25.Cortex-Debug) no VS Code com uma das configurações geradas no passo anterior, ou inicie manualmente um servidor GDB e conecte-se com `gdb-multiarch`. As configurações padrão usam um dos seguintes servidores GDB (instale o que for usar):

    *   **[J-Link](https://www.segger.com/downloads/jlink/):** Pode ser necessário gravar o firmware antes com `make jflash` ou `make jflash_meu_teste`.
    *   **[OpenOCD](https://openocd.org/):** `sudo apt install openocd` (Ubuntu/Debian)
    *   **[ST-Util](https://github.com/stlink-org/stlink):** `sudo apt install stlink-tools` (Ubuntu/Debian)

## 💄 Estilo de Código

Para manter a consistência e a qualidade do código, usamos ferramentas de formatação e linting.

### 🎨 Formatação

Usamos o `clang-format` para padronizar a formatação do código C/C++. As regras de estilo estão definidas no arquivo `.clang-format` na raiz do projeto.

Para formatar todo o código fonte (`src/`, `include/`, `test/`) de acordo com as regras, execute na pasta `build/`:

```bash
make format
```

### 🚨 Linter

Usamos o `clang-tidy` para análise estática, ajudando a identificar possíveis bugs, aplicar boas práticas e garantir a aderência a padrões de codificação. As regras de linting estão definidas no arquivo `.clang-tidy` na raiz do projeto.

O linter é executado durante a compilação quando a variável CMake `LINTER_MODE` está habilitada. Configure o CMake (dentro da pasta `build/`) com uma das seguintes opções:

*   **Habilitar Linter (apenas análise):**
    ```bash
    cmake .. -DLINTER_MODE=ON
    ```
*   **Habilitar Linter e aplicar correções automáticas:**
    ```bash
    cmake .. -DLINTER_MODE=FIX
    ```
*   **Desabilitar Linter (padrão):**
    ```bash
    cmake .. -DLINTER_MODE=OFF
    ```

Após configurar o CMake, compile o projeto normalmente para rodar o linter (se habilitado):

```bash
make -j
```

## 📦 Submódulos

Para adicionar uma biblioteca externa como um submódulo Git na pasta `lib/`:

```bash
git submodule add --name <nome_descritivo> <url_do_repositorio> lib/<nome_da_pasta>
# Exemplo:
# git submodule add --name lib_cmsis_dsp git@github.com:ARM-software/CMSIS-DSP.git lib/cmsis_dsp
```

Para clonar um projeto que usa submódulos pela primeira vez, ou para atualizar os submódulos existentes:

```bash
git submodule update --init --recursive
```

## 🐋 Docker

É possível usar o Docker para criar um ambiente de desenvolvimento e compilação conteinerizado, garantindo consistência entre diferentes máquinas e facilitando a integração contínua (CI/CD). É necessário ter o [Docker](https://docs.docker.com/get-docker/) e o [Docker Compose](https://docs.docker.com/compose/install/) instalados.

A configuração base do Docker para este template pode ser encontrada em https://github.com/ThundeRatz/stm32cubemx_docker. Adapte os arquivos em `.docker/` conforme necessário para o seu projeto.

### Compilar usando container

Execute a compilação diretamente de fora do container:

```bash
docker compose run build # Compila o projeto principal
docker compose run format # Formata o código
docker compose run lint   # Roda o linter (requer LINTER_MODE=ON no build)
```

### Ambiente de desenvolvimento interativo

Para entrar em um shell dentro do container e executar comandos manualmente:

```bash
docker compose run dev
```

E estando dentro do container você pode usar os comandos normais

```bash
mkdir -p build
cd build
cmake ..
make -j
```

> [!TIP]
> Se você usa o Visual Studio Code, a extensão [Dev Containers](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers) permite que você abra o projeto diretamente *dentro* do container definido no `docker-compose.yml`, proporcionando uma experiência de desenvolvimento integrada.

## 📝 Documentação

Este template está configurado para gerar documentação do código fonte usando [Doxygen](https://www.doxygen.nl/).

Para gerar a documentação (HTML e PDF, se LaTeX estiver instalado) na pasta `docs/`, execute o seguinte comando dentro da pasta `build/`:

```bash
make docs
```

A configuração do Doxygen é controlada pelo arquivo `Doxyfile` na raiz do projeto. Edite-o para personalizar a geração da documentação.

## 🛠️ Ambiente de Desenvolvimento Windows (WSL)

Se você está desenvolvendo em uma máquina Windows usando o [**Subsistema Windows para Linux (WSL)**](https://learn.microsoft.com/en-us/windows/wsl/), recomendamos o seguinte fluxo de trabalho para uma melhor experiência:

1.  **Instale as ferramentas de Build/Código no WSL:**
    *   `cmake`, `make`, `gcc-arm-none-eabi`, `git`, `clang-format`, `clang-tidy`, `doxygen`, etc. (usando o gerenciador de pacotes da sua distribuição Linux, como `apt`), conforme descrito na [seção de Dependências](#dependências)
2.  **Instale as ferramentas de Hardware/Interface no Windows:**
    *   [STM32CubeMX](https://www.st.com/en/development-tools/stm32cubemx.html)
    *   [STM32CubeProgrammer](https://www.st.com/en/development-tools/stm32cubeprog.html)
    *   Drivers e Software do seu Debugger (e.g., [J-Link Software and Documentation Pack](https://www.segger.com/downloads/jlink/), Drivers ST-LINK)
3.  **Adicione as Ferramentas Windows ao PATH:**
    Facilita chamar `STM32_Programmer_CLI.exe` ou `JLinkGDBServerCL.exe` diretamente do terminal WSL. Como o WSL importa o PATH do Windows automaticamente, edite seu PATH para incluir os diretórios de instação das ferramentas.
4.  **Fluxo de Trabalho Recomendado:**
    *   Use o terminal WSL para clonar, compilar (`cmake`, `make`), formatar (`make format`), etc.
    *   Execute o STM32CubeMX no Windows para configurar o hardware e gerar o código (o CMake pode detectá-lo via PATH).
    *   Use os comandos `make flash` ou `make jflash` no WSL (eles chamarão as ferramentas Windows via PATH).
    *   Para debug, execute o GDB Server apropriado (e.g., `JLinkGDBServerCL.exe`, `openocd.exe`, `st-util`) no **Windows** e conecte-se a ele a partir do `gdb-multiarch` no WSL ou via VS Code (veja nota abaixo).

> [!NOTE]
> **Rede WSL para Debug:** Ao rodar um GDB Server no Windows (porta `localhost:XXXX`), para que o GDB dentro do WSL consiga se conectar a ele, você pode precisar configurar o [**modo de rede espelhado (Mirrored mode networking)**](https://learn.microsoft.com/en-us/windows/wsl/networking#mirrored-mode-networking) no WSL (requer builds recentes do Windows 11). Isso faz com que o WSL compartilhe o mesmo endereço IP do Windows, facilitando a comunicação localhost.

**Alternativas:**
*   Você pode definir as variáveis de ambiente `JLINK_CMD` e `PROGRAMMER_CMD` no CMake ou no ambiente WSL para apontar explicitamente para os executáveis no Windows (`/mnt/c/...`), caso não queira adicioná-los ao PATH.
*   É possível instalar e usar ferramentas como OpenOCD ou stlink-tools diretamente no WSL e tentar passar o dispositivo USB para o WSL usando `usbipd-win`. Consulte a [documentação oficial do WSL sobre USB](https://learn.microsoft.com/en-us/windows/wsl/connect-usb) para mais detalhes, mas essa abordagem pode ser menos estável que usar as ferramentas nativas do Windows.

## 👥 Diretrizes de Contribuição

Para contribuir com este projeto (ou projetos derivados deste template), siga estas diretrizes:

### 💬 Mensagens de Commit Git

Para manter um histórico claro, consistente e compreensível globalmente, as mensagens de commit **devem obrigatoriamente ser escritas em Inglês**. Siga estas diretrizes ao escrever suas mensagens:

1.  **Use o Tempo Presente e Modo Imperativo (em Inglês):**
    *   Descreva o que o commit faz, como se estivesse dando uma ordem.
    *   Exemplo: Escreva `✨ Add user profile feature` (Adiciona funcionalidade de perfil de usuário) em vez de `Added user profile feature` (Adicionada funcionalidade...) ou `Adds user profile feature` (Adiciona funcionalidade...).

2.  **Comece com um Emoji Descritivo:**
    *   Um emoji no início da linha de assunto ajuda a identificar rapidamente o tipo de alteração.
    *   Exemplos comuns (Emoji `código`: Exemplo em Inglês - *Tradução/Contexto*):
        *   `🐛 Fix issue with timer interrupt` - *Corrige problema com interrupção do timer*
        *   `✨ Implement SPI communication module` - *Implementa módulo de comunicação SPI*
        *   `📝 Update README with setup instructions` - *Atualiza README com instruções de configuração*
        *   `🎨 Format code using clang-format` - *Formata código usando clang-format*
        *   `⚡ Optimize ADC reading loop` - *Otimiza loop de leitura do ADC*
        *   `♻️  Refactor GPIO initialization logic` - *Refatora lógica de inicialização do GPIO*
        *   `🔧 Adjust CMake toolchain file` - *Ajusta arquivo da toolchain CMake*
        *   `🧪 Add unit tests for calculation function` - *Adiciona testes unitários para função de cálculo*
        *   `⬆️  Update HAL library to version 1.8.0` - *Atualiza biblioteca HAL para versão 1.8.0*
        *   `⬇️  Downgrade external library due to bug` - *Reverte versão de biblioteca externa devido a bug*
        *   `🚑 Hotfix critical issue in motor control` - *Corrige problema crítico urgente no controle do motor*
    *   Para mais sugestões de emojis, veja: [Gitmoji](https://gitmoji.dev/)

3.  **Mantenha a Linha de Assunto Concisa:**
    *   A primeira linha (assunto) deve ser um resumo direto da mudança, idealmente com 50-72 caracteres.
    *   Se precisar de mais detalhes, deixe uma linha em branco após o assunto e escreva um corpo explicativo.

Seguir estas convenções torna o histórico do Git mais fácil de navegar e entender para todos os contribuidores.

### 🔀 GitHub Flow

1.  **Siga o [GitHub Flow](https://docs.github.com/pt/get-started/quickstart/github-flow):**
    *   Crie um branch a partir da `develop` para cada nova funcionalidade ou correção (`git checkout -b nome-da-feature`).
    *   Faça commits atômicos e descritivos no seu branch.
    *   Abra um Pull Request (PR) quando o trabalho estiver pronto para revisão.
    *   Discuta e revise o código no PR. Faça alterações conforme necessário.
    *   Após aprovação e passagem dos checks de CI, faça o merge do PR na `develop`.
2.  **Mantenha a coesão do código e documentação:** Certifique-se de que o código novo se integra bem com o existente e que a documentação (comentários, README, Doxygen) é atualizada conforme necessário.
3.  **Teste suas alterações:** Antes de submeter um Pull Request, compile e teste suas modificações localmente. Se houver testes automatizados, certifique-se de que eles passam.

## 🙌 Agradecimentos

Este projeto não teria sido possível sem o suporte e colaboração da equipe **ThundeRatz** como um todo.
As decisões de arquitetura e organização foram fortemente baseadas nas boas práticas adotadas nos projetos da equipe, garantindo um código mais modular, eficiente e escalável.

Também gostaríamos de reconhecer o projeto **[Micras](https://github.com/Team-Micras/MicrasFirmware)**, cujo desenvolvimento serviu de base para diversas decisões adotadas aqui.
As discussões técnicas e desafios enfrentados no Micras ajudaram a moldar a estrutura e as boas práticas deste template.


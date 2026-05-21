# 🔍 Procurador de Itens - Ferramentas de Busca e Organização

Coleção de scripts PowerShell e Bash para buscar, organizar e gerenciar arquivos em sistemas Windows e Linux/Mac.

## 📋 Índice

- [Sobre](#sobre)
- [Scripts Disponíveis](#scripts-disponíveis)
- [Instalação](#instalação)
- [Exemplos de Uso](#exemplos-de-uso)
- [Requisitos](#requisitos)
- [Contribuindo](#contribuindo)
- [Licença](#licença)

---

## 🎯 Sobre

Este repositório contém ferramentas desenvolvidas para facilitar a busca e organização de arquivos em grandes volumes de dados. Os scripts foram criados com foco em performance e facilidade de uso, permitindo:

- Buscar arquivos por termos específicos nos títulos
- Organizar arquivos relevantes e irrelevantes automaticamente
- Descobrir dispositivos AnyDesk e RDP na rede local
- Listar arquivos mais pesados em discos e diretórios

---

## ✨ Funcionalidades

### 🔎 Busca de Arquivos
- Busca case-insensitive por múltiplos termos
- Ignora extensões de arquivo (busca apenas no título)
- Suporte para caracteres especiais
- Performance otimizada para grandes volumes

### 📁 Organização Automática
- Move arquivos irrelevantes para pasta separada
- Mantém arquivos relevantes organizados
- Preview antes de mover
- Confirmação em cada etapa

### 🌐 Descoberta de Rede
- Detecta dispositivos com AnyDesk ativo (porta 7070)
- Verifica portas RDP (3389) abertas
- Resolve hostnames automaticamente
- Gera relatórios de dispositivos encontrados

### 💾 Análise de Disco
- Lista arquivos mais pesados
- Busca recursiva em diretórios
- Exibição em KB/MB/GB
- Progresso em tempo real

---

## 📦 Scripts Disponíveis

### 🔍 Busca e Organização

#### `procurar_e_mover_irrelevantes.ps1` ⭐ **RECOMENDADO**
Script completo que combina busca e organização em uma única execução. Procura termos nos títulos dos arquivos de uma pasta, identifica quais são relevantes e quais não são, e move os irrelevantes para outra pasta.

**Uso:**
```powershell
.\procurar_e_mover_irrelevantes.ps1
```

**Funcionalidades:**
- Busca arquivos por termos específicos (apenas nível 1 da pasta)
- Identifica arquivos relevantes e irrelevantes
- Preview dos arquivos a mover antes de executar
- Confirmação em cada etapa
- Relatório completo ao final

---

#### `procurar_itens.ps1`
Busca arquivos que contêm termos específicos no título. Usa `dir /s /b` nativamente para performance máxima em grandes volumes.

**Uso:**
```powershell
.\procurar_itens.ps1
```

**Exemplo:**
```
Digite os termos: 2024, relatorio, vendas
Digite o caminho: C:\Documentos
```

---

#### `procurar_itens.sh`
Versão Bash do script de busca para Linux/Mac. Funcionalidade equivalente ao `procurar_itens.ps1`.

**Uso:**
```bash
chmod +x procurar_itens.sh
./procurar_itens.sh
```

---

#### `mover_itens_nao_encontrados.ps1`
Move arquivos que NÃO contêm os termos especificados. Interativo: pede pasta de origem, pasta de destino e termos relevantes.

**Uso:**
```powershell
.\mover_itens_nao_encontrados.ps1
```

---

#### `mover_itens_nao_encontrados_rapido.ps1`
Versão rápida com suporte a parâmetros diretos na linha de comando. Também funciona de forma interativa se nenhum parâmetro for passado.

**Uso com parâmetros:**
```powershell
.\mover_itens_nao_encontrados_rapido.ps1 -PastaOrigem "C:\Origem" -PastaDestino "C:\Destino" -Termos "termo1","termo2"
```

**Uso interativo:**
```powershell
.\mover_itens_nao_encontrados_rapido.ps1
```

---

### 🌐 Descoberta de Rede

#### `descobrir_anydesk_e_rdp_rapido.ps1`
Escaneia a rede local para descobrir dispositivos com AnyDesk (porta 7070) e/ou RDP (porta 3389) ativos. Também obtém o ID do AnyDesk da máquina local.

**Uso:**
```powershell
.\descobrir_anydesk_e_rdp_rapido.ps1 -RedeBase "192.168.15"
```

**Parâmetros:**
| Parâmetro | Padrão | Descrição |
|-----------|--------|-----------|
| `-RedeBase` | `192.168.15` | Base da rede a escanear |
| `-InicioIP` | `1` | IP inicial do range |
| `-FimIP` | `254` | IP final do range |

**Funcionalidades:**
- Detecta porta 7070 (AnyDesk) e 3389 (RDP)
- Resolve hostnames automaticamente
- Obtém ID do AnyDesk local
- Gera relatório com instruções de conexão
- Salva resultados em arquivo `.txt`

---

### 💾 Análise de Disco

#### `listar_arquivos_pesados.ps1`
Lista os arquivos mais pesados em um diretório (Windows). Busca recursiva com progresso em tempo real.

**Uso:**
```powershell
.\listar_arquivos_pesados.ps1
```

---

#### `listar_arquivos_pesados_v2.sh`
Versão Bash para Linux/Mac com progresso detalhado. Mostra o diretório sendo escaneado em tempo real.

**Uso:**
```bash
chmod +x listar_arquivos_pesados_v2.sh
./listar_arquivos_pesados_v2.sh
```

---

## 🚀 Instalação

### Windows (PowerShell)

1. Clone o repositório:
```powershell
git clone https://github.com/NOLASCOrabelo/Procurador-de-itens.git
cd Procurador-de-itens
```

2. Permita execução de scripts (se necessário):
```powershell
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process
```

3. Execute o script desejado:
```powershell
.\procurar_e_mover_irrelevantes.ps1
```

---

### Linux/Mac (Bash)

1. Clone o repositório:
```bash
git clone https://github.com/NOLASCOrabelo/Procurador-de-itens.git
cd Procurador-de-itens
```

2. Dê permissão de execução:
```bash
chmod +x *.sh
```

3. Execute o script desejado:
```bash
./procurar_itens.sh
```

---

## 📖 Exemplos de Uso

### Exemplo 1: Buscar e Organizar Arquivos

```powershell
# Execute o script completo
.\procurar_e_mover_irrelevantes.ps1

# Informe os termos relevantes
Digite os termos: 456728, 456729, 456730

# Informe a pasta
Digite o caminho: C:\Documentos\Arquivos

# O script mostra:
# - 43 arquivos relevantes (permanecerão)
# - 37 arquivos irrelevantes (serão movidos)

# Confirme a movimentação
Deseja mover? (S/N): S
Digite pasta destino: C:\Documentos\Irrelevantes
```

---

### Exemplo 2: Descobrir Dispositivos na Rede

```powershell
# Execute o script de descoberta
.\descobrir_anydesk_e_rdp_rapido.ps1 -RedeBase "192.168.15"

# Resultado:
# IP              Hostname         AnyDesk  RDP
# 192.168.15.6    PC-ESCRITORIO    Sim      Sim
# 192.168.15.40   MediaPortal      Sim      Não
# 192.168.15.234  DESKTOP-PC       Sim      Sim

# Para conectar via RDP:
mstsc /v:192.168.15.6
```

---

### Exemplo 3: Listar Arquivos Pesados

```bash
# Execute o script
./listar_arquivos_pesados_v2.sh

# Informe o diretório
Digite o caminho: /home/usuario/Downloads

# Resultado:
# [1] 2.5 GB - /home/usuario/Downloads/video.mp4
# [2] 1.8 GB - /home/usuario/Downloads/backup.zip
# [3] 1.2 GB - /home/usuario/Downloads/filme.mkv
```

---

## 📋 Requisitos

### Windows
- Windows 10 ou superior
- PowerShell 5.1 ou superior
- Permissões de administrador (para o script de descoberta de rede)

### Linux/Mac
- Bash 4.0 ou superior
- Comandos padrão: `find`, `du`, `sort`, `bc`

---

## 🎨 Características

- ✅ **Case-insensitive**: Busca sem diferenciar maiúsculas/minúsculas
- ✅ **Performance**: Otimizado para grandes volumes de dados
- ✅ **Segurança**: Confirmações antes de operações destrutivas
- ✅ **Preview**: Visualize mudanças antes de aplicar
- ✅ **Progresso**: Indicadores de progresso em tempo real
- ✅ **Relatórios**: Gera relatórios detalhados das operações
- ✅ **Cross-platform**: Suporte para Windows, Linux e Mac

---

## 🛠️ Tecnologias

- **PowerShell** - Scripts para Windows
- **Bash** - Scripts para Linux/Mac
- **Git** - Controle de versão

---

## 🤝 Contribuindo

Contribuições são bem-vindas! Para contribuir:

1. Fork o projeto
2. Crie uma branch para sua feature (`git checkout -b feature/NovaFuncionalidade`)
3. Commit suas mudanças (`git commit -m 'Adiciona nova funcionalidade'`)
4. Push para a branch (`git push origin feature/NovaFuncionalidade`)
5. Abra um Pull Request

---

## 📄 Licença

Este projeto está sob a licença MIT. Veja o arquivo [LICENSE](LICENSE) para mais detalhes.

---

## 👤 Autor

**Thiago Nolasco**

---

## 📞 Suporte

Se você encontrar algum problema ou tiver sugestões:

1. Abra uma [Issue](https://github.com/NOLASCOrabelo/Procurador-de-itens/issues)
2. Entre em contato

---

<div align="center">

**⭐ Se este projeto foi útil, considere dar uma estrela!**

Made with ❤️ by Thiago Nolasco

</div>

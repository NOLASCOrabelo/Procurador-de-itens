# 🔍 Procurador de Itens - Ferramentas de Busca e Organização

Coleção de scripts PowerShell e Bash para buscar, organizar e gerenciar arquivos em sistemas Windows e Linux/Mac.

## 📋 Índice

- [Sobre](#sobre)
- [Funcionalidades](#funcionalidades)
- [Scripts Disponíveis](#scripts-disponíveis)
- [Instalação](#instalação)
- [Uso](#uso)
- [Exemplos](#exemplos)
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
- Detecta dispositivos com AnyDesk ativo
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
Script completo que combina busca e organização em uma única execução.

**Uso:**
```powershell
.\procurar_e_mover_irrelevantes.ps1
```

**Funcionalidades:**
- Busca arquivos por termos específicos
- Identifica arquivos relevantes e irrelevantes
- Move irrelevantes para pasta de destino
- Relatório completo ao final

---

#### `procurar_itens.ps1`
Busca arquivos que contêm termos específicos no título.

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
Versão Bash do script de busca para Linux/Mac.

**Uso:**
```bash
chmod +x procurar_itens.sh
./procurar_itens.sh
```

---

#### `mover_itens_nao_encontrados.ps1`
Move arquivos que NÃO contêm os termos especificados.

**Uso:**
```powershell
.\mover_itens_nao_encontrados.ps1
```

---

#### `mover_itens_nao_encontrados_rapido.ps1`
Versão rápida com suporte a parâmetros.

**Uso:**
```powershell
.\mover_itens_nao_encontrados_rapido.ps1 -PastaOrigem "C:\Origem" -PastaDestino "C:\Destino" -Termos "termo1","termo2"
```

---

### 🌐 Descoberta de Rede

#### `descobrir_anydesk_e_rdp_rapido.ps1` ⭐ **RECOMENDADO**
Descobre dispositivos com AnyDesk e/ou RDP na rede local.

**Uso:**
```powershell
.\descobrir_anydesk_e_rdp_rapido.ps1 -RedeBase "192.168.1"
```

**Funcionalidades:**
- Detecta porta 7070 (AnyDesk)
- Detecta porta 3389 (RDP)
- Resolve hostnames
- Gera relatório com instruções de conexão

---

#### `descobrir_anydesk_REAL.ps1`
Tenta obter IDs reais do AnyDesk via PowerShell Remoting.

**Uso:**
```powershell
.\descobrir_anydesk_REAL.ps1
```

**Requer:**
- Credenciais de administrador
- PowerShell Remoting habilitado nas máquinas remotas

---

#### `obter_id_anydesk.ps1`
Obtém o ID do AnyDesk da máquina local.

**Uso:**
```powershell
.\obter_id_anydesk.ps1
```

---

### 💾 Análise de Disco

#### `listar_arquivos_pesados.ps1`
Lista os arquivos mais pesados em um diretório (Windows).

**Uso:**
```powershell
.\listar_arquivos_pesados.ps1
```

---

#### `listar_arquivos_pesados.sh`
Versão Bash para Linux/Mac.

**Uso:**
```bash
chmod +x listar_arquivos_pesados.sh
./listar_arquivos_pesados.sh
```

---

#### `listar_arquivos_pesados_v2.sh`
Versão melhorada com progresso detalhado.

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
git clone https://github.com/seu-usuario/procurador-de-itens.git
cd procurador-de-itens
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
git clone https://github.com/seu-usuario/procurador-de-itens.git
cd procurador-de-itens
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

## 📖 Uso

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
# 1. video.mp4 - 2.5 GB
# 2. backup.zip - 1.8 GB
# 3. filme.mkv - 1.2 GB
```

---

## 📋 Requisitos

### Windows
- Windows 10 ou superior
- PowerShell 5.1 ou superior
- Permissões de administrador (para alguns scripts)

### Linux/Mac
- Bash 4.0 ou superior
- Comandos padrão: `find`, `du`, `sort`

---

## 📚 Documentação Adicional

Cada script possui um guia detalhado de uso:

- [`GUIA_SCRIPT_COMPLETO.txt`](GUIA_SCRIPT_COMPLETO.txt) - Guia do script completo de busca e organização
- [`GUIA_MOVER_IRRELEVANTES.txt`](GUIA_MOVER_IRRELEVANTES.txt) - Guia de movimentação de arquivos
- [`GUIA_ANYDESK_E_RDP.txt`](GUIA_ANYDESK_E_RDP.txt) - Guia de descoberta de rede
- [`LEIA-ME_ANYDESK.txt`](LEIA-ME_ANYDESK.txt) - Informações sobre AnyDesk
- [`ENTENDA_O_PROBLEMA.txt`](ENTENDA_O_PROBLEMA.txt) - Explicação sobre IDs do AnyDesk

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
- **Markdown** - Documentação

---

## 🤝 Contribuindo

Contribuições são bem-vindas! Para contribuir:

1. Fork o projeto
2. Crie uma branch para sua feature (`git checkout -b feature/NovaFuncionalidade`)
3. Commit suas mudanças (`git commit -m 'Adiciona nova funcionalidade'`)
4. Push para a branch (`git push origin feature/NovaFuncionalidade`)
5. Abra um Pull Request

---

## 📝 Changelog

### [1.0.0] - 2026-05-11

#### Adicionado
- Script completo de busca e organização
- Descoberta de dispositivos AnyDesk e RDP
- Listagem de arquivos pesados
- Suporte para Windows, Linux e Mac
- Documentação completa

#### Melhorado
- Performance de busca em grandes volumes
- Interface com confirmações e preview
- Relatórios detalhados

---

## 📄 Licença

Este projeto está sob a licença MIT. Veja o arquivo [LICENSE](LICENSE) para mais detalhes.

---

## 👤 Autor

**Thiago Nolasco**

---

## 🙏 Agradecimentos

- Comunidade PowerShell
- Comunidade Bash/Linux
- Todos os contribuidores

---

## 📞 Suporte

Se você encontrar algum problema ou tiver sugestões:

1. Abra uma [Issue](https://github.com/seu-usuario/procurador-de-itens/issues)
2. Consulte a [Documentação](docs/)
3. Entre em contato

---

## 🔗 Links Úteis

- [Documentação PowerShell](https://docs.microsoft.com/powershell/)
- [Guia Bash](https://www.gnu.org/software/bash/manual/)
- [AnyDesk](https://anydesk.com/)
- [Remote Desktop Protocol](https://docs.microsoft.com/windows-server/remote/remote-desktop-services/)

---

<div align="center">

**⭐ Se este projeto foi útil, considere dar uma estrela!**

Made with ❤️ by Thiago Nolasco

</div>

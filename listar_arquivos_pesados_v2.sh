#!/bin/bash

# Cores para output
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
WHITE='\033[1;37m'
RED='\033[0;31m'
DARKGRAY='\033[0;90m'
NC='\033[0m' # No Color

echo -e "${CYAN}--- Listador de Arquivos Mais Pesados (v2 - Recursivo) ---${NC}"
echo ""

# 1. Obter o caminho
read -p "Digite o caminho completo da pasta que deseja analisar (Ex: /home/user ou /mnt/data): " source_path

# Verificar se o caminho existe
if [[ ! -d "$source_path" ]]; then
    echo -e "${RED}AVISO: O caminho '$source_path' não existe ou não está acessível.${NC}"
    exit 1
fi

# 2. Obter quantidade de arquivos a listar
read -p "Quantos arquivos mais pesados deseja listar? (padrão: 20): " quantidade

# Validar entrada
if [[ -z "$quantidade" ]] || ! [[ "$quantidade" =~ ^[0-9]+$ ]]; then
    quantidade=20
fi

echo ""
echo -e "${CYAN}Analisando arquivos em $source_path ...${NC}"
echo -e "${YELLOW}Buscando recursivamente em TODOS os subdiretórios...${NC}"
echo -e "${YELLOW}Ignorando arquivos especiais (/dev, /proc, /sys)...${NC}"
echo ""

# 3. Criar arquivo temporário para armazenar resultados
temp_file=$(mktemp)
trap "rm -f $temp_file" EXIT

# Contador de progresso
contador_progresso=0
ultimo_dir=""

# Encontrar APENAS arquivos regulares recursivamente
echo -e "${CYAN}Escaneando arquivos...${NC}"
echo ""

find "$source_path" -type f -printf "%s\t%p\n" 2>/dev/null | \
    while IFS=$'\t' read -r tamanho caminho; do
        # Mostrar progresso com diretório atual
        ((contador_progresso++))
        
        # Extrair diretório do caminho
        dir_atual=$(dirname "$caminho")
        
        # Mostrar diretório atual se mudou
        if [[ "$dir_atual" != "$ultimo_dir" ]]; then
            echo -ne "\r${DARKGRAY}Escaneando: $dir_atual${NC}                                        " >&2
            ultimo_dir="$dir_atual"
        fi
        
        # Mostrar contador a cada 100 arquivos
        if (( contador_progresso % 100 == 0 )); then
            echo -ne "\r${YELLOW}Arquivos processados: $contador_progresso${NC}                                        " >&2
        fi
        
        # Escrever no arquivo temporário
        echo -e "$tamanho\t$caminho" >> "$temp_file"
    done

echo -e "\r${GREEN}✓ Escaneamento concluído! Total de arquivos encontrados: $contador_progresso${NC}                    "
echo ""

# Verificar se encontrou arquivos
if [[ $contador_progresso -eq 0 ]]; then
    echo -e "${RED}Nenhum arquivo regular foi encontrado em $source_path${NC}"
    echo -e "${YELLOW}Nota: Diretórios como /dev, /proc, /sys contêm apenas arquivos especiais (dispositivos), não arquivos regulares.${NC}"
    exit 0
fi

# Ordenar por tamanho (maior primeiro) e pegar os N maiores
echo -e "${CYAN}=== TOP $quantidade ARQUIVOS MAIS PESADOS ===${NC}"
echo ""

contador=1
tamanho_total=0

# Ordenar e processar os maiores arquivos
sort -rn "$temp_file" | head -n "$quantidade" | \
    while IFS=$'\t' read -r tamanho caminho; do
        # Verificar se o tamanho é válido
        if [[ -z "$tamanho" ]] || [[ "$tamanho" == "0" ]]; then
            continue
        fi
        
        # Calcular tamanhos em diferentes unidades
        tamanho_kb=$(echo "scale=2; $tamanho / 1024" | bc)
        tamanho_mb=$(echo "scale=2; $tamanho / 1048576" | bc)
        tamanho_gb=$(echo "scale=2; $tamanho / 1073741824" | bc)
        
        # Escolher unidade apropriada
        if (( $(echo "$tamanho_gb >= 1" | bc -l) )); then
            tamanho_formatado="${tamanho_gb} GB"
        elif (( $(echo "$tamanho_mb >= 1" | bc -l) )); then
            tamanho_formatado="${tamanho_mb} MB"
        else
            tamanho_formatado="${tamanho_kb} KB"
        fi
        
        echo -e "${YELLOW}[$contador]${NC} ${GREEN}$tamanho_formatado${NC} - ${WHITE}$caminho${NC}"
        
        # Acumular tamanho total
        tamanho_total=$((tamanho_total + tamanho))
        contador=$((contador + 1))
    done

echo ""
echo -e "${CYAN}=== RESUMO ===${NC}"

# Calcular total em diferentes unidades
total_kb=$(echo "scale=2; $tamanho_total / 1024" | bc)
total_mb=$(echo "scale=2; $tamanho_total / 1048576" | bc)
total_gb=$(echo "scale=2; $tamanho_total / 1073741824" | bc)

if (( $(echo "$total_gb >= 1" | bc -l) )); then
    echo -e "${YELLOW}Tamanho total dos $quantidade maiores arquivos: $total_gb GB${NC}"
elif (( $(echo "$total_mb >= 1" | bc -l) )); then
    echo -e "${YELLOW}Tamanho total dos $quantidade maiores arquivos: $total_mb MB${NC}"
else
    echo -e "${YELLOW}Tamanho total dos $quantidade maiores arquivos: $total_kb KB${NC}"
fi

echo -e "${DARKGRAY}Total de arquivos escaneados: $contador_progresso${NC}"
echo ""

#!/bin/bash

# Cores para output
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color

echo -e "${CYAN}--- Listador de Arquivos Mais Pesados ---${NC}"
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
echo -e "${YELLOW}Isso pode levar alguns minutos dependendo do tamanho do diretório...${NC}"
echo ""

# 3. Buscar e ordenar arquivos por tamanho
# Usar find + du para obter tamanhos, ordenar e pegar os maiores
echo -e "${CYAN}=== TOP $quantidade ARQUIVOS MAIS PESADOS ===${NC}"
echo ""

contador=1
tamanho_total=0

# Encontrar arquivos, obter tamanho em bytes, ordenar e pegar os N maiores
find "$source_path" -type f -exec du -b {} + 2>/dev/null | \
    sort -rn | \
    head -n "$quantidade" | \
    while IFS=$'\t' read -r tamanho caminho; do
        # Calcular tamanhos em MB e GB
        tamanho_mb=$(echo "scale=2; $tamanho / 1048576" | bc)
        tamanho_gb=$(echo "scale=2; $tamanho / 1073741824" | bc)
        
        # Escolher unidade apropriada
        if (( $(echo "$tamanho_gb >= 1" | bc -l) )); then
            tamanho_formatado="${tamanho_gb} GB"
        else
            tamanho_formatado="${tamanho_mb} MB"
        fi
        
        echo -e "${YELLOW}[$contador]${NC} ${GREEN}$tamanho_formatado${NC} - ${WHITE}$caminho${NC}"
        
        # Acumular tamanho total
        tamanho_total=$((tamanho_total + tamanho))
        contador=$((contador + 1))
    done

echo ""
echo -e "${CYAN}=== RESUMO ===${NC}"

# Calcular total em MB e GB
total_mb=$(echo "scale=2; $tamanho_total / 1048576" | bc)
total_gb=$(echo "scale=2; $tamanho_total / 1073741824" | bc)

if (( $(echo "$total_gb >= 1" | bc -l) )); then
    echo -e "${YELLOW}Tamanho total dos $quantidade maiores arquivos: $total_gb GB${NC}"
else
    echo -e "${YELLOW}Tamanho total dos $quantidade maiores arquivos: $total_mb MB${NC}"
fi

echo ""

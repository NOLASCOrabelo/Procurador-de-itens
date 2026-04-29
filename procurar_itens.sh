#!/bin/bash

# Cores para output
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
RED='\033[0;31m'
DARKGRAY='\033[0;90m'
NC='\033[0m' # No Color

echo -e "${CYAN}--- Procurador de Itens por Texto no Título ---${NC}"
echo ""

# 1. Obter os termos
read -p "Digite os termos que deseja procurar (separados por vírgula ou espaço): " termos_str

# Verificar se a entrada está vazia
if [[ -z "${termos_str// }" ]]; then
    echo -e "${RED}AVISO: Nenhum termo fornecido. Encerrando.${NC}"
    exit 1
fi

# Extrair termos, remover espaços em branco e duplicatas
# Substituir vírgulas por espaços e dividir em array
termos_str="${termos_str//,/ }"
declare -a termos_array
declare -A termos_unique

# Processar cada termo: trim e remover duplicatas
for termo in $termos_str; do
    # Trim (remover espaços no início e fim)
    termo=$(echo "$termo" | xargs)
    
    # Adicionar apenas se não estiver vazio e não for duplicado
    if [[ -n "$termo" ]] && [[ -z "${termos_unique[$termo]}" ]]; then
        termos_array+=("$termo")
        termos_unique["$termo"]=1
    fi
done

# Verificar se há termos válidos
if [[ ${#termos_array[@]} -eq 0 ]]; then
    echo -e "${RED}AVISO: Nenhum termo válido foi identificado. Encerrando.${NC}"
    exit 1
fi

# Mostrar termos a procurar
echo -e "${YELLOW}Termos a procurar: ${termos_array[*]}${NC}"
echo ""

# 2. Obter o local de busca
read -p "Digite o caminho completo da pasta onde deseja procurar (Ex: /home/user ou /mnt/data): " source_path

# Verificar se o caminho existe
if [[ ! -d "$source_path" ]]; then
    echo -e "${RED}AVISO: O caminho '$source_path' não existe ou não está acessível.${NC}"
    exit 1
fi

# Garantir barra no final
if [[ ! "$source_path" =~ /$ ]]; then
    source_path="${source_path}/"
fi

# 3. Varredura
echo ""
echo -e "${CYAN}Iniciando a busca em $source_path ...${NC}"
echo -e "${YELLOW}Este processo buscará os termos APENAS nos TÍTULOS dos arquivos e pastas.${NC}"
echo -e "${YELLOW}Extensões serão ignoradas!${NC}"
echo ""

# Inicializar array associativo para armazenar resultados
declare -A encontrados
for termo in "${termos_array[@]}"; do
    encontrados["$termo"]=""
done

counter=0

# Função para remover extensão do arquivo
remove_extension() {
    local filename="$1"
    local basename=$(basename "$filename")
    # Remover extensão (tudo após o último ponto)
    echo "${basename%.*}"
}

# Função para verificar se um item já está na lista
contains_item() {
    local item="$1"
    local list="$2"
    
    if [[ "$list" == *"|$item|"* ]]; then
        return 0  # true - contém
    else
        return 1  # false - não contém
    fi
}

# Usar find para varrer recursivamente (equivalente ao dir /s /b do Windows)
# Redirecionar erros para /dev/null para ignorar permissões negadas
while IFS= read -r file_path; do
    ((counter++))
    
    # PROGRESSO: Aviso para o usuário ver que não travou
    if (( counter % 2000 == 0 )); then
        echo -e "${DARKGRAY}PROGRESSO: Processando... $counter itens verificados até agora.${NC}"
    fi
    
    # Pega apenas o nome do arquivo, removendo a extensão
    title_only=$(remove_extension "$file_path")
    
    # Converter para minúsculas para comparação case-insensitive
    title_lower=$(echo "$title_only" | tr '[:upper:]' '[:lower:]')
    
    # Verificar cada termo
    for termo in "${termos_array[@]}"; do
        termo_lower=$(echo "$termo" | tr '[:upper:]' '[:lower:]')
        
        # Verifica se o termo está contido no título (case-insensitive)
        if [[ "$title_lower" == *"$termo_lower"* ]]; then
            # Evitar mostrar itens duplicados
            if ! contains_item "$file_path" "${encontrados[$termo]}"; then
                # Adicionar ao array de resultados (usando | como delimitador)
                if [[ -z "${encontrados[$termo]}" ]]; then
                    encontrados["$termo"]="|$file_path|"
                else
                    encontrados["$termo"]="${encontrados[$termo]}$file_path|"
                fi
                
                # SUCESSO OCORRIDO AGORA:
                echo -e "${GREEN} -> SUCESSO! Encontrei o termo '$termo' neste título!${NC}"
                echo -e "${GREEN}    Caminho: $file_path${NC}"
            fi
        fi
    done
done <<< "$(find "$source_path" \( -type f -o -type d \) 2>/dev/null)"

echo ""
echo -e "${CYAN}=== Busca concluída! Total de itens escaneados: $counter ===${NC}"
echo ""

# 4. Resumo Final (Avisos de Certo / Não Certo)
echo -e "${CYAN}--- RESULTADO FINAL ---${NC}"
echo ""

for termo in "${termos_array[@]}"; do
    # Contar quantos itens foram encontrados
    if [[ -z "${encontrados[$termo]}" ]]; then
        qdt=0
    else
        # Contar o número de pipes (cada item tem um pipe antes e depois)
        qdt=$(echo "${encontrados[$termo]}" | grep -o "|" | wc -l)
        qdt=$((qdt / 2))
    fi
    
    if [[ $qdt -gt 0 ]]; then
        # QUANDO DER CERTO
        echo -e "${GREEN}SUCESSO: O termo '$termo' foi encontrado em $qdt item(ns).${NC}"
    else
        # QUANDO NÃO DER CERTO / NÃO ENCONTRAR
        echo -e "${RED}NÃO ENCONTRADO: O termo '$termo' NÃO foi achado em lugar nenhum nesta pasta.${NC}"
    fi
done

echo ""

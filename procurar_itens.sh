#!/bin/bash

echo "--- Procurador e Movedor de Itens ---"

# 1. Obter os Asset IDs
read -p "Digite os Asset IDs que deseja procurar (separados por vírgula ou espaço): " asset_ids_str

if [ -z "$asset_ids_str" ]; then
    echo "Nenhum Asset ID fornecido. Encerrando."
    exit 1
fi

# Transformar a string recebida num bash array (substituindo vírgulas também por espaços)
asset_ids_str=${asset_ids_str//,/ }
read -ra ASSETS <<< "$asset_ids_str"

if [ ${#ASSETS[@]} -eq 0 ]; then
    echo "Nenhum ID válido fornecido. Encerrando."
    exit 1
fi

echo "Asset IDs a procurar: ${ASSETS[*]}"

# 2. Obter o diretório raiz de busca
read -p "Digite o caminho absoluto da pasta onde as buscas devem começar: " source_dir
if [ ! -d "$source_dir" ]; then
    echo "Erro: A pasta de origem '$source_dir' não existe."
    exit 1
fi

# 3. Obter a pasta de destino (N3)
read -p "Digite o caminho absoluto da pasta de destino (N3): " dest_dir
if [ ! -d "$dest_dir" ]; then
    read -p "A pasta de destino '$dest_dir' não existe. Deseja criá-la? (s/n): " create
    if [[ "$create" == "s" || "$create" == "S" ]]; then
        mkdir -p "$dest_dir" || { echo "Erro ao criar pasta de destino."; exit 1; }
        echo "Pasta de destino criada com sucesso."
    else
        echo "Operação cancelada."
        exit 1
    fi
fi

# 4. Realizar a busca e movimentação
echo -e "\nIniciando a busca..."
itens_movidos=0

# Loop em cada Asset ID procurado individualmente
for asset in "${ASSETS[@]}"; do
    
    # O 'find' procura recursivamente, ignorando pastas, focado em arquivos contendo o Asset ID no nome.
    # O format -print0 lida corretamente com os caminhos que possam possuir espaços no nome.
    while IFS= read -r -d $'\0' file; do
        filename=$(basename "$file")
        dest_file="$dest_dir/$filename"
        
        # Evitar sobreposição de arquivo com mesmo nome
        if [ -f "$dest_file" ]; then
             echo "Atenção: O arquivo '$filename' já existe no destino. Ignorando a movimentação."
        else
             mv "$file" "$dest_file"
             if [ $? -eq 0 ]; then
                 echo "MOVIDO: '$filename' -> '$dest_dir'"
                 ((itens_movidos++))
             else
                 echo "ERRO ao tentar mover: '$filename'"
             fi
        fi
    done < <(find "$source_dir" -type f -name "*${asset}*" -print0)

done

echo -e "\n--- Resumo ---"
echo "Total de itens movidos com sucesso: $itens_movidos"
echo "Operação concluída!"

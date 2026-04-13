import os
import shutil

def search_and_move_assets():
    print("--- Procurador e Movedor de Itens ---")
    
    # 1. Obter os Asset IDs
    asset_ids_str = input("Digite os Asset IDs que deseja procurar (separados por vírgula): ")
    if not asset_ids_str.strip():
        print("Nenhum Asset ID fornecido. Encerrando.")
        return
        
    # Limpar e criar uma lista de IDs (removendo espaços em branco extras)
    asset_ids = [aid.strip() for aid in asset_ids_str.split(',') if aid.strip()]
    if not asset_ids:
        print("Nenhum ID válido fornecido. Encerrando.")
        return
        
    print(f"Asset IDs a procurar: {asset_ids}")

    # 2. Obter o diretório raiz de busca
    source_dir = input("Digite o caminho da pasta onde as buscas devem começar (ex: C:\\Caminho\\Da\\Pasta): ")
    if not os.path.isdir(source_dir):
        print("Erro: A pasta de origem fornecida não existe. Verifique o caminho e tente novamente.")
        return

    # 3. Obter a pasta de destino (N3)
    dest_dir = input("Digite o caminho da pasta de destino (N3) (ex: C:\\Caminho\\Para\\N3): ")
    if not os.path.exists(dest_dir):
        create = input(f"A pasta de destino '{dest_dir}' não existe. Deseja criá-la? (s/n): ")
        if create.lower() == 's':
            try:
                os.makedirs(dest_dir)
                print("Pasta de destino criada com sucesso.")
            except Exception as e:
                print(f"Erro ao criar pasta de destino: {e}")
                return
        else:
            print("Operação cancelada.")
            return

    # 4. Realizar a busca pelas pastas e subpastas recursivamente
    print("\nIniciando a busca...")
    itens_movidos = 0
    itens_encontrados_ids = set()

    for root, dirs, files in os.walk(source_dir):
        for file in files:
            # Verifica se algum dos Asset IDs faz parte do nome do arquivo
            for asset_id in asset_ids:
                if asset_id in file:
                    source_path = os.path.join(root, file)
                    dest_path = os.path.join(dest_dir, file)
                    
                    # Evitar de mover um arquivo sobre outro com o mesmo nome
                    if os.path.exists(dest_path):
                        print(f"Atenção: O arquivo '{file}' já existe no destino. Ignorando a movimentação para não sobrescrever.")
                        continue
                        
                    try:
                        shutil.move(source_path, dest_path)
                        print(f"MOVIDO: '{file}' (de '{root}' para '{dest_dir}')")
                        itens_movidos += 1
                        itens_encontrados_ids.add(asset_id)
                    except Exception as e:
                        print(f"ERRO ao mover '{file}' de '{root}': {e}")

    # 5. Apresentar o resumo da operação final
    print("\n--- Resumo da Operação ---")
    print(f"Total de arquivos movidos com sucesso: {itens_movidos}")
    
    # Verifica quais IDs solicitados não tiveram nenhum arquivo correspondente encontrado
    itens_nao_encontrados = set(asset_ids) - itens_encontrados_ids
    if itens_nao_encontrados:
        print(f"ATENÇÃO - Os seguintes Asset IDs NÃO foram encontrados em lugar nenhum:")
        for no_id in itens_nao_encontrados:
            print(f"  - {no_id}")
    else:
        print("Sucesso: Pelo menos um arquivo foi encontrado e movido para CADA um dos Asset IDs fornecidos!")

if __name__ == "__main__":
    search_and_move_assets()

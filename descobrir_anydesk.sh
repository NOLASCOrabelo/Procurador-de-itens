#!/bin/bash

# Cores para output
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
RED='\033[0;31m'
WHITE='\033[1;37m'
DARKGRAY='\033[0;90m'
NC='\033[0m' # No Color

echo -e "${CYAN}=== Descobridor de AnyDesk na Rede Local ===${NC}"
echo ""

# Verificar se nmap está instalado
if ! command -v nmap &> /dev/null; then
    echo -e "${YELLOW}AVISO: nmap não está instalado. Instalando...${NC}"
    echo -e "${YELLOW}Execute: sudo apt-get install nmap (Debian/Ubuntu) ou sudo yum install nmap (RedHat/CentOS)${NC}"
    echo ""
fi

# Função para obter ID do AnyDesk local
get_local_anydesk_id() {
    local anydesk_paths=(
        "$HOME/.anydesk/service.conf"
        "/etc/anydesk/service.conf"
        "$HOME/.config/anydesk/service.conf"
    )
    
    for path in "${anydesk_paths[@]}"; do
        if [[ -f "$path" ]]; then
            local id=$(grep -oP 'ad\.anynet\.id=\K\d+' "$path" 2>/dev/null)
            if [[ -n "$id" ]]; then
                echo "$id"
                return 0
            fi
        fi
    done
    
    return 1
}

# Função para verificar se AnyDesk está rodando em um IP
check_anydesk_port() {
    local ip=$1
    timeout 1 bash -c "echo >/dev/tcp/$ip/7070" 2>/dev/null
    return $?
}

# 1. Obter ID local
echo -e "${YELLOW}[LOCAL] Verificando AnyDesk local...${NC}"
echo ""

local_id=$(get_local_anydesk_id)

if [[ -n "$local_id" ]]; then
    echo -e "${GREEN}✓ AnyDesk ID Local: ${WHITE}$local_id${NC}"
else
    echo -e "${RED}✗ AnyDesk não encontrado localmente${NC}"
fi

echo ""
echo -e "${DARKGRAY}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# 2. Descobrir rede local
echo -e "${YELLOW}[REDE] Descobrindo dispositivos na rede local...${NC}"
echo ""

# Obter IP local
local_ip=$(ip route get 1 | awk '{print $7; exit}' 2>/dev/null)

if [[ -z "$local_ip" ]]; then
    local_ip=$(hostname -I | awk '{print $1}')
fi

if [[ -z "$local_ip" ]]; then
    echo -e "${RED}Não foi possível determinar o IP local.${NC}"
    exit 1
fi

echo -e "${CYAN}IP Local: $local_ip${NC}"

# Extrair os 3 primeiros octetos
network_base=$(echo "$local_ip" | cut -d. -f1-3)
echo -e "${CYAN}Escaneando rede: $network_base.0/24${NC}"
echo ""

# Perguntar se quer escanear toda a rede
read -p "Deseja escanear toda a rede (1-254)? Isso pode levar alguns minutos. (S/N): " scan_all

if [[ "$scan_all" == "S" ]] || [[ "$scan_all" == "s" ]]; then
    start_ip=1
    end_ip=254
else
    read -p "IP inicial (1-254): " start_ip
    read -p "IP final (1-254): " end_ip
fi

echo ""
echo -e "${YELLOW}Escaneando IPs de $network_base.$start_ip até $network_base.$end_ip ...${NC}"
echo -e "${YELLOW}Procurando por AnyDesk (porta 7070)...${NC}"
echo ""

# Criar arquivo temporário para resultados
temp_file=$(mktemp)
trap "rm -f $temp_file" EXIT

contador=0
encontrados=0

for i in $(seq $start_ip $end_ip); do
    ip="$network_base.$i"
    ((contador++))
    
    # Mostrar progresso
    if (( contador % 10 == 0 )); then
        echo -e "${DARKGRAY}Progresso: $contador/$((end_ip - start_ip + 1)) IPs escaneados...${NC}"
    fi
    
    # Verificar se AnyDesk está rodando (porta 7070)
    if check_anydesk_port "$ip"; then
        ((encontrados++))
        
        # Tentar resolver hostname
        hostname=$(host "$ip" 2>/dev/null | awk '{print $NF}' | sed 's/\.$//')
        if [[ -z "$hostname" ]] || [[ "$hostname" == "3(NXDOMAIN)" ]]; then
            hostname="Não resolvido"
        fi
        
        # Salvar resultado
        echo "$ip|$hostname" >> "$temp_file"
        
        echo ""
        echo -e "${GREEN}✓ AnyDesk encontrado!${NC}"
        echo -e "  ${WHITE}IP: $ip${NC}"
        echo -e "  ${WHITE}Hostname: $hostname${NC}"
        echo -e "  ${YELLOW}AnyDesk ID: Não acessível remotamente (requer acesso SSH/RDP)${NC}"
        echo ""
    fi
done

echo ""
echo -e "${DARKGRAY}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# 3. Resumo final
echo -e "${CYAN}=== RESUMO ===${NC}"
echo ""

if [[ $encontrados -eq 0 ]]; then
    echo -e "${YELLOW}Nenhum AnyDesk encontrado na rede.${NC}"
else
    echo -e "${GREEN}Total de AnyDesks encontrados: $encontrados${NC}"
    echo ""
    
    echo -e "${WHITE}IP              | Hostname${NC}"
    echo -e "${DARKGRAY}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    
    while IFS='|' read -r ip hostname; do
        printf "${WHITE}%-15s${NC} | ${WHITE}%s${NC}\n" "$ip" "$hostname"
    done < "$temp_file"
    
    # Salvar em arquivo
    output_file="anydesk_descobertos_$(date +%Y%m%d_%H%M%S).txt"
    cp "$temp_file" "$output_file"
    echo ""
    echo -e "${GREEN}Resultados salvos em: $output_file${NC}"
fi

echo ""
echo -e "${YELLOW}NOTA: Para obter os IDs remotos, você precisa:${NC}"
echo -e "${YELLOW}  1. Acesso SSH/RDP à máquina remota${NC}"
echo -e "${YELLOW}  2. Ler o arquivo de configuração do AnyDesk${NC}"
echo -e "${YELLOW}     Linux: ~/.anydesk/service.conf ou /etc/anydesk/service.conf${NC}"
echo -e "${YELLOW}     Windows: %APPDATA%\\AnyDesk\\service.conf${NC}"
echo ""

# Oferecer script para obter IDs via SSH
echo -e "${CYAN}Deseja gerar um script para obter IDs via SSH? (S/N)${NC}"
read -p "> " gerar_script

if [[ "$gerar_script" == "S" ]] || [[ "$gerar_script" == "s" ]]; then
    cat > obter_ids_ssh.sh << 'EOF'
#!/bin/bash
# Script para obter IDs do AnyDesk via SSH

if [[ $# -lt 2 ]]; then
    echo "Uso: $0 <usuario> <ip>"
    echo "Exemplo: $0 admin 192.168.1.100"
    exit 1
fi

usuario=$1
ip=$2

echo "Conectando em $usuario@$ip ..."

# Tentar obter ID do AnyDesk
anydesk_id=$(ssh "$usuario@$ip" "grep -oP 'ad\.anynet\.id=\K\d+' ~/.anydesk/service.conf /etc/anydesk/service.conf 2>/dev/null | head -1")

if [[ -n "$anydesk_id" ]]; then
    echo "✓ AnyDesk ID: $anydesk_id"
else
    echo "✗ Não foi possível obter o ID do AnyDesk"
fi
EOF
    
    chmod +x obter_ids_ssh.sh
    echo -e "${GREEN}Script criado: obter_ids_ssh.sh${NC}"
    echo -e "${YELLOW}Uso: ./obter_ids_ssh.sh usuario ip${NC}"
    echo -e "${YELLOW}Exemplo: ./obter_ids_ssh.sh admin 192.168.1.100${NC}"
fi

echo ""

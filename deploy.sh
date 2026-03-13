#!/bin/bash
# deploy.sh - CREATIVE LIONS - Script de Gestão VPS
# whaticket-community-master

# Cores para o terminal
GREEN='\033[0;32m'
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m' # No Color

set -e

display_header() {
    clear
    echo -e "${CYAN}====================================================${NC}"
    echo -e "${CYAN}               CREATIVE LIONS                       ${NC}"
    echo -e "${CYAN}====================================================${NC}"
}

menu() {
    display_header
    echo -e "${GREEN}Selecione uma opção:${NC}"
    echo "1) LIMPAR VPS (Remover containers e volumes antigos)"
    echo "2) INSTALAÇÃO E UPDATE DOCKER"
    echo "3) INSTALAÇÃO COMPLETA"
    echo "4) ATUALIZAÇÃO (Front-end e Back-end)"
    echo "0) Sair"
    echo ""
    read -p "Opção: " OPTION
}

limpar_vps() {
    echo -e "${RED}⚠️ Limpando VPS... Isso removerá containers e volumes!${NC}"
    docker compose down -v || true
    docker system prune -af --volumes || true
    echo -e "${GREEN}✅ VPS Limpa!${NC}"
    read -p "Pressione Enter para voltar ao menu..."
}

instalar_docker() {
    echo -e "${CYAN}📥 Instalando/Atualizando Docker e Docker Compose...${NC}"
    sudo apt-get update
    sudo apt-get install -y ca-certificates curl gnupg lsb-release
    sudo mkdir -p /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg || true
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt-get update
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
    echo -e "${GREEN}✅ Docker instalado com sucesso!${NC}"
    read -p "Pressione Enter para voltar ao menu..."
}

instalacao_completa() {
    echo -e "${CYAN}🚀 Iniciando Instalação Completa...${NC}"
    
    if [ ! -f .env ]; then
        echo -e "${CYAN}📝 Criando arquivo .env padrão...${NC}"
        cp .env.example .env
        echo -e "${RED}⚠️ Por favor, ajuste as variáveis em .env antes de rodar novamente se necessário.${NC}"
    fi

    echo -e "${CYAN}🔨 Construindo e iniciando containers...${NC}"
    docker compose build
    docker compose up -d

    echo -e "${CYAN}⏳ Aguardando banco de dados (15s)...${NC}"
    sleep 15

    echo -e "${CYAN}🗄️ Executando Migrations e Seeds...${NC}"
    docker compose exec backend npx sequelize db:migrate
    docker compose exec backend npx sequelize db:seed:all

    echo -e "${GREEN}✅ Instalação concluída com sucesso!${NC}"
    docker compose ps
    read -p "Pressione Enter para voltar ao menu..."
}

atualizar_sistema() {
    echo -e "${CYAN}🔄 Atualizando Front-end e Back-end...${NC}"
    
    echo -e "${CYAN}📥 Baixando novas alterações do Git...${NC}"
    git pull origin main || echo "⚠️ Apenas continuando localmente..."

    echo -e "${CYAN}🔨 Reconstruindo containers...${NC}"
    docker compose build
    docker compose up -d

    echo -e "${CYAN}⏳ Aplicando possíveis migrations (5s)...${NC}"
    sleep 5
    docker compose exec backend npx sequelize db:migrate || echo "⚠️ Nenhuma migration nova."

    echo -e "${GREEN}✅ Sistema atualizado!${NC}"
    docker compose ps
    read -p "Pressione Enter para voltar ao menu..."
}

while true; do
    menu
    case $OPTION in
        1) limpar_vps ;;
        2) instalar_docker ;;
        3) instalacao_completa ;;
        4) atualizar_sistema ;;
        0) exit 0 ;;
        *) echo -e "${RED}Opção inválida!${NC}" ; sleep 2 ;;
    esac
done

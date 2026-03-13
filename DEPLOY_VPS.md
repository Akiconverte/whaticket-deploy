# Deploy VPS - Whaticket (baseado no seu localhost)
# Copia exatamente o que está rodando agora

# 1. Na VPS: preparar estrutura
mkdir -p /opt/whaticket
cd /opt/whaticket

# 2. Copiar arquivos do seu localhost para VPS
# Execute no seu localhost (Windows PowerShell):
# scp -r "C:\Users\w11\Downloads\Waticket\whaticket-community-master\*" root@SUA_VPS_IP:/opt/whaticket/

# 3. Na VPS: ajustar .env.production
nano .env.production
# Substitua SEU_DOMINIO_OU_IP_VPS pelo IP ou domínio real da VPS
# Ex: BACKEND_URL=http://200.100.50.25
# Ex: FRONTEND_URL=http://200.100.50.25:3000
# Ex: REACT_APP_BACKEND_URL=http://200.100.50.25:8080/

# 4. Na VPS: instalar Docker e Docker Compose (se ainda não tiver)
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh
sudo usermod -aG docker $USER
# Re-login ou: newgrp docker

# Docker Compose (se não tiver)
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# 5. Na VPS: construir e subir (exatamente como no seu localhost)
cd /opt/whaticket
docker compose build
docker compose up -d

# 6. Na VPS: rodar seed do banco (só na primeira vez)
docker compose exec backend npx sequelize db:seed:all

# 7. Verificar status
docker compose ps
docker compose logs -f backend

# 8. Acessar
# Frontend: http://SUA_VPS_IP:3000
# Backend API: http://SUA_VPS_IP:8080
# n8n (se usar): http://SUA_VPS_IP:5679

# IMPORTANTE: Firewall (se usar ufw)
sudo ufw allow 3000
sudo ufw allow 3001
sudo ufw allow 8080
sudo ufw allow 5679
sudo ufw allow 3306  # se precisar acessar MySQL de fora (cuidado)

# OBS: SSL/HTTPS
# Se precisar HTTPS, configure os certificados em ./ssl/certs/backend e ./ssl/certs/frontend
# O nginx no container frontend já está pronto para ler de /etc/nginx/ssl

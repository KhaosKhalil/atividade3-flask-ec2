#!/usr/bin/env bash
# Prepara a instancia EC2 (Ubuntu) e coloca o app Flask no ar na porta 5000.
#
# Uso, dentro da instancia, a partir da pasta do projeto:
#   bash deploy/setup_ec2.sh
# (opcional: passe outro nome para o rodape como primeiro argumento)
#
# O script:
#   1. atualiza os pacotes do sistema (Etapa 2)
#   2. instala Python, venv e pip (Etapa 2)
#   3. cria e usa o ambiente virtual (Etapa 3)
#   4. instala as dependencias do requirements.txt (Etapa 4)
#   5. cria um servico systemd com Gunicorn em 0.0.0.0:5000, que continua
#      rodando depois que voce fecha o SSH e volta sozinho apos reboot (Etapa 6)
set -euo pipefail

NOME_ALUNO="${1:-Khalil Ayoub de Lima Krayem}"
PROJETO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
USUARIO="$(whoami)"
SERVICO="webserver"

echo ">> Projeto em: $PROJETO_DIR (usuario: $USUARIO)"

echo ">> [Etapa 2] Atualizando pacotes do sistema..."
sudo apt-get update -y
sudo DEBIAN_FRONTEND=noninteractive apt-get upgrade -y

echo ">> [Etapa 2] Instalando Python, venv, pip e git..."
sudo apt-get install -y python3 python3-venv python3-pip git

echo ">> [Etapa 3] Criando ambiente virtual..."
cd "$PROJETO_DIR"
if [ ! -d venv ]; then
    python3 -m venv venv
fi
# shellcheck disable=SC1091
source venv/bin/activate

echo ">> [Etapa 4] Instalando dependencias do requirements.txt..."
pip install --upgrade pip
pip install -r requirements.txt
echo ">> Bibliotecas instaladas no venv:"
pip list

echo ">> [Etapa 6] Criando servico systemd '$SERVICO'..."
sudo tee /etc/systemd/system/${SERVICO}.service > /dev/null <<EOF
[Unit]
Description=Servidor Web Flask (Atividade 3)
After=network.target

[Service]
User=${USUARIO}
WorkingDirectory=${PROJETO_DIR}
Environment="NOME_ALUNO=${NOME_ALUNO}"
ExecStart=${PROJETO_DIR}/venv/bin/gunicorn --workers 2 --bind 0.0.0.0:5000 app:app
Restart=always

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable "$SERVICO"
sudo systemctl restart "$SERVICO"

sleep 2
sudo systemctl --no-pager status "$SERVICO" | head -n 5

IP_PUBLICO="$(curl -s --max-time 3 https://checkip.amazonaws.com || echo 'IP_PUBLICO')"
echo
echo ">> Pronto! Teste no navegador: http://${IP_PUBLICO}:5000"

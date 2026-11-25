# Atividade 3 – Deploy de Servidor Web Flask na AWS EC2

Aplicação Flask com herança de templates (`base.html`), publicada em uma instância EC2 Ubuntu e acessível em `http://IP_PUBLICO:5000`.

## Estrutura do projeto

```
atividade3-flask-ec2/
├── venv/                  # ambiente virtual (não vai para o Git)
├── app.py                 # cria o app Flask e as rotas
├── requirements.txt       # dependências com versões
├── templates/
│   ├── base.html          # cabeçalho, menu, conteúdo e rodapé comuns
│   ├── index.html         # herda base.html
│   ├── sobre.html         # herda base.html
│   ├── contato.html       # herda base.html
│   └── 404.html           # herda base.html
├── static/
│   ├── css/style.css
│   ├── js/main.js
│   └── img/logo.svg
└── deploy/
    ├── setup_ec2.sh       # prepara a EC2 e sobe o app como serviço
    └── webserver.service  # modelo do serviço systemd
```

## Nome no rodapé

O rodapé mostra o nome definido em `app.py` (`NOME_ALUNO`): **Khalil Ayoub de Lima Krayem**.

## Rodar localmente (Windows)

```powershell
python -m venv venv
.\venv\Scripts\Activate.ps1
pip install -r requirements.txt
python app.py
```

Abra http://localhost:5000.

---

## Passo a passo do deploy na AWS

### Etapa 1 – Criar a instância EC2 (no console da AWS / AWS Academy)

1. Abra o serviço **EC2** e clique em **Launch instance**.
2. **Name:** `webServer-seunome`.
3. **AMI:** Ubuntu Server (ex.: Ubuntu Server 24.04 LTS).
4. **Instance type:** um tipo elegível ao nível gratuito com 2 vCPUs e 4 GB de RAM (ex.: `t3.medium` no AWS Academy, ou o que o professor indicar).
5. **Key pair:** clique em **Create new key pair**, tipo RSA, formato `.pem`. Guarde o arquivo baixado em lugar seguro. **Nunca** envie o `.pem` para o GitHub (o `.gitignore` já bloqueia `*.pem`).
6. **Network settings > Security Group:** crie um novo com estas regras de entrada:

   | Tipo       | Protocolo | Porta | Origem             |
   |------------|-----------|-------|--------------------|
   | SSH        | TCP       | 22    | My IP (ou 0.0.0.0/0) |
   | Custom TCP | TCP       | 5000  | 0.0.0.0/0          |

7. Clique em **Launch instance**. Quando estiver *Running*, anote o **Public IPv4 address**.

### Etapa 2 – Acessar e preparar o servidor

Conecte pelo **EC2 Instance Connect** (botão *Connect* no console) ou pelo terminal:

```powershell
ssh -i C:\caminho\para\sua-chave.pem ubuntu@IP_PUBLICO
```

> No Windows, se o SSH reclamar de permissão do `.pem`, rode no PowerShell:
> `icacls sua-chave.pem /inheritance:r /grant:r "$($env:USERNAME):(R)"`

Dentro da instância:

```bash
sudo apt update && sudo apt upgrade -y
sudo apt install -y python3 python3-venv python3-pip git
```

### Etapa 3 – Pasta do projeto e ambiente virtual

Suba este projeto para um repositório no GitHub e, na instância:

```bash
cd ~
git clone https://github.com/SEU_USUARIO/SEU_REPOSITORIO.git atividade3-flask-ec2
cd atividade3-flask-ec2
python3 -m venv venv
source venv/bin/activate
```

### Etapa 4 – Dependências

```bash
pip install -r requirements.txt
pip list          # confira Flask, Gunicorn etc. dentro do venv
which python      # deve apontar para .../atividade3-flask-ec2/venv/bin/python
```

### Etapa 5 – Template base

Já está pronto: `templates/base.html` tem cabeçalho, menu, `{% block content %}`, `{% block title %}` e rodapé com nome + atividade. As outras páginas usam `{% extends "base.html" %}`.

### Etapa 6 – Executar o servidor e manter no ar

**Opção A (recomendada) – script automático com systemd.** Faz as etapas 2, 3 (venv), 4 e 6 de uma vez e mantém o app rodando mesmo depois de fechar o SSH (e após reiniciar a instância):

```bash
cd ~/atividade3-flask-ec2
bash deploy/setup_ec2.sh
```

Comandos úteis:

```bash
sudo systemctl status webserver     # ver se está rodando
sudo systemctl restart webserver    # reiniciar após mudar o código (git pull)
sudo journalctl -u webserver -f     # ver logs
```

**Opção B – manual com `nohup`** (mais simples, mas não volta sozinho após reboot):

```bash
cd ~/atividade3-flask-ec2
source venv/bin/activate
nohup gunicorn --workers 2 --bind 0.0.0.0:5000 app:app > app.log 2>&1 &
```

Para parar: `pkill gunicorn`.

> O `0.0.0.0` faz o Flask aceitar conexões externas. Com `127.0.0.1` só a própria instância acessaria.

### Teste e entrega

No navegador do seu computador: `http://IP_PUBLICO:5000`

Envie esse link pelo Teams (Atividade 3). A instância precisa estar ligada na hora da correção.

## Problemas comuns

- **Página não abre:** confira a regra da porta 5000 no Security Group e se o serviço está ativo (`systemctl status webserver`). Use `http://`, não `https://`.
- **IP mudou:** ao parar e iniciar a instância o IP público muda. O serviço volta sozinho; só envie o novo link.
- **AWS Academy:** o laboratório expira após 4 horas. Deixe o lab ativo no horário da correção.

"""Atividade 3 - Deploy de Servidor Web Flask em uma Instancia EC2 na AWS.

Arquivo principal: cria o app Flask e define as rotas.
"""
import os
from datetime import datetime

from flask import Flask, render_template

app = Flask(__name__)

# Dados exibidos no rodape (base.html).
NOME_ALUNO = os.environ.get("NOME_ALUNO", "Khalil Ayoub de Lima Krayem")
ATIVIDADE = "Atividade 3 - Deploy Flask na AWS EC2"


@app.context_processor
def dados_globais():
    """Variaveis disponiveis em todos os templates."""
    return {
        "nome_aluno": NOME_ALUNO,
        "atividade": ATIVIDADE,
        "ano": datetime.now().year,
    }


@app.route("/")
def index():
    return render_template("index.html")


@app.route("/sobre")
def sobre():
    return render_template("sobre.html")


@app.route("/contato")
def contato():
    return render_template("contato.html")


@app.errorhandler(404)
def pagina_nao_encontrada(erro):
    return render_template("404.html"), 404


if __name__ == "__main__":
    # host="0.0.0.0" aceita conexoes externas (nao so localhost).
    # A porta 5000 e a liberada no Security Group da EC2.
    port = int(os.environ.get("PORT", 5000))
    app.run(host="0.0.0.0", port=port, debug=False)

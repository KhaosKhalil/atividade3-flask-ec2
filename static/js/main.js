// Menu responsivo (celular)
const botaoMenu = document.getElementById("menu-toggle");
const menu = document.getElementById("menu");
if (botaoMenu && menu) {
    botaoMenu.addEventListener("click", () => {
        const aberto = menu.classList.toggle("aberto");
        botaoMenu.setAttribute("aria-expanded", aberto);
    });
}

// Relogio da pagina inicial
const relogio = document.getElementById("relogio");
if (relogio) {
    const atualizar = () => {
        relogio.textContent = new Date().toLocaleTimeString("pt-BR");
    };
    atualizar();
    setInterval(atualizar, 1000);
}

// Formulario de contato (apenas demonstracao no navegador)
const form = document.getElementById("form-contato");
if (form) {
    form.addEventListener("submit", (evento) => {
        evento.preventDefault();
        const nome = document.getElementById("nome").value.trim();
        const aviso = document.getElementById("aviso");
        aviso.textContent = `Obrigado, ${nome}! Mensagem recebida (demonstração).`;
        aviso.hidden = false;
        form.reset();
    });
}

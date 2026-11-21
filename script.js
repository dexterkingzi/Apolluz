
const formulario = document.getElementById("form-cliente");
const tipoPessoa = document.getElementById("tipo-pessoa");
const nome = document.getElementById("nome");
const documento = document.getElementById("documento");
const telefone = document.getElementById("telefone");
const areaToast = document.getElementById("area-toast");


function atualizarTipoPessoa() {
    const juridica = tipoPessoa.value === "juridica";

    document.getElementById("label-nome").textContent =
        juridica ? "Razão social *" : "Nome completo *";

    nome.placeholder = juridica
        ? "Digite a razão social"
        : "Digite o nome completo";

    document.getElementById("label-documento").textContent =
        juridica ? "CNPJ *" : "CPF *";

    documento.placeholder = juridica
        ? "00.000.000/0000-00"
        : "000.000.000-00";

    documento.maxLength = juridica ? 18 : 14;
    documento.value = "";
    limparErro(documento);
}

tipoPessoa.addEventListener("change", atualizarTipoPessoa);

function aplicarMascara(valor, tipo) {
    let numeros = valor.replace(/\D/g, "");

    if (tipo === "cpf") {
        numeros = numeros.slice(0, 11);

        return numeros
            .replace(/^(\d{3})(\d)/, "$1.$2")
            .replace(/^(\d{3})\.(\d{3})(\d)/, "$1.$2.$3")
            .replace(/\.(\d{3})(\d)/, ".$1-$2");
    }

    if (tipo === "cnpj") {
        numeros = numeros.slice(0, 14);

        return numeros
            .replace(/^(\d{2})(\d)/, "$1.$2")
            .replace(/^(\d{2})\.(\d{3})(\d)/, "$1.$2.$3")
            .replace(/\.(\d{3})(\d)/, ".$1/$2")
            .replace(/(\d{4})(\d)/, "$1-$2");
    }

    numeros = numeros.slice(0, 11);

    if (numeros.length <= 2) {
        return numeros ? `(${numeros}` : "";
    }

    if (numeros.length <= 6) {
        return numeros.replace(/^(\d{2})(\d+)/, "($1) $2");
    }

    if (numeros.length <= 10) {
        return numeros.replace(/^(\d{2})(\d{4})(\d+)/, "($1) $2-$3");
    }

    return numeros.replace(/^(\d{2})(\d{5})(\d+)/, "($1) $2-$3");
}

documento.addEventListener("input", () => {
    const tipo = tipoPessoa.value === "juridica" ? "cnpj" : "cpf";
    documento.value = aplicarMascara(documento.value, tipo);

    if (documento.classList.contains("invalido")) {
        validarCampo(documento);
    }
});

telefone.addEventListener("input", () => {
    telefone.value = aplicarMascara(telefone.value, "telefone");

    if (telefone.classList.contains("invalido")) {
        validarCampo(telefone);
    }
});

function validarCPF(valor) {
    const cpf = valor.replace(/\D/g, "");

    if (cpf.length !== 11 || /^(\d)\1{10}$/.test(cpf)) {
        return false;
    }

    for (let tamanho = 9; tamanho <= 10; tamanho++) {
        let soma = 0;

        for (let i = 0; i < tamanho; i++) {
            soma += Number(cpf[i]) * (tamanho + 1 - i);
        }

        let digito = (soma * 10) % 11;
        if (digito === 10) digito = 0;

        if (digito !== Number(cpf[tamanho])) {
            return false;
        }
    }

    return true;
}


function validarCNPJ(valor) {
    const cnpj = valor.replace(/\D/g, "");

    if (cnpj.length !== 14 || /^(\d)\1{13}$/.test(cnpj)) {
        return false;
    }

    function calcularDigito(base, pesos) {
        const soma = [...base].reduce(
            (total, numero, i) => total + Number(numero) * pesos[i],
            0
        );

        const resto = soma % 11;
        return resto < 2 ? 0 : 11 - resto;
    }

    const base = cnpj.slice(0, 12);
    const primeiro = calcularDigito(
        base,
        [5, 4, 3, 2, 9, 8, 7, 6, 5, 4, 3, 2]
    );

    const baseCompleta = base + primeiro;
    const segundo = calcularDigito(
        baseCompleta,
        [6, 5, 4, 3, 2, 9, 8, 7, 6, 5, 4, 3, 2]
    );

    return cnpj === base + primeiro + segundo;
}


function limparErro(campo) {
    campo.classList.remove("invalido");
    campo.removeAttribute("aria-invalid");

    const mensagem = campo.parentElement.querySelector(".mensagem-erro");
    if (mensagem) mensagem.textContent = "";
}


function validarCampo(campo) {
    const mensagem = campo.parentElement.querySelector(".mensagem-erro");
    const valor = campo.value.trim();
    let erro = "";

    if (campo.required && !valor) {
        erro = "Este campo é obrigatório.";
    } else if (campo.id === "email" && valor &&
        !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(valor)) {
        erro = "Digite um e-mail válido.";
    } else if (campo.id === "telefone" && valor &&
        ![10, 11].includes(valor.replace(/\D/g, "").length)) {
        erro = "Digite um telefone válido com DDD.";
    } else if (campo.id === "documento" && valor) {
        const valido = tipoPessoa.value === "juridica"
            ? validarCNPJ(valor)
            : validarCPF(valor);

        if (!valido) {
            erro = tipoPessoa.value === "juridica"
                ? "Digite um CNPJ válido."
                : "Digite um CPF válido.";
        }
    } else if (campo.id === "consumo" && valor &&
        (!Number.isFinite(Number(valor)) || Number(valor) <= 0)) {
        erro = "Informe um consumo maior que zero.";
    }

    campo.classList.toggle("invalido", Boolean(erro));
    campo.setAttribute("aria-invalid", String(Boolean(erro)));

    if (mensagem) mensagem.textContent = erro;

    return !erro;
}

formulario.querySelectorAll("input, select").forEach((campo) => {
    campo.addEventListener("blur", () => validarCampo(campo));

    campo.addEventListener("input", () => {
        if (campo.classList.contains("invalido")) validarCampo(campo);
    });

    campo.addEventListener("change", () => {
        if (campo.classList.contains("invalido")) validarCampo(campo);
    });
});

function mostrarToast(mensagem, tipo = "sucesso") {
    const toast = document.createElement("div");
    toast.className = tipo === "erro" ? "toast erro" : "toast";

    const texto = document.createElement("span");
    texto.className = "mensagem";
    texto.textContent = mensagem;

    const fechar = document.createElement("button");
    fechar.className = "fechar";
    fechar.type = "button";
    fechar.textContent = "×";
    fechar.setAttribute("aria-label", "Fechar notificação");

    let temporizador;

    function removerToast() {
        clearTimeout(temporizador);
        if (!toast.isConnected) return;

        toast.classList.add("saindo");
        setTimeout(() => toast.remove(), 300);
    }

    fechar.addEventListener("click", removerToast);
    toast.append(texto, fechar);
    areaToast.appendChild(toast);

    temporizador = setTimeout(removerToast, 4000);
}

formulario.addEventListener("submit", (evento) => {
    evento.preventDefault();

    const campos = [...formulario.querySelectorAll("input, select")];
    const valido = campos.map(validarCampo).every(Boolean);

    if (!valido) {
        mostrarToast("Confira os campos destacados antes de continuar.", "erro");
        formulario.querySelector(".invalido")?.focus();
        return;
    }

    mostrarToast("Cliente cadastrado com sucesso!");

    console.log("Dados do cliente:", {
        tipoPessoa: tipoPessoa.value,
        nome: nome.value.trim(),
        documento: documento.value,
        telefone: telefone.value,
        email: document.getElementById("email").value.trim(),
        cidade: document.getElementById("cidade").value.trim(),
        estado: document.getElementById("estado").value,
        consumo: document.getElementById("consumo").value
    });
});

atualizarTipoPessoa();

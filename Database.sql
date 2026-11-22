
-- =========================================================
-- BANCO DE DADOS: APOLLUZ
-- Sistema de Gestão Comercial e Operacional
-- SGBD: MySQL 8.0+
-- =========================================================
CREATE DATABASE apolluz
CHARACTER SET utf8mb4
COLLATE utf8mb4_unicode_ci;

USE apolluz;


-- =========================================================
-- 1. ÁREA COMERCIAL
-- =========================================================

-- TABELA: USUARIO
CREATE TABLE usuario (
    id_usuario BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(150) NOT NULL,
    email VARCHAR(150) NOT NULL UNIQUE,
    senha VARCHAR(255) NOT NULL,
    perfil VARCHAR(50) NOT NULL,
    status VARCHAR(30) DEFAULT 'ativo',
    data_cadastro DATETIME DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;


-- TABELA: EQUIPE_COMERCIAL
CREATE TABLE equipe_comercial (
    id_equipe BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    descricao TEXT,
    status VARCHAR(30) DEFAULT 'ativo'
) ENGINE=InnoDB;


-- TABELA: VENDEDOR
CREATE TABLE vendedor (
    id_vendedor BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    id_usuario BIGINT UNSIGNED NOT NULL UNIQUE,
    id_equipe BIGINT UNSIGNED NOT NULL,
    telefone VARCHAR(20),
    cargo VARCHAR(80),
    data_admissao DATE,
    status VARCHAR(30) DEFAULT 'ativo',

    CONSTRAINT fk_vendedor_usuario
        FOREIGN KEY (id_usuario)
        REFERENCES usuario(id_usuario),

    CONSTRAINT fk_vendedor_equipe
        FOREIGN KEY (id_equipe)
        REFERENCES equipe_comercial(id_equipe)
) ENGINE=InnoDB;


-- TABELA: LEADS
-- Nome alterado para evitar conflito com palavra reservada LEAD
CREATE TABLE leads (
    id_lead BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    id_vendedor BIGINT UNSIGNED NOT NULL,
    nome VARCHAR(150) NOT NULL,
    telefone VARCHAR(20),
    email VARCHAR(150),
    origem VARCHAR(100),
    data_entrada DATETIME DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(30) DEFAULT 'novo',
    observacoes TEXT,

    CONSTRAINT fk_leads_vendedor
        FOREIGN KEY (id_vendedor)
        REFERENCES vendedor(id_vendedor)
) ENGINE=InnoDB;


-- TABELA: META
CREATE TABLE meta (
    id_meta BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    id_vendedor BIGINT UNSIGNED NOT NULL,
    periodo_inicio DATE NOT NULL,
    periodo_fim DATE NOT NULL,
    valor_meta DECIMAL(12,2) NOT NULL,
    quantidade_vendas_meta INT DEFAULT 0,
    valor_realizado DECIMAL(12,2) DEFAULT 0.00,
    status VARCHAR(30) DEFAULT 'em_andamento',

    CONSTRAINT fk_meta_vendedor
        FOREIGN KEY (id_vendedor)
        REFERENCES vendedor(id_vendedor)
) ENGINE=InnoDB;


-- TABELA: CLIENTE
CREATE TABLE cliente (
    id_cliente BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    id_lead BIGINT UNSIGNED UNIQUE,
    nome_razao_social VARCHAR(180) NOT NULL,
    cpf_cnpj VARCHAR(18) UNIQUE,
    telefone VARCHAR(20),
    email VARCHAR(150),
    endereco VARCHAR(255),
    cidade VARCHAR(100),
    cep VARCHAR(10),
    tipo_pessoa VARCHAR(20),
    data_cadastro DATETIME DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_cliente_leads
        FOREIGN KEY (id_lead)
        REFERENCES leads(id_lead)
) ENGINE=InnoDB;


-- TABELA: CONTATO
CREATE TABLE contato (
    id_contato BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    id_lead BIGINT UNSIGNED NOT NULL,
    data_hora DATETIME DEFAULT CURRENT_TIMESTAMP,
    canal VARCHAR(80),
    resultado VARCHAR(150),
    observacao TEXT,
    proximo_contato DATETIME,

    CONSTRAINT fk_contato_leads
        FOREIGN KEY (id_lead)
        REFERENCES leads(id_lead)
) ENGINE=InnoDB;


-- TABELA: PROPOSTA
CREATE TABLE proposta (
    id_proposta BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    id_lead BIGINT UNSIGNED NOT NULL,
    data_criacao DATE,
    data_envio DATE,
    validade DATE,
    valor_total DECIMAL(12,2) NOT NULL,
    potencia_sistema DECIMAL(10,2),
    status VARCHAR(30) DEFAULT 'em_elaboracao',
    observacoes TEXT,

    CONSTRAINT fk_proposta_leads
        FOREIGN KEY (id_lead)
        REFERENCES leads(id_lead)
) ENGINE=InnoDB;


-- TABELA: CONTRATO
CREATE TABLE contrato (
    id_contrato BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    id_proposta BIGINT UNSIGNED NOT NULL UNIQUE,
    numero_contrato VARCHAR(50) NOT NULL UNIQUE,
    data_assinatura DATE,
    valor_contratado DECIMAL(12,2) NOT NULL,
    forma_pagamento VARCHAR(80),
    status VARCHAR(30) DEFAULT 'pendente',

    CONSTRAINT fk_contrato_proposta
        FOREIGN KEY (id_proposta)
        REFERENCES proposta(id_proposta)
) ENGINE=InnoDB;


-- TABELA: VENDA
CREATE TABLE venda (
    id_venda BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    id_cliente BIGINT UNSIGNED NOT NULL,
    id_vendedor BIGINT UNSIGNED NOT NULL,
    data_venda DATE NOT NULL,
    valor_total DECIMAL(12,2) NOT NULL,
    forma_pagamento VARCHAR(80),
    status VARCHAR(30) DEFAULT 'pendente',

    CONSTRAINT fk_venda_cliente
        FOREIGN KEY (id_cliente)
        REFERENCES cliente(id_cliente),

    CONSTRAINT fk_venda_vendedor
        FOREIGN KEY (id_vendedor)
        REFERENCES vendedor(id_vendedor)
) ENGINE=InnoDB;


-- =========================================================
-- 2. ÁREA DE PROJETOS
-- =========================================================

-- TABELA: PROJETO
CREATE TABLE projeto (
    id_projeto BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    id_venda BIGINT UNSIGNED NOT NULL UNIQUE,
    data_inicio DATE,
    data_visita_tecnica DATE,
    potencia_projeto DECIMAL(10,2),
    quantidade_modulos INT,
    modelo_inversor VARCHAR(120),
    status VARCHAR(40) DEFAULT 'em_andamento',
    data_aprovacao DATE,

    CONSTRAINT fk_projeto_venda
        FOREIGN KEY (id_venda)
        REFERENCES venda(id_venda)
) ENGINE=InnoDB;


-- =========================================================
-- 3. ÁREA DE INSTALAÇÃO E HOMOLOGAÇÃO
-- =========================================================

-- TABELA: INSTALACAO
CREATE TABLE instalacao (
    id_instalacao BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    id_projeto BIGINT UNSIGNED NOT NULL UNIQUE,
    data_agendada DATE,
    data_inicio DATE,
    data_conclusao DATE,
    status VARCHAR(40) DEFAULT 'pendente',
    observacoes TEXT,

    CONSTRAINT fk_instalacao_projeto
        FOREIGN KEY (id_projeto)
        REFERENCES projeto(id_projeto)
) ENGINE=InnoDB;


-- TABELA: HOMOLOGACAO
CREATE TABLE homologacao (
    id_homologacao BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    id_instalacao BIGINT UNSIGNED NOT NULL UNIQUE,
    concessionaria VARCHAR(150),
    protocolo VARCHAR(100),
    data_solicitacao DATE,
    data_aprovacao DATE,
    status VARCHAR(40) DEFAULT 'pendente',
    observacoes TEXT,

    CONSTRAINT fk_homologacao_instalacao
        FOREIGN KEY (id_instalacao)
        REFERENCES instalacao(id_instalacao)
) ENGINE=InnoDB;


-- =========================================================
-- 4. ÁREA DE MONITORAMENTO E ALERTAS
-- =========================================================

-- TABELA: MONITORAMENTO
CREATE TABLE monitoramento (
    id_monitoramento BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    id_instalacao BIGINT UNSIGNED NOT NULL UNIQUE,
    data_inicio DATE,
    status_usina VARCHAR(40),
    ultima_verificacao DATETIME,
    geracao_acumulada DECIMAL(14,2) DEFAULT 0.00,

    CONSTRAINT fk_monitoramento_instalacao
        FOREIGN KEY (id_instalacao)
        REFERENCES instalacao(id_instalacao)
) ENGINE=InnoDB;


-- TABELA: ALERTA
CREATE TABLE alerta (
    id_alerta BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    id_monitoramento BIGINT UNSIGNED NOT NULL,
    tipo VARCHAR(80),
    descricao TEXT,
    nivel VARCHAR(30),
    data_hora DATETIME DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(30) DEFAULT 'aberto',
    data_resolucao DATETIME,

    CONSTRAINT fk_alerta_monitoramento
        FOREIGN KEY (id_monitoramento)
        REFERENCES monitoramento(id_monitoramento)
) ENGINE=InnoDB;


-- =========================================================
-- 5. ÁREA DE PÓS-VENDA
-- =========================================================

-- TABELA: POS_VENDA
CREATE TABLE pos_venda (
    id_pos_venda BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    id_monitoramento BIGINT UNSIGNED NOT NULL,
    tipo_atendimento VARCHAR(100),
    descricao TEXT,
    prioridade VARCHAR(30),
    data_abertura DATETIME DEFAULT CURRENT_TIMESTAMP,
    data_fechamento DATETIME,
    status VARCHAR(30) DEFAULT 'aberto',

    CONSTRAINT fk_posvenda_monitoramento
        FOREIGN KEY (id_monitoramento)
        REFERENCES monitoramento(id_monitoramento)
) ENGINE=InnoDB;


-- =========================================================
-- 6. RELACIONAMENTO CLIENTE E POS_VENDA (N:N)
-- =========================================================

CREATE TABLE cliente_pos_venda (
    id_cliente BIGINT UNSIGNED NOT NULL,
    id_pos_venda BIGINT UNSIGNED NOT NULL,

    PRIMARY KEY (id_cliente, id_pos_venda),

    CONSTRAINT fk_cliente_posvenda_cliente
        FOREIGN KEY (id_cliente)
        REFERENCES cliente(id_cliente),

    CONSTRAINT fk_cliente_posvenda_posvenda
        FOREIGN KEY (id_pos_venda)
        REFERENCES pos_venda(id_pos_venda)
) ENGINE=InnoDB;

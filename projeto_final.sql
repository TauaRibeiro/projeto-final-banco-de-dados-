CREATE DATABASE projeto_final;
USE projeto_final;

/*
FUNÇÕES
*/
-- Encontrar última data de alteração do preco de um produto
DELIMITER //
CREATE FUNCTION encontrar_ultima_alteracao(`id_produto` INT)
RETURNS DATE NOT DETERMINISTIC
BEGIN
	DECLARE `resultado` DATE DEFAULT NULL;
    
    SELECT MAX(`pp`.`data_aplicacao`) INTO `resultado`
    FROM `preco_produto` AS `pp`
    WHERE `id_produto` = `pp`.`id_produto`;
    
    RETURN `resultado`;
END//
DELIMITER;

-- Achar o preco mais atualizado de um produto
DELIMITER //
CREATE FUNCTION achar_preco(`id_produto` INT)
RETURNS INT NOT DETERMINISTIC
BEGIN
	DECLARE `resultado` INT DEFAULT NULL;
    
    SELECT `pp`.`id_produto` INTO `resultado`
	FROM `preco_produto` AS `pp`
    WHERE 
    `pp`.`id_produto` = `id_produto` AND
    `pp`.`data_aplicacao` = encontrar_ultima_alteracao(`id_produto`);
    
    RETURN `resultado`;
END// 
DELIMITER ;

-- Calcular sub total da compra
DELIMITER //
CREATE FUNCTION calcular_subTotal(`id_preco_produto` INT, `quantidade` INT)
RETURNS DECIMAL(10, 2) DETERMINISTIC
BEGIN
	DECLARE `resultado` DECIMAL(10, 2);
    
    SELECT (`pp`.`preco_produto`*`quantidade`) INTO `resultado`
    FROM `preco_produto` AS `pp`
    WHERE `id_preco_produto` = `pp`.`id_preco_produto`;
    
    RETURN `resultado`;
END //
DELIMITER ;


/*
TRIGERS
*/

/*
PROCEDURES
*/

/*
TABLES
*/
CREATE TABLE `categoria` (
  `id_categoria` int AUTO_INCREMENT NOT NULL,
  `nome_categoria` varchar(50) NOT NULL,
  PRIMARY KEY (`id_categoria`)
);


CREATE TABLE `cliente` (
  `id_cliente` int AUTO_INCREMENT NOT NULL,
  `nome_cliente` varchar(150) NOT NULL,
  `cpf_cliente` varchar(11) NOT NULL,
  `id_endereco` int NOT NULL,
  `data_nascimento` date NOT NULL,
  `data_cadastro_cliente` date NOT NULL,
  `email_cliente` varchar(100) NOT NULL,
  PRIMARY KEY (`id_cliente`),
  UNIQUE KEY `cpf_cliente_UNIQUE` (`cpf_cliente`),
  KEY `fk_endereco_cliente_idx` (`id_endereco`),
  CONSTRAINT `fk_endereco_cliente` FOREIGN KEY (`id_endereco`) REFERENCES `endereco` (`id_endereco`) ON DELETE RESTRICT ON UPDATE RESTRICT
);


CREATE TABLE `compra` (
  `id_compra` int AUTO_INCREMENT NOT NULL,
  `id_cliente` int NOT NULL,
  `total_compra` decimal(10,0) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id_compra`),
  KEY `fk_cliente_compra_idx` (`id_cliente`),
  CONSTRAINT `fk_cliente_compra` FOREIGN KEY (`id_cliente`) REFERENCES `cliente` (`id_cliente`) ON DELETE RESTRICT ON UPDATE RESTRICT
);


CREATE TABLE `endereco` (
  `id_endereco` int AUTO_INCREMENT NOT NULL,
  `cep_endereco` varchar(8) NOT NULL,
  `rua_endereco` varchar(150) NOT NULL,
  `logradouro_endereco` varchar(150) NOT NULL,
  `numero_endereco` int NOT NULL,
  PRIMARY KEY (`id_endereco`)
);


CREATE TABLE `funcionario` (
  `id_funcionario` int AUTO_INCREMENT NOT NULL,
  `nome_funcionario` varchar(150) NOT NULL,
  `cpf_funcionario` varchar(11) NOT NULL,
  `salario_funcionario` decimal(10,2) NOT NULL,
  `data_efetivacao_funcionario` date NOT NULL,
  `data_nascimento` date NOT NULL,
  PRIMARY KEY (`id_funcionario`),
  UNIQUE KEY `cpf_funcionario_UNIQUE` (`cpf_funcionario`)
);


CREATE TABLE `interacao_cliente` (
  `id_interacao` int AUTO_INCREMENT NOT NULL,
  `id_funcionario` int NOT NULL,
  `id_cliente` int NOT NULL,
  `transcricao_interacao` text NOT NULL,
  `data_interacao` date NOT NULL,
  PRIMARY KEY (`id_interacao`),
  KEY `fk_funcionario_interacao_idx` (`id_funcionario`),
  KEY `fk_cliente_interacao_idx` (`id_cliente`),
  CONSTRAINT `fk_cliente_interacao` FOREIGN KEY (`id_cliente`) REFERENCES `cliente` (`id_cliente`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `fk_funcionario_interacao` FOREIGN KEY (`id_funcionario`) REFERENCES `funcionario` (`id_funcionario`) ON DELETE RESTRICT ON UPDATE RESTRICT
);


CREATE TABLE `item_compra` (
  `id_item` int(11) AUTO_INCREMENT NOT NULL,
  `id_compra` int(11) NOT NULL,
  `id_preco_produto` int(11) NOT NULL,
  `quantidade_item` int(11) NOT NULL,
  `sub_total` decimal(10,2) NOT NULL,
  `id_produto` int(11) NOT NULL,
  PRIMARY KEY (`id_item`),
  KEY `fk_compra_item_idx` (`id_compra`),
  KEY `fk_precoProduto_item_idx` (`id_preco_produto`),
  KEY `fk_produto_itemCompra` (`id_produto`),
  CONSTRAINT `fk_compra_item` FOREIGN KEY (`id_compra`) REFERENCES `compra` (`id_compra`),
  CONSTRAINT `fk_precoProduto_item` FOREIGN KEY (`id_preco_produto`) REFERENCES `preco_produto` (`id_preco_produto`),
  CONSTRAINT `fk_produto_itemCompra` FOREIGN KEY (`id_produto`) REFERENCES `preco_produto` (`id_produto`)
);


CREATE TABLE `preco_produto` (
  `id_preco_produto` int AUTO_INCREMENT NOT NULL,
  `id_produto` int NOT NULL,
  `preco_produto` decimal(10,2) NOT NULL,
  `data_aplicacao` date NOT NULL,
  PRIMARY KEY (`id_preco_produto`),
  KEY `fk_produto_precoProduto_idx` (`id_produto`),
  CONSTRAINT `fk_produto_precoProduto` FOREIGN KEY (`id_produto`) REFERENCES `produto` (`id_produto`) ON DELETE RESTRICT ON UPDATE RESTRICT
);


CREATE TABLE `produto` (
  `id_produto` int AUTO_INCREMENT NOT NULL,
  `nome_produto` varchar(150) NOT NULL,
  `quantidade_produto` int NOT NULL,
  `id_categoria` int NOT NULL,
  `id_status` int NOT NULL,
  PRIMARY KEY (`id_produto`),
  KEY `fk_categoria_produto_idx` (`id_categoria`),
  KEY `fk_status_produto_idx` (`id_status`),
  CONSTRAINT `fk_categoria_produto` FOREIGN KEY (`id_categoria`) REFERENCES `categoria` (`id_categoria`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `fk_status_produto` FOREIGN KEY (`id_status`) REFERENCES `status` (`id_status`) ON DELETE RESTRICT ON UPDATE RESTRICT
);


CREATE TABLE `segmentacao_cliente` (
  `id_cliente` int NOT NULL,
  `id_categoria` int NOT NULL,
  PRIMARY KEY (`id_cliente`,`id_categoria`),
  KEY `fk_categoria_segmentacaoCliente_idx` (`id_categoria`),
  CONSTRAINT `fk_categoria_segmentacaoCliente` FOREIGN KEY (`id_categoria`) REFERENCES `categoria` (`id_categoria`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `fk_cliente_segmentacaoCliente` FOREIGN KEY (`id_cliente`) REFERENCES `cliente` (`id_cliente`) ON DELETE RESTRICT ON UPDATE RESTRICT
);


CREATE TABLE `status` (
  `id_status` int AUTO_INCREMENT NOT NULL,
  `nome_status` varchar(50) NOT NULL,
  PRIMARY KEY (`id_status`)
);


CREATE TABLE `tarefa` (
  `id_tarefa` int AUTO_INCREMENT NOT NULL,
  `id_funcionario` int NOT NULL,
  `nome_tarefa` varchar(150) NOT NULL,
  `descricao_tarefa` varchar(300) NOT NULL,
  `data_inicio_tarefa` date NOT NULL,
  `data_fim_tarefa` date DEFAULT NULL,
  `id_status` int DEFAULT NULL,
  PRIMARY KEY (`id_tarefa`),
  KEY `fk_funcionario_tarefa_idx` (`id_funcionario`),
  KEY `fk_status_tarefa_idx` (`id_status`),
  CONSTRAINT `fk_funcionario_tarefa` FOREIGN KEY (`id_funcionario`) REFERENCES `funcionario` (`id_funcionario`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `fk_status_tarefa` FOREIGN KEY (`id_status`) REFERENCES `status` (`id_status`) ON DELETE RESTRICT ON UPDATE RESTRICT
);


CREATE TABLE `historico` (
	`id_historico` INT AUTO_INCREMENT NOT NULL,
    `tipo_acao` VARCHAR(50) NOT NULL,
    `id_compra` INT NOT NULL,
    `id_item` INT,
    `data_registro` DATETIME NOT NULL,
    
    PRIMARY KEY(`id_historico`),
    CONSTRAINT `fk_compra_historico` FOREIGN KEY(`id_compra`) REFERENCES `compra`(`id_compra`)
		ON DELETE RESTRICT
        ON UPDATE RESTRICT,
	CONSTRAINT `fk_item_historico` FOREIGN KEY(`id_item`) REFERENCES `item_compra`(`id_item`)
		ON DELETE RESTRICT
        ON UPDATE RESTRICT
);

/*
SELECTS
*/


/*
VIEWS
*/


/*
ALTER TABLES
*/

ALTER TABLE `item_compra`
	ADD COLUMN `id_produto` INT NOT NULL,
    ADD CONSTRAINT `fk_produto_itemCompra` FOREIGN KEY (`id_produto`) REFERENCES `preco_produto`(`id_produto`)
		ON DELETE RESTRICT
        ON UPDATE RESTRICT;
/*
UPDATES
*/


/*
INSERTS
*/


/*
DELETES
*/


COMMIT;
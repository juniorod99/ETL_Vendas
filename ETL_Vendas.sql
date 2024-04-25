CREATE DATABASE ETL_Vendas
use ETL_Vendas

-- CRIANDO TABELA VENDEDOR
CREATE TABLE Vendedor (
   codigo_vendedor        smallint not null,
   nome_vendedor        varchar(20),
   sexo_vendedor        varchar(1), -- 1 - M | 0 - F
   perc_comissao decimal(19,2),
   mat_funcionario      smallint not null
); 

-- ADICIONANDO CHAVE PRIMARIA
ALTER TABLE Vendedor ADD PRIMARY KEY (codigo_vendedor);

-- INSERINDO DADOS DO VENDEDOR NO ETL UTILIZANDO OS DADOS DO ERP
INSERT INTO ETL_Vendas.dbo.Vendedor (codigo_vendedor, nome_vendedor, sexo_vendedor, perc_comissao, mat_funcionario)
SELECT cdvdd, nmvdd, sxvdd, perccomissao, matfunc
FROM ERP_Vendas.dbo.tbvdd;

-- TRATANDO TABELA SEXO_VENDEDOR PARA FICAR MAIS COMPREENSIVEL
UPDATE Vendedor
SET sexo_vendedor = 
	CASE
		WHEN sexo_vendedor = '1' THEN 'M'
		WHEN sexo_vendedor = '0' THEN 'F'
	END;

SELECT * FROM Vendedor

-- CRIANDO TABELA DEPENDETES
CREATE TABLE Dependente (
   codigo_dependente      INT IDENTITY(1,1) PRIMARY KEY, 
   nome_dependente        varchar(150),
   data_nascimento        date,
   sexo_dependente        varchar(2),
   codigo_vendedor        smallint,
   inep_escola			  varchar(10),
   CONSTRAINT FK_Dep_Vdd FOREIGN KEY (codigo_vendedor) REFERENCES Vendedor (codigo_vendedor)
)

-- INSERINDO DADOS DO DEPENDENTE NO ETL UTILIZANDO OS DADOS DO ERP
INSERT INTO ETL_Vendas.dbo.Dependente(nome_dependente, data_nascimento, sexo_dependente, codigo_vendedor, inep_escola)
SELECT nmdep, dtnasc, sxdep, cdvdd, inepescola
FROM ERP_Vendas.dbo.tbdep;

-- FORMATANDO DATA PARA FORMATO BRASILEIRO
UPDATE Dependente
SET data_nascimento = FORMAT(data_nascimento_formatada, 'dd/MM/yyyy');

select * from Dependente

-- CRIANDO TABELA PRODUTOS
CREATE TABLE Produtos(
    codigo_produto		INT IDENTITY(1,1) PRIMARY KEY,
    nome_produto		varchar(50) NULL,
    tipo_produto		varchar(1) NULL,
    unidade_produto		varchar(2) NULL,
    sl_produto			int NULL,
    status_produto		varchar(50) NULL
);

-- INSERINDO DADOS DO PRODUTO NO ETL UTILIZANDO OS DADOS DO ERP
INSERT INTO ETL_Vendas.dbo.Produtos(nome_produto, tipo_produto, unidade_produto, sl_produto, status_produto)
SELECT nmpro, tppro, undpro, slpro, stpro
FROM ERP_Vendas.dbo.tbpro;

select * from Produtos

-- CRIANDO TABELA VENDA
CREATE TABLE Venda(
    codigo_venda		INT IDENTITY(1,1) PRIMARY KEY,
    data_venda			date NULL,
    codigo_cliente		smallint NULL,
    nome_cliente		varchar(50) NULL,
    idade_cliente		smallint NULL,
    classific_cliente	smallint NULL,
    sexo_cliente		varchar(1) NULL,
    cidade_cliente		varchar(50) NULL,
    estado_cliente		varchar(50) NULL,
    pais_cliente		varchar(50) NULL,
    canal_venda			varchar(12) NOT NULL,
    status_venda		smallint NULL, -- 1 concluída, 2 em aberto e 3 é cancelada
    deleteda			smallint NULL,
    codigo_vendedor		smallint NULL
);

-- ADICIONANDO CHAVE ESTRANGEIRA DE VENDA COM VENDEDOR
ALTER TABLE Venda ADD CONSTRAINT "fk_venda_vendedor" FOREIGN KEY ( codigo_vendedor ) REFERENCES Vendedor ( codigo_vendedor );

-- INSERINDO DADOS DA VENDA NO ETL UTILIZANDO OS DADOS DO ERP
INSERT INTO ETL_Vendas.dbo.Venda(data_venda, codigo_cliente, nome_cliente, idade_cliente, classific_cliente, sexo_cliente, cidade_cliente, estado_cliente, pais_cliente, canal_venda, status_venda, deleteda, codigo_vendedor)
SELECT dtven , cdcli , nmcli , agecli, clacli, sxcli, cidcli, estcli, paicli, canal, stven, deleted, cdvdd
FROM ERP_Vendas.dbo.tbven;

-- ADICIONANDO NOVA COLUNA PARA COLOCAR SITUAÇAO DA VENDA
ALTER TABLE Venda
ADD situacao_venda varchar(50) NULL;

-- COLOCANDO DADOS NA NOVA COLUNA DE ACORDO COM STATUS DA VENDA
UPDATE Venda
SET situacao_venda = 
	CASE
		WHEN status_venda = '1' THEN 'Concluída'
		WHEN status_venda = '2' THEN 'Em Aberto'
		WHEN status_venda = '3' THEN 'Cancelada'
	END;

select * from Venda

-- CRIANDO TABELA DE ITENS DA VENDA
CREATE TABLE VendaItem(
    codigo_venda_item		INT IDENTITY(1,1) PRIMARY KEY,
    codigo_produto			int NULL,
    quantidade_venda		int NULL,
    valor_unitario_venda    decimal(18, 2) NULL,
    valor_total_venda		decimal(29, 2) NULL,
    codigo_venda			int NULL
);

-- ADICIONANDO CHAVE ESTRANGEIRA DE VendaItem COM PRODUTOS
ALTER TABLE VendaItem ADD CONSTRAINT "fk_vendas_item_produto" FOREIGN KEY ( codigo_produto ) REFERENCES Produtos ( codigo_produto );

-- ADICIONANDO CHAVE ESTRANGEIRA DE VendaItem COM VENDA
ALTER TABLE VendaItem ADD CONSTRAINT "fk_vendas_item_venda" FOREIGN KEY ( codigo_venda ) REFERENCES Venda ( codigo_venda );

-- INSERINDO DADOS DE ITENS DA VENDA NO ETL UTILIZANDO OS DADOS DO ERP
INSERT INTO ETL_Vendas.dbo.VendaItem(codigo_produto, quantidade_venda, valor_unitario_venda, valor_total_venda, codigo_venda)
SELECT cdpro , qtven , vruven, vrtven, cdven
FROM ERP_Vendas.dbo.tbven_item;

-- INSERINDO VALOR TOTAL DA VENDA
UPDATE VendaItem
SET valor_total_venda = valor_unitario_venda * quantidade_venda

select * from VendaItem


-- CRIANDO UMA TABELA PARA OS CLIENTES
CREATE TABLE Cliente(
    codigo_cliente		INT IDENTITY(1,1) PRIMARY KEY,
    nome_cliente		varchar(50) NULL,
    idade_cliente		smallint NULL,
    classific_cliente	smallint NULL,
    sexo_cliente		varchar(1) NULL,
    cidade_cliente		varchar(50) NULL,
    estado_cliente		varchar(50) NULL,
    pais_cliente		varchar(50) NULL,
);

-- INSERINDO CLIENTES SEM QUE TENHAM REGISTROS DUPLICADOS
INSERT INTO ETL_Vendas.dbo.Cliente(nome_cliente, idade_cliente, classific_cliente, sexo_cliente, cidade_cliente, estado_cliente, pais_cliente)
SELECT DISTINCT nmcli , agecli, clacli, sxcli, cidcli, estcli, paicli
FROM ERP_Vendas.dbo.tbven;


select * from Cliente

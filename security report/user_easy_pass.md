## Descrição
Este script realiza as seguintes operações relacionadas à segurança de logins no SQL Server:

1. Cria uma tabela temporária `#Senhas` para armazenar combinações de senhas geradas e logins existentes.
2. Gera uma lista de caracteres válidos, incluindo letras maiúsculas e números, excluindo caracteres específicos que podem causar problemas.
3. Constrói combinações de senhas com base nos caracteres gerados.
4. Adiciona os nomes de logins existentes no SQL Server (em diferentes casos: original, minúsculo e maiúsculo) à tabela de senhas.
5. Valida as senhas geradas contra os logins armazenados utilizando a função `PWDCOMPARE`, retornando as correspondências entre login e senha.

## Observações
- O script utiliza tabelas temporárias e manipulação de caracteres para geração de senhas.
- A função `PWDCOMPARE` compara uma senha em texto claro com o hash armazenado no SQL Server.
- Para evitar impactos de bloqueio ou lentidão, foram aplicados *hints* `WITH(NOLOCK)` em algumas consultas.
- Ideal para auditorias ou testes de segurança. Certifique-se de usar este script apenas em ambientes controlados e com as devidas autorizações.

```SQL
SET NOCOUNT ON


IF (OBJECT_ID('tempdb..#Senhas') IS NOT NULL) DROP TABLE #Senhas
CREATE TABLE #Senhas (
    Senha VARCHAR(100)
)

-- Gera as senhas (maiúsculas e números)
DECLARE @Caracteres TABLE ( Caractere VARCHAR(1) )

DECLARE 
    @Contador INT = 48, -- 33
    @Total INT = 57 -- 165

WHILE(@Contador < @Total)
BEGIN

	IF (@Contador NOT IN (127, 134, 143, 145, 146, 152, 153, 154, 155, 156, 157, 158, 159))
	BEGIN
	
		INSERT INTO @Caracteres
		VALUES(CHAR(@Contador))

	END

	SET @Contador += 1

END
```

```SQL
INSERT INTO #Senhas
SELECT * FROM @Caracteres



SET @Contador = 1
SET @Total = 4

WHILE(@Contador <= @Total)
BEGIN
	
	INSERT INTO #Senhas
	SELECT 
		A.Senha + B.Caractere
	FROM
		#Senhas A
		JOIN @Caracteres B ON 1=1

	
	SET @Contador += 1

END
```

```SQL
-- Logins
INSERT INTO #Senhas
SELECT [name]
FROM sys.sql_logins

INSERT INTO #Senhas
SELECT LOWER([name])
FROM sys.sql_logins WITH(NOLOCK)

INSERT INTO #Senhas
SELECT UPPER([name])
FROM sys.sql_logins WITH(NOLOCK)
```

```SQL
SELECT DISTINCT
    A.[name],
    B.Senha
FROM 
    sys.sql_logins			A WITH(NOLOCK)
    CROSS APPLY #Senhas		B
WHERE
	PWDCOMPARE(B.Senha, A.password_hash) = 1
```
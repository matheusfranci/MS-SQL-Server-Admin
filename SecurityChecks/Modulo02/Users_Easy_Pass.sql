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

-- Logins
INSERT INTO #Senhas
SELECT [name]
FROM sys.sql_logins

INSERT INTO #Senhas
SELECT LOWER([name])
FROM sys.sql_logins

INSERT INTO #Senhas
SELECT UPPER([name])
FROM sys.sql_logins


SELECT DISTINCT
    A.[name],
    B.Senha
FROM 
    sys.sql_logins			A
    CROSS APPLY #Senhas		B
WHERE
	PWDCOMPARE(B.Senha, A.password_hash) = 1


/*

O que é CLR External Access/Unsafe?

Safe: O código executado por um assembly com permissões seguras não pode acessar recursos externos do sistema, como 
arquivos, rede, variáveis de ambiente ou o registro. Conexão ao banco só pode ser feita com "Context connection = true/yes"

External Access: mesmas permissões que os assemblies seguros, com a capacidade adicional de acessar recursos externos do 
sistema, como arquivos, redes (SMTP, Socket, SQLClient, Web, Ping, Logs de Eventos, DNS, MSDTC), variáveis de ambiente 
e o registro.

Unsafe/Unrestricted: permite que os assemblies tenham acesso irrestrito aos recursos, dentro e fora do SQL Server. 
O código em execução de dentro de um assembly não seguro também pode chamar código não gerenciado.

-------------------------------------------------

Safe é a configuração de permissão recomendada para assemblies que executam tarefas de computação e gerenciamento de dados 
sem acessar recursos fora do SQL Server . EXTERNAL_ACCESS é recomendado para assemblies que acessam recursos fora do 
SQL Server. 

EXTERNAL_ACCESS assemblies por padrão são executados como a SQL Server conta de serviço. É possível que EXTERNAL_ACCESS 
código represente explicitamente o contexto de segurança de autenticação do Windows do chamador. Como o padrão é executar 
como a SQL Server conta de serviço, a permissão para executar EXTERNAL_ACCESS deve ser dada somente a logons confiáveis 
para execução como a conta de serviço. 

De uma perspectiva de segurança, EXTERNAL_ACCESS e assemblies não seguros são idênticos. No entanto, os assemblies do 
EXTERNAL_ACCESS fornecem várias proteções de confiabilidade e robustez que não estão em ASSEMBLIES não seguros. 

Especificar unsafe permite que o código no assembly execute operações ilegais no espaço do SQL Server processo e, portanto, possa 
comprometer a robustez e a escalabilidade do SQL Server 

-------------------------------------------------

Passos para criar um assembly

Safe: Simplesmente cria o assembly normalmente

External Access / Unsafe: 
    - Owner do banco precisa de permissões de EXTERNAL ACCESS ASSEMBLY e/ou UNSAFE ASSEMBLY e o banco deve ser marcado
    como Trustworthy (Risco de segurança)

    OU

    - Assembly é assinado, Chave assimétrica ou certificado são criados


-------------------------------------------------

CLR Strict Security e o SQL Server 2017

- Microsoft recomenda habilitar o CLR Strict Security no SQL Server 2017+ e até os assemblies safe precisam agora ser 
assinados (ou banco Trustworthy, o que não é recomendado). 

- Essa mudança ocorreu por conta de alterações de segurança no .NET Framework, mais especificamente no Code Access 
Security (CAS), que não é mais suportado, por permitir algumas brechas de segurança, como códigos Safe acessando dados 
externos, executando códigos não-gerenciados, etc..


Referência: 
- https://docs.microsoft.com/pt-br/sql/relational-databases/clr-integration/security/clr-integration-code-access-security?view=sql-server-ver15
- https://www.sqlservercentral.com/steps/stairway-to-sqlclr-level-4-security-external-and-unsafe-assemblies
- https://joeydantoni.com/2017/04/19/sqlclr-in-sql-server-2017/
- https://sqlquantumleap.com/2017/08/07/sqlclr-vs-sql-server-2017-part-1-clr-strict-security/

*/



-- Verificando External Access/Unsafe no banco atual
SELECT
    [name],
    clr_name,
    permission_set_desc,
    create_date,
    modify_date
FROM 
    sys.assemblies WITH(NOLOCK)
WHERE 
    [permission_set] <> 1 
    AND is_user_defined = 1
	AND [clr_name] NOT LIKE 'microsoft.sqlserver.integrationservices.server%'



-- Verificando External Access/Unsafe em todos os bancos
DECLARE @DadosSQLCLR TABLE ( [database_name] NVARCHAR(128), [assembly_name] nvarchar(128), [clr_name] nvarchar(256), [permission_set_desc] nvarchar(60), [create_date] datetime, [modify_date] datetime )

INSERT INTO @DadosSQLCLR
(
    [database_name],
    assembly_name,
    clr_name,
    permission_set_desc,
    create_date,
    modify_date
)
EXEC sys.sp_MSforeachdb
    @command1 = N'SELECT 
''?'',
[name],
	clr_name,
	permission_set_desc,
	create_date,
	modify_date
FROM 
	[?].sys.assemblies WITH(NOLOCK)
WHERE 
	[permission_set] <> 1 
	AND is_user_defined = 1
	AND [clr_name] NOT LIKE ''microsoft.sqlserver.integrationservices.server%'''


SELECT * FROM @DadosSQLCLR


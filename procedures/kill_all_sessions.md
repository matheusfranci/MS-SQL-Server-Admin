## Objetivo
Este script encerra todas as sessões ativas em um banco de dados específico, com exceção das sessões de sistema e da própria sessão que executa o comando.

## Entrada esperada
- O nome do banco de dados deve ser especificado diretamente no script.

## Saída esperada
- Todas as conexões ativas no banco de dados informado serão encerradas, permitindo a execução de tarefas administrativas.

## Observações adicionais
- **Atenção**: Este script deve ser usado com cuidado, especialmente em ambientes de produção, para evitar a interrupção de serviços críticos.
- Sessões de sistema e a sessão do próprio usuário que executa o script não serão afetadas.
- Antes de executar, valide o impacto no ambiente para evitar desconexões inesperadas de usuários.

## Localização do script
Certifique-se de editar o script para especificar o banco de dados desejado antes de sua execução.

```SQL
USE [master]
GO
DECLARE @query VARCHAR(MAX) = ''
DECLARE @dbid VARCHAR(MAX) = ''

 

select @dbid = [dbid] from sys.sysdatabases where name = 'NOME_BANCO' --Informe o nome da base de dados
SELECT 
    @query = COALESCE(@query, ',') + 'KILL ' + CONVERT(VARCHAR, spid) + '; '
FROM
    master..sysprocesses
WHERE
    dbid > 4 -- Não eliminar sessões em databases de sistema
    AND spid <> @@SPID -- Não eliminar a sua própria sessão
    and dbid = @dbid
IF (LEN(@query) > 0)
    EXEC(@query)
```
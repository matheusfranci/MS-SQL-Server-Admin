# Monitoring and Killing Connections to the Model Database

## Objetivo
Este script monitora as conexões ativas à base de dados **`model`** no SQL Server, verificando se ela está em uso e fornecendo os comandos necessários para encerrar todas as conexões que utilizam esse banco de dados.

## Entrada esperada
- O script é configurado para monitorar a base de dados **`model`** sem necessidade de ajustes adicionais.

## Saída esperada
1. Mensagem indicando se a base de dados **`model`** está em uso ou não.
2. Detalhes das sessões ativas conectadas à base de dados **`model`**, caso existam.
3. Comandos **`KILL`** gerados automaticamente para encerrar as conexões identificadas.

## Observações adicionais
- **Uso recomendado**: Este script é útil para diagnosticar bloqueios ou uso inesperado do banco de dados **`model`**, que é uma base de sistema usada como template para criar novos bancos de dados.
- **Cuidados ao executar**: Certifique-se de avaliar o impacto de encerrar conexões antes de executar os comandos **`KILL`**, especialmente em ambientes compartilhados.
- Para encerrar conexões, copie os comandos **`KILL`** gerados e execute-os manualmente.

## Localização do script
O script já está configurado para a base **`model`**. Caso deseje monitorar outro banco de dados, substitua `'model'` pelo nome do banco desejado nas queries.


```SQL
-- Find who is having connection? Below query can help in that.

IF EXISTS (
        SELECT request_session_id
        FROM sys.dm_tran_locks
        WHERE resource_database_id = DB_ID('model')
        )
BEGIN
    PRINT 'Model Database in use!!'
    SELECT *
    FROM sys.dm_exec_sessions
    WHERE session_id IN (
            SELECT request_session_id
            FROM sys.dm_tran_locks
            WHERE resource_database_id = DB_ID('model')
            )
END
ELSE
    PRINT 'Model Database not in used.'
```

```SQL  
-- Kill the connection. Below query would provide KILL command which we can run to kill ALL connections which are using model database.

SELECT 'KILL ' + CONVERT(varchar(10), l.request_session_id)
 FROM sys.databases d, sys.dm_tran_locks l
 WHERE d.database_id = l.resource_database_id
 AND d.name = 'model'
```
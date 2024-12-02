# Descrição da Consulta de Agendamentos do SQL Server

Este script consulta as tabelas do banco de dados `msdb` para retornar informações sobre os jobs do SQL Server que são configurados para serem executados automaticamente quando o SQL Server Agent é iniciado.

## Explicação do Script

- **Tabelas Consultadas**:
  - `msdb.dbo.sysjobs`: Contém informações sobre os jobs do SQL Server.
  - `msdb.dbo.sysjobschedules`: Relaciona os jobs aos seus agendamentos.
  - `msdb.dbo.sysschedules`: Contém os detalhes dos agendamentos, incluindo a frequência.

- **Condições**:
  - A consulta faz um `JOIN` entre as tabelas `sysjobs`, `sysjobschedules` e `sysschedules` para combinar os dados dos jobs e seus agendamentos.
  - A condição `WHERE C.freq_type = 64` filtra apenas os jobs agendados para iniciar automaticamente quando o SQL Server Agent for iniciado.

## Resultado Esperado

A consulta retorna todos os jobs que estão configurados para iniciar automaticamente com o SQL Server Agent, fornecendo informações sobre os jobs, seus agendamentos e a frequência com que devem ser executados.

```sql
SELECT 
	*
FROM 
	msdb.dbo.sysjobs A
	JOIN msdb.dbo.sysjobschedules B ON B.job_id = A.job_id
	JOIN msdb.dbo.sysschedules C ON C.schedule_id = B.schedule_id
WHERE
	C.freq_type = 64 -- Start automatically when SQL Server Agent starts
```
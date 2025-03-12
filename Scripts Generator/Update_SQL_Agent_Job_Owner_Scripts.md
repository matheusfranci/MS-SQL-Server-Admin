# Geração de Scripts para Atualizar o Proprietário de Jobs do SQL Agent

Este script SQL gera dinamicamente scripts para atualizar o proprietário de jobs do SQL Server Agent no banco de dados `msdb`. Ele consulta as tabelas `msdb.dbo.sysjobs` e `master.dbo.syslogins` para obter informações sobre os jobs e seus proprietários e gera scripts `sp_update_job` para alterar o proprietário para `marcos.vinicius`.

## Visão Geral do Script

O script executa as seguintes etapas:

1.  **Consulta `msdb.dbo.sysjobs` e `master.dbo.syslogins`:** Consulta as tabelas `msdb.dbo.sysjobs` e `master.dbo.syslogins` para obter informações sobre jobs e logins.
2.  **Junção das Tabelas:** Junta as tabelas `msdb.dbo.sysjobs` e `master.dbo.syslogins` com base no SID do proprietário do job.
3.  **Geração de Scripts `sp_update_job`:** Gera scripts `sp_update_job` para cada job, com as seguintes opções:
    * `@job_id`: ID do job (convertido para `VARCHAR(36)`).
    * `@owner_login_name`: `marcos.vinicius` (novo proprietário do job).
4.  **Exibição dos Scripts:** Exibe os scripts gerados como resultado da consulta.

## Detalhes do Script

```sql
SELECT 'USE [msdb]
GO
EXEC msdb.dbo.sp_update_job @job_id = N''' + CONVERT(VARCHAR(36), j.job_id) + ''', @owner_login_name = N''marcos.vinicius''
GO'
FROM
    msdb.dbo.sysjobs j
INNER JOIN
    master.dbo.syslogins s ON j.owner_sid = s.sid;

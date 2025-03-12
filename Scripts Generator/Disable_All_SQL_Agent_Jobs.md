# Geração de Scripts para Desabilitar Todos os Jobs do SQL Agent

Este script SQL gera dinamicamente scripts para desabilitar todos os jobs do SQL Server Agent. Ele consulta a tabela `msdb.dbo.sysjobs` e gera scripts `exec msdb.dbo.sp_update_job` para definir o status `@enabled` como 0 (desabilitado) para cada job.

## Visão Geral do Script

O script executa as seguintes etapas:

1.  **Consulta `msdb.dbo.sysjobs`:** Consulta a tabela `msdb.dbo.sysjobs` para obter o nome de todos os jobs do SQL Server Agent.
2.  **Geração de Scripts:** Gera scripts `exec msdb.dbo.sp_update_job` para desabilitar cada job encontrado.
3.  **Exibição dos Scripts:** Exibe os scripts gerados como resultado da consulta.

## Detalhes do Script

```sql
SELECT 'exec msdb.dbo.sp_update_job @job_name = '''+name+''', @enabled = 0
GO'
FROM msdb.dbo.sysjobs

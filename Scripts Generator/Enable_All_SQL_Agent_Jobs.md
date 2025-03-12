# Geração de Scripts para Habilitar Todos os Jobs do SQL Agent

Este script SQL gera dinamicamente scripts para habilitar todos os jobs do SQL Server Agent. Ele consulta a tabela `msdb.dbo.sysjobs` e gera scripts `EXEC msdb.dbo.sp_update_job` para definir o status `@enabled` como 1 (habilitado) para cada job.

## Visão Geral do Script

O script executa as seguintes etapas:

1.  **Consulta `msdb.dbo.sysjobs`:** Consulta a tabela `msdb.dbo.sysjobs` para obter o nome de todos os jobs do SQL Server Agent.
2.  **Geração de Scripts:** Gera scripts `EXEC msdb.dbo.sp_update_job` para habilitar cada job encontrado.
3.  **Exibição dos Scripts:** Exibe os scripts gerados como resultado da consulta.

## Detalhes do Script

```sql
SELECT 'EXEC msdb.dbo.sp_update_job @job_name='''+name+''',
@enabled = 1
GO'
FROM msdb.dbo.sysjobs

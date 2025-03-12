# Gerador de Scripts para Desativar Espelhamento de Banco de Dados Sincronizado

Este script SQL gera dinamicamente scripts para desativar o espelhamento de bancos de dados que estão atualmente sincronizados. Ele utiliza as tabelas do sistema `sys.databases` e `sys.database_mirroring` para identificar os bancos de dados com espelhamento em estado "SYNCHRONIZED" e gera comandos `ALTER DATABASE` para desativá-los.

## Visão Geral do Script

O script executa as seguintes etapas:

1.  **Seleção de Dados:** Seleciona o nome do banco de dados de `sys.databases`.
2.  **Junção com `sys.database_mirroring`:** Junta as tabelas `sys.databases` e `sys.database_mirroring` para obter informações sobre o estado do espelhamento.
3.  **Filtragem por Estado Sincronizado:** Filtra os resultados para incluir apenas bancos de dados com `mirroring_state_desc` igual a "SYNCHRONIZED".
4.  **Geração de Script:** Constrói dinamicamente um script `ALTER DATABASE ... SET PARTNER OFF` para cada banco de dados filtrado.
5.  **Exibição dos Scripts:** Exibe os scripts gerados como resultado da consulta.

## Detalhes do Script

```sql
SELECT 'ALTER DATABASE ['+ db.name +'] SET PARTNER OFF
GO'
FROM sys.databases db
inner join sys.database_mirroring dm
on db.database_id = dm.database_id
WHERE dm.mirroring_state_desc = 'SYNCHRONIZED';

# Geração de Scripts para Definir o Nível de Segurança do Espelhamento de Banco de Dados para OFF

Este script SQL gera dinamicamente scripts para alterar o nível de segurança do espelhamento de banco de dados (database mirroring) para `OFF` em bancos de dados onde o nível de segurança atual é `FULL`. Ele consulta as tabelas `sys.databases` e `sys.database_mirroring` para identificar os bancos de dados com espelhamento configurado e gera scripts `ALTER DATABASE` para definir o nível de segurança para `OFF`.

## Visão Geral do Script

O script executa as seguintes etapas:

1.  **Consulta `sys.databases` e `sys.database_mirroring`:** Consulta as tabelas `sys.databases` e `sys.database_mirroring` para obter informações sobre bancos de dados e espelhamento.
2.  **Filtragem de Bancos de Dados:** Filtra os bancos de dados para incluir apenas aqueles com espelhamento configurado e onde o nível de segurança atual é `FULL`.
3.  **Geração de Scripts `ALTER DATABASE ... SET SAFETY OFF`:** Gera scripts `ALTER DATABASE [database_name] SET SAFETY OFF` para cada banco de dados filtrado.
4.  **Exibição dos Scripts:** Exibe os scripts gerados como resultado da consulta.

## Detalhes do Script

```sql
SELECT 'ALTER DATABASE ['+ db.name +'] SET SAFETY OFF
GO'
FROM sys.databases db
inner join sys.database_mirroring dm
on db.database_id = dm.database_id
WHERE dm.mirroring_safety_level_desc = 'FULL';

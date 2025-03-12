# Geração de Scripts para Excluir Dados de Tabelas

Este documento descreve dois scripts SQL que geram dinamicamente scripts `DELETE FROM` para limpar dados de tabelas em um banco de dados.

## Script 1: Excluir Dados de Todas as Tabelas

Este script gera scripts `DELETE FROM` para todas as tabelas encontradas no esquema `INFORMATION_SCHEMA.TABLES`, independentemente do tipo de tabela.

### Visão Geral do Script

O script executa as seguintes etapas:

1.  **Consulta `INFORMATION_SCHEMA.TABLES`:** Consulta a tabela `INFORMATION_SCHEMA.TABLES` para obter o esquema e o nome de todas as tabelas no banco de dados.
2.  **Geração de Scripts:** Gera scripts `DELETE FROM` para cada tabela encontrada.
3.  **Exibição dos Scripts:** Exibe os scripts gerados como resultado da consulta.

### Detalhes do Script

```sql
SELECT 'DELETE FROM ['+ TABLE_SCHEMA +'].['+ TABLE_NAME +']
GO'
FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE = 'BASE TABLE';

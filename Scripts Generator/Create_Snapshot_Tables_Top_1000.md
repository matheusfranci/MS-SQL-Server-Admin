# Geração de Scripts para Copiar as 1000 Primeiras Linhas de Tabelas

Este script SQL gera dinamicamente scripts `SELECT TOP 1000 ... INTO ...` para copiar as 1000 primeiras linhas de cada tabela no banco de dados atual para uma nova tabela com o nome original da tabela seguido por um sufixo de data (neste caso, `20240719`).

## Visão Geral do Script

O script executa as seguintes etapas:

1.  **Consulta `sys.tables`:** Consulta a tabela `sys.tables` para obter informações sobre todas as tabelas no banco de dados atual.
2.  **Geração de Scripts `SELECT TOP 1000 ... INTO ...`:** Gera scripts `SELECT TOP 1000 * INTO [table_name20240719] FROM [table_name]` para cada tabela.
3.  **Adição de Quebra de Linha e `GO`:** Adiciona uma quebra de linha (`CHAR(13) + CHAR(10)`) e o comando `GO` para separar os scripts gerados.
4.  **Exibição dos Scripts:** Exibe os scripts gerados como resultado da consulta.

## Detalhes do Script

```sql
SELECT
    'SELECT TOP 1000 * INTO [' + name + '20240719] FROM [' + name + ']' + CHAR(13) + CHAR(10) + 'GO'
FROM
    sys.tables;

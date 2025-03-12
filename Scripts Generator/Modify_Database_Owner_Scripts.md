# Gerador de Scripts para Alterar Proprietário de Banco de Dados

Este script SQL gera dinamicamente scripts para alterar o proprietário de bancos de dados de usuário (excluindo bancos de dados do sistema) para o login "marcos.vinicius". Ele utiliza a tabela do sistema `sys.databases` para identificar os bancos de dados com proprietários diferentes de "marcos.vinicius" e gera comandos `ALTER AUTHORIZATION` para alterar a propriedade.

## Visão Geral do Script

O script executa as seguintes etapas:

1.  **Seleção de Dados:** Seleciona o nome do banco de dados de `sys.databases`.
2.  **Filtragem por Proprietário:** Filtra os resultados para incluir apenas bancos de dados cujo proprietário (identificado por `SUSER_SNAME(owner_sid)`) não é "marcos.vinicius".
3.  **Filtragem de Bancos de Dados do Sistema:** Exclui os bancos de dados do sistema (`master`, `msdb`, `tempdb`, `model`).
4.  **Geração de Script:** Constrói dinamicamente um script `ALTER AUTHORIZATION` para cada banco de dados filtrado, definindo o proprietário como "marcos.vinicius".
5.  **Exibição dos Scripts:** Exibe os scripts gerados como resultado da consulta.

## Detalhes do Script

```sql
SELECT
'USE MASTER
GO
ALTER AUTHORIZATION ON DATABASE::['+name+'] TO [marcos.vinicius]
GO'
    FROM sys.databases
    where SUSER_SNAME(owner_sid) != 'marcos.vinicius'
    and name NOT IN ('master', 'msdb', 'tempdb', 'model')

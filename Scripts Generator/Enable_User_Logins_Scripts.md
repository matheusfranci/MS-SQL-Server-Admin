# Geração de Scripts para Habilitar Logins de Usuário

Este script SQL gera dinamicamente scripts para habilitar logins de usuário no SQL Server. Ele consulta a tabela `syslogins` e gera scripts `ALTER LOGIN ... ENABLE` para habilitar logins que não correspondem a determinados critérios.

## Visão Geral do Script

O script executa as seguintes etapas:

1.  **Consulta `syslogins`:** Consulta a tabela `syslogins` para obter o nome de todos os logins.
2.  **Filtragem de Logins:** Filtra os logins para excluir logins específicos (`siga`, `sa`, `S2\matheussantos.orion`) e logins que correspondem a padrões específicos (logins temporários `#` e logins de sistema `sis.`).
3.  **Geração de Scripts:** Gera scripts `ALTER LOGIN ... ENABLE` para habilitar os logins restantes.
4.  **Exibição dos Scripts:** Exibe os scripts gerados como resultado da consulta.

## Detalhes do Script

```sql
SELECT
'ALTER LOGIN [' + loginname + '] ENABLE
GO'
FROM syslogins
WHERE name not IN ('siga', 'sa', 'S2\matheussantos.orion') and name not like '%#%' and name not like '%sis.%';

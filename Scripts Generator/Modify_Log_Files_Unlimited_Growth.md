# Gerador de Scripts para Configurar Arquivos de Log com Crescimento Ilimitado

Este script SQL gera dinamicamente scripts para modificar o tamanho máximo e o crescimento de todos os arquivos de log de banco de dados do usuário (excluindo bancos de dados do sistema). Ele configura o tamanho máximo (`MAXSIZE`) para `UNLIMITED` e o crescimento do arquivo (`FILEGROWTH`) para 262144 KB (256 MB).

## Visão Geral do Script

O script executa as seguintes etapas:

1.  **Seleção de Dados:** Seleciona o nome do arquivo de log e o nome do banco de dados de `sys.master_files` e `sys.databases`.
2.  **Geração de Script:** Constrói dinamicamente um script `ALTER DATABASE` para cada arquivo de log, configurando `MAXSIZE` e `FILEGROWTH`.
3.  **Filtragem de Bancos de Dados:** Exclui os bancos de dados do sistema (`master`, `msdb`, `tempdb`, `model`).
4.  **Exibição dos Scripts:** Exibe os scripts gerados como resultado da consulta.

## Detalhes do Script

```sql
SELECT
    'USE master
GO
ALTER DATABASE [' + b.name + '] MODIFY FILE (NAME = N''' + a.name + ''', MAXSIZE = UNLIMITED, FILEGROWTH = 262144KB )
GO'
FROM
    sys.master_files as a
INNER JOIN sys.databases as b
    on a.database_id = b.database_id
WHERE a.type_desc = 'LOG' and b.name not in ('master', 'msdb', 'tempdb', 'model');

# Geração de Scripts para Conceder Permissões de EXECUTE em Stored Procedures

Este script SQL gera dinamicamente scripts para conceder permissões `EXECUTE` em stored procedures específicas para o usuário `suporte_dados`. Ele consulta as tabelas de sistema `sys.objects`, `sys.procedures` e `sys.schemas` para identificar as stored procedures nos esquemas especificados e gera scripts `GRANT EXECUTE` correspondentes.

## Visão Geral do Script

O script executa as seguintes etapas:

1.  **Consulta `sys.objects`, `sys.procedures` e `sys.schemas`:** Consulta as tabelas de sistema para obter informações sobre stored procedures e seus esquemas.
2.  **Filtragem de Esquemas:** Filtra as stored procedures para incluir apenas aquelas nos esquemas com IDs 1 e 8.
3.  **Geração de Scripts `GRANT EXECUTE`:** Gera scripts `GRANT EXECUTE ON OBJECT [schema].[procedure] TO suporte_dados` para cada stored procedure filtrada.
4.  **Remoção de Duplicatas:** Utiliza `DISTINCT` para garantir que apenas um script seja gerado para cada stored procedure única.
5.  **Exibição dos Scripts:** Exibe os scripts gerados como resultado da consulta.

## Detalhes do Script

```sql
SELECT DISTINCT
'GRANT EXECUTE ON OBJECT [' + s.Name + '].[' + o.name + ']
TO suporte_dados
GO'
FROM sys.objects o
INNER JOIN sys.procedures p ON p.object_id = o.object_id
INNER JOIN sys.schemas s ON s.schema_id = o.schema_id
WHERE s.schema_id IN (1, 8);

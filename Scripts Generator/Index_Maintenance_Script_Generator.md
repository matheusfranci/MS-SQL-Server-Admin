# Geração de Scripts para Manutenção de Índices com Base na Fragmentação

Este script SQL consulta a fragmentação de índices em um banco de dados específico (`curso`) e gera scripts para reconstruir ou reorganizar os índices com base nos níveis de fragmentação.

## Visão Geral do Script

O script executa as seguintes etapas:

1.  **Consulta de Fragmentação:** Consulta a fragmentação média de índices usando a função `sys.dm_db_index_physical_stats`.
2.  **Junção com `sys.indexes`:** Junta os resultados com a tabela `sys.indexes` para obter o nome do índice e o nome da tabela.
3.  **Geração de Scripts:** Gera scripts `ALTER INDEX` para reconstruir ou reorganizar os índices com base nos seguintes critérios:
    * Fragmentação acima de 30%: Gera script `REBUILD WITH (ONLINE = ON)`.
    * Fragmentação entre 5% e 30% (inclusive): Gera script `REORGANIZE`.
4.  **Exibição dos Resultados:** Exibe o nome da tabela, o nome do índice, a fragmentação média e o script gerado.

## Detalhes do Script

```sql
select
    nome_tabela = object_name(b.object_id),
    nome_indice = name,
    fragmentacao_media = avg_fragmentation_in_percent,
    script = case
        when avg_fragmentation_in_percent > 30 then 'alter index ' + name + ' on ' + object_name(b.object_id) + ' rebuild with (online = on)'
        when avg_fragmentation_in_percent >= 5 and avg_fragmentation_in_percent <= 30 then 'alter index ' + name + ' on ' + object_name(b.object_id) + ' reorganize'
    end
from sys.dm_db_index_physical_stats (db_id('curso'), null, null, null, null) as a
join sys.indexes as b on a.object_id = b.object_id and a.index_id = b.index_id

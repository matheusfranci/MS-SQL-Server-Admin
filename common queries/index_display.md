### Este script recupera informações detalhadas sobre os índices em um banco de dados SQL Server, incluindo o nome do índice, as colunas incluídas no índice, o tipo de índice, se é único ou não, a tabela ou visão associada e o tipo de objeto. Abaixo está a descrição dos campos retornados:

### Campos de Saída:

- **index_name**: Nome do índice.
- **columns**: Lista de colunas incluídas no índice, separadas por vírgula.
- **index_type**: Tipo do índice, incluindo opções como:
  - Índice Clustered
  - Índice único não-clustered
  - Índice XML
  - Índice espacial
  - Índice clustered columnstore
  - Índice nonclustered columnstore
  - Índice nonclustered hash
- **unique**: Indica se o índice é único ou não.
- **table_view**: O esquema e o nome da tabela ou visão associada ao índice.
- **object_type**: Tipo do objeto associado ao índice (Tabela ou Visão).

### Considerações:
- O script filtra objetos de sistema (`t.is_ms_shipped <> 1`).
- A condição `index_id > 0` garante que apenas índices válidos sejam retornados.
- As colunas associadas ao índice são ordenadas pelo `key_ordinal`.

Esse script é útil para auditar os índices em seu banco de dados SQL Server, fornecendo informações sobre a estrutura dos índices e os objetos com os quais estão associados.

```SQL
select i.[name] as index_name,
    substring(column_names, 1, len(column_names)-1) as [columns],
    case when i.[type] = 1 then 'Clustered index'
        when i.[type] = 2 then 'Nonclustered unique index'
        when i.[type] = 3 then 'XML index'
        when i.[type] = 4 then 'Spatial index'
        when i.[type] = 5 then 'Clustered columnstore index'
        when i.[type] = 6 then 'Nonclustered columnstore index'
        when i.[type] = 7 then 'Nonclustered hash index'
        end as index_type,
    case when i.is_unique = 1 then 'Unique'
        else 'Not unique' end as [unique],
    schema_name(t.schema_id) + '.' + t.[name] as table_view, 
    case when t.[type] = 'U' then 'Table'
        when t.[type] = 'V' then 'View'
        end as [object_type]
from sys.objects t
    inner join sys.indexes i
        on t.object_id = i.object_id
    cross apply (select col.[name] + ', '
                    from sys.index_columns ic
                        inner join sys.columns col
                            on ic.object_id = col.object_id
                            and ic.column_id = col.column_id
                    where ic.object_id = t.object_id
                        and ic.index_id = i.index_id
                            order by key_ordinal
                            for xml path ('') ) D (column_names)
where t.is_ms_shipped <> 1
and index_id > 0
order by i.[name]
```
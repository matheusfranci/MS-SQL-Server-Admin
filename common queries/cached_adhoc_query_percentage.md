# Consultas para Verificar o Percentual de Consultas Ad-hoc em Cache

## Descrição das Consultas

Essas consultas SQL são usadas para calcular o percentual de planos de execução do tipo *Ad-hoc* armazenados no cache de planos do SQL Server. Elas ajudam a avaliar se há uso excessivo de consultas Ad-hoc, o que pode impactar negativamente o desempenho do servidor ao ocupar espaço no cache.

### Detalhes:
1. **Primeira Consulta:**
   - Utiliza a visão de gerenciamento dinâmico `sys.dm_exec_cached_plans`.
   - Filtra planos do tipo *Ad-hoc* e calcula o percentual sobre o total de planos armazenados no cache.

2. **Segunda Consulta:**
   - Também utiliza `sys.dm_exec_cached_plans` para calcular o percentual de planos *Ad-hoc*.
   - O resultado é apresentado como uma coluna chamada `Ad-hoc query %`.

### Finalidade:
Essas consultas são úteis para identificar possíveis otimizações no uso de planos de execução, como a implementação de *parameterized queries* ou o uso de `OPTION(RECOMPILE)` para evitar o armazenamento de consultas Ad-hoc desnecessárias.

### Campos Retornados:
- **Ad-hoc query %**: Percentual de planos de execução do tipo *Ad-hoc* no cache.

```SQL
SELECT Convert(INT,
                Sum(CASE p.objtype WHEN 'Adhoc' THEN 1 ELSE 0 END) * 1.00
                / Count(*) * 100
              )
  FROM sys.dm_exec_cached_plans AS p
```

```SQL
SELECT Convert(INT,Sum
        (
        CASE a.objtype 
        WHEN 'Adhoc' 
        THEN 1 ELSE 0 END)
        * 1.00/ Count(*) * 100
              ) as 'Ad-hoc query %'
  FROM sys.dm_exec_cached_plans AS a
```
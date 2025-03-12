# Consulta de Configurações Recomendadas do SQL Server

Este script SQL consulta as configurações do SQL Server relacionadas a "Optimize for Ad hoc Workloads", "Cost Threshold for Parallelism" e "Max Degree of Parallelism". Ele exibe os valores atuais, mínimos e máximos, a descrição de cada configuração, valores recomendados e os comandos para alterar as configurações para os valores recomendados.

## Visão Geral do Script

O script executa as seguintes etapas:

1.  **Seleção de Dados:** Seleciona o nome, valor em uso, valor mínimo, valor máximo e descrição das configurações do SQL Server.
2.  **Cálculo de Valores Recomendados:** Calcula valores recomendados específicos para cada configuração.
3.  **Geração de Comandos:** Gera comandos `EXEC sys.sp_configure` para definir as configurações para os valores recomendados.
4.  **Filtragem de Configurações:** Filtra os resultados para incluir apenas as configurações "Optimize for Ad hoc Workloads", "Cost Threshold for Parallelism" e "Max Degree of Parallelism".
5.  **Ordenação dos Resultados:** Ordena os resultados pelo nome da configuração.

## Detalhes do Script

```sql
SELECT
    name as Nome,
    value_in_use as "Valor em uso",
    minimum as "Valor mínimo",
    maximum as "Valor máximo",
    description as "Descrição",
    CASE
        WHEN name = 'cost threshold for parallelism' THEN 50
        WHEN name = 'max degree of parallelism' THEN 8
        WHEN name = 'optimize for ad hoc workloads' THEN 1
        ELSE 'Pesquise'
    END "Valor recomendado",
    CASE
        WHEN name = 'cost threshold for parallelism' THEN 'EXEC sys.sp_configure N''cost threshold for parallelism'', N''50''
        GO'
        WHEN name = 'max degree of parallelism' THEN 'EXEC sys.sp_configure N''max degree of parallelism'', N''8''
        GO'
        WHEN name = 'optimize for ad hoc workloads' THEN 'EXEC sys.sp_configure N''optimize for ad hoc workloads'', N''1''
        GO'
        ELSE 'PESQUISE'
    END 'Comando'
FROM sys.configurations
WHERE name IN ('Optimize for Ad hoc Workloads', 'Cost Threshold for Parallelism', 'Max Degree of Parallelism')
ORDER BY name;

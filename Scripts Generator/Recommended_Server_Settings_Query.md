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
WHEN name = 'cost threshold for parallelism' THEN 'EXEC sys.sp_configure N''cost threshold for parallelism, N''50''
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

## Monitoramento do Espaço em Disco no SQL Server

Este script SQL realiza a consulta do espaço em disco dos volumes de arquivos de banco de dados no SQL Server, proporcionando informações sobre o espaço total, disponível e utilizado, tanto em GB quanto em percentual.

### Passos do Script:
1. **Consulta de Espaço no Volume**:
    - O script utiliza a função `dm_os_volume_stats` para acessar informações sobre os volumes de disco utilizados pelos arquivos do banco de dados.
    - Ele calcula o **Espaço Total**, **Espaço Disponível** e o **Espaço em Uso** (em %).

2. **Campos Retornados**:
    - **Data**: Data e hora do momento da execução da consulta.
    - **Montagem**: Ponto de montagem do volume no sistema.
    - **Volume**: Nome do volume lógico.
    - **Total (GB)**: Total de espaço do volume, em GB.
    - **Espaço Disponível (GB)**: Espaço disponível no volume, em GB.
    - **Espaço Disponível (%)**: Percentual de espaço disponível.
    - **Espaço em Uso (%)**: Percentual de espaço em uso.

3. **Filtro de Resultados**:
    - O script filtra os resultados para mostrar apenas os volumes que têm espaço em uso.

---

## Execução do Script PowerShell para Informações de Disco

A segunda parte do script utiliza o PowerShell para consultar informações detalhadas do espaço em disco dos volumes no servidor, coletando o nome do disco, o espaço total e o espaço livre em MB e GB.

### Passos do Script:
1. **Execução de Comando PowerShell**:
    - O comando PowerShell `Get-WmiObject` é executado via SQL Server usando `xp_cmdshell`.
    - Ele coleta dados do sistema operacional sobre o espaço em disco dos volumes de tipo `DriveType = 3` (disco rígido).

2. **Criação de Tabela Temporária**:
    - Uma tabela temporária (`#output`) é criada para armazenar o resultado do comando PowerShell.

3. **Conversão de Valores**:
    - O espaço total e livre é calculado em MB e GB, com conversão de unidades.
    - O script extrai os dados do resultado da execução do PowerShell e os apresenta de forma estruturada.

4. **Remoção da Tabela Temporária**:
    - Após a execução, a tabela temporária é descartada.
	
```SQL
SELECT DISTINCT
    GETDATE() as [Data],
    VS.volume_mount_point [Montagem] ,
    VS.logical_volume_name AS [Volume] ,
    CAST(CAST(VS.total_bytes AS DECIMAL(19, 2)) / 1024 / 1024 / 1024 AS DECIMAL(10, 2)) AS [Total (GB)] ,
    CAST(CAST(VS.available_bytes AS DECIMAL(19, 2)) / 1024 / 1024 / 1024 AS DECIMAL(10, 2)) AS [Espaço Disponível (GB)] ,
    CAST(( CAST(VS.available_bytes AS DECIMAL(19, 2)) / CAST(VS.total_bytes AS DECIMAL(19, 2)) * 100 ) AS DECIMAL(10, 2)) AS [Espaço Disponível ( % )] ,
    CAST(( 100 - CAST(VS.available_bytes AS DECIMAL(19, 2)) / CAST(VS.total_bytes AS DECIMAL(19, 2)) * 100 ) AS DECIMAL(10, 2)) AS [Espaço em uso ( % )]
FROM
    sys.master_files AS MF
    CROSS APPLY [sys].[dm_os_volume_stats](MF.database_id, MF.file_id) AS VS
WHERE
    CAST(VS.available_bytes AS DECIMAL(19, 2)) / CAST(VS.total_bytes AS DECIMAL(19, 2)) * 100 < 100;


declare @svrName varchar(255)
declare @sql varchar(400)
--by default it will take the current server name, we can the set the server name as well
set @svrName = @@SERVERNAME
set @sql = 'powershell.exe -c "Get-WmiObject -ComputerName ' + QUOTENAME(@svrName,'''') + ' -Class Win32_Volume -Filter ''DriveType = 3'' | select name,capacity,freespace | foreach{$_.name+''|''+$_.capacity/1048576+''%''+$_.freespace/1048576+''*''}"'
--creating a temporary table
CREATE TABLE #output
(line varchar(255))
--inserting disk name, total space and free space value in to temporary table
insert #output
EXEC xp_cmdshell @sql
--script to retrieve the values in MB from PS Script output
select rtrim(ltrim(SUBSTRING(line,1,CHARINDEX('|',line) -1))) as drivename
   ,round(cast(rtrim(ltrim(SUBSTRING(line,CHARINDEX('|',line)+1,
   (CHARINDEX('%',line) -1)-CHARINDEX('|',line)) )) as Float),0) as 'capacity(MB)'
   ,round(cast(rtrim(ltrim(SUBSTRING(line,CHARINDEX('%',line)+1,
   (CHARINDEX('*',line) -1)-CHARINDEX('%',line)) )) as Float),0) as 'freespace(MB)'
from #output
where line like '[A-Z][:]%'
order by drivename
--script to retrieve the values in GB from PS Script output
select rtrim(ltrim(SUBSTRING(line,1,CHARINDEX('|',line) -1))) as drivename
   ,round(cast(rtrim(ltrim(SUBSTRING(line,CHARINDEX('|',line)+1,
   (CHARINDEX('%',line) -1)-CHARINDEX('|',line)) )) as Float)/1024,0) as 'capacity(GB)'
   ,round(cast(rtrim(ltrim(SUBSTRING(line,CHARINDEX('%',line)+1,
   (CHARINDEX('*',line) -1)-CHARINDEX('%',line)) )) as Float) /1024 ,0)as 'freespace(GB)'
from #output
where line like '[A-Z][:]%'
order by drivename
--script to drop the temporary table
drop table #output



declare @svrName varchar(255)
declare @sql varchar(400)
--by default it will take the current server name, we can the set the server name as well
set @svrName = @@SERVERNAME
set @sql = 'powershell.exe -c "Get-WmiObject -ComputerName ' + QUOTENAME(@svrName,'''') + ' -Class Win32_Volume -Filter ''DriveType = 3'' | select name,capacity,freespace | foreach{$_.name+''|''+$_.capacity/1048576+''%''+$_.freespace/1048576+''*''}"'
--creating a temporary table
CREATE TABLE #output
(line varchar(255))
--inserting disk name, total space and free space value in to temporary table
insert #output
EXEC xp_cmdshell @sql
--script to retrieve the values in GB from PS Script output
select rtrim(ltrim(SUBSTRING(line,1,CHARINDEX('|',line) -1))) as drivename
   ,round(cast(rtrim(ltrim(SUBSTRING(line,CHARINDEX('|',line)+1,
   (CHARINDEX('%',line) -1)-CHARINDEX('|',line)) )) as Float)/1024,0) as 'capacity(GB)'
   ,round(cast(rtrim(ltrim(SUBSTRING(line,CHARINDEX('%',line)+1,
   (CHARINDEX('*',line) -1)-CHARINDEX('%',line)) )) as Float) /1024 ,0)as 'freespace(GB)'
from #output
where line like '[A-Z][:]%'
order by drivename
--script to drop the temporary table
drop table #output
```
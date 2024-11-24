### Descrição da Query

Essa query retorna informações detalhadas sobre os arquivos de banco de dados em um servidor SQL Server, incluindo tamanho, crescimento e uso de cada arquivo.

#### Campos Retornados:
1. **`Database Name`**: Nome do banco de dados ao qual o arquivo pertence.
2. **`Logical Name`**: Nome lógico do arquivo.
3. **`Size`**: Tamanho atual do arquivo, convertido para KB.
4. **`Max Size`**: Tamanho máximo configurado para o arquivo, exibindo "Unlimited" caso não haja limite.
5. **`Growth`**: Taxa de crescimento do arquivo, em percentual ou em KB.
6. **`usage`**: Tipo do arquivo:
   - **Data Only**: Arquivo de dados.
   - **Log Only**: Arquivo de log.
   - **FILESTREAM Only**: Arquivo associado ao FILESTREAM.
   - **Informational purposes Only**: Arquivo de uso informativo.
   - **Full-text**: Arquivo associado a índices de texto completo.

#### Tabelas Utilizadas:
- **`sys.master_files`**: Contém informações sobre todos os arquivos físicos associados aos bancos de dados no servidor.
- **`sys.filegroups`**: Fornece informações sobre grupos de arquivos nos bancos de dados.

#### Filtros e Junções:
- Usa `LEFT JOIN` entre `sys.master_files` e `sys.filegroups` para obter detalhes sobre grupos de arquivos, aplicando condições baseadas no tipo de arquivo e na ausência de remoção do log (`drop_lsn IS NULL`).

```SQL
SELECT
DB_name(S.database_id) AS [Database Name]
,S.[name] AS [Logical Name]
--,S.[file_id] AS [File ID]
--, S.[physical_name] AS [File Name]
--,CAST(CAST(G.name AS VARBINARY(256)) AS sysname) AS [FileGroup_Name]
,CONVERT (varchar(10),(S.[size]*8)) + ' KB' AS [Size]
,CASE WHEN S.[max_size]=-1 THEN 'Unlimited' ELSE CONVERT(VARCHAR(10),CONVERT(bigint,S.[max_size])*8) +' KB' END AS [Max Size]
,CASE s.is_percent_growth WHEN 1 THEN CONVERT(VARCHAR(10),S.growth) +'%' ELSE Convert(VARCHAR(10),S.growth*8) +' KB' END AS [Growth]
,Case WHEN S.[type]=0 THEN 'Data Only'
WHEN S.[type]=1 THEN 'Log Only'
WHEN S.[type]=2 THEN 'FILESTREAM Only'
WHEN S.[type]=3 THEN 'Informational purposes Only'
WHEN S.[type]=4 THEN 'Full-text '
END AS [usage]
FROM sys.master_files AS S
LEFT JOIN sys.filegroups AS G ON ((S.type = 2 OR S.type = 0)
AND (S.drop_lsn IS NULL)) AND (S.data_space_id=G.data_space_id)
```
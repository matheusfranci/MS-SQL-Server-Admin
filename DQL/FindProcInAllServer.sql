CREATE TABLE #tmpprocesult
(
Banco VARCHAR(MAX),
name VARCHAR(MAX),
type_desc VARCHAR(MAX),
create_date DATE,
modify_date DATE
)
INSERT INTO #tmpprocesult
exec SP_MSFOREACHDB'
USE [?]
select
DB_NAME() AS Banco,
name,
type_desc,
create_date,
modify_date
from 
   sys.procedures 
where 
   name like "%IT4CarregaDocumentosWMS_Diagonal%";'
   SELECT * FROM #tmpprocesult
DROP TABLE #tmpprocesult

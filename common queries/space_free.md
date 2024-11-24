### Descrição
Este script realiza uma consulta para verificar o espaço em disco disponível e o espaço utilizado pelos arquivos de banco de dados no SQL Server. Ele usa tabelas temporárias para armazenar informações sobre os discos e o espaço utilizado, calculando e apresentando os resultados de forma organizada.

### Explicação do Script
1. **Criação e inserção nas tabelas temporárias:**
   - A tabela temporária `#TMPFIXEDDRIVES` armazena o espaço livre em disco por unidade (Drive).
   - A tabela temporária `#TMPSPACEUSED` armazena o espaço utilizado por cada arquivo de banco de dados.
   - A primeira tabela temporária é preenchida executando `xp_FIXEDDRIVES`, uma extensão do SQL Server que retorna informações sobre as unidades de disco.
   - A segunda tabela temporária é preenchida com a execução de `sp_msforeachdb`, que coleta informações sobre o espaço utilizado por cada arquivo em todos os bancos de dados.

2. **Consulta principal:**
   - A consulta principal junta as tabelas `SYS.DATABASES` e `SYS.MASTER_FILES`, correlacionando as informações de cada banco de dados com o espaço livre nas unidades de disco.
   - A consulta exibe:
     - O nome da unidade de disco.
     - O espaço livre disponível no disco, formatado em MB ou GB, dependendo do valor.
     - O nome do banco de dados e do arquivo.
     - O tipo de arquivo (dados ou log).
     - O tamanho do arquivo, formatado em MB ou GB.
     - O espaço livre restante no arquivo.
     - O caminho físico do arquivo.

3. **Ordenação:**
   - Os resultados são ordenados pelo espaço livre no disco e pelo espaço livre no arquivo, de forma decrescente.

4. **Limpeza:**
   - Após a consulta, as tabelas temporárias são removidas com `DROP TABLE`.
   
```SQL
USE master
GO 

CREATE TABLE #TMPFIXEDDRIVES ( DRIVE CHAR(1), MBFREE INT) 

INSERT INTO #TMPFIXEDDRIVES 
EXEC xp_FIXEDDRIVES 

CREATE TABLE #TMPSPACEUSED ( DBNAME VARCHAR(50), FILENME VARCHAR(50), SPACEUSED FLOAT) 

INSERT INTO #TMPSPACEUSED 
EXEC( 'sp_msforeachdb''use [?]; Select ''''?'''' DBName, Name FileNme, fileproperty(Name,''''SpaceUsed'''') SpaceUsed from sysfiles''') 

SELECT   C.DRIVE, 
         CASE  
           WHEN (C.MBFREE) > 1000 THEN CAST(CAST(((C.MBFREE) / 1024.0) AS DECIMAL(18,2)) AS VARCHAR(20)) + ' GB' 
           ELSE CAST(CAST((C.MBFREE) AS DECIMAL(18,2)) AS VARCHAR(20)) + ' MB' 
           END AS DISKSPACEFREE, 
         A.NAME AS DATABASENAME, 
         B.NAME AS FILENAME, 
         CASE B.TYPE  
           WHEN 0 THEN 'DATA' 
           ELSE TYPE_DESC 
           END AS FILETYPE, 
         CASE  
           WHEN (B.SIZE * 8 / 1024.0) > 1000 
           THEN CAST(CAST(((B.SIZE * 8 / 1024) / 1024.0) AS DECIMAL(18,2)) AS VARCHAR(20)) + ' GB' 
           ELSE CAST(CAST((B.SIZE * 8 / 1024.0) AS DECIMAL(18,2)) AS VARCHAR(20)) + ' MB' 
           END AS FILESIZE, 
         CAST((B.SIZE * 8 / 1024.0) - (D.SPACEUSED / 128.0) AS DECIMAL(15,2)) SPACEFREE, 
         B.PHYSICAL_NAME 
FROM     SYS.DATABASES A 
         JOIN SYS.MASTER_FILES B ON A.DATABASE_ID = B.DATABASE_ID 
         JOIN #TMPFIXEDDRIVES C  ON LEFT(B.PHYSICAL_NAME,1) = C.DRIVE 
         JOIN #TMPSPACEUSED D    ON A.NAME = D.DBNAME AND B.NAME = D.FILENME 
ORDER BY DISKSPACEFREE, 
         SPACEFREE DESC 
          
DROP TABLE #TMPFIXEDDRIVES 

DROP TABLE #TMPSPACEUSED 
```
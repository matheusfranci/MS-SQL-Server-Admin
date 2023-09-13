DECLARE @search VARCHAR(100), @table SYSNAME, @column SYSNAME

DECLARE curTabCol CURSOR FOR
    SELECT c.TABLE_SCHEMA + '.' + c.TABLE_NAME, c.COLUMN_NAME
    FROM INFORMATION_SCHEMA.COLUMNS c
    JOIN INFORMATION_SCHEMA.TABLES t 
      ON t.TABLE_NAME=c.TABLE_NAME AND t.TABLE_TYPE='BASE TABLE' -- avoid views
    WHERE c.DATA_TYPE IN ('varchar','nvarchar') -- searching only in these column types
    --AND c.COLUMN_NAME IN ('NAME','DESCRIPTION') -- searching only in these column names

SET @search='String aqui'

OPEN curTabCol
FETCH NEXT FROM curTabCol INTO @table, @column

WHILE (@@FETCH_STATUS = 0)
BEGIN
    EXECUTE('IF EXISTS 
             (SELECT * FROM ' + @table + ' WHERE ' + @column + ' = ''' + @search + ''') 
             PRINT ''' + @table + '.' + @column + '''')
    FETCH NEXT FROM curTabCol INTO @table, @column
END

CLOSE curTabCol
DEALLOCATE curTabCol

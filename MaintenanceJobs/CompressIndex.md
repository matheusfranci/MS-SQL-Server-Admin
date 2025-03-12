# Script: Compressão de Índices Particionados

Este script SQL realiza a compressão de dados em índices particionados, reconstruindo-os com compressão de página (`PAGE`) e um fator de preenchimento (`FILLFACTOR`) de 90. Ele também inclui um horário de corte para interromper o processo.

```sql
DECLARE   
    @comando          NVARCHAR(MAX),
	@horario_de_corte VARCHAR(20)
DECLARE
    cur_compressao CURSOR FOR SELECT DISTINCT 
                                     'ALTER INDEX ' + QUOTENAME(i.name)
                                     + ' ON '
                                     + QUOTENAME(OBJECT_SCHEMA_NAME(o.object_id))
                                     + '.'
                                     + QUOTENAME(OBJECT_NAME(o.object_id))
                                     + ' REBUILD PARTITION = ALL WITH (FILLFACTOR = 90, DATA_COMPRESSION = PAGE)'
                              FROM sys.partitions p
                               JOIN sys.indexes i ON i.object_id = p.object_id AND i.index_id = p.index_id
                               JOIN sys.objects o ON i.object_id = o.object_id
                               WHERE p.data_compression = 0
							     AND  QUOTENAME(OBJECT_SCHEMA_NAME(o.object_id)) <> '[sys]'
BEGIN
    IF CONVERT(VARCHAR(20), GETDATE(), 120) > CONVERT(VARCHAR(20), GETDATE(), 23) + ' 05:45:00'
        SET @horario_de_corte = CONVERT(VARCHAR(20), GETDATE() + 1, 23) + ' 05:45:00'
    ELSE
        SET @horario_de_corte = CONVERT(VARCHAR(20), GETDATE(), 23) + ' 05:45:00'	
    OPEN cur_compressao
    FETCH cur_compressao INTO @comando
    WHILE @@fetch_status = 0
    BEGIN
	    IF CONVERT(VARCHAR(20), GETDATE(), 120) > @horario_de_corte
		BEGIN
	    	CLOSE cur_compressao
        	DEALLOCATE cur_compressao
		    RETURN
		END
	    EXEC sys.sp_executesql @comando
	    FETCH cur_compressao INTO @comando
    END
	CLOSE cur_compressao
	DEALLOCATE cur_compressao
END

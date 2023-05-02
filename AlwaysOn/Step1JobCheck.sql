DECLARE 
@NODE INT;
IF 
(SELECT TOP 1 role
    FROM sys.dm_hadr_availability_replica_states) < 2
	SET @NODE = 1
	ELSE
	SET @NODE = 2
IF @NODE < 2
PRINT'1'
ELSE
SELECT 1/0

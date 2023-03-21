-- Find who is having connection? Below query can help in that.

IF EXISTS (
        SELECT request_session_id
        FROM sys.dm_tran_locks
        WHERE resource_database_id = DB_ID('model')
        )
BEGIN
    PRINT 'Model Database in use!!'
    SELECT *
    FROM sys.dm_exec_sessions
    WHERE session_id IN (
            SELECT request_session_id
            FROM sys.dm_tran_locks
            WHERE resource_database_id = DB_ID('model')
            )
END
ELSE
    PRINT 'Model Database not in used.'
    
-- Kill the connection. Below query would provide KILL command which we can run to kill ALL connections which are using model database.

SELECT 'KILL ' + CONVERT(varchar(10), l.request_session_id)
 FROM sys.databases d, sys.dm_tran_locks l
 WHERE d.database_id = l.resource_database_id
 AND d.name = 'model'

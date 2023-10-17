WITH 
    p AS
(
  SELECT 
      [path] = 
          REVERSE(SUBSTRING(p, CHARINDEX(N'\', p), 260)) + N'log.trc'
  FROM 
  (
       SELECT 
           REVERSE([path]) 
       FROM sys.traces WHERE is_default = 1
  ) s (p)
)
SELECT 
   t.TextData,
   t.DatabaseID,
   t.HostName,
   t.ApplicationName,
   t.LoginName,
   t.SPID,
   t.StartTime,
   t.DatabaseName,
   t.SessionLoginName
FROM p 
CROSS APPLY sys.fn_trace_gettable(p.[path], DEFAULT) AS t
WHERE t.TextData LIKE N'%memory (MB)%'
AND   t.TextData NOT LIKE N'WITH%p%'
ORDER BY t.StartTime DESC;

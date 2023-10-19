-->Plan Cache Summary<-----------------------------------------
DECLARE @start DATETIME, @end DATETIME
SELECT @start = DATEADD(hh,-24,GETDATE())
SELECT @end = GETDATE()

SELECT 
'Plan Cache' AS [counter],
Hits.[instance_name], 
CAST(MIN((Hits.[cntr_value] * 1.0 / Total.[cntr_value]) * 100.0) AS DECIMAL(5,2)) AS [hit_ratio_MIN], 
MIN(Pages.[cntr_value]) AS [page_MIN], 
(MIN(Pages.[cntr_value]) * 8/1024) AS [mb_MIN], 
CAST(AVG((Hits.[cntr_value] * 1.0 / Total.[cntr_value]) * 100.0) AS DECIMAL(5,2)) AS [hit_ratio_AVG], 
AVG(Pages.[cntr_value]) AS [page_AVG], 
(AVG(Pages.[cntr_value]) * 8/1024) AS [mb_AVG], 
CAST(MAX((Hits.[cntr_value] * 1.0 / Total.[cntr_value]) * 100.0) AS DECIMAL(5,2)) AS [hit_ratio_MAX], 
MAX(Pages.[cntr_value]) AS [page_MAX],
(MAX(Pages.[cntr_value]) * 8/1024) AS [mb_MAX] 
FROM 
(
SELECT [instance_name], [cntr_value], [date_stamp], [counter_name]
FROM iDBA.[MetaBOT].[dm_os_performance_counters]
WHERE [counter_name] = 'Cache Hit Ratio'
AND [date_stamp] BETWEEN @start AND @end

) Hits 

INNER JOIN

(
SELECT [instance_name], [cntr_value], [date_stamp] 
FROM iDBA.[MetaBOT].[dm_os_performance_counters] 
WHERE [counter_name] = 'Cache Hit Ratio Base'
AND [date_stamp] BETWEEN @start AND @end
) Total 
ON Hits.[date_stamp] = Total.[date_stamp] 
AND [Hits].[instance_name] = [Total].[instance_name]

INNER JOIN 

(
SELECT [instance_name], [cntr_value], [date_stamp] 
FROM iDBA.[MetaBOT].[dm_os_performance_counters] 
WHERE [object_name] LIKE '%:Plan Cache%'
AND [counter_name] = 'Cache Pages'
AND [date_stamp] BETWEEN @start AND @end
) Pages
ON Hits.[date_stamp] = [Pages].[date_stamp]
AND Hits.[instance_name] = [Pages].[instance_name]
GROUP BY Hits.[counter_name], Hits.[instance_name];	

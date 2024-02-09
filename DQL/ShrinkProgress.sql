select
[status],
start_time,
convert(varchar,(total_elapsed_time/(1000))/60) + 'M ' + convert(varchar,(total_elapsed_time/(1000))%60) + 'S' AS [Elapsed],
convert(varchar,(estimated_completion_time/(1000))/60) + 'M ' + convert(varchar,(estimated_completion_time/(1000))%60) + 'S' as [ETA],
command,
last_wait_type,
database_id,
blocking_session_id,
percent_complete
from  sys.dm_exec_requests
where estimated_completion_time > 1
order by total_elapsed_time desc


select
[status],
start_time as "Início",
convert(varchar,(total_elapsed_time/(1000))/60) + 'M ' + convert(varchar,(total_elapsed_time/(1000))%60) + 'S' AS [Tempo de processamento],
convert(varchar,(estimated_completion_time/(1000))/60) + 'M ' + convert(varchar,(estimated_completion_time/(1000))%60) + 'S' as [Estimativa em min],
command as "Comando",
last_wait_type,
database_id,
blocking_session_id as "Sessão bloqueadora",
percent_complete as "Percentual completo"
from  sys.dm_exec_requests
where estimated_completion_time > 1
order by total_elapsed_time desc

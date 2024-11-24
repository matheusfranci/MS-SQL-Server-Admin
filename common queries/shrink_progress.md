### Descrição
Este script consulta a DMV `sys.dm_exec_requests` para exibir informações detalhadas sobre as requisições em execução no SQL Server, incluindo tempo de processamento, estimativas de conclusão, percentual de progresso, entre outros.

### Explicação do Script
1. **Seleção de colunas:**
   - `status`: estado atual da requisição.
   - `start_time`: momento de início da execução.
   - `Tempo de processamento`: tempo total que a requisição está em execução, convertido para minutos e segundos.
   - `Estimativa em min`: estimativa de tempo restante para a conclusão da requisição, convertida para minutos e segundos.
   - `command`: comando que está sendo executado.
   - `last_wait_type`: tipo de espera mais recente.
   - `database_id`: ID do banco de dados em que a requisição está sendo executada.
   - `blocking_session_id`: ID da sessão que está bloqueando a requisição.
   - `percent_complete`: percentual de conclusão da requisição.

2. **Filtro:**
   - A cláusula `WHERE` filtra as requisições com `estimated_completion_time` maior que 1 segundo.

3. **Ordenação:**
   - A consulta é ordenada pela coluna `total_elapsed_time` de forma decrescente, ou seja, as requisições que estão em execução por mais tempo aparecerão primeiro.

```SQL
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
```
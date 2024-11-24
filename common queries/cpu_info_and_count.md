# Consulta para Obter Informações sobre CPUs Lógicas e Físicas

## Descrição da Consulta

Esta consulta recupera informações sobre o número de CPUs lógicas e físicas disponíveis no servidor SQL. As informações são obtidas a partir da visão `sys.dm_os_sys_info`, que fornece detalhes sobre a configuração do sistema operacional e do hardware do servidor, incluindo CPUs e memória.

### Detalhes:
1. **Fontes de Dados:**
   - `sys.dm_os_sys_info`: Exibe informações do sistema operacional relacionadas ao SQL Server, incluindo detalhes sobre a CPU, memória e outros recursos do servidor.

2. **Cálculos:**
   - **Logical CPU Count**: Retorna o número de CPUs lógicas do servidor.
   - **Hyperthread Ratio**: Retorna a proporção entre CPUs lógicas e físicas, considerando se o servidor está utilizando hyperthreading.
   - **Physical CPU Count**: Calcula o número de CPUs físicas, dividindo o número de CPUs lógicas pelo valor da proporção de hyperthreading.

3. **Uso de `OPTION (RECOMPILE)`**:
   - A diretiva `OPTION (RECOMPILE)` instrui o SQL Server a reavaliar o plano de execução da consulta a cada execução, garantindo que a consulta use os dados mais atualizados.

### Finalidade:
Esta consulta é útil para identificar e monitorar a configuração de CPUs do servidor, o que pode ser importante para análise de desempenho e para verificar a eficiência do uso de hardware, especialmente em servidores com hyperthreading.

```SQL
SELECT cpu_count AS [Logical CPU Count], hyperthread_ratio AS [Hyperthread Ratio],
cpu_count/hyperthread_ratio AS [Physical CPU Count] 
FROM sys.dm_os_sys_info OPTION (RECOMPILE);
```
## Explicação do Script SQL

Este script realiza a verificação do estado de uma réplica de disponibilidade em um ambiente de Always On no SQL Server, definindo um valor para a variável `@NODE` com base no papel da réplica. Em seguida, executa uma condicional que imprime ou gera um erro, dependendo do valor de `@NODE`.

### Passos do Script:

1. **Declaração de Variáveis:**
   - A variável `@NODE` é declarada como um inteiro, que será utilizada para armazenar um valor com base na verificação do papel da réplica.

2. **Verificação do Papel da Réplica:**
   - O script executa uma consulta que verifica o papel da réplica de disponibilidade no sistema `sys.dm_hadr_availability_replica_states`. Se o valor do papel for menor que 2, isso indica que a réplica é primária, e a variável `@NODE` é configurada para 1.
   - Caso contrário, `@NODE` é configurada para 2, indicando que a réplica é secundária.

3. **Condicional com Base no Valor de `@NODE`:**
   - Se o valor de `@NODE` for menor que 2 (indicando que a réplica é primária), o script imprime o valor '1'.
   - Caso contrário, ele tenta realizar uma operação de divisão por zero (`SELECT 1/0`), o que gera um erro de execução.

4. **Proteção contra Erro de Divisão por Zero:**
   - Há uma verificação de segurança (se `1 = 0`) para evitar o erro de divisão por zero real. Caso o valor de `@NODE` seja maior ou igual a 2, a operação de divisão por zero não será executada diretamente. 

Este script pode ser útil em ambientes de alta disponibilidade para monitoramento ou controle de fluxos específicos com base no estado da réplica.

```SQL
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
```
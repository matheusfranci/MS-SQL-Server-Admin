### Descrição
Este script lê o valor do registro no Windows que especifica o plano de energia ativo no sistema, verificando o valor associado à chave do registro e retornando o nome do plano de energia correspondente.

### Explicação do Script
1. **Declaração de variáveis:**
   - `@value`: armazena o valor retornado pela leitura do registro.
   - `@key`: especifica a chave do registro que contém as configurações de planos de energia.

2. **Execução do comando `xp_regread`:**  
   O comando `xp_regread` é usado para ler um valor de registro do sistema, nesse caso, o valor associado à chave `ActivePowerScheme` que determina o plano de energia ativo.

3. **Condicional:**  
   O script verifica o valor de `@value` retornado e retorna o nome correspondente ao plano de energia ativo:
   - `381b4222-f694-41f0-9685-ff5bb260df2e` -> (Balanced)
   - `8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c` -> (High performance)
   - `a1841308-3541-4fab-bc81-f71556f20b4a` -> (Power saver)
   
```SQL
DECLARE
    @value VARCHAR(64),
    @key VARCHAR(512) = 'SYSTEM\CurrentControlSet\Control\Power\User\PowerSchemes'
EXEC master..xp_regread
    @rootkey = 'HKEY_LOCAL_MACHINE',
    @key = @key,
    @value_name = 'ActivePowerScheme',
    @value = @value OUTPUT;
SELECT (CASE
    WHEN @value = '381b4222-f694-41f0-9685-ff5bb260df2e' THEN '(Balanced)'
    WHEN @value = '8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c' THEN '(High performance)'
    WHEN @value = 'a1841308-3541-4fab-bc81-f71556f20b4a' THEN '(Power saver)'
END)
```
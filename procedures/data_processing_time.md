# Script para Processamento de Arquivo e Cálculo de Tempo

Este script realiza a cópia de dados da tabela `empresas` para a tabela `empresas_bkp_07`, e calcula o tempo de processamento do arquivo, exibindo o tempo em minutos.

## Etapas:

1. **Definir Variável de Início**:
    - A variável `@StartTime` é definida com a data e hora atuais (`GETDATE()`), marcando o início do processamento.

2. **Imprimir Mensagem de Início**:
    - Uma mensagem é exibida no console para informar que o processamento do arquivo está em andamento.

3. **Copiar Dados**:
    - A consulta `SELECT CNPJ_BASICO INTO empresas_bkp_07 FROM empresas` copia os dados da coluna `CNPJ_BASICO` da tabela `empresas` para a tabela `empresas_bkp_07`.

4. **Calcular o Tempo de Processamento**:
    - A variável `@Dur` calcula o tempo de execução em minutos, utilizando a função `DATEDIFF` para medir a diferença entre o tempo atual (`GETDATE()`) e o tempo de início (`@StartTime`).

5. **Imprimir o Tempo de Processamento**:
    - O tempo de processamento é impresso no console, com a mensagem "Arquivo processado em X minutos", onde X é o tempo calculado.

6. **Imprimir Mensagem de Finalização**:
    - Uma mensagem de finalização é exibida no console.

## Uso:
- Este script pode ser útil para monitorar o tempo necessário para processar grandes volumes de dados e gerar backups ou relatórios de tabelas específicas.

```sql
DECLARE @StartTime DATETIME = GETDATE();
PRINT '---------------------------------------------------------'
PRINT 'Segue caminho do arquivo processado: '
SELECT CNPJ_BASICO INTO empresas_bkp_07 FROM empresas;
DECLARE @Dur INT = DATEDIFF(MINUTE, @StartTime, GETDATE());
PRINT 'Arquivo processado em' + CAST(@Dur AS VARCHAR) + ' minutos';
PRINT '---------------------------------------------------------'
```
### Descrição da Query

Esta consulta é utilizada para verificar o status do serviço de **Database Mail** no SQL Server e, caso não esteja em execução, tentar reiniciá-lo.

1. **Desabilitar a Contagem de Linhas**:
   - `Set NoCount On` é utilizado para impedir que o SQL Server retorne o número de linhas afetadas pela execução das instruções, o que pode melhorar a performance.

2. **Criação da Tabela Temporária `#Status`**:
   - Uma tabela temporária chamada `#Status` é criada para armazenar o status do serviço de **Database Mail**.

3. **Inserção do Status do Database Mail**:
   - A consulta executa a stored procedure `msdb.dbo.sysmail_help_status_sp`, que retorna o status atual do **Database Mail**. O resultado é inserido na tabela temporária `#Status`.

4. **Verificação do Status**:
   - A consulta verifica se o status do **Database Mail** está como 'STARTED'. Se não estiver, significa que o serviço não está em execução.

5. **Tentativa de Reinício do Database Mail**:
   - Caso o serviço não esteja em execução, um erro é gerado com a mensagem "Database Mail was not running, attempting to restart" usando `Raiserror`.
   - Em seguida, a stored procedure `msdb.dbo.sysmail_start_sp` é executada para tentar iniciar o serviço de **Database Mail**.

6. **Exibição do Status**:
   - Por fim, o status atual do **Database Mail** é exibido pela consulta `SELECT * FROM #Status`.

```SQL
Set	Nocount On

If Object_Id('tempdb..#Status') Is Not Null
	Drop Table #Status
Go

Create Table #Status (
	[Status] Nvarchar(100)
)

Insert	#Status
Exec 	msdb.dbo.sysmail_help_status_sp

If Not Exists (
	Select	Top 1
			0
	From	#Status
	Where	Status = 'STARTED'
)
Begin
	Raiserror ('Database Mail was not running, attempting to restart', 16, 1) With Nowait
	Exec	msdb.dbo.sysmail_start_sp
End

SELECT * FROM #Status
```
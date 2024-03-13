

CREATE OR ALTER PROCEDURE [dbo].[stpTesta_Insert]
AS
BEGIN

	INSERT INTO dirceuresende.dbo.Teste ( Nome )
	VALUES( ORIGINAL_LOGIN() )

END



EXEC sys.sp_procoption 
	@ProcName = 'dbo.stpTesta_Insert', 
	@OptionName = 'startup', 
	@OptionValue = 'on'


SELECT TOP 100
    [name],
    [type_desc],
    [create_date],
    [modify_date],
    is_ms_shipped
FROM 
    sys.procedures
WHERE 
    is_auto_executed = 1


EXEC sys.sp_procoption 
	@ProcName = 'dbo.stpTesta_Insert', 
	@OptionName = 'startup', 
	@OptionValue = 'off'

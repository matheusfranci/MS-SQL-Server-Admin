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

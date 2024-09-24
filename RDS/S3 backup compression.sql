-- Verifica se o backup é comprimido
EXEC rdsadmin.dbo.rds_show_configuration
@name='S3 backup compression'

-- Caso retorne false, esse comando ativará a propriedade
exec rdsadmin..rds_set_configuration 'S3 backup compression', 'true';

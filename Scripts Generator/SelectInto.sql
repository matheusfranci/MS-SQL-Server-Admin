SELECT 
    'SELECT TOP 1000 * INTO [' + name + '20240719] FROM [' + name + ']' + CHAR(13) + CHAR(10) + 'GO'
FROM
    sys.tables;

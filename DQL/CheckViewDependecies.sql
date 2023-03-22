SELECT referenced_database_name,referenced_schema_name, referenced_entity_name FROM sys.sql_expression_dependencies
 WHERE referencing_id = OBJECT_ID(N'nomedaview');

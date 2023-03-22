Use Database_name
SELECT
name,
OBJECT_DEFINITION(object_id) as "SQL Text"
FROM
sys.procedures
WHERE OBJECT_DEFINITION(object_id) LIKE '%Nomedaproc%';

SELECT 
    schema_name(o.schema_id) AS sch,
    object_name(s.object_id) AS [object_name],
    c.name AS [column_name],
    s.name AS [stats_name],
    s.stats_id,
    STATS_DATE(s.object_id, s.stats_id) AS [stats_update_date], 
    s.auto_created,
    s.user_created,
    'DROP STATISTICS [' + schema_name(o.schema_id) + '].[' + object_name(s.object_id) + '].[' + s.name + '];' AS cmd_drop,
	'CREATE STATISTICS [' + s.name + '] ON [' + schema_name(o.schema_id) + '].[' + object_name(s.object_id) + '] ([' + c.name + ']) WITH FULLSCAN;' AS cmd_create
FROM sys.stats AS s 
INNER JOIN sys.objects AS o 
    ON o.object_id = s.object_id 
INNER JOIN sys.stats_columns AS sc 
    ON s.object_id = sc.object_id 
    AND s.stats_id = sc.stats_id 
INNER JOIN sys.columns AS c 
    ON sc.object_id = c.object_id 
    AND c.column_id = sc.column_id
WHERE o.type = 'U' -- Only check for stats on user-tables
ORDER BY object_name, schema_name(o.schema_id), column_name;

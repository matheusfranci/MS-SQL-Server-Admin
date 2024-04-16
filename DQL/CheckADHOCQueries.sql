SELECT Convert(INT,
                Sum(CASE p.objtype WHEN 'Adhoc' THEN 1 ELSE 0 END) * 1.00
                / Count(*) * 100
              )
  FROM sys.dm_exec_cached_plans AS p

SELECT Convert(INT,Sum
        (
        CASE a.objtype 
        WHEN 'Adhoc' 
        THEN 1 ELSE 0 END)
        * 1.00/ Count(*) * 100
              ) as 'Ad-hoc query %'
  FROM sys.dm_exec_cached_plans AS a

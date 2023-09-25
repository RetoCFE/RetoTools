
SELECT 
	session_id,
	database_id,
	DB_NAME(database_id) db_name,
	percent_complete, 
	command,
	start_time,
 CAST(((DATEDIFF(s,start_time,GetDate()))/3600) as varchar) + ' hour(s), '
     + CAST((DATEDIFF(s,start_time,GetDate())%3600)/60 as varchar) + 'min, '
     + CAST((DATEDIFF(s,start_time,GetDate())%60) as varchar) + ' sec' as running_time,	
	DATEADD(ms, estimated_completion_time, GETDATE()) estimated_finish_time,
	(total_elapsed_time / 1000 / 60) AS total_elapsed_time_min,
	CAST((estimated_completion_time/3600000) as varchar) + ' hour(s), '
     + CAST((estimated_completion_time %3600000)/60000 as varchar) + 'min, '
     + CAST((estimated_completion_time %60000)/1000 as varchar) + ' sec' as est_time_to_go,
    dateadd(second,estimated_completion_time/1000, getdate()) as est_completion_time,
	estimated_completion_time,
	status, 
	cpu_time,
	total_elapsed_time,
	wait_time,
	wait_type,
	last_wait_type
FROM sys.dm_exec_requests
--where session_id = 107
--where DB_NAME(database_id) = 'aceyus_survey'
order by�percent_complete�desc

SELECT command,
            s.text,
            start_time,
            percent_complete,
            CAST(((DATEDIFF(s,start_time,GetDate()))/3600) as varchar) + ' hour(s), '
                  + CAST((DATEDIFF(s,start_time,GetDate())%3600)/60 as varchar) + 'min, '
                  + CAST((DATEDIFF(s,start_time,GetDate())%60) as varchar) + ' sec' as running_time,
            CAST((estimated_completion_time/3600000) as varchar) + ' hour(s), '
                  + CAST((estimated_completion_time %3600000)/60000 as varchar) + 'min, '
                  + CAST((estimated_completion_time %60000)/1000 as varchar) + ' sec' as est_time_to_go,
            dateadd(second,estimated_completion_time/1000, getdate()) as est_completion_time
FROM sys.dm_exec_requests r
CROSS APPLY sys.dm_exec_sql_text(r.sql_handle) s
WHERE r.command in ('RESTORE DATABASE', 'BACKUP DATABASE', 'RESTORE LOG', 'BACKUP LOG')


---Recursos del Cluster-------
					
		DECLARE @command nvarchar(2000)  			
  					
		 SET QUOTED_IDENTIFIER ON			
				-- To allow advanced options to be changed.  
         EXECUTE sp_configure 'show advanced options', 1;  
         GO  
                -- To update the currently configured value for advanced options.  
         RECONFIGURE;  
         GO  
                -- To enable the feature.  
         EXECUTE sp_configure 'xp_cmdshell', 1;  
         GO  
                -- To update the currently configured value for this feature.  
         RECONFIGURE;  
         GO
				
		DECLARE @sql varchar(400)
		DECLARE @sql2 varchar(400)
					
		SET @sql  = 'powershell.exe -c "Get-ClusterResource |select Name, State, ResourceType | foreach{$_.name+''|''+$_.state+''*''+$_.ResourceType}"'						
		SET @sql2 = 'powershell.exe -c "Get-ClusterNode |select Name, ID, State | foreach{$_.name+''|''+$_.id+''*''+$_.state}"'						
		
        CREATE TABLE #Recurso
		(line varchar(255))
		CREATE TABLE #Nodos
		(line varchar(255))			
		
		insert #Recurso			
		EXEC xp_cmdshell @sql			
		insert #Nodos			
		EXEC xp_cmdshell @sql2			
		
		CREATE TABLE #Recursos_Cluster
		([Name] VARCHAR(100),			
		[State] VARCHAR(100),
		[ResourceType] VARCHAR(100))			
		   
		INSERT #Recursos_Cluster			
		SELECT  
		SUBSTRING(line,1,CHARINDEX('|',line)-1), --as Nombre,			
		SUBSTRING(line,CHARINDEX('|',line)+1,7), --as Estado,
		SUBSTRING(line,CHARINDEX('*',line)+1,30) --as Recurso
		FROM #Recurso		
		WHERE line like '%SQL Server Availability%'	
		UNION
		SELECT  
		SUBSTRING(line,1,CHARINDEX('|',line)-1), --as Nombre,			
		SUBSTRING(line,CHARINDEX('*',line)+1,5), --as Estado,
		SUBSTRING(line,CHARINDEX('|',line)+1,1) --as ID
		FROM #Nodos
		GO
	
	    SELECT Name, State, ResourceType 
		FROM #Recursos_Cluster
		WHERE Name IS NOT NULL
		order by ResourceType
		GO
				
		drop table #Recurso
		drop table #Nodos
		drop table #Recursos_Cluster


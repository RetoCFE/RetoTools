
		DECLARE @command nvarchar(2000)  			
  					
				
---Space Disks					
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
		 
		DECLARE @svrName varchar(255)			
		DECLARE @sql varchar(400)			
					
		--BY default it will take the current server name, we can the set the server name as well			
--		SET @svrName = @@SERVERNAME			
		SET @sql = 'powershell.exe -c "Get-WmiObject -Class Win32_Volume -Filter ''DriveType = 3'' | select name,capacity,freespace | foreach{$_.name+''|''+$_.capacity/1048576+''%''+$_.freespace/1048576+''*''}"'			
					
		--creating a temporary table			
		--DROP TABLE #Space_Disks			
		CREATE TABLE #Space_Disks			
		(line varchar(255))			
					
		--inserting disk name, total space and free space value in to temporary table			
		insert #Space_Disks			
		EXEC xp_cmdshell @sql			
					
		--script to retrieve the values in GB from PS script output			
					
		CREATE TABLE #Capacity_Disk			
		([CurrentHost] VARCHAR(100),			
		[DriveName] VARCHAR(100),			
		[Capacity(GB)] INT,			
		[Freespace(GB)] INT)			
					
		INSERT #Capacity_Disk			
		SELECT  CONVERT(varchar(250), SERVERPROPERTY('ComputerNamePhysicalNetBIOS')) COLLATE Latin1_General_CI_AS AS [CurrentHost],			
		rtrim(ltrim(SUBSTRING(line,1,CHARINDEX('|',line) -1))) as DriveName,round(cast(rtrim(ltrim(SUBSTRING(line,CHARINDEX('|',line)+1, (CHARINDEX('%',line) -1)-CHARINDEX('|',line)) )) as Float)/1024,0) as 'Capacity(GB)'			
		,round(cast(rtrim(ltrim(SUBSTRING(line,CHARINDEX('%',line)+1, (CHARINDEX('*',line) -1)-CHARINDEX('%',line)) )) as Float) /1024 ,0)as 'Freespace(GB)'			
		FROM #Space_Disks			
		WHERE line like '[A-Z][:]%'			
		ORDER BY DriveName			
		GO			

		SELECT * FROM #Capacity_Disk			
					
		GO			

		DROP TABLE #Space_Disks			
		DROP TABLE #Capacity_Disk			
		GO			

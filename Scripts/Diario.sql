USE [aceyus_cms]
GO
/****** Object:  StoredProcedure [dbo].[CFE_DETALLE_IVR_DIARIO]    Script Date: 24/04/2023 01:27:52 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		  JOSE LUIS GODINEZ
-- Create date:   ---------------
-- Update Author: BENJAMIN RESENDIZ / JOSE LUIS GODINEZ
-- Update date:	  09/08/2022,18/11/2022,23/11/2022,24/11/2022,25/11/2022,16/01/2023,30/01/2023
-- Description:	  REPORTES ACEYUS
-- =============================================
ALTER PROCEDURE [dbo].[CFE_DETALLE_IVR_DIARIO]
	-- Add the parameters for the stored procedure here

 @StartDate DateTime
,@EndDate DateTime
,@ReportArray VARCHAR(1000)
,@StartTime VARCHAR(12)
,@EndTime VARCHAR(12)
,@DayArray VARCHAR(32)
,@ShiftReport VARCHAR(1)
,@SelectedTimeZoneID INT = 11
,@ScopeTimeZoneID  INT = 11

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

------------------------------------------------------------------
--DECLARE @StartDate DateTime = '2022-11-01 00:00:00',
--		@EndDate DateTime = '2022-11-22 00:00:00'

DECLARE @VERANO		  INT = 5,
		@VERANO_FIN   INT = 4,
		@INVERNO	  INT = 6,
		@INVIERNO_FIN INT = 5,
		@ACTUAL		  INT = 0,
		@ACTUAL_FIN   INT = 0

	 IF @StartDate <= '2022-10-29 00:00:00' BEGIN SET @ACTUAL = @VERANO  END
ELSE IF @StartDate >= '2022-10-30 00:00:00' BEGIN SET @ACTUAL = @INVERNO END

	 IF @ACTUAL = @VERANO  BEGIN SET @ACTUAL_FIN = @VERANO_FIN   END
ELSE IF @ACTUAL = @INVERNO BEGIN SET @ACTUAL_FIN = @INVIERNO_FIN END


SELECT 
	ULTIMOPASO,
	TRANSFERENCIA,
	SESSIONID,
	AUTOATENDIDA  
INTO #movimientos
FROM [GRDB-LISTENER.CFE.MX].[DBANIVSRPU].[dbo].[TB_MOVIVRCFE] WITH(NOLOCK)
WHERE FECHA BETWEEN DATEADD(HOUR,-1,@StartDate) 
				AND DATEADD(HOUR, 1,@EndDate)


SELECT
	CallTimestamp,
	SessionID,
	Duration,
	ApplicationName,
	EndDetails  
INTO #cdr 
FROM [EPDB-LISTENER].[VoicePortal].[dbo].[CDR] WITH(NOLOCK)
WHERE 
	ApplicationName IN ('DSS-Flow-CDMX','DSS-Flow-MTY','Hotline','RetornoMenu')
AND CallTimestamp BETWEEN DATEADD(HOUR,@ACTUAL,@StartDate) 
					  AND DATEADD(HOUR,@ACTUAL,@EndDate) --POR ALGUN MOTIVO SINO LO PONES ASÍ EN EL AND DEL BETWEEN
																								   --TE TOMA LA HORA 00 DEL DIA SIGUIENTE 16/01/2023
AND (SessionID COLLATE Latin1_General_CI_AI NOT IN (SELECT [SESSIONID] FROM [cust_report].[dbo].[TB_SESSIONDUPLICADAS])) --EXCLUSIÓN DE LLAMADAS DUPLICADAS SOLICITADO POR ENRIQUE 30/01/2023


SELECT * INTO #tempivot FROM (
SELECT 
	CONVERT(date,(DATEADD(HOUR,-@ACTUAL,CallTimestamp))) AS DIA,
	TERMINACION = 
	 CASE
		WHEN ApplicationName = 'HotLine' 
			AND EndDetails NOT LIKE '%Transferred%'									       THEN 'ABANDONADAS'
		WHEN ApplicationName IN ('HotLine','DSS-Flow-MTY','DSS-Flow-CDMX','RetornoMenu') 
			AND EndDetails LIKE '%Transferred%'										       THEN 'TRANSFERIDAS'
		WHEN ApplicationName IN ('HotLine','DSS-Flow-MTY','DSS-Flow-CDMX','RetornoMenu') 
			AND EndDetails NOT LIKE  '%Transferred%'
			AND (TRANSFERENCIA IS NULL AND AUTOATENDIDA IS NULL AND Duration <= 10)		   THEN 'AUTOATENDIDAS'
		WHEN ApplicationName IN ('HotLine','DSS-Flow-MTY','DSS-Flow-CDMX','RetornoMenu') 
			AND EndDetails NOT LIKE  '%Transferred%'  
			AND (TRANSFERENCIA IS NULL AND AUTOATENDIDA IS NOT NULL)					   THEN 'AUTOATENDIDAS'
		WHEN ApplicationName IN ('HotLine','DSS-Flow-MTY','DSS-Flow-CDMX','RetornoMenu') 
			AND EndDetails NOT LIKE  '%Transferred%'
			AND (TRANSFERENCIA IS NULL AND AUTOATENDIDA IS NULL AND Duration > 10)	       THEN 'ABANDONADAS'
		WHEN ApplicationName IN ('HotLine','DSS-Flow-MTY','DSS-Flow-CDMX','RetornoMenu') 
			AND EndDetails NOT LIKE  '%Transferred%'
			AND (TRANSFERENCIA IS NULL AND AUTOATENDIDA IS NOT NULL AND Duration > 10)	   THEN 'AUTOATENDIDAS' --ENTRA EN LA CONDICIÓN WHEN 3
		WHEN ApplicationName IN ('HotLine','DSS-Flow-MTY','DSS-Flow-CDMX','RetornoMenu') 
			AND EndDetails NOT LIKE  '%Transferred%'
			AND (TRANSFERENCIA IS NOT NULL AND AUTOATENDIDA IS NOT NULL AND Duration > 10) THEN 'AUTOATENDIDAS' --PROBAR DURACION / SE CORTA EN EP PERO PINTA COMO TRANSFER EN BANDERAS 
		WHEN ApplicationName IN ('HotLine','DSS-Flow-MTY','DSS-Flow-CDMX','RetornoMenu') 
			AND EndDetails NOT LIKE  '%Transferred%'
			AND (AUTOATENDIDA IS NULL AND Duration > 10)								   THEN 'ABANDONADAS'
		WHEN ApplicationName IN ('HotLine','DSS-Flow-MTY','DSS-Flow-CDMX','RetornoMenu') 
			AND EndDetails NOT LIKE  '%Transferred%'
			AND (AUTOATENDIDA IS NULL AND Duration <= 10)								   THEN 'AUTOATENDIDAS'
	 ELSE '' END,
	 COUNT(*) AS TOTAL
FROM #cdr a
  LEFT JOIN #movimientos b ON a.SessionID COLLATE Latin1_General_CI_AI = b.SESSIONID
	GROUP BY
		CONVERT(date,(DATEADD(HOUR,-@ACTUAL,CallTimestamp))),
			 CASE
		WHEN ApplicationName = 'HotLine' 
			AND EndDetails NOT LIKE '%Transferred%'									       THEN 'ABANDONADAS'
		WHEN ApplicationName IN ('HotLine','DSS-Flow-MTY','DSS-Flow-CDMX','RetornoMenu') 
			AND EndDetails LIKE '%Transferred%'										       THEN 'TRANSFERIDAS'
		WHEN ApplicationName IN ('HotLine','DSS-Flow-MTY','DSS-Flow-CDMX','RetornoMenu') 
			AND EndDetails NOT LIKE  '%Transferred%'
			AND (TRANSFERENCIA IS NULL AND AUTOATENDIDA IS NULL AND Duration <= 10)		   THEN 'AUTOATENDIDAS'
		WHEN ApplicationName IN ('HotLine','DSS-Flow-MTY','DSS-Flow-CDMX','RetornoMenu') 
			AND EndDetails NOT LIKE  '%Transferred%'  
			AND (TRANSFERENCIA IS NULL AND AUTOATENDIDA IS NOT NULL)					   THEN 'AUTOATENDIDAS'
		WHEN ApplicationName IN ('HotLine','DSS-Flow-MTY','DSS-Flow-CDMX','RetornoMenu') 
			AND EndDetails NOT LIKE  '%Transferred%'
			AND (TRANSFERENCIA IS NULL AND AUTOATENDIDA IS NULL AND Duration > 10)	       THEN 'ABANDONADAS'
		WHEN ApplicationName IN ('HotLine','DSS-Flow-MTY','DSS-Flow-CDMX','RetornoMenu') 
			AND EndDetails NOT LIKE  '%Transferred%'
			AND (TRANSFERENCIA IS NULL AND AUTOATENDIDA IS NOT NULL AND Duration > 10)	   THEN 'AUTOATENDIDAS'
		WHEN ApplicationName IN ('HotLine','DSS-Flow-MTY','DSS-Flow-CDMX','RetornoMenu') 
			AND EndDetails NOT LIKE  '%Transferred%'
			AND (TRANSFERENCIA IS NOT NULL AND AUTOATENDIDA IS NOT NULL AND Duration > 10) THEN 'AUTOATENDIDAS'
		WHEN ApplicationName IN ('HotLine','DSS-Flow-MTY','DSS-Flow-CDMX','RetornoMenu') 
			AND EndDetails NOT LIKE  '%Transferred%'
			AND (AUTOATENDIDA IS NULL AND Duration > 10)								   THEN 'ABANDONADAS'
		WHEN ApplicationName IN ('HotLine','DSS-Flow-MTY','DSS-Flow-CDMX','RetornoMenu') 
			AND EndDetails NOT LIKE  '%Transferred%'
			AND (AUTOATENDIDA IS NULL AND Duration <= 10)								   THEN 'AUTOATENDIDAS'
	 ELSE '' END ) AS TLS

PIVOT (MAX(TOTAL) FOR TERMINACION IN (
AUTOATENDIDAS,
ABANDONADAS,
TRANSFERIDAS)) AS PVT


SELECT
	 DIA		   [DIA]
	,AUTOATENDIDAS [AUTOATENDIDAS IVR]
	,ABANDONADAS   [ABANDONADAS IVR]
	--,TRANSFERIDAS  [TRANSFERIDAS IVR]
FROM #tempivot
ORDER BY
	DIA
  


DROP TABLE #cdr,#movimientos,#tempivot



END


--EXEC [CFE_DETALLE_IVR_DIARIO] '04/02/2023 00:00:00', '04/03/2023 00:00:00', '999', '00:00', '00:00', '1,2,3,4,5,6,7', 'Y', 12, 12


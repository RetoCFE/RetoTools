-------------------------------------------------------------------
--                           Ingresar Fechas
-------------------------------------------------------------------
DECLARE
 @StartDate DateTime = '6/14/2023 00:00:00'
,@EndDate   DateTime = '6/15/2023 00:00:00'
,@Intervalo INT = 12
-------------------------------------------------------------------
--              Dia Normal
-------------------------------------------------------------------
/***** Script for SelectTopNRows command from SSMS  ******/
SELECT  datepart(hour, fecha) AS Fecha,count(*)  as TotalLlamadas
  FROM [DBANIVSRPU].[dbo].[TB_MOVIVRCFE]
  where convert(date,fecha) = '2023-06-01'
  and MOVIMIENTO3 is null
  group by  datepart(hour, fecha)
-------------------------------------------------------------------
--              Dia a Validar
-------------------------------------------------------------------
/***** Script for SelectTopNRows command from SSMS  ******/
SELECT  datepart(hour, fecha) AS Fecha,count(*)  as TotalLlamadas
  FROM [DBANIVSRPU].[dbo].[TB_MOVIVRCFE]
  where convert(date,fecha) = '2023-06-01'
  and MOVIMIENTO3 is null
  group by  datepart(hour, fecha)
  /***** Script for SelectTopNRows command from SSMS  ******/
SELECT  datepart(hour, fecha) AS Fecha,count(*)  as TotalLlamadas
  FROM [DBANIVSRPU].[dbo].[TB_MOVIVRCFE]
  where convert(date,fecha) BETWEEN @StartDate and @EndDate
  and MOVIMIENTO3 is null
  group by  datepart(hour, fecha)
  order by datepart(hour, fecha) asc
-------------------------------------------------------------------
--                  Se valida la info del intervalo 
-------------------------------------------------------------------
  SELECT  *
  FROM [DBANIVSRPU].[dbo].[TB_MOVIVRCFE]
  where convert(date,fecha)  BETWEEN @StartDate and @EndDate
  and MOVIMIENTO3 is null
  and datepart(hour, fecha) = @Intervalo
 order by ANI asc ,FECHA asc
-------------------------------------------------------------------
--                  Se Valida SinInfoWS
-------------------------------------------------------------------
/****** Script for SelectTopNRows command from SSMS  ******/
SELECT *
  FROM [VoicePortal].[dbo].[CDR]

  where convert(date,dateadd(hour,-6,[CallTimestamp] )) BETWEEN @StartDate and @EndDate 
  and  EndDetails like '%820039%' --VDMSinInfoWS

-------------------------------------------------------------------
--                  Se realiza cruce
-------------------------------------------------------------------

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
*
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
						  AND DATEADD(HOUR,@ACTUAL,@EndDate)
	AND (SessionID COLLATE SQL_Latin1_General_CP1_CI_AI NOT IN (SELECT [SESSIONID] COLLATE SQL_Latin1_General_CP1_CI_AI FROM [cust_report].[dbo].[TB_SESSIONDUPLICADAS])) --30/01/2023

SELECT *
INTO #total
FROM #movimientos m
JOIN #cdr c ON m.SESSIONID COLLATE SQL_Latin1_General_CP1_CI_AI = c.SessionID COLLATE SQL_Latin1_General_CP1_CI_AI;
-------------------------------------------------------------------
---             Se obtiene Tabla a validar:
-------------------------------------------------------------------

SELECT t.FECHA, t.DNIS, t.ANI, t.UCID, t.SESSIONID, t.MOVIMIENTO1, t.MOVIMIENTO2, t.MOVIMIENTO3, t.MOVIMIENTO4, t.MOVIMIENTO5, t.MOVIMIENTO6, t.MOVIMIENTO7, t.MOVIMIENTO8, t.MOVIMIENTO9, t.MOVIMIENTO10, t.MOVIMIENTO11, t.MOVIMIENTO12, t.MOVIMIENTO13, t.MOVIMIENTO14, t.MOVIMIENTO15, t.MOVIMIENTO16, t.MOVIMIENTO17, t.MOVIMIENTO18, t.MOVIMIENTO19, t.MOVIMIENTO20, t.TRANSFERENCIA, t.AUTOATENDIDA, t.ULTIMOPASO, t.RPU, t.FECHAUPDATE, t.CallTimestamp, t.SessionID, t.Duration, t.ApplicationName, t.EndDetails
FROM #total t
WHERE t.ANI IN (
    SELECT ANI
    FROM (
        SELECT ANI, FECHA, LAG(FECHA) OVER (PARTITION BY ANI ORDER BY FECHA) AS PreviousFecha
        FROM #total
    ) sub
    WHERE ABS(DATEDIFF(SECOND, PreviousFecha, FECHA)) <= 10
	AND t.MOVIMIENTO3 is null
    GROUP BY ANI
    HAVING COUNT(*) > 1
)
ORDER BY t.ANI, t.FECHA;
-------------------------------------------------------------------
--                  En caso de sospechar duplicadas insertar
-------------------------------------------------------------------
--Insert INTO [cust_report].[dbo].[TB_SESSIONDUPLICADAS] (SESSIONID) VALUES('')
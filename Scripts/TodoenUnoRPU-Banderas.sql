
DECLARE
 @StartDate DateTime = '11/03/2023 00:00:00'
,@EndDate   DateTime = '11/04/2023 00:00:00'

---- ===========================================================================
---- ******* LLAMADAS RECIBIDAS	EN IVR y ABANDONADAS EN IVR *********
---- ===========================================================================

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


CREATE TABLE #movimientos (
	[FECHA]			[datetime] NULL,
	[DNIS]			[varchar](50) NULL,
	[ANI]			[varchar](50) NULL,
	[SESSIONID]		[varchar](100) NOT NULL,
	[MOVIMIENTO1]	[varchar](50) NULL,
	[MOVIMIENTO2]	[varchar](50) NULL,
	[MOVIMIENTO3]	[varchar](50) NULL,
	[MOVIMIENTO4]	[varchar](50) NULL,
	[MOVIMIENTO5]	[varchar](50) NULL,
	[MOVIMIENTO6]	[varchar](50) NULL,
	[MOVIMIENTO7]	[varchar](50) NULL,
	[MOVIMIENTO8]	[varchar](50) NULL,
	[MOVIMIENTO9]	[varchar](50) NULL,
	[MOVIMIENTO10]	[varchar](50) NULL,
	[MOVIMIENTO11]	[varchar](50) NULL,
	[MOVIMIENTO12]	[varchar](50) NULL,
	[MOVIMIENTO13]	[varchar](50) NULL,
	[MOVIMIENTO14]	[varchar](50) NULL,
	[MOVIMIENTO15]	[varchar](50) NULL,
	[MOVIMIENTO16]	[varchar](50) NULL,
	[MOVIMIENTO17]	[varchar](50) NULL,
	[MOVIMIENTO18]	[varchar](50) NULL,
	[MOVIMIENTO19]	[varchar](50) NULL,
	[MOVIMIENTO20]	[varchar](50) NULL,
	[TRANSFERENCIA] [varchar](50) NULL,
	[AUTOATENDIDA]	[varchar](50) NULL,
	[ULTIMOPASO]	[varchar](50) NULL,
	[RPU]			[varchar](50) NULL,
)
---
CREATE CLUSTERED INDEX IX_tempMov ON #movimientos
(
	[SESSIONID] ASC,
	[FECHA] ASC
)
---
CREATE TABLE #cdr(
	[CallTimestamp]   [datetime]	 NULL,
	[SessionID]		  [varchar](255) NULL,
	[Duration]		  [int]			 NULL,
	[ApplicationName] [varchar](255) NULL,
	[EndDetails]	  [varchar](255) NULL,
	[ANICDR]  [varchar](255) NULL
)
---
CREATE CLUSTERED INDEX IX_tempCDR ON #cdr
(
	[SessionID] ASC,
	[CallTimestamp] ASC
)

--------------------------------------------------

INSERT INTO #movimientos (
	[FECHA],
	[DNIS],
	[ANI],
	[SESSIONID],
	[MOVIMIENTO1],
	[MOVIMIENTO2],
	[MOVIMIENTO3],
	[MOVIMIENTO4],
	[MOVIMIENTO5],
	[MOVIMIENTO6],
	[MOVIMIENTO7],
	[MOVIMIENTO8],
	[MOVIMIENTO9],
	[MOVIMIENTO10],
	[MOVIMIENTO11],
	[MOVIMIENTO12],
	[MOVIMIENTO13],
	[MOVIMIENTO14],
	[MOVIMIENTO15],
	[MOVIMIENTO16],
	[MOVIMIENTO17],
	[MOVIMIENTO18],
	[MOVIMIENTO19],
	[MOVIMIENTO20],
	[TRANSFERENCIA],
	[AUTOATENDIDA],
	[ULTIMOPASO],
	[RPU])
SELECT 
	[FECHA],
	[DNIS],
	[ANI],
	[SESSIONID],
	[MOVIMIENTO1],
	[MOVIMIENTO2],
	[MOVIMIENTO3],
	[MOVIMIENTO4],
	[MOVIMIENTO5],
	[MOVIMIENTO6],
	[MOVIMIENTO7],
	[MOVIMIENTO8],
	[MOVIMIENTO9],
	[MOVIMIENTO10],
	[MOVIMIENTO11],
	[MOVIMIENTO12],
	[MOVIMIENTO13],
	[MOVIMIENTO14],
	[MOVIMIENTO15],
	[MOVIMIENTO16],
	[MOVIMIENTO17],
	[MOVIMIENTO18],
	[MOVIMIENTO19],
	[MOVIMIENTO20],
	[TRANSFERENCIA],
	[AUTOATENDIDA],
	[ULTIMOPASO],
	[RPU]
FROM [DBANIVSRPU].[dbo].[TB_MOVIVRCFE] WITH(NOLOCK)
WHERE 
	[FECHA] BETWEEN DATEADD(HOUR,-1,@StartDate) 
				AND DATEADD(HOUR, 1,@EndDate)

--------------------------------------------------

--SELECT 
--	[SESSIONID] 
-- INTO #tempDuplicadas 
--FROM [cust_report].[dbo].[TB_SESSIONDUPLICADAS]

--------------------------------------------------
INSERT INTO #cdr (
	CallTimestamp,
	SessionID,
	Duration,
	ApplicationName,
	EndDetails,
	ANICDR) 
SELECT
	CallTimestamp,
	SessionID,
	Duration,
	ApplicationName,
	EndDetails,
	OriginatingNumber
FROM [EPDB-LISTENER].[VoicePortal].[dbo].[CDR] WITH(NOLOCK)
WHERE 
	ApplicationName IN ('DSS-Flow-CDMX','DSS-Flow-MTY','Hotline','RetornoMenu')
AND 
	CallTimestamp BETWEEN DATEADD(HOUR,@ACTUAL,@StartDate)  
					  AND DATEADD(SECOND,59,DATEADD(MINUTE,59,DATEADD(HOUR,@ACTUAL_FIN,@EndDate)))
--AND 
--	(SessionID COLLATE Latin1_General_CI_AI NOT IN (SELECT [SESSIONID] FROM #tempDuplicadas))

--------------------------------------------------

SELECT 
	CONVERT(date,(DATEADD(HOUR,-6,a.CallTimestamp)))[DIA],
	b.FECHA											[FECHA_Banderas],
	DATEADD(HOUR,-6,a.CallTimestamp)				[CallTimestamp_IVR],
	REPLACE(REPLACE(ANICDR,'sip:',''),'@cfe.mx','') [ANI_CDR],
	dbo.[FN_LADAS](REPLACE(REPLACE(ANICDR,'sip:',''),'@cfe.mx','')) AS 'Estado',
	ANI												[ANI],
	a.EndDetails									[TERMINACION_IVR],
	a.SessionID [SessionID],
	a.ApplicationName [ApplicationName],
	[TERMINACION_Banderas] = 
	 CASE
		WHEN ApplicationName = 'HotLine' 
			AND EndDetails NOT LIKE '%Transferred%'									       THEN 'ABANDONADAS'
		WHEN ApplicationName IN ('HotLine','DSS-Flow-MTY','DSS-Flow-CDMX','RetornoMenu','Dev-DSS-Flow') 
			AND EndDetails LIKE '%Transferred%'										       THEN 'TRANSFERIDAS'
		WHEN ApplicationName IN ('HotLine','DSS-Flow-MTY','DSS-Flow-CDMX','RetornoMenu','Dev-DSS-Flow') 
			AND EndDetails NOT LIKE  '%Transferred%'
			AND (TRANSFERENCIA IS NULL AND AUTOATENDIDA IS NULL AND Duration <= 10)		   THEN 'AUTOATENDIDAS'
		WHEN ApplicationName IN ('HotLine','DSS-Flow-MTY','DSS-Flow-CDMX','RetornoMenu','Dev-DSS-Flow') 
			AND EndDetails NOT LIKE  '%Transferred%'  
			AND (TRANSFERENCIA IS NULL AND AUTOATENDIDA IS NOT NULL)					   THEN 'AUTOATENDIDAS'
		WHEN ApplicationName IN ('HotLine','DSS-Flow-MTY','DSS-Flow-CDMX','RetornoMenu','Dev-DSS-Flow') 
			AND EndDetails NOT LIKE  '%Transferred%'
			AND (TRANSFERENCIA IS NULL AND AUTOATENDIDA IS NULL AND Duration > 10)	       THEN 'ABANDONADAS'
		WHEN ApplicationName IN ('HotLine','DSS-Flow-MTY','DSS-Flow-CDMX','RetornoMenu','Dev-DSS-Flow') 
			AND EndDetails NOT LIKE  '%Transferred%'
			AND (TRANSFERENCIA IS NULL AND AUTOATENDIDA IS NOT NULL AND Duration > 10)	   THEN 'AUTOATENDIDAS'
		WHEN ApplicationName IN ('HotLine','DSS-Flow-MTY','DSS-Flow-CDMX','RetornoMenu','Dev-DSS-Flow') 
			AND EndDetails NOT LIKE  '%Transferred%'
			AND (TRANSFERENCIA IS NOT NULL AND AUTOATENDIDA IS NOT NULL AND Duration > 10) THEN 'AUTOATENDIDAS' 
		WHEN ApplicationName IN ('HotLine','DSS-Flow-MTY','DSS-Flow-CDMX','RetornoMenu','Dev-DSS-Flow') 
			AND EndDetails NOT LIKE  '%Transferred%'
			AND (AUTOATENDIDA IS NULL AND Duration > 10)								   THEN 'ABANDONADAS'
		WHEN ApplicationName IN ('HotLine','DSS-Flow-MTY','DSS-Flow-CDMX','RetornoMenu','Dev-DSS-Flow') 
			AND EndDetails NOT LIKE  '%Transferred%'
			AND (AUTOATENDIDA IS NULL AND Duration <= 10)								   THEN 'AUTOATENDIDAS'
	 ELSE '' END,
	 MOVIMIENTO1,
	 MOVIMIENTO2,
	 MOVIMIENTO3,
	 MOVIMIENTO4,
	 MOVIMIENTO5,
	 MOVIMIENTO6,
	 MOVIMIENTO7,
	 MOVIMIENTO8,
	 MOVIMIENTO9,
	 MOVIMIENTO10,
	 MOVIMIENTO11,
	 MOVIMIENTO12,
	 MOVIMIENTO13,
	 MOVIMIENTO14,
	 MOVIMIENTO15,
	 MOVIMIENTO16,
	 MOVIMIENTO17,
	 MOVIMIENTO18,
	 MOVIMIENTO19,
	 MOVIMIENTO20,
	 TRANSFERENCIA,
	 AUTOATENDIDA,
	 ULTIMOPASO,
	 RPU,
	 Duration
INTO #tempIVR
FROM #cdr a
  LEFT JOIN #movimientos b ON a.SessionID COLLATE Latin1_General_CI_AI = b.SESSIONID
  --Select * from #tempIVR
  --ORDER BY CallTimestamp_IVR,Duration

SELECT 'Abandono por Hora'


SELECT
    DIA,
    DATEPART(HOUR, CallTimestamp_IVR) as 'Hora',
    SUM(CASE WHEN TERMINACION_Banderas = 'AUTOATENDIDAS' THEN 1 ELSE 0 END) as Autoatendidas,
    SUM(CASE WHEN TERMINACION_Banderas = 'ABANDONADAS' THEN 1 ELSE 0 END) as Abandonadas,
    SUM(CASE WHEN TERMINACION_Banderas = 'TRANSFERIDAS' THEN 1 ELSE 0 END) as Transferidas,	
	  CAST(
        (SUM(CASE WHEN TERMINACION_Banderas = 'AUTOATENDIDAS' THEN 1.0 ELSE 0 END) /
        (SUM(CASE WHEN TERMINACION_Banderas = 'AUTOATENDIDAS' THEN 1.0 ELSE 0 END) +
        SUM(CASE WHEN TERMINACION_Banderas = 'ABANDONADAS' THEN 1.0 ELSE 0 END)) * 100.0
        ) AS DECIMAL(10, 2)
    ) as 'ILLA',
	SUM(1) as Total
FROM #tempIVR
GROUP BY DATEPART(HOUR, CallTimestamp_IVR), DIA
ORDER BY DATEPART(HOUR, CallTimestamp_IVR), DIA;

Select 'Abandono Medias Horas';

WITH Subconsulta AS (
    SELECT
        DIA,
        RIGHT('0' + CONVERT(VARCHAR, DATEPART(HOUR, CallTimestamp_IVR)), 2) + ':' +
        CASE
            WHEN DATEPART(MINUTE, CallTimestamp_IVR) < 30 THEN '00'
            ELSE '30'
        END AS HoraMinutos,
        TERMINACION_Banderas
    FROM #tempIVR
)
SELECT
    DIA,
    HoraMinutos,
    SUM(CASE WHEN TERMINACION_Banderas = 'AUTOATENDIDAS' THEN 1 ELSE 0 END) as Autoatendidas,
    SUM(CASE WHEN TERMINACION_Banderas = 'ABANDONADAS' THEN 1 ELSE 0 END) as Abandonadas,
    SUM(CASE WHEN TERMINACION_Banderas = 'TRANSFERIDAS' THEN 1 ELSE 0 END) as Transferidas,
	  CAST(
        (SUM(CASE WHEN TERMINACION_Banderas = 'AUTOATENDIDAS' THEN 1.0 ELSE 0 END) /
        (SUM(CASE WHEN TERMINACION_Banderas = 'AUTOATENDIDAS' THEN 1.0 ELSE 0 END) +
        SUM(CASE WHEN TERMINACION_Banderas = 'ABANDONADAS' THEN 1.0 ELSE 0 END)) * 100.0
        ) AS DECIMAL(10, 2)
    ) as 'ILLA',
	COUNT(*) as Total
FROM Subconsulta
GROUP BY DIA, HoraMinutos
ORDER BY DIA, HoraMinutos;


--Movimientos por estado
select 'Movimientos por estado'
Select Estado,count(*) as 'Total Abandonadas' from #tempIVR
where   TERMINACION_Banderas ='ABANDONADAS'
--and ULTIMOPASO like '%Menu%'
group by Estado
order by Count(*) Desc

SELECT 
   DIA, -- Agregamos la columna de fecha
   Estado, 
   COUNT(*) as 'Total Abandonadas' 
FROM #tempIVR
WHERE TERMINACION_Banderas = 'ABANDONADAS'
GROUP BY DIA, Estado -- Agrupamos por fecha y Estado
ORDER BY DIA, COUNT(*) Desc -- Ordenamos por fecha y total descendente

--Porcentaje de abandono por opcion
select 'Porcentaje de abandono por opcion'
SELECT 
   [ULTIMOPASO], 
   SUM(TOTAL) AS TOTAL, 
   CONCAT(CAST((SUM(TOTAL) * 100.0 / (SELECT SUM(TOTAL) FROM (SELECT COUNT(*) AS TOTAL FROM #tempIVR WHERE TERMINACION_Banderas = 'ABANDONADAS' AND [ULTIMOPASO] IS NOT NULL GROUP BY [ULTIMOPASO]) subquery2)) AS DECIMAL(10,4)), '%') AS Porcentaje 
FROM (
   SELECT 
      [ULTIMOPASO], 
      COUNT([ULTIMOPASO]) AS TOTAL 
   FROM #tempIVR 
   WHERE TERMINACION_Banderas = 'ABANDONADAS' AND [ULTIMOPASO] IS NOT NULL 
   GROUP BY [ULTIMOPASO]
) subquery 
GROUP BY [ULTIMOPASO] 
ORDER BY SUM(TOTAL) Desc


--estado
SELECT 
   DIA, -- Agregamos la columna de fecha
   Estado, 
   SUM(CASE WHEN TERMINACION_Banderas = 'ABANDONADAS' THEN 1 ELSE 0 END) as 'Total Abandonadas',
   SUM(CASE WHEN TERMINACION_Banderas = 'AUTOATENDIDAS' THEN 1 ELSE 0 END) as 'Total Autoatendidas',
   SUM(CASE WHEN TERMINACION_Banderas = 'TRANSFERIDAS' THEN 1 ELSE 0 END) as 'Total Transferidas'
FROM #tempIVR
GROUP BY DIA, Estado -- Agrupamos por fecha y Estado
ORDER BY DIA, Estado;


SELECT 
    DIA,
    ULTIMOPASO,
    SUM(CASE WHEN TERMINACION_Banderas = 'ABANDONADAS' THEN 1 ELSE 0 END) as 'Total Abandonadas',
    SUM(CASE WHEN TERMINACION_Banderas = 'AUTOATENDIDAS' THEN 1 ELSE 0 END) as 'Total Autoatendidas',
    SUM(CASE WHEN TERMINACION_Banderas = 'TRANSFERIDAS' THEN 1 ELSE 0 END) as 'Total Transferidas',
    COUNT(*) as Total,
    isnull(CAST(ROUND((SUM(CASE WHEN TERMINACION_Banderas = 'AUTOATENDIDAS' THEN 1 ELSE 0 END) * 100.0) / NULLIF(SUM(CASE WHEN TERMINACION_Banderas IN ('AUTOATENDIDAS', 'ABANDONADAS') THEN 1 ELSE 0 END), 0), 2) AS DECIMAL(10, 2)),0) AS 'ILLA AUTOATENDIDAS',
    isnull(CAST(ROUND((SUM(CASE WHEN TERMINACION_Banderas = 'ABANDONADAS' THEN 1 ELSE 0 END) * 100.0) / NULLIF(SUM(CASE WHEN TERMINACION_Banderas IN ('AUTOATENDIDAS', 'ABANDONADAS') THEN 1 ELSE 0 END), 0), 2) AS DECIMAL(10, 2)),0) AS 'ILLA ABANDONADAS'
FROM #tempIVR
GROUP BY DIA, ULTIMOPASO
ORDER BY DIA, ULTIMOPASO;





----busqueda por ani
--Select 'Busqueda por ani'
--Select 
--DIA,FECHA_Banderas,CallTimestamp_IVR,ANI_CDR,Estado,ANI,TERMINACION_IVR,SessionID,ApplicationName,TERMINACION_Banderas,MOVIMIENTO1,MOVIMIENTO2,MOVIMIENTO3,MOVIMIENTO4,MOVIMIENTO5,MOVIMIENTO6,TRANSFERENCIA,AUTOATENDIDA,ULTIMOPASO,RPU,Duration
--from #tempIVR
--where ULTIMOPASO is null and TERMINACION_IVR='FarEndDisconnect : Unknown Disconnect Reason' -- and Movimiento3='44.Opcion0-FenomenoNatural'--and  TERMINACION_Banderas = 'ABANDONADAS'
--order by TERMINACION_Banderas

select 'Porcentaje de abandono por opcion'
SELECT 
   [ULTIMOPASO], 
   SUM(TOTAL) AS TOTAL, 
   CONCAT(CAST((SUM(TOTAL) * 100.0 / (SELECT SUM(TOTAL) FROM (SELECT COUNT(*) AS TOTAL FROM #tempIVR WHERE TERMINACION_Banderas = 'ABANDONADAS' AND [ULTIMOPASO] IS NOT NULL GROUP BY [ULTIMOPASO]) subquery2)) AS DECIMAL(10,4)), '%') AS Porcentaje 
FROM (
   SELECT 
      [ULTIMOPASO], 
      COUNT([ULTIMOPASO]) AS TOTAL 
   FROM #tempIVR 
   WHERE TERMINACION_Banderas = 'ABANDONADAS' 
   GROUP BY [ULTIMOPASO]
) subquery 
GROUP BY [ULTIMOPASO] 
ORDER BY SUM(TOTAL) Desc




Select 
	DIA,
	--DATEPART(HOUR, CallTimestamp_IVR) as 'Hora',
    SUM(CASE WHEN TERMINACION_Banderas = 'AUTOATENDIDAS' THEN 1 ELSE 0 END) as Autoatendidas,
    SUM(CASE WHEN TERMINACION_Banderas = 'ABANDONADAS' THEN 1 ELSE 0 END) as Abandonadas,
    SUM(CASE WHEN TERMINACION_Banderas = 'TRANSFERIDAS' THEN 1 ELSE 0 END) as Transferidas
FROM #tempIVR
where ULTIMOPASO is null
group by DIA
order by DIA asc


Select 
	DIA,
	DATEPART(HOUR, CallTimestamp_IVR) as 'Hora',
	ULTIMOPASO,
    SUM(CASE WHEN TERMINACION_Banderas = 'AUTOATENDIDAS' THEN 1 ELSE 0 END) as Autoatendidas,
    SUM(CASE WHEN TERMINACION_Banderas = 'ABANDONADAS' THEN 1 ELSE 0 END) as Abandonadas,
    SUM(CASE WHEN TERMINACION_Banderas = 'TRANSFERIDAS' THEN 1 ELSE 0 END) as Transferidas
FROM #tempIVR
where movimiento3 like '44.Opcion0-FenomenoNatural'
group by DATEPART(HOUR, CallTimestamp_IVR),DIA,	ULTIMOPASO
order by DIA,DATEPART(HOUR, CallTimestamp_IVR) asc 

Select 
	DIA,
	ULTIMOPASO,
    SUM(CASE WHEN TERMINACION_Banderas = 'AUTOATENDIDAS' THEN 1 ELSE 0 END) as Autoatendidas,
    SUM(CASE WHEN TERMINACION_Banderas = 'ABANDONADAS' THEN 1 ELSE 0 END) as Abandonadas,
    SUM(CASE WHEN TERMINACION_Banderas = 'TRANSFERIDAS' THEN 1 ELSE 0 END) as Transferidas
FROM #tempIVR
where movimiento3 like '44.Opcion0-FenomenoNatural'
group by DATEPART(HOUR, CallTimestamp_IVR),DIA,ULTIMOPASO
order by DIA,DATEPART(HOUR, CallTimestamp_IVR) asc 



Select 
	ULTIMOPASO,
    SUM(CASE WHEN TERMINACION_Banderas = 'AUTOATENDIDAS' THEN 1 ELSE 0 END) as Autoatendidas,
    SUM(CASE WHEN TERMINACION_Banderas = 'ABANDONADAS' THEN 1 ELSE 0 END) as Abandonadas,
    SUM(CASE WHEN TERMINACION_Banderas = 'TRANSFERIDAS' THEN 1 ELSE 0 END) as Transferidas
FROM #tempIVR
where movimiento3 = '44.Opcion0-FenomenoNatural'
group by ULTIMOPASO




Select * FROM #tempIVR
where ultimopaso like '%RPU%'

--ani='7911110685' or ANI_CDR='7911110685'

drop table #cdr,#movimientos,#tempIVR

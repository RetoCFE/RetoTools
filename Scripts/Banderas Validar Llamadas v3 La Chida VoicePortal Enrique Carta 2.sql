
--CONECTA A BASE IP 10.226.0.145
--LA TABLA TEMPORAL #tempIVR CONTIENE LOS REGISTROS DETALLADOS PARA UN MAYOR ANÁLISIS 

DECLARE @StartDate DateTime = '2023-02-01 00:00:00',
		@EndDate   DateTime = '2023-03-01 00:00:00'

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
	[FECHA]			[datetime]     NULL,
	[DNIS]			[varchar](50)  NULL,
	[ANI]			[varchar](50)  NULL,
	[SESSIONID]		[varchar](100) NOT NULL,
	[MOVIMIENTO1]	[varchar](50)  NULL,
	[MOVIMIENTO2]	[varchar](50)  NULL,
	[MOVIMIENTO3]	[varchar](50)  NULL,
	[MOVIMIENTO4]	[varchar](50)  NULL,
	[MOVIMIENTO5]	[varchar](50)  NULL,
	[MOVIMIENTO6]	[varchar](50)  NULL,
	[MOVIMIENTO7]	[varchar](50)  NULL,
	[MOVIMIENTO8]	[varchar](50)  NULL,
	[MOVIMIENTO9]	[varchar](50)  NULL,
	[MOVIMIENTO10]	[varchar](50)  NULL,
	[MOVIMIENTO11]	[varchar](50)  NULL,
	[MOVIMIENTO12]	[varchar](50)  NULL,
	[MOVIMIENTO13]	[varchar](50)  NULL,
	[MOVIMIENTO14]	[varchar](50)  NULL,
	[MOVIMIENTO15]	[varchar](50)  NULL,
	[MOVIMIENTO16]	[varchar](50)  NULL,
	[MOVIMIENTO17]	[varchar](50)  NULL,
	[MOVIMIENTO18]	[varchar](50)  NULL,
	[MOVIMIENTO19]	[varchar](50)  NULL,
	[MOVIMIENTO20]	[varchar](50)  NULL,
	[TRANSFERENCIA] [varchar](50)  NULL,
	[AUTOATENDIDA]	[varchar](50)  NULL,
	[ULTIMOPASO]	[varchar](50)  NULL,
	[RPU]			[varchar](50)  NULL,
)
---
CREATE CLUSTERED INDEX IX_tempMov ON #movimientos
(
	[SESSIONID] ASC,
	[FECHA] ASC
)

--=====================================

CREATE TABLE #cdr(
	[CallTimestamp] [datetime] NULL,
	[SessionID] [varchar](255) NULL,
	[Duration] [int] NULL,
	[ApplicationName] [varchar](255) NULL,
	[EndDetails] [varchar](255) NULL,
)
---
CREATE CLUSTERED INDEX IX_tempCDR ON #cdr
(
	[SessionID] ASC,
	[CallTimestamp] ASC
)

--=====================================

INSERT INTO #movimientos (
	FECHA,
	DNIS,
	ANI,
	SESSIONID,
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
	RPU)
SELECT 
	FECHA,
	DNIS,
	ANI,
	SESSIONID,
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
	RPU
FROM [10.226.0.157].[DBANIVSRPU].[dbo].[TB_MOVIVRCFE] WITH(NOLOCK)
WHERE 
	FECHA BETWEEN DATEADD(HOUR,-1,@StartDate) 
			  AND DATEADD(HOUR, 1,@EndDate)

--====================================

SELECT 
	[SESSIONID] 
INTO #tempDuplicadas 
FROM [10.226.0.187].[cust_report].[dbo].[TB_SESSIONDUPLICADAS]
---
INSERT INTO #cdr (
	CallTimestamp,
	SessionID,
	Duration,
	ApplicationName,
	EndDetails) 
SELECT
	CallTimestamp,
	SessionID,
	Duration,
	ApplicationName,
	EndDetails 
FROM [VoicePortal].[dbo].[CDR] WITH(NOLOCK)
WHERE 
	ApplicationName IN ('DSS-Flow-CDMX','DSS-Flow-MTY','Hotline','RetornoMenu')
AND 
	CallTimestamp BETWEEN DATEADD(HOUR,@ACTUAL,@StartDate) 
					  AND DATEADD(SECOND,59,DATEADD(MINUTE,59,DATEADD(HOUR,@ACTUAL_FIN,@EndDate)))
AND 
	(SessionID COLLATE Latin1_General_CI_AI NOT IN (SELECT [SESSIONID] FROM #tempDuplicadas))

--====================================

SELECT 
	CONVERT(date,(DATEADD(HOUR,-6,a.CallTimestamp))) [DIA],
	b.FECHA											 [FECHA_Banderas],
	DATEADD(HOUR,-6,a.CallTimestamp)				 [CallTimestamp_IVR],
	a.EndDetails									 [TERMINACION_IVR],
	[TERMINACION_Banderas] = 
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
	 ELSE '' END,
	 ANI,
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

--====================================

SELECT
	DIA,
	COUNT(*) [ABANDONADAS IVR TOTALES]
INTO #tempAbanTls
FROM #tempIVR 
WHERE 
	TERMINACION_Banderas = 'ABANDONADAS'
GROUP BY
	DIA
---
SELECT
	DIA,
	COUNT(*) [ABANDONADAS IVR MENU PRINCIPAL]
INTO #tempMenuPrin
FROM #tempIVR 
WHERE 
	(ULTIMOPASO = '2.MenuPrincipal' OR ULTIMOPASO = 'MenuPrincipal')
AND 
	MOVIMIENTO3 IS NULL
AND 
	TERMINACION_Banderas = 'ABANDONADAS'
GROUP BY
	DIA

--====================================
--====================================

SELECT
	SUM(a.[ABANDONADAS IVR TOTALES])		[ABANDONADAS IVR TOTALES],
	SUM(b.[ABANDONADAS IVR MENU PRINCIPAL]) [ABANDONADAS IVR MENU PRINCIPAL SIN MOVIMIENTO3],
	CONVERT(varchar,
		ROUND(SUM(CONVERT(float,b.[ABANDONADAS IVR MENU PRINCIPAL])) / 
			  SUM(CONVERT(float,a.[ABANDONADAS IVR TOTALES])) * 100,2,1)) + '%' [ABAN IVR MP SIN MOV3 %]
FROM #tempAbanTls a
  LEFT JOIN #tempMenuPrin b ON a.DIA = b.DIA


DROP TABLE #cdr,#movimientos,#tempIVR,#tempDuplicadas,#tempAbanTls,#tempMenuPrin
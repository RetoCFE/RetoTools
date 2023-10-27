

--OBTIENE TODO
SELECT * INTO #Movimientos 
FROM [GRDB-LISTENER.CFE.MX].[DBANIVSRPU].[dbo].[TB_MOVIVRCFE] b with (nolock)
where FECHA BETWEEN '2023-10-19 00:00:00' AND '2023-10-19 13:00:00'
-- Insertar el resultado del conteo en una tabla temporal (#ABANDONO en este caso)
ORDER BY FECHA ASC 


SELECT *
FROM (
    SELECT *
    FROM [EPDB-LISTENER].[VoicePortal].[dbo].[CDR] a with (nolock)
    WHERE [CallTimestamp] BETWEEN '2023-10-26 06:00:00.000'
                               AND '2023-10-26 19:00:00.000'
    AND ApplicationName IN ('DSS-Flow-CDMX', 'DSS-Flow-MTY', 'Hotline')
    AND [EndDetails] NOT LIKE 'Trans%'
    AND [Duration] > 10
) a
LEFT JOIN #Movimientos b with (nolock)
ON a.SessionID = b.SESSIONID COLLATE SQL_Latin1_General_CP1_CI_AI
WHERE AUTOATENDIDA IS NULL;


SELECT DATEPART(HOUR,DATEADD(HOUR,-6,[CallTimestamp])),COUNT(*)
FROM (
    SELECT *
    FROM [EPDB-LISTENER].[VoicePortal].[dbo].[CDR] a with (nolock)
    WHERE [CallTimestamp] BETWEEN '2023-10-19 06:00:00.000'
                               AND '2023-10-19 19:00:00.000'
    AND ApplicationName IN ('DSS-Flow-CDMX', 'DSS-Flow-MTY', 'Hotline')
    AND [EndDetails] NOT LIKE 'Trans%'
    AND [Duration] > 10
) a
LEFT JOIN #Movimientos b with (nolock)
ON a.SessionID = b.SESSIONID COLLATE SQL_Latin1_General_CP1_CI_AI
WHERE AUTOATENDIDA IS NULL AND ULTIMOPASO = '2.MenuPrincipal'
GROUP BY DATEPART(HOUR,DATEADD(HOUR,-6,[CallTimestamp]))
ORDER BY DATEPART(HOUR,DATEADD(HOUR,-6,[CallTimestamp])) ASC 


SELECT *
FROM (
    SELECT *
    FROM [EPDB-LISTENER].[VoicePortal].[dbo].[CDR] a with (nolock)
    WHERE [CallTimestamp] BETWEEN '2023-10-19 06:00:00.000'
                               AND '2023-10- 19:00:00.000'
    AND ApplicationName IN ('DSS-Flow-CDMX', 'DSS-Flow-MTY', 'Hotline')
and [EndDetails] Not like 'Trans%' 
) a
LEFT JOIN #Movimientos b with (nolock)
ON a.SessionID = b.SESSIONID COLLATE SQL_Latin1_General_CP1_CI_AI
     	  WHERE  AUTOATENDIDA IS  not  NULL 
		  or   [Duration]  <=  10 



SELECT
    FORMAT(ROUND(100.0 * (SELECT SUM(Atendidas) FROM #ATENDIDO) / 
    ((SELECT SUM(Atendidas) FROM #ATENDIDO) + (SELECT SUM(Abandono) FROM #ABANDONO)), 2), '0.##') + '%' AS Resultado;

-- Insertar el valor del conteo en una tabla
DROP TABLE #Movimientos,#ABANDONO,#ATENDIDO

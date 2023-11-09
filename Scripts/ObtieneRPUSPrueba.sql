--Correr desde proposito | se ejecuta con el dia en curso para obtener RPUs Frescos
DECLARE @StartDate DATE, @EndDate DATE

-- Calcular el StartDate un día antes del EndDate
SET @EndDate = GETDATE(); -- Fecha actual
SET @StartDate = DATEADD(DAY, -1, @EndDate); -- StartDate es un día antes de EndDate

--SELECT 'Fecha Inicial:' + CONVERT(VARCHAR, @StartDate, 101) AS FechaInicial,
--       'Fecha Final:' + CONVERT(VARCHAR, @EndDate, 101) AS FechaFinal;

WITH RankedResults AS (
    SELECT 
        [ULTIMOPASO],
        [RPU],
        ROW_NUMBER() OVER (PARTITION BY ULTIMOPASO ORDER BY (SELECT NULL)) AS RowNum
    FROM [DBANIVSRPU].[dbo].[TB_MOVIVRCFE]
    WHERE 
        Fecha >= @StartDate
		and Fecha <= @EndDate
        AND (
            ULTIMOPASO = '85.Fallas_SSOrdenNoActiva'
            OR ULTIMOPASO LIKE '%84.Fallas_SS%'
            OR ULTIMOPASO LIKE '%80.FallasSaldo%'
            OR ULTIMOPASO LIKE '%59.SSOrdenActivaNoAssign%'
        )
        AND RPU IS NOT NULL
)
SELECT [ULTIMOPASO], [RPU]
FROM RankedResults
WHERE RowNum <= 10
ORDER BY ULTIMOPASO DESC;


DECLARE @StartDate Date, @EndDate Date
SET @StartDate ='11/01/2023 00:00:00' Set @EndDate='11/02/2023 00:00:00'
USE CFE
Select 'Micar'
EXEC [CFE].[dbo].[CFE_Detallado_Operacion_ACD] @StartDate, @EndDate
--EXEC CFE_Detallado_Operacion_ACD_Diario @StartDate, @EndDate
USE aceyus_bypass
Select 'Consolidado IVR'
EXEC [REPORT_6502_CONSOLIDADO_OPCION_IVR] @StartDate, @EndDate, '999', '00:00', '00:00', '1,2,3,4,5,6,7', 'Y', 12, 12
Select 'IVRACD Intervalo'
EXEC [REPORT_6493_DETALLE_IVR_ACD_INTERVAL] @StartDate, @EndDate, '999', '00:00', '00:00', '1,2,3,4,5,6,7', 'Y', 12, 12
Select 'IVRACD Hora'
EXEC [REPORT_6494_DETALLE_IVR_ACD_HORA] @StartDate, @EndDate, '999', '00:00', '00:00', '1,2,3,4,5,6,7', 'Y', 12, 12
Select 'Recibidas x Opciones IVR'
EXEC [REPORT_6495_RECIBIDAS_OPCION_IVR] @StartDate, @EndDate, '999', '00:00', '00:00', '1,2,3,4,5,6,7', 'Y', 12, 12
Select 'IVRACD IVR x Estado'
EXEC REPORT_6503_LLAMADAS_IVR_ESTADO @StartDate, @EndDate, '999', '00:00', '00:00', '1,2,3,4,5,6,7', 'Y', 12, 12
Select 'IVRACD Diario'
EXEC [REPORT_6492_DETALLE_IVR_ACD_DIARIO] @StartDate, @EndDate, '999', '00:00', '00:00', '1,2,3,4,5,6,7', 'Y', 12, 12
Select 'IVRACD Llamadas atendidas 10 min'
EXEC [REPORT_6501_LLAMADAS_ATENDIDAS_10MIN_NAC] @StartDate, @EndDate, '999', '00:00', '00:00', '1,2,3,4,5,6,7', 'Y', 12, 12
USE aceyus_cms
Select 'IVRACD Diario Callback'
EXEC CFE_DETALLE_IVRACD_DIARIO_Callback @StartDate, @EndDate, '999', '00:00', '00:00', '1,2,3,4,5,6,7', 'Y', 12, 12
Select 'IVRACD Min Callback'
EXEC [CFE_DETALLE_IVRACD_MIN_CallBack] @StartDate, @EndDate, '999', '00:00', '00:00', '1,2,3,4,5,6,7', 'Y', 12, 12


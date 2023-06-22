@echo off

REM Direcciones IP a las que se quiere conectar
set ips=10.225.0.146 10.225.0.147 10.226.0.146 10.226.0.147 10.226.1.20

REM Usuario que se va a utilizar para la conexión SSH
set usuario=USER

REM Contraseña del usuario
set password=Password

REM Recorrer las direcciones IP y ejecutar el comando ssh en cada una de ellas

for %%i in (%ips%) do (
    echo Conectando a %%i...
    plink.exe -batch -ssh %usuario%@%%i -pw %password% hostname -I
    plink.exe -batch -ssh %usuario%@%%i -pw %password% df -h

echo -------------------------------------------------------------------------------------------

)

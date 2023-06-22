@echo off

rem Set the list of IP addresses to ping
set "ips=10.225.0.163 10.225.0.52 10.225.0.141 10.225.0.149 10.225.0.156 10.225.0.157 10.225.0.34 10.226.0.145 10.226.0.148 10.226.0.156 10.226.0.157 10.226.0.163 10.226.0.168 10.226.0.169 10.226.0.170 10.226.0.171 10.226.0.34"

rem Loop through the list of IP addresses
:loop
echo.
echo -----------------------------------------
echo Pinging the following IP addresses:
echo %ips%
echo -----------------------------------------
echo.

for %%i in (%ips%) do (
  echo.
  echo Pinging %%i ...
  ping -n 1 %%i | findstr /C:"Perdidos = 4" /C:"Request timed out." >nul
  if errorlevel 1 (
    echo %%i is responding.
  ) else (
    echo %%i is not responding or has intermittent connectivity.
  )
)

echo.
echo -----------------------------------------
echo Finished pinging all IP addresses.
echo -----------------------------------------
echo.

pause
goto loop
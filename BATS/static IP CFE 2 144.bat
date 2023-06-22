@echo off
@echo.
@echo.Conectando a la matrix, por favor espere ...
@echo.
netsh interface ipv4 set address name = "Wi-Fi" static 10.55.244.144 255.255.252.0 10.55.244.1

@echo.Asegurando area de ingreso, por favor espere ...
@echo.
netsh int ip set dns name = "Wi-Fi" source = static addr = 10.55.48.169 primary
netsh int ip add dns name = "Wi-Fi" addr = 10.225.2.148 index = 2
netsh winhttp set proxy 10.151.1.239:888 bypass-list="*.cfe.mx;*.cfemex.com;10.*;o71*;*o71*;*ws4e.cfe.mx*"
@echo.Conectado! Disfrute su estancia ...
@echo.

pause

close 
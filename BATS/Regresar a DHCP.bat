@echo off
@echo.
@echo.Configurado DHCP, por favor espere... 

netsh interface ipv4 set address name="Wi-Fi" source=DHCP
netsh interface ipv4 set dns name="Wi-Fi" source=DHCP

@echo.Listo!
@echo.
pause


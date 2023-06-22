select @@servername as EQUIPO, concat(network_subnet_ip,'/',network_subnet_prefix_length) as SUBNET,
ip_address as IP_ADDRESS, 
state_desc as STATUS 
from sys.availability_group_listener_ip_addresses
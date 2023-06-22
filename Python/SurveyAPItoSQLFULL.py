import os
import csv
from datetime import datetime
import sys
from dateutil.parser import parse

# Obtener la ruta del script
script_dir = os.path.dirname(os.path.abspath(__file__))

# Obtener el nombre del archivo CSV de entrada del argumento de línea de comandos
if len(sys.argv) < 2:
    print("Debe proporcionar el nombre del archivo CSV de entrada como argumento.")
    sys.exit(1)

input_filename = sys.argv[1]
input_file = os.path.join(script_dir, input_filename)

# Nombre del archivo SQL de salida
output_filename = "SurveyAPItoSQL{}.sql"
output_file = os.path.join(script_dir, output_filename.format(datetime.now().strftime("%Y%m%d%H%M%S")))

# Definir los números de campo para asignar los valores de "Satisfaccion", "Rapidez" y "Amabilidad"
satisfaccion_field = 13
rapidez_field = 31
amabilidad_field = 22

# Contador de inserciones realizadas
insert_count = 0

# Abrir el archivo CSV de entrada y el archivo SQL de salida
with open(input_file, 'r') as csv_file, open(output_file, 'w') as sql_file:
    reader = csv.reader(csv_file)

    # Saltar la primera fila que contiene los encabezados
    next(reader)

    # Escribir el encabezado del archivo SQL
    sql_file.write("INSERT INTO Survey_Contingencia (DateTime, Date, Status, Contact_Number, Agent_ID, Satisfaccion, Rapidez, Amabilidad) VALUES\n")

    # Procesar cada fila del archivo CSV
    for row in reader:
        # Obtener los valores de las columnas requeridas
        date_started = parse(row[2]).strftime("%Y-%m-%d %H:%M:%S.%f")[:-3]  # Eliminar los últimos 3 dígitos para ajustar el formato
        status = row[0]
        contact_number = row[7]
        agent_id = row[8]

        # Obtener los valores de "Satisfaccion", "Rapidez" y "Amabilidad" basados en los números de campo
        satisfaccion = row[satisfaccion_field].strip() if len(row) > satisfaccion_field else "Not Available"
        rapidez = row[rapidez_field].strip() if len(row) > rapidez_field else "Not Available"
        amabilidad = row[amabilidad_field].strip() if len(row) > amabilidad_field else "Not Available"

        # Escapar comillas simples en los valores
        values = [date_started, date_started.split()[0], status, contact_number, agent_id, satisfaccion, rapidez, amabilidad]
        values = [value.replace("'", "''") if isinstance(value, str) else value for value in values]

        # Escribir la declaración INSERT en el archivo SQL
        sql_file.write("('{}', '{}', '{}', '{}', '{}', '{}', '{}', '{}'),\n".format(*values))

        insert_count += 1

    # Eliminar la coma extra al final y cerrar la declaración INSERT
    sql_file.seek(sql_file.tell() - 2, os.SEEK_SET)
    sql_file.truncate()
    sql_file.write(";\n")

print("Se generó el archivo SQL con un total de {} inserciones.".format(insert_count))

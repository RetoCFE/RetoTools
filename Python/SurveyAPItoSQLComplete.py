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

# Definir los números de campo para asignar los valores de "Satisfaccion", "Rapidez" y "Amabilidad"
satisfaccion_field = 12
rapidez_field = 30
amabilidad_field = 21
satisfaccion_value = 13
rapidez_value = 31
amabilidad_value = 22

# Contador de registros que cumplen con la condición
count = 0
total=0
# Contador de inserciones realizadas
insert_count = 0

# Tamaño máximo de valores de fila en una sentencia INSERT
max_row_values = 1000

# Nombre del archivo SQL de salida
output_filename = "SurveyAPItoSQL{}.sql"
output_file = os.path.join(script_dir, output_filename.format(datetime.now().strftime("%Y%m%d%H%M%S")))

# Calcular el número total de filas en el archivo CSV
with open(input_file, 'r') as csv_file:
    reader = csv.reader(csv_file)
    num_rows = sum(1 for _ in reader)

# Reabrir el archivo CSV para procesar las filas
with open(input_file, 'r') as csv_file, open(output_file, 'w') as sql_file:
    reader = csv.reader(csv_file)

    # Saltar la primera fila que contiene los encabezados
    next(reader)

    # Lista para almacenar los valores de las filas que cumplen con la condición
    rows_to_insert = []

    # Procesar cada fila del archivo CSV

    for i, row in enumerate(reader, 1):
        total=total+1
        # Obtener los valores de las columnas requeridas
        status = row[0].upper()
        satisfaccion_Status = row[satisfaccion_field].strip() if len(row) > satisfaccion_field else "Not Available"
        rapidez_Status = row[rapidez_field].strip() if len(row) > rapidez_field else "Not Available"
        amabilidad_Status = row[amabilidad_field].strip() if len(row) > amabilidad_field else "Not Available"
        satisfaccion_Valor = row[satisfaccion_value].strip() if len(row) > satisfaccion_value else "Not Available"
        rapidez_Valor = row[rapidez_value].strip() if len(row) > rapidez_value else "Not Available"
        amabilidad_Valor = row[amabilidad_value].strip() if len(row) > amabilidad_value else "Not Available"

        # Verificar si el estado es "Completed" y los valores de los campos requeridos son "SUCCESS"
        if (
            status == "COMPLETED"
            and satisfaccion_Status == "SUCCESS"
            and rapidez_Status == "SUCCESS"
            and amabilidad_Status == "SUCCESS"
            and row[8] != ''  # Agentvacio
        ):
            # Obtener el valor de la fecha de inicio y convertirlo al formato deseado
            date_started = row[2].strip() if len(row) > 1 else "Not Available"
            try:
                date_started = parse(date_started).strftime("%Y-%m-%d %H:%M:%S.%f")[:-3]
                date = date_started.split()[0]
            except:
                date_started = "Not Available"
                date = "Not Available"

            # Escapar comillas simples en los valores
            values = [
                date_started,
                date,
                status,
                row[7],  # Contact_Number
                row[8],  # Agent_ID
                satisfaccion_Valor,
                rapidez_Valor,
                amabilidad_Valor
            ]
            values = [value.replace("'", "''") if isinstance(value, str) else value for value in values]

            # Agregar los valores a la lista de filas a insertar
            rows_to_insert.append(values)

            count += 1

        # Verificar si se ha alcanzado el límite máximo de valores de fila en una sentencia INSERT o se han procesado todas las filas
        if len(rows_to_insert) == max_row_values or (i == num_rows and len(rows_to_insert) > 0):
            # Escribir la declaración INSERT en el archivo SQL
            sql_file.write("INSERT INTO Survey_Contingencia (DateTime, Date, Status, Contact_Number, Agent_ID, Satisfaccion, Rapidez, Amabilidad) VALUES\n")
            for j, values in enumerate(rows_to_insert, 1):
                if j < len(rows_to_insert):
                    sql_file.write("('{}', '{}', '{}', '{}', '{}', '{}', '{}', '{}'),\n".format(*values))
                else:
                    # Última línea de inserción con registros restantes
                    sql_file.write("('{}', '{}', '{}', '{}', '{}', '{}', '{}', '{}');\n".format(*values))

            insert_count += 1

            # Limpiar la lista de filas a insertar
            rows_to_insert.clear()
  

# Mostrar el resultado
print("Número total de registros: {}".format(total))
print("Número total de registros que cumplen con la condición: {}".format(count))
print("Número total de sentencias INSERT generadas: {}".format(insert_count))

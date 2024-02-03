import io
import os

this_dir = os.path.dirname(os.path.abspath(__file__))
activate_this_path = this_dir + '/activate_this.py'

try:
    with io.open(activate_this_path, "rb") as file:
        activate_this_code = file.read()
        activate_globals = {"__file__": activate_this_path}
        exec(activate_this_code, activate_globals)
    print("Entorno virtual activado correctamente.")
except FileNotFoundError:
    print(f"No se encontró el archivo {activate_this_path}. Asegúrate de que la ruta sea correcta.")
except Exception as e:
    print(f"Error al activar el entorno virtual: {str(e)}")

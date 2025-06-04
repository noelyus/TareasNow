<?php
session_start();
require_once("../db/conexion.php");//requerimos del archivo de conexion con la base de datos

if ($_SERVER["REQUEST_METHOD"] == "POST") {
    $correo = $_POST["username"];
    $contrasenia = $_POST["password"]; //comprobamos y definimos los valores que envia el usuario por el formilario 

    $query = "SELECT id, nombre, contrasenia, id_rol FROM usuario WHERE correo = ?"; //tenemos la variable query
    $stmt = $conn->prepare($query); // tenemos la variable stmt que es igual a preparar la consulta a la base de datos (query)
    $stmt->bind_param("s", $correo); //ahora stmt tiene que cambiar la interrogacion, por un string (s) que sera el correo del usuario 
    $stmt->execute();//stmt debe ejecutar la consulta en la base de datos
    $result = $stmt->get_result(); //la variable result ahora es igual a el resultado de la ejecucion de stmnt a la base de datos.

    $usuarioEncontrado = false;//Por defecto usuario no se encuentra hasta que se encuentra

    while ($user = $result->fetch_assoc()) {//mientras haya resultado en la consulta se guardara la fila recibida en la variable user
        if ($contrasenia === $user['contrasenia']) {//dentro del resultado de nuestro usuario comprobamos si la contraseña enviada 
            //esta en formato string y es igual a la de la base de datos
            $_SESSION["credenciales"] = $user; //guardamos los datos del usuario en la variable de sesion credenciales 
            //seria buena idea descartar la contraseña de aqui
    
            // Redirigir según el rol
            if ($user['id_rol'] == 1) {//comprobamos el rol del usuario y segun sea se enviara al usuario a un dashboard distinto
                header("Location: ../../../FRONTEND/TFG/dashboard_alumno.html");
            } elseif ($user['id_rol'] == 2) {
                header("Location: ../../../FRONTEND/TFG/dashboard_profesor.html");
            } elseif ($user['id_rol'] == 3) {
                header("Location: ../../../FRONTEND/TFG/dashboard_admin.html");
            } else {
                echo "Error al obtener el rol del usuario";
            }
    
            $usuarioEncontrado = true;//se cambia la variable usuario encontrado a true para confirmar que se ha encontrado
            exit;
        }
    }
    
    if (!$usuarioEncontrado) {//si el usuario no se ha validado/encontrasdo saltara el error de usuario o contraseña incorrectos
        echo "Contraseña o usuario incorrecto.";
    }

}
<?php
session_start();
require_once("../db/conexion.php");

// Verificar si hay una sesión activa
if (!isset($_SESSION['credenciales'])) {
    header("Location: login.php");
    exit();
}

$user = $_SESSION["credenciales"]; 

// Parámetros recibidos
$usuarioID = $_GET['id_usuario'] ;
$imagenID = $_GET['id_imagen'] ;
$aplicacionNOMBRE = $_GET['nombre_contenedor'];
//informacion del contenedor
$query = "SELECT nombre 
FROM imagenes WHERE  id = ?";
$stmt = $conn->prepare($query);
$stmt->bind_param("i",$imagenID);
$stmt->execute();
$result = $stmt->get_result();
$fila = $result->fetch_assoc();
$NombreIMG = $fila['nombre'];

// Ruta absoluta del volumen
$volumen = realpath(__DIR__ . "/../data/$usuarioID");

// Validar que exista la carpeta del volumen
if (!is_dir($volumen)) {
    http_response_code(400);
    echo "Directorio no encontrado: $volumen";
    exit;
}

// Puerto aleatorio entre 8000 y 8999
$puerto = rand(8000, 8999);//arreglar puerto aleatorio para que no coincida con funcion para comprobar

// Nombre del contenedor
$containerName = "$aplicacionNOMBRE.$usuarioID";

// Comando docker
$cmd = "sudo docker run --rm -d -p {$puerto}:80 --name $containerName -v $volumen:/root/Desktop/Documentos $NombreIMG"; //generamos el comando docker

// Ejecutar el comando
exec($cmd . " 2>&1", $output, $status); //ejecutamos el comando y redirijimos los errores y la salida del comando en output y si ha funcionado saldra un valor de 0 

if ($status === 0) {
    header("Location:http://back.tareasnow.local:{$puerto}");
} else {
    echo "Error al ejecutar el contenedor:\n" . implode("\n", $output);//si funciona, nos redirije a la direccion de nuestro contenedor sino mostrara los errores 
}
?>

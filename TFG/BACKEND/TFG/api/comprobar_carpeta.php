<?php
//Aqui se busca en la base de datos las tareas que el alumno ha comppletado
session_start();
require_once("../db/conexion.php");

// Verificar si hay una sesión activa
if (!isset($_SESSION['credenciales'])) {
    header("Location: login.php");
    exit();
}

$user = $_SESSION["credenciales"]; 
$user_id = $user['id'];
$user_dir = "../data/" . $user_id;

if (!file_exists($user_dir)) {
    mkdir($user_dir, 0755, true);
}
header('Location: ../../../FRONTEND/TFG/pages/aplicaciones.html');
exit();

// Aquí lanzas o rediriges a la app con acceso a esa carpeta
// Ejemplo: llamar a un script que levante un contenedor con ese volumen
?>

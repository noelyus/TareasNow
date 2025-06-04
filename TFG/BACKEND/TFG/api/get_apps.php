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
 
//consulta para buscar las aplicaciones del usuario
$query = "SELECT id_aplicacion, curso_id, nombre_app, id_imagen, ruta_icono, nombre_curso, nivel, nombre_usuario, id_usuario, id_rol FROM usuarios_x_aplicaciones WHERE id_usuario = ?";
$stmt = $conn->prepare($query);
$stmt->bind_param("s",$user["id"] );
$stmt->execute();
$result = $stmt->get_result();

$aplicaciones_usuario = [];
 
while ($rowB = $result->fetch_assoc()) {
    $aplicaciones_usuario[] = $rowB;
}

echo json_encode([    
'aplicaciones_usuario' => $aplicaciones_usuario,
'rol_usuario' => $user["id_rol"],
'id_usuario' => $user["id"]
]);




<?php
//Aqui se buscaran las tareas que el profesor no ha puntuado aun
session_start();
require_once("../db/conexion.php");

// Verificar si hay una sesión activa
if (!isset($_SESSION['credenciales'])) {
    header("Location: login.php");
    exit();
}

$user = $_SESSION["credenciales"]; 
 
//consulta para buscar tareas completas del usuario
$query = "SELECT id_alumno, nombre_alumno, correo_alumno, id_tarea, nombre_tarea, nota, id_entregado, id_profesor FROM tareas_sin_puntuar WHERE id_profesor = ?";
$stmt = $conn->prepare($query);
$stmt->bind_param("s",$user["id"] );
$stmt->execute();
$result = $stmt->get_result();

$tareasprof_sinnota = [];
 
while ($rowB = $result->fetch_assoc()) {
    $tareasprof_sinnota[] = $rowB;
}

echo json_encode($tareasprof_sinnota);
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
 
//consulta para buscar tareas completas del usuario
$query = "SELECT nombre_alumno, id_usuario, id_tarea, titulo, nota, nombre_asignatura, fecha_entrega FROM v_tareas_terminadas WHERE id_usuario = ?";
$stmt = $conn->prepare($query);
$stmt->bind_param("s",$user["id"] );
$stmt->execute();
$result = $stmt->get_result();

$tareas_completas = [];
 
while ($rowB = $result->fetch_assoc()) {
    $tareas_completas[] = $rowB;
}

echo json_encode($tareas_completas);
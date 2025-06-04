<?php
//Aqui se busca en la base de datos las tareas que el alumno no ha terminado 
session_start();
require_once("../db/conexion.php");

// Verificar si hay una sesión activa
if (!isset($_SESSION['credenciales'])) {
    header("Location: login.php");
    exit();
}


$user = $_SESSION["credenciales"]; 

//consulta para buscar las tareas que el usuario tiene pendientes
$query = "SELECT id_tarea, id_de_alumno, nombre_alumno, fecha_limite, id_creador, titulo_tarea, nombre_asignatura  FROM tareas_sin_terminar WHERE id_de_alumno = ?";
$stmt = $conn->prepare($query);
$stmt->bind_param("s",$user["id"] );
$stmt->execute();
$result = $stmt->get_result();

$tareas_pendientes = [];

while ($rowB = $result->fetch_assoc()) {
    $tareas_pendientes[] = $rowB;
}

echo json_encode($tareas_pendientes);
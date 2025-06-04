<?php
//Aqui se busca en la base de datos las tareas en las que el alumno ha sido puntuado
session_start();
require_once("../db/conexion.php");

// Verificar si hay una sesión activa
if (!isset($_SESSION['credenciales'])) {
    header("Location: login.php");
    exit();
}


$user = $_SESSION["credenciales"]; 

//consulta para buscar las tareas que el usuario tiene completas y puntuadas
$query = "SELECT nombre_alumno, id_usuario, id_tarea, titulo, nota, fecha_entrega, nombre_asignatura, id_asignatura FROM tareas_puntuadas WHERE id_usuario = ?";
$stmt = $conn->prepare($query);
$stmt->bind_param("s",$user["id"] );
$stmt->execute();
$result = $stmt->get_result();

$tareas_puntuadas_ALUMNOS = [];

while ($rowB = $result->fetch_assoc()) {
    $tareas_puntuadas_ALUMNOS[] = $rowB;
}

echo json_encode($tareas_puntuadas_ALUMNOS);
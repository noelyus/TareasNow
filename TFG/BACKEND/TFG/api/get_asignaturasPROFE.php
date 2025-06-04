<?php
//en este documento se sacaran las asignaturas de cada profesor
session_start();
require_once("../db/conexion.php");

// Verificar si hay una sesión activa
if (!isset($_SESSION['credenciales'])) {
    header("Location: login.php");
    exit();
}

$user = $_SESSION["credenciales"]; 
 
//consulta para buscar las tareas que el usuario tiene completas y puntuadas
$query = "SELECT id_profesor, nombre_profesor, nombre_asignatura, id_asignatura, nombre_curso, nivel_curso FROM
profesores_asignaturas WHERE id_profesor = ?";
$stmt = $conn->prepare($query);
$stmt->bind_param("s",$user["id"] );
$stmt->execute();
$result = $stmt->get_result();

$asignaturas_profesor = [];

while ($rowB = $result->fetch_assoc()) {
    $asignaturas_profesor[] = $rowB;
}

echo json_encode($asignaturas_profesor);
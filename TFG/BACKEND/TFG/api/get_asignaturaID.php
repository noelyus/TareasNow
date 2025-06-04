<?php
//Para ver los detalles de una asignatura
session_start();
require_once("../db/conexion.php");

// Verificar si hay una sesión activa
if (!isset($_SESSION['credenciales'])) {
    header("Location: login.php");
    exit();
}
//Verificamos que se recibe el id de la asignatura que queremos visualizar
if (!isset($_GET['id'])) {
    echo json_encode(['error' => 'Falta el ID de la Asignatura']);
    exit;
}
//guardamos el id recibido del metodo get en $idAsignatura 
$idAsignatura  = intval($_GET['id']);


$user = $_SESSION["credenciales"]; //guardamos los datos de inicio de sesion del usuario en $user


//consulta para buscar la informacion de la asignatura
$query = "SELECT nombre_asignatura, id_curso, nombre_curso, nivel, id_profesor, nombre, correo FROM vista_asignatura  WHERE id_asignatura = ?";
$stmt = $conn->prepare($query);
$stmt->bind_param("i",$idAsignatura );
$stmt->execute();
$result = $stmt->get_result();

$detalles_asignatura = [];//declaramos el array donde se almacenaran los datos

while ($rowB = $result->fetch_assoc()) { //mientras haya resultado añadimos la fila a detalles_asignatura 
    $detalles_asignatura[] = $rowB;
}


//consulta para buscar las tareas de la asignatura
$queryTarea = "SELECT id_tarea, id_asignatura, titulo_tarea, fecha_limite  FROM vista_tarea  WHERE id_asignatura = ?";
$stmtTar = $conn->prepare($queryTarea);
$stmtTar->bind_param("i",$idAsignatura );
$stmtTar->execute();
$resultTarea = $stmtTar->get_result();
 
$Tareas_asignaturas = [];

while ($rowTarea = $resultTarea->fetch_assoc()) { //mientras haya resultado añadimos la fila a Tareas_asignaturas  
    $Tareas_asignaturas[] = $rowTarea;
}

echo json_encode([
    'id_rol' => $user["id_rol"],
    'asignatura' => $detalles_asignatura, 
    'tareas' => $Tareas_asignaturas
]);
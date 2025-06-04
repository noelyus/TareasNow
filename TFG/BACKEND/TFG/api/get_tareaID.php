<?php
//Aqui se busca en la base de datos informacion de la tarea 
session_start();
require_once("../db/conexion.php");

// Verificar si hay una sesión activa
if (!isset($_SESSION['credenciales'])) {
    header("Location: login.php");
    exit();
}
//Verificamos que se recibe el id de la tarea que queremos visualizar
if (!isset($_GET['id'])) {
    echo json_encode(['error' => 'Falta el ID de la tarea']);
    exit;
}
//guardamos el id recibido del en $idTarea
$idTarea = intval($_GET['id']);


$user = $_SESSION["credenciales"]; //guardamos los datos de inicio de sesion del usuario en $user



//consulta para buscar la informacion de la tarea que se tiene que ver
$query = "SELECT id_tarea, titulo_tarea, descripcion, fecha_limite, asignatura, curso, nivel_curso, creador_tarea FROM vista_tarea WHERE id_tarea = ?";
$stmt = $conn->prepare($query);
$stmt->bind_param("i",$idTarea );
$stmt->execute();
$result = $stmt->get_result();

$detalles_tarea = [];//declaramos el array donde se almacenaran los datos

while ($rowB = $result->fetch_assoc()) { //mientras haya resultado añadimos la fila a detalles_tarea 
    $detalles_tarea[] = $rowB;
}

//tambien debemos de mostrar los archivos que esten asociados con la tarea en la base de datos 
$queryArchivos = "SELECT id, id_tarea, id_usuario, nombre, ruta, tipo, titulo_tarea FROM archivos_tareas WHERE id_tarea = ?";
$stmtArchivos = $conn->prepare($queryArchivos);
$stmtArchivos->bind_param("i", $idTarea);
$stmtArchivos->execute();
$resultArchivos = $stmtArchivos->get_result();

$archivos = [];
while ($archivo = $resultArchivos->fetch_assoc()) {
    $archivos[] = $archivo;
}

//Para el profesor vamos a sacar las entregas hechas y no hechas de sus alumnos

$EntregasHechas = [];
$EntregasnoHechas = [];
//consulta para las tareas hechas
$consultaEntregasHechas = "SELECT nombre_alumno, id_tarea, id_usuario, titulo, nota, fecha_entrega, id_entrega_completa from v_tareas_terminadas where id_tarea = ?";
$stmtHechas = $conn->prepare($consultaEntregasHechas);
$stmtHechas->bind_param("i",$idTarea);
$stmtHechas->execute();
$resultHechas = $stmtHechas->get_result();

$EntregasHechas = [];

while ($entregaHecha = $resultHechas->fetch_assoc()) {
    $EntregasHechas[] = $entregaHecha;
}


//Aqui se enviaran las tareas no hechas
$consultaEntregasnoHechas = "SELECT id_entrega_incompleta, id_de_alumno, id_tarea, id_de_alumno, nombre_alumno, fecha_limite, id_creador, titulo_tarea, nombre_asignatura from tareas_sin_terminar where id_tarea = ?";
$stmtnoHechas = $conn->prepare($consultaEntregasnoHechas);
$stmtnoHechas->bind_param("i",$idTarea);
$stmtnoHechas->execute();
$resultnoHechas = $stmtnoHechas->get_result();

$EntregasnoHechas = [];

while ($entreganoHecha = $resultnoHechas->fetch_assoc()) {
    $EntregasnoHechas[] = $entreganoHecha;
}


echo json_encode([
    'tarea' => $detalles_tarea,
    'id_rol' => $user["id_rol"],
    'id_usuario' => $user['id'],
    'archivos' => $archivos,
    'hechas' => $EntregasHechas,
    'no_hechas' => $EntregasnoHechas
]);


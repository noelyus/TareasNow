<?php
//en este archivo sacaremos la informacion de una entrega para mostrarse en una pagina html 
session_start();
require_once("../db/conexion.php");
// Verificar si hay una sesión activa
if (!isset($_SESSION['credenciales'])) {
    header("Location: login.php");
    exit();
}
//verificamos que se recibe el id de la
if (!isset($_GET['id_entrega_completa'])) {
    echo json_encode(["error" => "No hay tarea seleccionada"]);
    exit();
}
$user = [];
$id_entrega = [];
//guardamos el id recibido en una variable
$id_entrega = $_GET['id_entrega_completa'];
$user = $_SESSION['credenciales']; //guardamos los datos de inicio de sesion del usuario en $user


//buscamos la informacion de la entrega
$query = "SELECT nombre_alumno, id_usuario, id_tarea, titulo, id_entrega_completa, nota, fecha_entrega, Comentarioalumno, Comentarioprofesor, nombre_asignatura, id_asignatura
  FROM v_tareas_terminadas WHERE  id_entrega_completa = ?";
$stmt = $conn->prepare($query);
$stmt->bind_param("i",$id_entrega);
$stmt->execute();
$result = $stmt->get_result();
$informacion_entrega = $result -> fetch_assoc();



//Buscamos la informacion del archivo en la base de datos
$queryArch = 'SELECT id_de_archivo, id_entrega, extension, id_alumno, nombre_archivo, ruta_archivo FROM v_archivos_entregas where id_entrega = ? ';
$stmtArch = $conn->prepare($queryArch);
$stmtArch->bind_param('i', $id_entrega);
$stmtArch->execute();
$resultArch = $stmtArch->get_result();

$informacion_archivos = [];
while($archiv = $resultArch ->fetch_assoc() ){
$informacion_archivos[] = $archiv;
}



echo json_encode([
    'entrega' => $informacion_entrega,
    'rol' => $user['id_rol'],
    'archivos' => $informacion_archivos
]);






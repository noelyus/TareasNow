<?php
session_start();
require_once("../db/conexion.php");

// Verificar si hay una sesión activa
if (!isset($_SESSION['credenciales'])) {
    header("Location: login.php");
    exit();
}

$user = $_SESSION["credenciales"]; //nos traemos las credenciales del usuario de la variable sesion y lass metemos en user

// Consulta para buscar asignaturas del usuario
$query = "SELECT nombre, id_usuario, tipo, asignatura, id_asignatura, curso, id_profesor, nivel 
          FROM asignaturasasign 
          WHERE id_usuario = ?"; 

$stmt = $conn->prepare($query);
$stmt->bind_param("s", $user["id"]);
$stmt->execute();
$result = $stmt->get_result();//hacemos una consulta a asignaturasasign y segun el id del usaurio qeu se sacaba en el login

$asignaturas = [];//definimos la variable array asiganturas

while ($rowA = $result->fetch_assoc()) {
    $id_profesor = $rowA["id_profesor"];//mientras haya resultado en la consulta guardamos el id_profesor de la asignatura en 
    //id_profesor

    // Buscar datos del profesor en la tabla usuario con la variable almacenada justo arriba
    $queryProf = "SELECT nombre, correo FROM usuario WHERE id = ?";
    $stmtProf = $conn->prepare($queryProf);
    $stmtProf->bind_param("s", $id_profesor);
    $stmtProf->execute();
    $resultProf = $stmtProf->get_result();

    if ($profesor = $resultProf->fetch_assoc()) {//mientras haya resultado en la anterior consulta guardamos el registro en profesor
        $rowA["profesor"] = $profesor; //definimos un nuevo miniarray dentro de nuestra fila que sera profesor con correo y nombre
    } else {
        $rowA["profesor"] = null; // Por si no se encuentra el profesor
    }

    $asignaturas[] = $rowA;//metemos todo nuestro array en la variable array asignaturas y las encodeamos en json
}

echo json_encode($asignaturas);

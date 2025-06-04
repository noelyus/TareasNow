<?php
//en este archivo sacaremos la informacion de una entrega para mostrarse en una pagina html 
session_start();
require_once("../db/conexion.php");

// Verificar si hay una sesión activa
if (!isset($_SESSION['credenciales'])) {
    header("Location: login.php");
    exit();
}
if (!isset($_POST['id_usuario'], $_POST['id_tarea'])) {
    http_response_code(400);
    echo json_encode(["error" => "Faltan datos obligatorios."]);
    exit;
}
$id_usuario = intval($_POST['id_usuario']);
$id_tarea = intval($_POST['id_tarea']);
$comentario = isset($_POST['comentario']) && trim($_POST['comentario']) !== '' ? $_POST['comentario'] : null;
//ejecutamos un procedimiento en la base de datos que añadira la entrega a entregas_completas y la eliminara de tareas_incompletas
$stmtCompletar = $conn->prepare("CALL completar_tareas(?, ?, ?)");
$stmtCompletar->bind_param("iis", $id_tarea, $id_usuario, $comentario);
$stmtCompletar->execute();

$resultado = $stmtCompletar->get_result();
$fila = $resultado->fetch_assoc();
$id_entrega_final = $fila['id'];

$stmtCompletar->close();


//procesamiento del archivo 
if (isset($_FILES['archivo']) && $_FILES['archivo']['error'] === UPLOAD_ERR_OK) {
    $nombreOriginal = basename($_FILES['archivo']['name']);
    $info = pathinfo($nombreOriginal);
    $nombreSinExtension = $info['filename'];
    $extension = strtolower($info['extension']);

    $nombreFinal = uniqid() . '_' . $nombreOriginal;
    $directorio = "../uploads/entrega{$id_tarea}_{$id_usuario}/";

    if (!file_exists($directorio)) {
        mkdir($directorio, 0777, true);
    }

    $rutaDestino = $directorio . $nombreFinal;
 
  // se registra el archivo  en la base de datos
    if (move_uploaded_file($_FILES['archivo']['tmp_name'], $rutaDestino)) {
        
        $stmtTipo = $conn->prepare("SELECT id FROM tipos_archivos WHERE tipo =  ?");
        $stmtTipo->bind_param("s", $extension);
        $stmtTipo->execute();
        $stmtTipo->bind_result($id_tipo);

        if ($stmtTipo->fetch()) {
            $stmtTipo->close();

            $rutaRelativa = "uploads/entrega{$id_tarea}_{$id_usuario}/" . $nombreFinal;

            $stmtArchivo = $conn->prepare("
                INSERT INTO archivos_entregas (id_entrega, id_tipo,  id_usuario, nombre, ruta, id_tarea)
                VALUES ( ?, ?, ?, ?, ?, ?) 
            ");
            $stmtArchivo->bind_param("iiissi", $id_entrega_final, $id_tipo, $id_usuario, $nombreSinExtension, $rutaRelativa, $id_tarea);
            $stmtArchivo->execute();
            $stmtArchivo->close();
        } else {
            $stmtTipo->close();
            echo json_encode(['error' => 'Extensión no permitida o no registrada']);
            exit;
        }
    } else {
        echo json_encode(['error' => 'Error al mover el archivo']);
        exit;
    }

}
header("Location: ../../../frontend/tfg/pages/entregaID.html?id_entrega_completa=$id_entrega_final");
exit();


   


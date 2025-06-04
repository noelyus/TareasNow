<?php
require_once('../db/conexion.php');
header('Content-Type: application/json');

//Leer desde $_POST 
if (!isset($_POST['id_tarea'])) {
    echo json_encode(['success' => false, 'message' => 'ID de tarea no recibido']);
    exit();
}

$id_tarea = $_POST['id_tarea']; //guardamos el id de la tarea que queremos eliminar

// Llamar al procedimiento almacenado
$query = "CALL eliminar_tareas(?)";
$stmt = $conn->prepare($query);
$stmt->bind_param("i", $id_tarea);

// Eliminar carpeta de archivos
$ruta_archivo = "../uploads/tarea$id_tarea/";
if (is_dir($ruta_archivo)) {
    array_map('unlink', glob("$ruta_archivo/*"));
    rmdir($ruta_archivo);
}

if ($stmt->execute()) {
    echo json_encode(['success' => true]);
} else {
    echo json_encode(['success' => false, 'message' => $stmt->error]);
}
?>

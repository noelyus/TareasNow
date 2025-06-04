<?php
require_once('../db/conexion.php');
header('Content-Type: application/json');

//  Leer desde $_POST en vez de php://input
if (!isset($_POST['id_entrega_completa'])) {
    echo json_encode(['success' => false, 'message' => 'ID de entrega no recibido']);
    exit();
}

$id_entrega = $_POST['id_entrega_completa'];
$nota = $_POST['nota'];
$comentario = $_POST['comentarioProfeNuevo'];
//llamada a la base de datos para actualizar la nota y el comentario
$query = "UPDATE entregas_completas set nota = ?, ComentarioProfesor = ? where id = ? ";
$stmt = $conn->prepare($query);
$stmt->bind_param("isi", $nota, $comentario, $id_entrega);


if ($stmt->execute()) {
    echo json_encode(['success' => true]);
} else {
    echo json_encode(['success' => false, 'message' => $stmt->error]);
}
?>
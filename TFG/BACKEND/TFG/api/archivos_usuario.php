<?php
session_start();

// Asegúrate de validar o recibir $usuarioID (aquí por ejemplo por sesión)
if (!isset($_SESSION['credenciales'])) {
    http_response_code(401);
    echo json_encode(['error' => 'No autenticado']);
    exit();
}

$usuarioID = $_GET['id_usuario'] ?? null;
if (!$usuarioID) {
    http_response_code(400);
    echo json_encode(['error' => 'Falta usuarioID']);
    exit();
}

$volumen = realpath(__DIR__ . "/../data/$usuarioID");

if (!$volumen || !is_dir($volumen)) {
    http_response_code(404);
    echo json_encode(['error' => 'Directorio no encontrado']);
    exit();
}

// URL base para acceder a los archivos (ajusta según tu servidor)
$baseUrl = "back.tareasnow.local/data/$usuarioID/";

$archivos = [];
$dir = opendir($volumen);
if ($dir) {
    while (($file = readdir($dir)) !== false) {
        if ($file === '.' || $file === '..') continue;
        $rutaCompleta = $volumen . DIRECTORY_SEPARATOR . $file;
        if (is_file($rutaCompleta)) {
            $archivos[] = [
                'nombre' => $file,
                'url' => $baseUrl . rawurlencode($file)
            ];
        }
    }
    closedir($dir);
}

header('Content-Type: application/json');
echo json_encode(['archivos' => $archivos]);

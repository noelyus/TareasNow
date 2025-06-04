<?php
session_start();

// Verificar si hay una sesión activa
if (!isset($_SESSION['credenciales'])) {
    header("Location: login.php");
    exit();
}

$user = $_SESSION['credenciales'];

switch ($user['id_rol']) {
    case '1':
        header("Location: ../../../FRONTEND/TFG/dashboard_alumno.html");
        break;
    case '2':
        header("Location: ../../../FRONTEND/TFG/dashboard_profesor.html");
        break;
    case '3':
        header("Location: ../../../FRONTEND/TFG/dashboard_admin.html");
        break;
    default:
        header("Location: login.php");
}
exit();
?>

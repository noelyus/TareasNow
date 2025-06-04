<?php
session_start();
require_once("../db/conexion.php");
header('Content-Type: application/json');

ini_set('display_errors', 1); //pedimos al php sacar los errores (este PHP fue complicado)
ini_set('display_startup_errors', 1);
error_reporting(E_ALL);

if (!isset($_SESSION['credenciales']) || $_SESSION['credenciales']['id_rol'] != 2) {
    echo json_encode(['error' => 'No autorizado']);
    exit;
}//comprobamos que el usuario es profesor y esta registrado

$user = $_SESSION["credenciales"];
$id_profesor = $user['id']; //sacamos la informacion del profesor para usarla mas adelante

if (!isset($_POST['id_asignatura'], $_POST['titulo_tarea'], $_POST['descripcion_tarea'], $_POST['fecha_limite'])) {
    echo json_encode(['error' => 'Faltan datos del formulario']);
    exit;
}//comprobamos que se reciben los datos
$id_asignatura = intval($_POST['id_asignatura']);
$titulo = trim($_POST['titulo_tarea']);
$descripcion = trim($_POST['descripcion_tarea']);
$fecha = $_POST['fecha_limite'];
$fecha_final = date('Y-m-d H:i:s', strtotime($fecha));//guardamos los datos recibidos del formulario en variables
// Crear tarea llamando al procedimiento encargado en la base de datos
$stmt = $conn->prepare("CALL creador_tareas(?, ?, ?, ?, ?)");
$stmt->bind_param("sssis", $titulo ,$descripcion, $fecha_final, $id_asignatura, $id_profesor);

if (!$stmt->execute()) {
    echo json_encode(['error' => 'Error al crear la tarea']);
    exit;
}//reportamos error 
//Consulta para buscar el id de la tarea que se acaba de hacer
$queryIDtarea = "SELECT MAX(id) FROM tarea WHERE id_creador = ?";
$stmtIDtarea = $conn->prepare($queryIDtarea);
$stmtIDtarea->bind_param("i", $id_profesor);
$stmtIDtarea->execute();
$resultIdtarea = $stmtIDtarea->get_result();
$row = $resultIdtarea->fetch_row();
$id_tarea = $row[0]; //seleccionamos una sola fila por si llegase a dar mas
$stmtIDtarea->close();


// Subir archivo
if (isset($_FILES['archivo_tarea']) && $_FILES['archivo_tarea']['error'] === UPLOAD_ERR_OK) {//si recibimos el archivo correctamente
    $nombreOriginal = basename($_FILES['archivo_tarea']['name']);//sacamos el nombre de este 
    $info = pathinfo($nombreOriginal);
    $nombreSinExtension = $info['filename'];// sacamos el nombre del archivo sin la extension
    $extension = strtolower($info['extension']);//sacamos la extension en minusculas

    $nombreFinal = uniqid() . '_' . $nombreOriginal;//aplicamos un id unico al archivo para evitar conflictos en el sistema
    $directorio = "../uploads/tarea$id_tarea/"; //creamos un directorio donde se guardara el archivo, este directorio esta asociado al idtarea

    if (!file_exists($directorio)) {//si el directorio de la tarea no existe se crea
        mkdir($directorio, 0777, true);
    }

    $rutaDestino = $directorio . $nombreFinal;//para la ruta destino concatenamos el directorio y el nombre final 
 
  
    if (move_uploaded_file($_FILES['archivo_tarea']['tmp_name'], $rutaDestino)) {//movemos el archivo a nuestra carpeta final
        
        $stmtTipo = $conn->prepare("SELECT id FROM tipos_archivos WHERE tipo =  ?");
        $stmtTipo->bind_param("s", $extension);
        $stmtTipo->execute();
        $stmtTipo->bind_result($id_tipo);//buscamos la extension del archivo en la base de datos y guardamos su id

        if ($stmtTipo->fetch()) {//si la extension se encuentra cerramos la consulta 
            $stmtTipo->close();

            $rutaRelativa = "uploads/tarea$id_tarea/" . $nombreFinal; // creamos una ruta relaativa para la base de datos

            $stmtArchivo = $conn->prepare("
                INSERT INTO archivos (id_tarea, id_usuario, ruta, nombre, id_tipo)
                VALUES ( ?, ?, ?, ?, ?)
            ");
            $stmtArchivo->bind_param("isssi", $id_tarea, $id_profesor, $rutaRelativa, $nombreSinExtension, $id_tipo);
            $stmtArchivo->execute();
            $stmtArchivo->close(); //introducimos el archivo creado en la base de datos 
        } else {
            $stmtTipo->close();
            echo json_encode(['error' => 'Extensión no permitida o no registrada']);
            exit;//error si no se encontrara la extension
        }
    } else {
        echo json_encode(['error' => 'Error al mover el archivo']);
        exit;
    }
}

echo json_encode(['success' => true]); //devolver un succes si todo ha salido correctamente
$conn->close();

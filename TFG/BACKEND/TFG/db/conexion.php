<?php
$host = "localhost"; //definimos la variable donde establecemos la direccion de la base de datos 
$user = "TFG"; //definimos el usuario para acceder a la base de datos
$password = "1234qwerty."; //definimos la contraseña del usuario de la base de datos
$dbname = "tfg_db";//el nombre de la base de datos que se utilizara 

$conn = new mysqli($host, $user, $password, $dbname); //preparamos la variable conn que establece una conexion a mysql con las 
//anteriores variables

if ($conn->connect_error) {
    die("Conexión fallida: " . $conn->connect_error);
}//en caso de que haya un error que salte y se pueda ver 


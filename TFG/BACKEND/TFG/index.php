<?php
header('Content-Type: application/json');
echo json_encode([
    'status' => 'OK',
    'message' => 'API backend funcionando correctamente',
]);

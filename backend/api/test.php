<?php

echo json_encode([
    'status' => 'ok',
    'message' => 'PHP is working',
    'time' => date('Y-m-d H:i:s'),
    'uri' => $_SERVER['REQUEST_URI'] ?? 'unknown',
]);

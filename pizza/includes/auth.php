<?php
// includes/auth.php
if(session_status() === PHP_SESSION_NONE) session_start();

function is_logged_in(){
    return isset($_SESSION['user']);
}
function require_login(){
    if(!is_logged_in()){
        header('Location: /public/login.php');
        exit;
    }
}
function is_admin(){
    return is_logged_in() && ($_SESSION['user']['role'] ?? '') === 'admin';
}
function require_admin(){
    if(!is_admin()){
        http_response_code(403);
        echo "Forbidden";
        exit;
    }
}

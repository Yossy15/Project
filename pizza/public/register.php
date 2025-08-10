<?php
require_once __DIR__ . '/../includes/db.php';
require_once __DIR__ . '/../includes/functions.php';
if (session_status() === PHP_SESSION_NONE) session_start();

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
  $name = trim($_POST['name'] ?? '');
  $email = trim($_POST['email'] ?? '');
  $pass = $_POST['password'] ?? '';
  $addr = trim($_POST['address'] ?? '');

  if (!$name || !$email || !$pass) {
    $error = "กรุณากรอกข้อมูลให้ครบ";
  } else {
    $hash = password_hash($pass, PASSWORD_DEFAULT);
    $stmt = $pdo->prepare("INSERT INTO users (name,email,password,address) VALUES (?,?,?,?)");
    try {
      $stmt->execute([$name, $email, $hash, $addr]);
      header('Location: login.php');
      exit;
    } catch (Exception $e) {
      $error = "มีบัญชีนี้อยู่แล้วหรือเกิดข้อผิดพลาด";
    }
  }
}
?>
<!doctype html>
<html>

<head>
  <meta charset="utf-8">
  <title>Register</title>
  <link rel="stylesheet" href="css/style.css">
  <link rel="stylesheet" href="css/register.css">
  <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@400;600&display=swap" rel="stylesheet">
</head>

<body>
  <div class="header">
    <div><a href="index.php">Pizza Shop</a></div>
    <div><a href="login.php">Login</a></div>
  </div>
  <div class="container">
    <h2>สมัครสมาชิก</h2>
    <?php if (!empty($error)) echo '<p class="err">' . esc($error) . '</p>'; ?>
    <form method="post">
      <div class="form-row"><label>ชื่อ <input type="text" name="name" required></label></div>
      <div class="form-row"><label>Email <input type="email" name="email" required></label></div>
      <div class="form-row"><label>Password <input type="password" name="password" required></label></div>
      <div class="form-row"><label>ที่อยู่ <textarea name="address"></textarea></label></div>
      <button class="btn" type="submit">Register</button>
    </form>
  </div>
</body>

</html>
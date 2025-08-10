<?php
require_once __DIR__ . '/../includes/db.php';
require_once __DIR__ . '/../includes/auth.php';
require_once __DIR__ . '/../includes/functions.php';

if (session_status() === PHP_SESSION_NONE) session_start();

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
  $email = $_POST['email'] ?? '';
  $pass = $_POST['password'] ?? '';

  $stmt = $pdo->prepare("SELECT * FROM users WHERE email = ?");
  $stmt->execute([$email]);
  $user = $stmt->fetch();
  if ($user && password_verify($pass, $user['password'])) {
    session_regenerate_id(true);
    $_SESSION['user'] = [
      'id' => $user['id'],
      'name' => $user['name'],
      'email' => $user['email'],
      'role' => $user['role'],
    ];
    if ($user['role'] === 'admin') header('Location: ../admin/index.php');
    else header('Location: index.php');
    exit;
  } else {
    $error = "อีเมลหรือรหัสผ่านไม่ถูกต้อง";
  }
}
?>
<!doctype html>
<html>

<head>
  <meta charset="utf-8">
  <title>Login</title>
  <!-- <link rel="stylesheet" href="css/style.css"> -->
  <link rel="stylesheet" href="css/login.css">
  <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@400;600&display=swap" rel="stylesheet">
</head>

<body>
  <div class="header">
    <div><a href="index.php">Pizza Shop</a></div>
    <div><a href="register.php">Register</a></div>
  </div>
  <div class="container">
    <h2>เข้าสู่ระบบ</h2>
    <?php if (!empty($error)) echo '<p class="err">' . esc($error) . '</p>'; ?>
    <form method="post">
      <div class="form-row"><label>Email <input type="email" name="email" required></label></div>
      <div class="form-row"><label>Password <input type="password" name="password" required></label></div>
      <button class="btn" type="submit">Login</button>
    </form>
  </div>
</body>

</html>
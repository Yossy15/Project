<?php
require_once __DIR__ . '/../includes/db.php';
require_once __DIR__ . '/../includes/auth.php';
require_once __DIR__ . '/../includes/functions.php';
if (session_status() === PHP_SESSION_NONE) session_start();
require_login();

$user = $_SESSION['user'];
$st = $pdo->prepare("SELECT * FROM orders WHERE user_id = ? ORDER BY created_at DESC");
$st->execute([$user['id']]);
$orders = $st->fetchAll();
?>
<!doctype html>
<html>

<head>
  <meta charset="utf-8">
  <title>Profile</title>
  <link rel="stylesheet" href="css/style.css">
  <link rel="stylesheet" href="css/profile.css">
  <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@400;600&display=swap" rel="stylesheet">
</head>

<body>
  <div class="header">
    <div><a href="index.php">Pizza Shop</a></div>
    <div><a href="cart.php">Cart</a></div>
  </div>
  <div class="container">
    <h2>โปรไฟล์</h2>
    <p>ชื่อ: <?php echo esc($user['name']); ?></p>
    <p>อีเมล: <?php echo esc($user['email']); ?></p>
    <h3>ประวัติการสั่งซื้อ</h3>
    <?php if (!$orders) echo "<p class='no-orders'>ยังไม่มีการสั่งซื้อ</p>";
    else { ?>
      <table class="table">
        <tr>
          <th>ID</th>
          <th>วันที่</th>
          <th>รวม</th>
          <th>สถานะ</th>
        </tr>
        <?php foreach ($orders as $o): ?>
          <tr>
            <td><?php echo $o['id']; ?></td>
            <td><?php echo $o['created_at']; ?></td>
            <td>$<?php echo number_format($o['total'], 2); ?></td>
            <td><?php echo esc($o['status']); ?></td>
          </tr>
        <?php endforeach; ?>
      </table>
    <?php } ?>
  </div>
</body>

</html>
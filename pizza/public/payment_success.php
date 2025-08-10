<?php
require_once __DIR__ . '/../includes/db.php';
require_once __DIR__ . '/../includes/auth.php';
if (session_status() === PHP_SESSION_NONE) session_start();
require_login();

$order_id = $_GET['order_id'] ?? null;
if (!$order_id) {
  echo "Invalid";
  exit;
}

$stmt = $pdo->prepare("SELECT o.*, u.name as user_name FROM orders o JOIN users u ON u.id=o.user_id WHERE o.id = ?");
$stmt->execute([$order_id]);
$order = $stmt->fetch();
if (!$order) {
  echo "Order not found";
  exit;
}

$itSt = $pdo->prepare("SELECT * FROM order_items WHERE order_id = ?");
$itSt->execute([$order_id]);
$items = $itSt->fetchAll();
?>
<!doctype html>
<html>

<head>
  <meta charset="utf-8">
  <title>Order Success</title>
  <link rel="stylesheet" href="css/style.css">
  <link rel="stylesheet" href="css/payment_success.css">
  <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@400;600&display=swap" rel="stylesheet">
</head>

<body>
  <div class="header">
    <div><a href="index.php">Pizza Shop</a></div>
  </div>
  <div class="container">
    <h2>สั่งซื้อสำเร็จ (Order #<?php echo $order['id']; ?>)</h2>
    <p>ผู้สั่ง: <?php echo esc($order['user_name']); ?></p>
    <p>ที่อยู่: <?php echo esc($order['address']); ?></p>
    <p>สถานะการชำระเงิน: <?php echo esc($order['payment_status']); ?></p>
    <h3>Items</h3>
    <ul>
      <?php foreach ($items as $it) echo '<li>' . esc($it['name']) . ' - ' . esc($it['size']) . ' x ' . esc($it['quantity']) . ' ($' . number_format($it['price'], 2) . ')</li>'; ?>
    </ul>
    <p>Total: $<?php echo number_format($order['total'], 2); ?></p>
  </div>
</body>

</html>
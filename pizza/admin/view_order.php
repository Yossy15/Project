<?php
require_once __DIR__ . '/../includes/db.php';
require_once __DIR__ . '/../includes/auth.php';
if (session_status() === PHP_SESSION_NONE) session_start();
require_admin();

$id = $_GET['id'] ?? null;
if (!$id) exit("invalid");
$st = $pdo->prepare("SELECT o.*, u.name, u.email FROM orders o JOIN users u ON u.id=o.user_id WHERE o.id = ?");
$st->execute([$id]);
$o = $st->fetch();
if (!$o) exit("not found");
$it = $pdo->prepare("SELECT * FROM order_items WHERE order_id = ?");
$it->execute([$id]);
$items = $it->fetchAll();
?>
<!doctype html>
<html>

<head>
  <meta charset="utf-8">
  <title>View Order</title>
  <link rel="stylesheet" href="/public/css/style.css">
  <link rel="stylesheet" href="css/view_order.css">
  <link href="https://fonts.googleapis.com/css2?family=Nunito:wght@400;600&display=swap" rel="stylesheet">
</head>

<body>
  <div class="header">
    <div>Admin</div>
    <div><a href="orders.php">Back</a></div>
  </div>
  <div class="container">
    <h2>Order #<?php echo $o['id']; ?></h2>
    <div class="order-details">
      <p>User: <?php echo esc($o['name']) . ' (' . esc($o['email']) . ')'; ?></p>
      <p>Address: <?php echo esc($o['address']); ?></p>
      <p>Payment: <?php echo esc($o['payment_method']) . ' / ' . esc($o['payment_status']); ?></p>
    </div>
    <h3>Items</h3>
    <ul class="order-items">
      <?php
      if (empty($items)) {
        echo '<li>ไม่มีรายการสินค้า</li>';
      } else {
        foreach ($items as $it) {
          echo '<li>' . esc($it['name']) . ' - ' . esc($it['size']) . ' x ' . esc($it['quantity']) . ' ($' . number_format($it['price'], 2) . ')</li>';
        }
      }
      ?>
    </ul>
    <div class="order-details">
      <p>Total: $<?php echo number_format($o['total'], 2); ?></p>
    </div>
  </div>
</body>

</html>
<?php
require_once __DIR__ . '/../includes/db.php';
require_once __DIR__ . '/../includes/auth.php';
require_once __DIR__ . '/../includes/functions.php';
if(session_status() === PHP_SESSION_NONE) session_start();
require_admin();

$sumSt = $pdo->query("SELECT COUNT(*) as cnt, SUM(total) as total_sum FROM orders");
$summary = $sumSt->fetch();
?>
<!doctype html>
<html>
<head>
  <meta charset="utf-8">
  <title>Admin Dashboard</title>
  <link rel="stylesheet" href="/public/css/style.css">
  <link rel="stylesheet" href="css/index.css">
  <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@400;600&display=swap" rel="stylesheet">
</head>
<body>
  <div class="header">
    <div>Admin</div>
    <div>
      <a href="../public/index.php">Go to Shop</a> | <a href="/public/logout.php">Logout</a>
    </div>
  </div>
  <div class="container">
    <h2>Dashboard</h2>
    <p class="summary">Orders: <?php echo $summary['cnt']; ?> | Total sales: $<?php echo number_format($summary['total_sum']?:0,2); ?></p>
    <div class="button-group">
      <a class="btn" href="products.php">Manage Products</a>
      <a class="btn" href="orders.php">View Orders</a>
    </div>
  </div>
</body>
</html>
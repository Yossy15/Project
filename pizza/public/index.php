<?php
require_once __DIR__ . '/../includes/db.php';
require_once __DIR__ . '/../includes/auth.php';
require_once __DIR__ . '/../includes/functions.php';
if (session_status() === PHP_SESSION_NONE) session_start();

// search and filter
$q = $_GET['q'] ?? '';
$min = $_GET['min'] ?? '';
$max = $_GET['max'] ?? '';

$sql = "SELECT * FROM products WHERE 1=1";
$params = [];
if ($q) {
  $sql .= " AND name LIKE ?";
  $params[] = "%$q%";
}
if ($min !== '') {
  $sql .= " AND price >= ?";
  $params[] = $min;
}
if ($max !== '') {
  $sql .= " AND price <= ?";
  $params[] = $max;
}

$stmt = $pdo->prepare($sql);
$stmt->execute($params);
$products = $stmt->fetchAll();
?>
<!doctype html>
<html>

<head>
  <meta charset="utf-8">
  <title>Pizza Shop</title>
  <!-- <link rel="stylesheet" href="css/style.css"> -->
  <link rel="stylesheet" href="css/index.css">
  <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@400;600&display=swap" rel="stylesheet">
</head>

<body>
  <div class="header">
    <div><a href="index.php">Pizza Shop</a></div>
    <div>
      <?php if (is_logged_in()) {
        echo '<a href="profile.php">' . esc($_SESSION['user']['name']) . '</a> | <a href="cart.php">Cart</a> | <a href="logout.php">Logout</a>';
      } else {
        echo '<a href="login.php">Login</a> | <a href="register.php">Register</a> | <a href="cart.php">Cart</a>';
      } ?>
    </div>
  </div>

  <div class="container">
    <h2>Menu</h2>
    <form method="get" style="margin-bottom:12px;">
      <input type="text" name="q" placeholder="ค้นหาพิซซ่า..." value="<?php echo esc($q); ?>">
      <button class="btn" type="submit">ค้นหา/กรอง</button>
    </form>
    <div class="products">
      <?php foreach ($products as $p): ?>
        <div class="product">
          <img src="<?php echo esc($p['image'] ?: 'https://via.placeholder.com/200x140'); ?>" alt="">
          <h4><?php echo esc($p['name']); ?></h4>
          <p class="small"><?php echo esc($p['description']); ?></p>
          <p><strong>$<?php echo number_format($p['price'], 2); ?></strong></p>
          <a class="btn" href="product.php?id=<?php echo $p['id']; ?>">เลือก</a>
        </div>
      <?php endforeach; ?>
    </div>
  </div>
</body>

</html>
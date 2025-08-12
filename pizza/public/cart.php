<?php
require_once __DIR__ . '/../includes/functions.php';
if (session_status() === PHP_SESSION_NONE) session_start();

$cart = $_SESSION['cart'] ?? [];

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
  if (isset($_POST['remove'])) {
    $k = (int)$_POST['remove'];
    if (isset($cart[$k])) {
      unset($cart[$k]);
    }
    $_SESSION['cart'] = array_values($cart);
    header('Location: cart.php');
    exit;
  }
  if (isset($_POST['update'])) {
    foreach ($_POST['qty'] as $k => $v) {
      $k = (int)$k;
      $v = max(1, (int)$v);
      if (isset($cart[$k])) $cart[$k]['quantity'] = $v;
    }
    $_SESSION['cart'] = $cart;
    header('Location: cart.php');
    exit;
  }
  if (isset($_POST['apply_voucher'])) {
    $_SESSION['voucher_code'] = trim($_POST['voucher'] ?? '');
    header('Location: cart.php');
    exit;
  }
}

$total = 0;
foreach ($cart as $it) {
  $total += $it['price'] * $it['quantity'];
}
?>
<!doctype html>
<html>

<head>
  <meta charset="utf-8">
  <title>Cart</title>
  <link rel="stylesheet" href="css/style.css">
  <link rel="stylesheet" href="css/cart.css">
  <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@400;600&display=swap" rel="stylesheet">
</head>

<body>
  <div class="header">
    <div><a href="index.php">Pizza Shop</a></div>
    <div><a href="checkout.php">Checkout</a></div>
  </div>
  <div class="container">
    <h2>ตะกร้าสินค้า</h2>
    <?php if (empty($cart)) echo "<p>ตะกร้าว่าง</p>";
    else ?>
    <form method="post">
      <table class="table">
        <tr>
          <th>#</th>
          <th>รูป</th>
          <th>ชื่อ</th>
          <th>รายละเอียด</th>
          <th>ราคา</th>
          <th>จำนวน</th>
          <th>รวม</th>
          <th>จบ</th>
        </tr>
        <?php foreach ($cart as $k => $it): ?>
          <tr>
            <td><?php echo $k + 1; ?></td>
            <td><img src="<?php echo esc($it['image'] ?: 'https://via.placeholder.com/80x60'); ?>" style="width:80px;height:60px;object-fit:cover;"></td>
            <td><?php echo esc($it['name']); ?></td>
            <td><?php echo "Crust: " . esc($it['crust']) . ", Size: " . esc($it['size']); ?></td>
            <td>$<?php echo number_format($it['price'], 2); ?></td>
            <td><input type="number" name="qty[<?php echo $k; ?>]" value="<?php echo $it['quantity']; ?>" min="1"></td>
            <td>$<?php echo number_format($it['price'] * $it['quantity'], 2); ?></td>
            <td><button name="remove" value="<?php echo $k; ?>" class="secondary">ลบ</button></td>
          </tr>
        <?php endforeach; ?>
        <tr>
          <td colspan="6" style="text-align:right">Subtotal</td>
          <td colspan="2">$<?php echo number_format($total, 2); ?></td>
        </tr>
      </table>
      <div style="margin-top:10px;">
        <button class="btn" name="update" value="1">อัปเดตจำนวน</button>
        <a class="btn" href="checkout.php">ไปชำระเงิน</a>
      </div>
    </form>
    <hr>
    <!-- <h3>มีโค้ดส่วนลด? ใส่ที่นี่</h3>
    <form method="post"><input type="text" name="voucher" placeholder="CODE" value="<?php echo esc($_SESSION['voucher_code'] ?? ''); ?>"><button class="btn" name="apply_voucher" value="1">ใช้โค้ด</button></form> -->

  </div>
</body>

</html>
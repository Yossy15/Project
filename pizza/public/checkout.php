<?php
require_once __DIR__ . '/../includes/db.php';
require_once __DIR__ . '/../includes/auth.php';
require_once __DIR__ . '/../includes/functions.php';
if (session_status() === PHP_SESSION_NONE) session_start();
require_login();

$cart = $_SESSION['cart'] ?? [];
if (empty($cart)) {
  header('Location: cart.php');
  exit;
}

// compute totals
$subtotal = 0;
foreach ($cart as $it) $subtotal += $it['price'] * $it['quantity'];

$voucher_code = $_SESSION['voucher_code'] ?? null;
$discount = 0.00;
if ($voucher_code) {
  $st = $pdo->prepare("SELECT * FROM vouchers WHERE code = ?");
  $st->execute([$voucher_code]);
  $v = $st->fetch();
  if ($v) {
    // check expiry and max uses (simple)
    $expired = ($v['expires_at'] && strtotime($v['expires_at']) < time());
    $max_uses_reached = ($v['max_uses'] > 0 && $v['uses'] >= $v['max_uses']);
    if (!$expired && !$max_uses_reached) {
      if ($v['type'] === 'percent') {
        $discount = round($subtotal * ($v['value'] / 100), 2);
      } else {
        $discount = min($subtotal, $v['value']);
      }
    } else {
      $voucher_code = null;
      $_SESSION['voucher_code'] = null;
      $voucher_msg = "โค้ดหมดอายุหรือใช้งานครบแล้ว";
    }
  } else {
    $voucher_code = null;
    $_SESSION['voucher_code'] = null;
    $voucher_msg = "โค้ดไม่ถูกต้อง";
  }
}

$total = round($subtotal - $discount, 2);

// handle place order
if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['place_order'])) {
  $address = trim($_POST['address'] ?? '');
  $payment = $_POST['payment'] ?? 'cod'; // 'cod' or 'stripe' (stripe simulated)

  $pdo->beginTransaction();
  $ordSt = $pdo->prepare("INSERT INTO orders (user_id, total, discount, voucher_code, address, payment_method, payment_status) VALUES (?,?,?,?,?,?,?)");
  $ordSt->execute([$_SESSION['user']['id'], $total, $discount, $voucher_code, $address, $payment, ($payment === 'cod' ? 'pending' : 'pending')]);
  $order_id = $pdo->lastInsertId();

  $itSt = $pdo->prepare("INSERT INTO order_items (order_id, product_id, name, crust, size, price, quantity) VALUES (?,?,?,?,?,?,?)");
  foreach ($cart as $it) {
    $itSt->execute([$order_id, $it['product_id'], $it['name'], $it['crust'], $it['size'], $it['price'], $it['quantity']]);
  }
  // increment voucher uses
  if ($voucher_code) {
    $uSt = $pdo->prepare("UPDATE vouchers SET uses = uses + 1 WHERE code = ?");
    $uSt->execute([$voucher_code]);
  }
  $pdo->commit();

  // clear cart and voucher
  unset($_SESSION['cart']);
  unset($_SESSION['voucher_code']);
  header('Location: payment_success.php?order_id=' . $order_id);
  exit;
}

$user_info = $_SESSION['user'];
?>
<!doctype html>
<html>

<head>
  <meta charset="utf-8">
  <title>Checkout</title>
  <link rel="stylesheet" href="css/style.css">
  <link rel="stylesheet" href="css/chackout.css">
</head>

<body>
  <div class="header">
    <div><a href="index.php">Pizza Shop</a></div>
    <div><a href="cart.php">Cart</a></div>
  </div>
  <div class="container">
    <h2>ชำระเงิน</h2>
    <h3>ข้อมูลผู้ซื้อ</h3>
    <p><?php echo esc($user_info['name']); ?> (<?php echo esc($user_info['email']); ?>)</p>
    <form method="post">
      <div class="form-row"><label>ที่อยู่จัดส่ง <textarea name="address" required><?php echo esc($_SESSION['user']['address'] ?? ''); ?></textarea></label></div>
      <h3>สรุปรายการ</h3>
      <ul>
        <?php foreach ($cart as $it): ?>
          <li><?php echo esc($it['name']) . " - " . esc($it['size']) . " x " . esc($it['quantity']) . " => $" . number_format($it['price'] * $it['quantity'], 2); ?></li>
        <?php endforeach; ?>
      </ul>
      <p>Subtotal: $<?php echo number_format($subtotal, 2); ?></p>
      <p>Discount: $<?php echo number_format($discount, 2); ?> <?php if (!empty($voucher_msg)) echo ' - ' . esc($voucher_msg); ?></p>
      <p><strong>Total: $<?php echo number_format($total, 2); ?></strong></p>
      <div class="form-row">
        <label>Payment method:
          <select name="payment">
            <option value="cod">Cash on Delivery</option>
            <option value="stripe">Online (simulated)</option>
          </select>
        </label>
      </div>
      <button class="btn" name="place_order" value="1" type="submit">ยืนยันการสั่งซื้อ</button>
    </form>
  </div>
</body>

</html>
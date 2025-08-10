<?php
require_once __DIR__ . '/../includes/db.php';
require_once __DIR__ . '/../includes/auth.php';
if (session_status() === PHP_SESSION_NONE) session_start();
require_admin();

// update status
if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['update_status'])) {
  $id = (int)$_POST['order_id'];
  $st = $pdo->prepare("UPDATE orders SET status = ?, payment_status = ? WHERE id = ?");
  $st->execute([$_POST['status'], $_POST['payment_status'], $id]);
  header('Location: orders.php');
  exit;
}

$st = $pdo->query("SELECT o.*, u.email FROM orders o JOIN users u ON u.id=o.user_id ORDER BY o.created_at DESC");
$orders = $st->fetchAll();
?>
<!doctype html>
<html>

<head>
  <meta charset="utf-8">
  <title>Orders</title>
  <link rel="stylesheet" href="/public/css/style.css">
  <link rel="stylesheet" href="css/orders.css">
  <link href="https://fonts.googleapis.com/css2?family=Nunito:wght@400;600&display=swap" rel="stylesheet">
</head>

<body>
  <div class="header">
    <div>Admin</div>
    <div><a href="index.php">Dashboard</a></div>
  </div>
  <div class="container">
    <h2>Orders</h2>
    <?php if (empty($orders)): ?>
      <p class="no-orders">ยังไม่มีการสั่งซื้อ</p>
    <?php else: ?>
      <table class="table">
        <tr>
          <th>ID</th>
          <th>User</th>
          <th>Total</th>
          <th>Payment</th>
          <th>Status</th>
          <th>Action</th>
        </tr>
        <?php foreach ($orders as $o): ?>
          <tr>
            <td><?php echo $o['id']; ?></td>
            <td><?php echo esc($o['email']); ?></td>
            <td>$<?php echo number_format($o['total'], 2); ?></td>
            <td><?php echo esc($o['payment_method']) . ' / ' . esc($o['payment_status']); ?></td>
            <td><?php echo esc($o['status']); ?></td>
            <td>
              <form method="post">
                <input type="hidden" name="order_id" value="<?php echo $o['id']; ?>">
                <select name="status">
                  <option value="pending" <?php echo $o['status'] === 'pending' ? 'selected' : ''; ?>>pending</option>
                  <option value="preparing" <?php echo $o['status'] === 'preparing' ? 'selected' : ''; ?>>preparing</option>
                  <option value="shipped" <?php echo $o['status'] === 'shipped' ? 'selected' : ''; ?>>shipped</option>
                  <option value="cancelled" <?php echo $o['status'] === 'cancelled' ? 'selected' : ''; ?>>cancelled</option>
                </select>
                <select name="payment_status">
                  <option value="pending" <?php echo $o['payment_status'] === 'pending' ? 'selected' : ''; ?>>pending</option>
                  <option value="paid" <?php echo $o['payment_status'] === 'paid' ? 'selected' : ''; ?>>paid</option>
                  <option value="failed" <?php echo $o['payment_status'] === 'failed' ? 'selected' : ''; ?>>failed</option>
                </select>
                <button class="btn" name="update_status" value="1">Update</button>
              </form>
              <a class="btn" href="view_order.php?id=<?php echo $o['id']; ?>">View</a>
            </td>
          </tr>
        <?php endforeach; ?>
      </table>
    <?php endif; ?>
  </div>
</body>

</html>
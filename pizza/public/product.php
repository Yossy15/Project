<?php
require_once __DIR__ . '/../includes/db.php';
require_once __DIR__ . '/../includes/functions.php';
if (session_status() === PHP_SESSION_NONE) session_start();

$id = $_GET['id'] ?? null;
if (!$id) {
  header('Location: index.php');
  exit;
}
$stmt = $pdo->prepare("SELECT * FROM products WHERE id = ?");
$stmt->execute([$id]);
$product = $stmt->fetch();
if (!$product) {
  echo "ไม่พบสินค้า";
  exit;
}

// handle add to cart
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
  $crust = $_POST['crust'] ?? 'regular';
  $size = $_POST['size'] ?? 'medium';
  $qty = max(1, (int)($_POST['qty'] ?? 1));
  $price = calc_price_by_size($product['price'], $size);

  $item = [
    'product_id' => $product['id'],
    'name' => $product['name'],
    'crust' => $crust,
    'size' => $size,
    'price' => $price,
    'quantity' => $qty,
    'image' => $product['image']
  ];
  if (!isset($_SESSION['cart'])) $_SESSION['cart'] = [];
  $_SESSION['cart'][] = $item;
  header('Location: cart.php');
  exit;
}
?>
<!doctype html>
<html>

<head>
  <meta charset="utf-8">
  <title><?php echo esc($product['name']); ?></title>
  <link rel="stylesheet" href="css/style.css">
  <link rel="stylesheet" href="css/product.css">
  <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@400;600&display=swap" rel="stylesheet">
</head>

<body>
  <div class="header">
    <div><a href="index.php">Pizza Shop</a></div>
    <div><a href="cart.php">Cart</a></div>
  </div>
  <div class="container">
    <h2><?php echo esc($product['name']); ?></h2>
    <div class="product-detail">
      <div class="product-image">
        <img src="<?php echo esc($product['image'] ?: 'https://via.placeholder.com/300x220'); ?>" alt="<?php echo esc($product['name']); ?>">
      </div>
      <div class="product-info">
        <p><?php echo esc($product['description']); ?></p>
        <p>Base price: $<?php echo number_format($product['price'], 2); ?></p>
        <form method="post">
          <div class="form-row">
            <label>Crust
              <select name="crust">
                <option value="thin">Thin</option>
                <option value="regular" selected>Regular</option>
                <option value="stuffed">Stuffed</option>
              </select>
            </label>
          </div>
          <div class="form-row">
            <label>Size
              <select name="size">
                <option value="small">Small</option>
                <option value="medium" selected>Medium</option>
                <option value="large">Large (+30%)</option>
              </select>
            </label>
          </div>
          <div class="form-row">
            <label>Quantity <input type="number" name="qty" value="1" min="1"></label>
          </div>
          <button class="btn" type="submit">เพิ่มลงตะกร้า</button>
        </form>
      </div>
    </div>
    <div>
      <br />
    </div>
  </div>
  
</body>

</html>
<?php
require_once __DIR__ . '/../includes/db.php';
require_once __DIR__ . '/../includes/auth.php';
if (session_status() === PHP_SESSION_NONE) session_start();
require_admin();

// handle delete
if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['delete'])) {
  $id = (int)$_POST['delete'];
  $st = $pdo->prepare("DELETE FROM products WHERE id = ?");
  $st->execute([$id]);
  header('Location: products.php');
  exit;
}

// handle upload new product
if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['add'])) {
  $name = $_POST['name'];
  $desc = $_POST['description'];
  $price = $_POST['price'];
  $imgPath = null;
  if (isset($_FILES['image']) && $_FILES['image']['error'] === 0) {
    $ext = pathinfo($_FILES['image']['name'], PATHINFO_EXTENSION);
    $fname = 'Uploads/' . time() . '_' . basename($_FILES['image']['name']);
    @move_uploaded_file($_FILES['image']['tmp_name'], __DIR__ . '/../public/' . $fname);
    $imgPath = $fname;
  }
  $st = $pdo->prepare("INSERT INTO products (name,description,price,image) VALUES (?,?,?,?)");
  $st->execute([$name, $desc, $price, $imgPath]);
  header('Location: products.php');
  exit;
}

$st = $pdo->query("SELECT * FROM products ORDER BY created_at DESC");
$products = $st->fetchAll();
?>
<!doctype html>
<html>

<head>
  <meta charset="utf-8">
  <title>Manage Products</title>
  <link rel="stylesheet" href="/public/css/style.css">
  <link rel="stylesheet" href="css/products.css">
  <link href="https://fonts.googleapis.com/css2?family=Nunito:wght@400;600&display=swap" rel="stylesheet">
</head>

<body>
  <div class="header">
    <div>Admin</div>
    <div><a href="index.php">Dashboard</a></div>
  </div>
  <div class="container">
    <h2>Products</h2>
    <form method="post" enctype="multipart/form-data">
      <h3>Add New Product</h3>
      <div class="form-row">
        <label>ชื่อสินค้า <input type="text" name="name" placeholder="Name" required></label>
      </div>
      <div class="form-row">
        <label>ราคา <input type="number" step="0.01" name="price" placeholder="Price" required></label>
      </div>
      <div class="form-row">
        <label>รายละเอียด <textarea name="description" placeholder="Description"></textarea></label>
      </div>
      <div class="form-row">
        <label>รูปภาพ <input type="file" name="image" accept="image/*"></label>
      </div>
      <button class="btn" name="add" value="1" type="submit">Add</button>
    </form>

    <?php if (empty($products)): ?>
      <p class="no-orders">ยังไม่มีสินค้า</p>
    <?php else: ?>
      <table class="table">
        <tr>
          <th>ID</th>
          <th>Image</th>
          <th>Name</th>
          <th>Price</th>
          <th>Action</th>
        </tr>
        <?php foreach ($products as $p): ?>
          <tr>
            <td><?php echo $p['id']; ?></td>
            <td><img src="/public/<?php echo esc($p['image'] ?: 'https://via.placeholder.com/80x60'); ?>" alt="<?php echo esc($p['name']); ?>"></td>
            <td><?php echo esc($p['name']); ?></td>
            <td>$<?php echo number_format($p['price'], 2); ?></td>
            <td>
              <a class="btn" href="edit_product.php?id=<?php echo $p['id']; ?>">Edit</a>
              <form method="post">
                <button class="secondary" name="delete" value="<?php echo $p['id']; ?>">Delete</button>
              </form>
            </td>
          </tr>
        <?php endforeach; ?>
      </table>
    <?php endif; ?>
  </div>
</body>

</html>
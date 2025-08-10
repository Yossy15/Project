<?php
require_once __DIR__ . '/../includes/db.php';
require_once __DIR__ . '/../includes/auth.php';
if (session_status() === PHP_SESSION_NONE) session_start();
require_admin();

$id = $_GET['id'] ?? null;
if (!$id) {
  header('Location: products.php');
  exit;
}
$st = $pdo->prepare("SELECT * FROM products WHERE id = ?");
$st->execute([$id]);
$p = $st->fetch();
if (!$p) {
  echo "Not found";
  exit;
}

if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['save'])) {
  $name = $_POST['name'];
  $desc = $_POST['description'];
  $price = $_POST['price'];
  $imgPath = $p['image'];
  if (isset($_FILES['image']) && $_FILES['image']['error'] === 0) {
    $fname = 'Uploads/' . time() . '_' . basename($_FILES['image']['name']);
    @move_uploaded_file($_FILES['image']['tmp_name'], __DIR__ . '/../public/' . $fname);
    $imgPath = $fname;
  }
  $u = $pdo->prepare("UPDATE products SET name=?, description=?, price=?, image=? WHERE id=?");
  $u->execute([$name, $desc, $price, $imgPath, $id]);
  header('Location: products.php');
  exit;
}
?>
<!doctype html>
<html>

<head>
  <meta charset="utf-8">
  <title>Edit Product</title>
  <link rel="stylesheet" href="/public/css/style.css">
  <link rel="stylesheet" href="css/edit.css">
  <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@400;600&display=swap" rel="stylesheet">
</head>

<body>
  <div class="header">
    <div>Admin</div>
    <div><a href="products.php">Back</a></div>
  </div>
  <div class="container">
    <h2>Edit Product #<?php echo $p['id']; ?></h2>
    <form method="post" enctype="multipart/form-data">
      <div class="form-row">
        <label>ชื่อสินค้า <input type="text" name="name" value="<?php echo esc($p['name']); ?>" required></label>
      </div>
      <div class="form-row">
        <label>ราคา <input type="number" step="0.01" name="price" value="<?php echo $p['price']; ?>" required></label>
      </div>
      <div class="form-row">
        <label>รายละเอียด <textarea name="description"><?php echo esc($p['description']); ?></textarea></label>
      </div>
      <div class="form-row">
        <label>รูปภาพปัจจุบัน</label>
        <img src="/public/<?php echo esc($p['image'] ?: 'https://via.placeholder.com/160x120'); ?>" alt="Current product image">
      </div>
      <div class="form-row">
        <label>อัปโหลดรูปภาพใหม่ <input type="file" name="image" accept="image/*"></label>
      </div>
      <button class="btn" name="save" value="1" type="submit">Save</button>
    </form>
  </div>
</body>

</html>
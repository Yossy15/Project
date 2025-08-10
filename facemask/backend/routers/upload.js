const express = require("express");
const multer = require("multer");
const { v2: cloudinary } = require("cloudinary");
const { CloudinaryStorage } = require("multer-storage-cloudinary");

const router = express.Router();

// ตั้งค่า Cloudinary
cloudinary.config({
  cloud_name: 'drvneziac',//process.env.CLOUDINARY_CLOUD_NAME
  api_key: '258331568541728',//process.env.CLOUDINARY_API_KEY
  api_secret: 'DK_XBRg9JbbXX5i4nBOe-rzWi3E',//process.env.CLOUDINARY_API_SECRET
});

// ตั้งค่า storage สำหรับ Multer
const storage = new CloudinaryStorage({
  cloudinary: cloudinary,
  params: {
    folder: "uploads", // โฟลเดอร์ใน Cloudinary
    allowed_formats: ["jpg", "png", "jpeg", "gif", "webp", "pdf"],
    public_id: (req, file) => file.originalname.split(".")[0], // ชื่อไฟล์โดยไม่เอานามสกุล
  },
});

const upload = multer({ storage: storage });

router.post("/", upload.single("filename"), async (req, res) => {
  try {
    if (!req.file || !req.file.path) {
      return res.status(400).send({ error: "No file uploaded" });
    }

    console.log("File uploaded to Cloudinary");

    return res.send({
      message: "File uploaded to Cloudinary",
      name: req.file.originalname,
      type: req.file.mimetype,
      downloadURL: req.file.path, // Cloudinary URL
    });
  } catch (error) {
    console.error("Error uploading file:", error);
    return res.status(500).send({ error: "Error uploading file" });
  }
});

module.exports = router;

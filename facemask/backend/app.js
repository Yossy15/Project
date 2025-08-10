const express = require('express');
const cors = require('cors');
const body_parser = require('body-parser');
const authRoutes = require('./routers/authRouter');
const imgsRoutes = require('./routers/imgRouter');
const uploadRoutes = require('./routers/upload');
const errorController = require('./controllers/errorController');

const app = express();

// ✅ ตั้งค่า CORS ก่อน route ทั้งหมด
app.use(cors({
  origin: '*', // ระบุ origin ที่อนุญาต
  methods: ['GET', 'POST', 'PUT', 'DELETE'],
  credentials: true
}));

app.use(body_parser.json());

app.use('/auth', authRoutes);
app.use('/img', imgsRoutes);
app.use('/upload', uploadRoutes);

// ❌ ลบการตั้ง header ด้วย res.setHeader เพราะ cors middleware จัดการให้แล้ว
// ❌ ลบ app.use(cors()); ซ้ำซ้อน

module.exports = app;

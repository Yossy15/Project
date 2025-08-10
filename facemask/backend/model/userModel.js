const mongoose = require('mongoose');
const db = require("../config/db");
const { Schema } = mongoose;

const userSchema = new mongoose.Schema({
  avatar_img: { type: String, required: true },
  name: { type: String, required: true },
  email: { type: String, required: true, unique: true },
  password: { type: String, required: true },
  actype: { type: String, default: 'user' },
  createdAt: { type: Date, default: Date.now }
});

const UserModel = db.model('User', userSchema);
module.exports = UserModel;

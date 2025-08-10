const mongoose = require('mongoose');
const db = require("../config/db");
const { Schema } = mongoose;

const imageSchema = new mongoose.Schema({
  image_url: { type: String, required: true },
  facemash_id: { type: String, required: true },
  points: { type: Number, default: 0 },
  createdAt: { type: Date, default: Date.now }
});

const ImageModel = db.model('Image', imageSchema);

module.exports = ImageModel;
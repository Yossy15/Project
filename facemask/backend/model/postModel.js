const mongoose = require('mongoose');
const db = require("../config/db");
const { Schema } = mongoose;

const postSchema = new mongoose.Schema({
  title: { type: String, required: true },
  body: { type: String, required: true },
  user: { type: String, required: true },
  createdAt: { type: Date, default: Date.now }
});

const PostModel = db.model('Post', postSchema);

module.exports = PostModel;

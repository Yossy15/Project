require('dotenv').config();
const mongoose = require('mongoose');

const connection = mongoose.createConnection(process.env.MONGO_URI, {
});

connection
  .on('open', () => {
    console.log("MongoDB Connected");
  })
  .on('error', (error) => {
    console.error("MongoDB Connection error:", error);
  });

module.exports = connection; 

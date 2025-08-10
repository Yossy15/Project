const Image = require('../model/imgModel');

exports.fetchAll = () => Image.find();

exports.updatePoints = (id, points) => 
  Image.findByIdAndUpdate(id, { points }, { new: true });

exports.fetchTopTen = () =>
  Image.find().sort({ points: -1 }).limit(10);

exports.fetchTopTenUser = () =>
  Image.aggregate([
    { $group: {
        _id: "$facemash_id",
        totalPoints: { $sum: "$points" },
        images: { $push: "$$ROOT" }
      }
    },
    { $sort: { totalPoints: -1 } },
    { $limit: 10 }
  ]);

exports.onlyone = (id) => Image.findById(id);

exports.findimage = (id) => Image.findOne({ _id: id });

exports.addImage = (image_url, facemash_id) => 
  new Image({ image_url, facemash_id }).save();

exports.delete = (id) => Image.findByIdAndDelete(id);

exports.fetchAllByUserId = (userId) =>
  Image.find({ facemash_id: userId }); // assuming userId === facemash_id

exports.fetchAllByFacemashId = (facemashId) =>
  Image.find({ facemash_id: facemashId });

exports.changeImage = (image_url, image_id) =>
  Image.findByIdAndUpdate(image_id, { image_url }, { new: true });
const Post = require('../model/postModel');


exports.fetchAll = async () => {
  return await Post.find().sort({ createdAt: -1 });
};

exports.createPost = async (postData) => {
  const post = new Post(postData);
  return await post.save();
};

exports.deletePost = async (id) => {
  return await Post.findByIdAndDelete(id);
};

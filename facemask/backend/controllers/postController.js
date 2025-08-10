const { validationResult } = require('express-validator');
const postService = require('../services/postServices');

exports.fetchAll = async (req, res, next) => {
  try {
    const posts = await postService.fetchAll();
    res.status(200).json(posts);
  } catch (error) {
    return res.status(400).json({ error: error.message });
  }
};

exports.postPost = async (req, res, next) => {
  const errors = validationResult(req);
  if (!errors.isEmpty())
    return res.status(422).json({ errors: errors.array() });

  const { title, body, user } = req.body;

  try {
    await postService.createPost({ title, body, user });
    res.status(201).json({ message: 'Posted!' });
  } catch (error) {
    return res.status(400).json({ error: error.message });
  }
};

exports.deletePost = async (req, res, next) => {
  try {
    const result = await postService.deletePost(req.params.id);
    if (!result) {
      return res.status(404).json({ message: 'Post not found' });
    }
    res.status(200).json({ message: 'Deleted successfully' });
  } catch (error) {
    return res.status(400).json({ error: error.message });
  }
};
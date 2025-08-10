const express = require('express');
const { body } = require('express-validator');
const postController = require('../controllers/postController');

const router = express.Router();

router.get('/', postController.fetchAll);

router.post(
  '/',
  [
    body('title').notEmpty().withMessage('Title is required'),
    body('body').notEmpty().withMessage('Body is required'),
    body('user').notEmpty().withMessage('User is required')
  ],
  postController.postPost
);

router.delete('/:id', postController.deletePost);

module.exports = router;

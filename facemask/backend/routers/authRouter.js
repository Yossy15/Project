const express = require('express');
const { body } = require('express-validator');
const authController = require('../controllers/authController');

const router = express.Router();

router.post(
  '/signup',
  [
    body('email').isEmail().withMessage('Enter valid email'),
    body('password').isLength({ min: 6 }).withMessage('Password too short'),
    body('name').notEmpty()
  ],
  authController.signup
);

router.post('/login', authController.login);
router.get('/me', authController.getCurrentUser);
router.get('/check-token', authController.checkToken);
router.get('/account', authController.getAccount);
router.get('/account/:userId', authController.getAccountById);

router.post('/update-password', authController.updatePassword);
router.put('/change-name', authController.changeName);
router.put('/change-avatar', authController.changeAvatar);
router.post('/getUsedetail', authController.getUserDetail);

module.exports = router;

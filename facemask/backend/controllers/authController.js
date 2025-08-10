// const validationResult  = require('express-validator');
const authService = require('../services/authServices');
const jwt = require('jsonwebtoken');

exports.signup = async (req, res, next) => {
  // const errors = validationResult(req);


  try {
    await authService.createUser(req.body);
    res.status(201).json({ message: 'Successfully registered' });
  } catch (error) {
    return res.status(400).json({ error: error.message });
  }
};

exports.login = async (req, res, next) => {
  const { email, password } = req.body;
  try {
    const user = await authService.findByEmail(email);
    if (!user) throw new Error('User not found');

    const isEqual = await require('bcryptjs').compare(password, user.password);
    if (!isEqual) throw new Error('Wrong password');

    const token = jwt.sign(
      {
        email: user.email,
        userId: user._id,
        actype: user.actype,
      },
      'secretfortoken',
      { expiresIn: '1h' }
    );

    res.status(200).json({
      token,
      userId: user._id,
      actype: user.actype,
      message: 'Login successfully'
    });
  } catch (error) {
    return res.status(400).json({ error: error.message });
  }
};

exports.getCurrentUser = async (req, res, next) => {
  try {
    const user = await authService.findById(req.userId);
    if (!user) return res.status(404).json({ message: "User not found" });
    res.status(200).json(user);
  } catch (error) {
    return res.status(400).json({ error: error.message });
  }
};

exports.checkToken = (req, res) => {
  res.status(200).json({ message: "true" });
};

exports.getUserDetail = async (req, res, next) => {
  try {
    const user = await authService.findById(req.body.userId);
    if (!user) return res.status(404).json({ message: 'User not found' });

    const { _id, avatar_img, name, email } = user;
    res.status(200).json({ aid: _id, avatar_img, name, email });
  } catch (error) {
    return res.status(400).json({ error: error.message });
  }
};

exports.getAccount = async (req, res, next) => {
  try {
    const users = await authService.getAllAccounts();
    res.status(200).json(users);
  } catch (error) {
    return res.status(400).json({ error: error.message });
  }
};

exports.updatePassword = async (req, res, next) => {
  const { userId, oldPassword, newPassword } = req.body;

  try {
    await authService.updatePassword(userId, oldPassword, newPassword);
    res.status(200).json({ message: 'Password changed successfully.' });
  } catch (error) {
    return res.status(400).json({ error: error.message });
  }
};

exports.changeName = async (req, res, next) => {
  try {
    await authService.updateName(req.body.userId, req.body.newName);
    res.status(200).json({ message: 'Name changed successfully.' });
  } catch (error) {
    return res.status(400).json({ error: error.message });
  }
};

exports.changeAvatar = async (req, res, next) => {
  try {
    await authService.updateAvatar(req.body.userId, req.body.newAvatarImg);
    res.status(200).json({ message: 'Avatar changed successfully.' });
  } catch (error) {
    return res.status(400).json({ error: error.message });
  }
};

exports.getAccountById = async (req, res, next) => {
  try {
    const user = await authService.getAccountById(req.params.userId);
    if (!user) return res.status(404).json({ message: 'Account not found' });
    res.status(200).json(user);
  } catch (error) {
    return res.status(400).json({ error: error.message });
  }
};
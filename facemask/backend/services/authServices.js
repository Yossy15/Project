const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const User = require('../model/userModel');
exports.createUser = async ({ avatar_img, name, email, password }) => {
  const hashedPassword = await bcrypt.hash(password, 12);
  const user = new User({ avatar_img, name, email, password: hashedPassword });
  return await user.save();
};

exports.findByEmail = async (email) => {
  return await User.findOne({ email });
};

exports.findById = async (userId) => {
  return await User.findById(userId);
};

exports.getAllAccounts = async () => {
  return await User.find();
};

exports.updatePassword = async (userId, oldPassword, newPassword) => {
  const user = await User.findById(userId);
  if (!user) throw new Error('User not found');

  const isEqual = await bcrypt.compare(oldPassword, user.password);
  if (!isEqual) throw new Error('Old password incorrect');

  const hashed = await bcrypt.hash(newPassword, 12);
  user.password = hashed;
  await user.save();
};

exports.updateName = async (userId, newName) => {
  return await User.findByIdAndUpdate(userId, { name: newName }, { new: true });
};

exports.updateAvatar = async (userId, newAvatarImg) => {
  return await User.findByIdAndUpdate(userId, { avatar_img: newAvatarImg }, { new: true });
};

exports.getAccountById = async (userId) => {
  return await User.findById(userId).select('-password');
};
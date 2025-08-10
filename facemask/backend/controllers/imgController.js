const imageService = require('../services/imgServices');

exports.fetchAll = async (req, res, next) => {
  try {
    const images = await imageService.fetchAll();
    res.status(200).json(images);
  } catch (err) {
    err.statusCode ||= 500;
    next(err);
  }
};

exports.updatePoints = async (req, res, next) => {
  try {
    const result = await imageService.updatePoints(req.params.id, req.body.points);
    if (result) {
      res.status(200).json({ message: 'Points updated successfully' });
    } else {
      res.status(404).json({ message: 'Image not found' });
    }
  } catch (err) {
    next(err);
  }
};

exports.fetchTopTen = async (req, res, next) => {
  try {
    const topTen = await imageService.fetchTopTen();
    res.status(200).json(topTen);
  } catch (err) {
    next(err);
  }
};

exports.fetchTopTenUser = async (req, res, next) => {
  try {
    const users = await imageService.fetchTopTenUser();
    res.status(200).json(users);
  } catch (err) {
    next(err);
  }
};

exports.onlyone = async (req, res, next) => {
  try {
    const image = await imageService.onlyone(req.params.id);
    res.status(200).json(image);
  } catch (err) {
    next(err);
  }
};

exports.findimage = async (req, res, next) => {
  try {
    const image = await imageService.findimage(req.params.id);
    res.status(200).json(image);
  } catch (err) {
    next(err);
  }
};

exports.upload = async (req, res, next) => {
  try {
    const { image_url, facemash_id } = req.body;
    await imageService.addImage(image_url, facemash_id);
    res.status(200).json({ message: 'Image successfully added' });
  } catch (err) {
    next(err);
  }
};

exports.delete = async (req, res, next) => {
  try {
    await imageService.delete(req.params.id);
    res.status(200).json({ message: 'Image deleted' });
  } catch (err) {
    next(err);
  }
};

exports.fetchAllUserImg = async (req, res, next) => {
  try {
    const images = await imageService.fetchAllByUserId(req.params.userId);
    res.status(200).json(images);
  } catch (err) {
    next(err);
  }
};

exports.fetchAllUserDetail = async (req, res, next) => {
  try {
    const images = await imageService.fetchAllByFacemashId(req.params.facemashId);
    res.status(200).json(images);
  } catch (err) {
    next(err);
  }
};

exports.changeImage = async (req, res, next) => {
  try {
    const { image_id, image_url } = req.body;
    await imageService.changeImage(image_url, image_id);
    res.status(200).json({ message: 'Image changed successfully.' });
  } catch (err) {
    next(err);
  }
};
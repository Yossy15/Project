const express = require('express');
const router = express.Router();
const imgsController = require('../controllers/imgController');

router.get('/', imgsController.fetchAll);
router.put('/update-score/:id', imgsController.updatePoints);
router.get('/top-ten', imgsController.fetchTopTen);
router.get('/top-ten-user', imgsController.fetchTopTenUser);
router.get('/find/:id', imgsController.onlyone);
router.get('/findimage/:id', imgsController.findimage);
router.post('/add-image', imgsController.upload);
router.delete('/delete/:id', imgsController.delete);
router.get('/fetchAllUserImg/:userId', imgsController.fetchAllUserImg);
router.get('/fetchAllUserDetail/:facemashId', imgsController.fetchAllUserDetail);
router.put('/changeImg',  imgsController.changeImage);

module.exports = router;

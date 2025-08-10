const router = require('express').Router();
const UserController = require("../controller/user.controller");

router.get('/users', UserController.getAll);
router.get('/user/:userId', UserController.getOne);
router.post('/registration',UserController.register);
router.post('/login',UserController.login);
router.post('/resetU',UserController.reset);


module.exports = router;
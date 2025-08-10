const express = require('express');
const router = express.Router();
const inserted = require('../controller/insert.controller');

router.post('/c-lotto', inserted.createLottoData);
router.post('/resetLotto', inserted.resetLotto);

module.exports = router;

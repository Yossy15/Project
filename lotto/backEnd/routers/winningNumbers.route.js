const router = require('express').Router();
const winningNumbers = require('../controller/winningNumbers.controller');

router.get('/winning', winningNumbers.getAllWinning);
router.get('/randomWin', winningNumbers.randomWinning);
router.get('/resetWin', winningNumbers.resetWinningNumbers);

module.exports = router;

const express = require('express');
const router = express.Router();
const prizeCheckController = require('../controller/PrizeCheck.controller');

// เส้นทางสำหรับตรวจสอบรางวัล
router.post('/check-prize', prizeCheckController.checkPrizes);
router.post('/PlussPrizes', prizeCheckController.PlussPrizes);

module.exports = router;

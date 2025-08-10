const router = require('express').Router();
const WalletController = require('../controller/wallet.controller');

router.post('/createwallet', WalletController.createWallet);

module.exports = router;

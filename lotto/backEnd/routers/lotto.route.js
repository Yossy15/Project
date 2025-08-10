const router = require('express').Router();
const LottoController = require('../controller/lotto.controller');

router.get('/lottos', LottoController.getAllLottos);
router.get('/lotto/:lottoNumber', LottoController.getLottoByNumber);
router.get('/availablelottos', LottoController.getAvailableLottos);// เส้นแสดง lotto ที่สามารถซื้อได้
router.get('/sold-lotto', LottoController.getAllLottosWithZeroAmount);//lotto ที่ขายแล้ว

router.post('/buylotto', LottoController.buyLotto); 
router.post('/randombuy', LottoController.randomBuyLotto);
// แสดงลอตโต้ของผู้ใช้
router.get('/user-lottos/:userId', LottoController.getUserLottos);


 

module.exports = router;
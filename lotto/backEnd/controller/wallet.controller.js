
const WalletService = require('../services/wallet.services');

exports.createWallet = async (req, res, next) => {
    try {
        const {userId, Balance} = req.body;
         // ตรวจสอบว่า wallet สำหรับ userId นี้มีอยู่แล้วหรือไม่
         const existingWallet = await WalletService.getWalletByUserId(userId);
         if (existingWallet) {
             return res.status(400).json({ status: false, message: 'Wallet already exists for this user' });
         }
        
        
        // สร้าง wallet ใหม่
        const wallet = await WalletService.createWallet(userId, Balance);


        res.json({status:true, success:wallet});
    } catch (error) {
        next(error);
    }
};


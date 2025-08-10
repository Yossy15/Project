const WalletModel = require("../model/wallet.model");

class WalletService{
    static async createWallet (userId, balance = 1000){
        const createWallet = new WalletModel({ userId, Balance: balance });
        return await createWallet.save();
       
    }

   // ฟังก์ชันในการดึง wallet โดย userId
   static async getWalletByUserId(userId) {
    try {
        // ตรวจสอบประเภทข้อมูลของ userId (MongoDB ObjectId)
        const wallet = await WalletModel.findOne({ userId });
        return wallet;
    } catch (error) {
        console.error(`Error retrieving wallet for userId ${userId}: ${error.message}`);
        throw error;
    }
}

    // ฟังก์ชันในการอัปเดตยอดเงินใน wallet
    static async updateWalletBalance(userId, amount) {
        try {
            // ตรวจสอบและใช้ชื่อฟิลด์ที่ถูกต้อง
            const updatedWallet = await WalletModel.findOneAndUpdate(
                { userId }, // ชื่อฟิลด์ต้องตรงกับโมเดล
                { $inc: { Balance: amount } }, // การเพิ่มหรือลดยอดเงิน
                { new: true, runValidators: true } // ส่งกลับเอกสารที่อัปเดตและใช้การตรวจสอบข้อมูล
            );
            return updatedWallet;
        } catch (error) {
            console.error(`Error updating wallet balance for userId ${userId}: ${error.message}`);
            throw error;
        }
    }
}


module.exports = WalletService;
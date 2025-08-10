const prizeCheckService = require('../services/PrizeCheck.service');
const WalletService = require('../services/wallet.services');
const TicketService = require('../services/ticket.services');

exports.checkPrizes = async (req, res) => {
    try {
        const { userId, drawDate } = req.body;

        // ตรวจสอบการป้อนข้อมูล
        if (!userId || !drawDate) {
            return res.status(400).json({ error: 'ต้องระบุ userId และ drawDate' });
        }

        // เรียกใช้งาน service method
        const result = await prizeCheckService.checkUserPrizes(userId, drawDate);

        // ส่งผลลัพธ์กลับเป็น response
        return res.status(200).json(result);
    } catch (error) {
        // จัดการกับข้อผิดพลาด
        return res.status(400).json({ error: error.message });
    }
};

exports.PlussPrizes = async (req, res, next) => {
    try {
        // Extract userId and prize amount from the request body
        const { userId, prize, num } = req.body;

        // Validate input
        // if (!userId || !num || typeof prize !== 'number') {
        //     return res.status(400).json({ status: false, message: 'Invalid input' });
        // }

        // Find and delete the ticket
        const ticketResult = await TicketService.delTN(num);

        if (!ticketResult) {
            return res.status(404).json({ status: false, message: 'Ticket not found' });
        }
    
        // Call the service function to update the wallet balance
        const walletResult = await prizeCheckService.PlussPrizes(userId, prize);

        // Respond based on the result
        if (walletResult.status) {
            res.json({ 
                status: true, 
                message: 'Prize added to wallet and ticket deleted',
                ticketInfo: ticketResult,
                walletUpdate: walletResult.message
            });
        } else {
            res.status(400).json({ status: false, message: walletResult.message });
        }
    } catch (error) {
        // Handle unexpected errors
        console.error("Error in PlussPrizes:", error);
        next(error);
    }
};

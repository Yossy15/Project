const Ticket = require('../model/ticket.model');
const WinningNumbers = require('../model/winningNumbers.model');
const Prizes = require('../model/Prizes.model');
const WalletService = require('../services/wallet.services');

exports.checkUserPrizes = async (userId, drawDate) => {
    try {
        console.log('Checking prizes for user:', userId, 'on date:', drawDate);

        // แปลง drawDate ให้เป็นรูปแบบ YYYY-MM-DD
        const [year, month, day] = drawDate.split('-');
        const startDate = new Date(year, month - 1, parseInt(day));
        const endDate = new Date(year, month - 1, parseInt(day) + 2);

        console.log('Date range:', startDate, 'to', endDate);

        // ดึงข้อมูล Ticket ทั้งหมดของ User
        const tickets = await Ticket.find({ UserID: userId }).populate({ path: 'LottoID' });
        console.log('Found tickets:', tickets.length);

        if (!tickets.length) {
            return { message: 'ไม่พบ Ticket สำหรับผู้ใช้' };
        }

        // ดึงข้อมูล Winning Numbers ตาม DrawDate
        const winningNumbers = await WinningNumbers.findOne({
            DrawDate: {
                $gte: startDate,
                $lt: endDate
            }
        });
        console.log('Winning Numbers:', winningNumbers);

        if (!winningNumbers) {
            return { message: 'ไม่พบ Winning numbers สำหรับ DrawDate นี้' };
        }

        // เตรียมเก็บผลลัพธ์
        const results = [];

        for (const ticket of tickets) {
            if (!ticket.LottoID || !ticket.LottoID.LottoNumber) {
                console.log('Invalid ticket:', ticket);
                continue;
            }

            const lottoNumber = String(ticket.LottoID.LottoNumber);
            console.log('Checking lotto number:', lottoNumber);

            // ตรวจสอบว่ามีการบันทึกข้อมูลรางวัลแล้วหรือไม่
            const existingPrize = await Prizes.findOne({
                DrawID: winningNumbers._id,
                TicketID: ticket._id
            });

            if (existingPrize) {
                results.push({
                    ticketId: ticket._id,
                    lottoNumber: lottoNumber,
                    drawDate: drawDate,
                    prize: existingPrize.PrizeAmount,
                    claimed: existingPrize.Claimed,  // เพิ่มสถานะการเรียกร้องรางวัล
                    message: existingPrize.Claimed ? 'คุณได้รับรางวัลแล้วใน DrawDate นี้' : 'คุณมีรางวัลที่ยังไม่ได้เรียกร้อง'
                });
                continue;
            }

            let prizeAmount = 0;
            let prizeMessage = '';

              // ตรวจสอบรางวัล
              if (lottoNumber === String(winningNumbers.FirstPrize)) {
                prizeAmount = 10000;
                prizeMessage = 'คุณถูกรางวัลที่ 1';
            } else if (lottoNumber === String(winningNumbers.SecondPrize)) {
                prizeAmount = 8000; // สมมติว่ารางวัลที่ 2 มีมูลค่า 200,000 บาท
                prizeMessage = 'คุณถูกรางวัลที่ 2';
            } else if (lottoNumber === String(winningNumbers.ThirdPrize)) {
                prizeAmount = 6000; // สมมติว่ารางวัลที่ 3 มีมูลค่า 80,000 บาท
                prizeMessage = 'คุณถูกรางวัลที่ 3';
            } else if (lottoNumber === String(winningNumbers.FourthPrize)) {
                prizeAmount = 4000; // สมมติว่ารางวัลที่ 4 มีมูลค่า 40,000 บาท
                prizeMessage = 'คุณถูกรางวัลที่ 4';
            } else if (lottoNumber === String(winningNumbers.FifthPrize)) {
                prizeAmount = 2000; // สมมติว่ารางวัลที่ 5 มีมูลค่า 20,000 บาท
                prizeMessage = 'คุณถูกรางวัลที่ 5';
            }

            if (prizeAmount > 0) {
                // บันทึกข้อมูลรางวัล
                const prize = new Prizes({
                    DrawID: winningNumbers._id,
                    UserID: ticket.UserID,
                    TicketID: ticket._id,
                    PrizeAmount: prizeAmount,
                    Claimed: false  // เพิ่มสถานะ Claimed เริ่มต้นเป็น false
                });

                await prize.save();
                console.log('Prize saved:', prize);

                results.push({
                    ticketId: ticket._id,
                    lottoNumber: lottoNumber,
                    drawDate: drawDate,
                    prize: prizeAmount,
                    claimed: false,  // เพิ่มสถานะการเรียกร้องรางวัล
                    message: `${prizeMessage} จำนวน ${prizeAmount} บาท! (ยังไม่ได้เรียกร้อง)`
                });
            } else {
                results.push({
                    ticketId: ticket._id,
                    lottoNumber: lottoNumber,
                    drawDate: drawDate,
                    prize: 0,
                    claimed: false,
                    message: 'ขออภัย คุณไม่ได้รับรางวัล'
                });
            }
        }

        if (!results.length) {
            return { message: 'ไม่พบรางวัลสำหรับ Ticket ของผู้ใช้ใน DrawDate นี้.' };
        }

        console.log('Results:', results);
        return results;

    } catch (error) {
        console.error('Error in checkUserPrizes:', error);
        throw new Error(`เกิดข้อผิดพลาด: ${error.message}`);
    }
};


exports.PlussPrizes = async (userId, prize, num) => {
    try {
        // Retrieve wallet by userId
        const wallet = await WalletService.getWalletByUserId(userId);
        
        // Check if wallet exists
        if (!wallet) {
            throw new Error('Wallet not found');
        }

        // Ensure the prize amount is valid
        if (prize <= 0) {
            throw new Error('Prize amount must be greater than zero');
        }

        // Calculate new balance
        const amount =  +prize;

        // Update wallet balance
        await WalletService.updateWalletBalance(userId, amount);

        return { status: true, message: 'Balance updated successfully' };
    } catch (error) {
        console.error("Error in PlussPrizes:", error);
        return { status: false, message: error.message };
    }
};

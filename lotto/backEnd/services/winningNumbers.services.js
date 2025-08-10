const moment = require('moment-timezone');
const WinningNumbers = require('../model/winningNumbers.model');
const Lotto = require('../model/lotto.model');

exports.getAllWinning = async () => {
    return await WinningNumbers.find();
};

exports.randomWinning = async () => {
    try {
        // Helper function to get a random Lotto number
        const getRandomLotto = async () => {
            const number = Math.floor(Math.random() * 100) + 1;
            const winning = await Lotto.findOne({ lotto: number });
            return winning ? winning.LottoNumber : null;
        };

        // Generate random numbers for each prize
        const prizes = {
            first: await getRandomLotto(),
            second: await getRandomLotto(),
            third: await getRandomLotto(),
            fourth: await getRandomLotto(),
            fifth: await getRandomLotto()
        };

        // Check if any prize is missing
        if (Object.values(prizes).some(prize => prize === null)) {
            throw new Error('ไม่สามารถสุ่มหมายเลขล็อตโต้ครบทุกรางวัลได้');
        }

        // Set the draw date
        const drawDate = moment().tz('Asia/Bangkok').startOf('day').toDate();

        // Create and save the winning numbers record
        const winningRecord = new WinningNumbers({
            DrawDate: drawDate,
            LottoWin: prizes.first,
            FirstPrize: prizes.first,
            SecondPrize: prizes.second,
            ThirdPrize: prizes.third,
            FourthPrize: prizes.fourth,
            FifthPrize: prizes.fifth
        });

        await winningRecord.save();

        return {
            DrawDate: moment(winningRecord.DrawDate).format('YYYY-MM-DD'),
            LottoWin: winningRecord.LottoWin,
            FirstPrize: winningRecord.FirstPrize,
            SecondPrize: winningRecord.SecondPrize,
            ThirdPrize: winningRecord.ThirdPrize,
            FourthPrize: winningRecord.FourthPrize,
            FifthPrize: winningRecord.FifthPrize
        };
    } catch (error) {
        console.error('Error in randomWinning service:', error);
        throw new Error(`เกิดข้อผิดพลาด: ${error.message}`);
    }
};

exports.resetWin = async () => {
    await WinningNumbers.deleteMany({});
};

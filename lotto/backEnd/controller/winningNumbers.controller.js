const lottoService = require('../services/winningNumbers.services');
const winningNumbersService = require('../services/winningNumbers.services');

exports.getAllWinning = async (req, res, next) => {
    try {
        const winningNumbers = await lottoService.getAllWinning();
        res.json({ status: true, data: winningNumbers });
    } catch (error) {
        next(error);
    }
};

exports.randomWinning = async (req, res, next) => {
    try {
        const result = await winningNumbersService.randomWinning();
        res.status(201).json({
            message: 'Winning record added successfully.',
            data: result
        });
    } catch (error) {
        console.error('Error in controller:', error);
        res.status(500).json({
            message: 'Error processing random winning number.',
            error: error.message
        });
    }
};

exports.resetWinningNumbers = async (req, res, next) => {
    try {
        await lottoService.resetWin();
        res.status(200).json({
            message: 'Winning numbers have been reset successfully.'
        });
    } catch (error) {
        console.error('Error in controller:', error);
        res.status(500).json({
            message: 'Error resetting winning numbers.',
            error: error.message
        });
    }
};
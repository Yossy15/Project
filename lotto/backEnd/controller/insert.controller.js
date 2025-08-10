const inserted = require('../services/insert.services');

exports.resetLotto = async (req, res, next) => {
    try {
        await inserted.resetLotto();
        res.status(200).json({
            message: 'reset successfully.'
        });
    } catch (error) {
        console.error('Error in controller:', error);
        res.status(500).json({
            message: 'Error resetting.',
            error: error.message
        });
    }
};

exports.createLottoData = async (req, res, next) => {
    try {
        await inserted.insertLottoData();
        res.status(200).json({ message: 'Successfully inserted 100 lotto records.' });
    } catch (error) {
        res.status(500).json({ message: 'Error inserting lotto data.', error });
    }
};

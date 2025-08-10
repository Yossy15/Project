const TicketService = require('../services/ticket.services');

exports.getAllTicket = async (req, res, next) => {
    try {
        const ticket = await TicketService.getAllTicket();
        res.json({ status: true, data: ticket });
    } catch (error) {
        next(error);
    }
};

exports.delT = async (req, res, next) => {
    try {
        const {userId} = req.params;
        const delT = await TicketService.delT(userId);
        if (!delT) {
            return res.status(404).json({ status: false, message: 'not found' });
        }
        res.json({ status: true, data: delT });
    } catch (error) {
        next(error);
    }
};

exports.delAllT = async (req, res, next) => {
    try {
        // Call deleteAllTickets instead of delT
        const delT = await TicketService.deleteAllTickets();
        if (!delT.deletedCount) { // Check if any tickets were deleted
            return res.status(404).json({ status: false, message: 'No tickets found to delete' });
        }
        res.json({ status: true, data: delT });
    } catch (error) {
        next(error);
    }
};


exports.TgetOne = async (req, res, next) => {
    try {
        const { userId } = req.params;
        // console.log('In controller, userId:', userId);
        // console.log('req.params:', req.params);

        const user = await TicketService.TgetOne(userId);

        if (!user) {
            return res.status(404).json({ status: false, message: 'not found' });
        }

        res.json({ status: true, data: user });
    } catch (error) {
        next(error);
    }
};

exports.delTN = async (req, res) => {
    try {
        const { num } = req.params; // Assuming num is passed as a URL parameter

        const result = await TicketService.delTN(num);

        if (result && result.success) {
            return res.status(200).json({ success: true, message: 'Ticket deleted successfully', data: result.ticketInfo });
        } else if (result && !result.success) {
            return res.status(403).json({ success: false, message: result.message });
        } else {
            return res.status(500).json({ success: false, message: 'Internal server error' });
        }
    } catch (error) {
        console.error('Error in deleteTicket controller:', error);
        return res.status(500).json({ success: false, message: 'Internal server error' });
    }
};

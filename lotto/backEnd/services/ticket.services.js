const Ticket = require('../model/ticket.model');
const LottoSer = require('../services/lotto.services')
const LottoMo = require('../model/lotto.model');
const userMo = require('../model/user.model');
const mongoose = require('mongoose');

exports.getAllTicket = async () => {
    return await Ticket.find();
};

exports.createTicket = async (userId, lottoId) => {
    const ticket = new Ticket({
        UserID: userId,
        LottoID: lottoId
    });
    return await ticket.save();
};

exports.delT = async (userId) => {
    try {
        const result = await Ticket.deleteMany({ UserID: userId });
        return result; 
    } catch (error) {
        const result = await Ticket.deleteMany({ UserID: userId });
        return result;
    }
};

exports.deleteAllTickets = async () => {
    try {
        const result = await Ticket.deleteMany({});
        return result;
    } catch (error) {
        console.error('Error deleting all tickets:', error);
        throw new Error('Failed to delete all tickets');
    }
};

exports.TgetOne = async (userId) => {
    try {
        // ดึงข้อมูลของผู้ใช้ที่ตรงกับ userId
        const user = await Ticket.find({ UserID: userId });
        
        if (user.length === 0) {
            console.log('User not found for userId:', userId);
            return {
                id: null,
                name: null,
                tickets: []
            };
        }
        console.log('User found:', user);

        // ดึงข้อมูลตั๋วทั้งหมดที่เกี่ยวข้องกับ userId
        let tickets = [];
        try {
            // ดึงข้อมูลของตั๋วทั้งหมดที่ตรงกับ user.LottoID
            tickets = await LottoMo.find({ _id: { $in: user.map(u => u.LottoID) } });
            console.log('Tickets fetched:', tickets);
        } catch (err) {
            console.error(`Failed to fetch tickets for user ${userId}:`, err);
        }

        // ดึงชื่อของผู้ใช้
        let nameU = { name: 'Unknown' };
        try {
            nameU = await userMo.findOne({ _id: userId });
            console.log('User name:', nameU.name);
        } catch (err) {
            console.error(`Failed to fetch user name for user ${userId}:`, err);
        }

        return {
            name: nameU.name,
            id: userId,
            tickets: tickets
        };

    } catch (error) {
        console.error('Error fetching user and tickets:', error);
        throw error;
    }
};


exports.delTN = async (lottoNumber) => {
    try {
        // Find the lotto with the given number
        const lotto = await LottoMo.findOne({ LottoNumber: lottoNumber });
        
        if (!lotto) {
            console.log('No lotto found with number:', lottoNumber);
            return { success: false, message: 'Lotto not found' };
        }
        
        // Find the ticket associated with this lotto
        const ticket = await Ticket.findOne({ LottoID: lotto._id });
        
        if (!ticket) {
            console.log('No ticket found for lotto:', lottoNumber);
            return { success: false, message: 'Ticket not found' };
        }
        
        // Get user information
        const user = await userMo.findOne({ _id: ticket.UserID });
        
        if (!user) {
            console.log('No user found for ticket:', ticket._id);
            return { success: false, message: 'User not found' };
        }
        
        // Store ticket information before deletion
        const ticketInfo = {
            ticketId: ticket._id,
            lottoNumber: lotto.LottoNumber,
            userName: user.name,
            userId: user._id
        };
        
        // Delete the ticket
        await Ticket.deleteOne({ _id: ticket._id });
        console.log('Ticket deleted:', ticket._id);
        
        // Return the ticket information
        return {
            success: true,
            deleted: true,
            ticketInfo
        };
    } catch (error) {
        console.log('Error finding and deleting ticket by number:', error);
        return { success: false, message: 'Internal server error' };
    }
};



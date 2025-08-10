const mongoose = require('mongoose');
const Lotto = require('../model/lotto.model');

exports.resetLotto = async () => {
    try {
        await Lotto.deleteMany({});
    } catch (error) {
        console.error('Error resetting lotto data:', error);
        throw error;
    }
};

// ฟังก์ชันสำหรับสร้างเลขลอตเตอรี่ 6 หลักแบบสุ่ม
exports.generateRandomLottoNumber = async () => {
    let number = '';
    for (let i = 0; i < 6; i++) {
        number += Math.floor(Math.random() * 10); // สุ่มเลข 0-9
    }
    return number;
};

// ฟังก์ชันสำหรับแทรกข้อมูลล็อตโต้ลงใน MongoDB
exports.insertLottoData = async () => {
    try {
        await Lotto.deleteMany({});

        // สร้างข้อมูลล็อตโต้สุ่ม 100 ข้อมูล
        const lottos = [];
        for (let i = 0; i < 100; i++) {
            lottos.push({
                LottoNumber: await exports.generateRandomLottoNumber(), // Use exports to call the function
                DrawDate: new Date(), // วันปัจจุบัน
                Price: 80,
                Amount: 1,
                lotto: i + 1
            });
        }

        // แทรกข้อมูลล็อตโต้ลงใน MongoDB
        await Lotto.insertMany(lottos);
        
    } catch (error) {
        console.error('Error inserting lotto data:', error);
        throw error;
    }
    // Remove the finally block with mongoose.disconnect()
};



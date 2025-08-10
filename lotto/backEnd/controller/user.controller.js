const UserService = require("../services/user.services");
const WalletService = require('../services/wallet.services');


exports.reset = async (req, res, next) => {
    try {
        // Fetch all users
        const users = await UserService.getAllUsers();

        // Check if users exist
        if (!users.length) {
            return res.status(404).json({
                message: 'No users found to reset.'
            });
        }

        // Iterate over users and perform actions based on user type
        for (const user of users) {
            if (user.type === 'user') {
                // Delete the user if they are not an admin
                await UserService.deleteUser(user._id);
            }
        }

        res.status(200).json({
            message: 'Reset successfully. Non-admin users have been deleted.'
        });
    } catch (error) {
        console.error('Error in controller:', error);
        res.status(500).json({
            message: 'Error resetting.',
            error: error.message
        });
    }
};

exports.getAll = async (req, res, next) => {
    try {
        const users = await UserService.getAll();
        res.json({ status: true, data: users });
    } catch (error) {
        next(error);
    }
};

exports.getOne = async (req, res, next) => {
    try {
        const { userId } = req.params;
        // console.log('In controller, userId:', userId);
        // console.log('req.params:', req.params);

        const user = await UserService.getOne(userId);

        if (!user) {
            return res.status(404).json({ status: false, message: 'not found' });
        }

        res.json({ status: true, data: user });
    } catch (error) {
        next(error);
    }
};


exports.register = async(req,res,next)=>{
    try {
        const {name, email, phone, password, confpass} = req.body;

        if (!name || !email || !phone || !password || !confpass) {
            return res.status(400).json({ status: false, message: 'All fields are required' });
        }

        // ตรวจสอบว่ารหัสผ่านและรหัสผ่านยืนยันตรงกัน
        if (password !== confpass) {
        console.error("Password and confirmation password do not match");
        return res.status(400).json({ status: false, message: 'Password and confirmation password do not match' });
        }
        

        const successRes = await UserService.registerUser(name, email, phone, password, confpass);

        res.json({status:true,success:"User Registered Successfully"});
    } catch (error) {
        
    }
}

exports.login = async (req, res, next) => {
    try {
        const { email, password } = req.body;
        
        // ตรวจสอบผู้ใช้
        const user = await UserService.checkuser(email);
        if (!user) {
            console.log("User does not exist");
            return res.status(404).json({ status: false, message: 'User does not exist' });
        }
        
        // ตรวจสอบรหัสผ่าน
        const isMatch = await user.comparePassword(password);
        if (isMatch === false) {
            console.log("Invalid password");
            return res.status(401).json({ status: false, message: 'Invalid password' });
        }

        // ตรวจสอบประเภทผู้ใช้
        const userType = user.type; 
        if (userType !== 'Admin' && userType !== 'user') {
            console.log("Invalid user type");
            return res.status(403).json({ status: false, message: 'Invalid user type' });
        }
        
        // สร้าง token
        let tokenData = { _id: user._id, email: user.email, type: user.type };
        const token = await UserService.generateToken(tokenData, "secretKey", '1h');

         // ดึงข้อมูลกระเป๋าเงินของผู้ใช้
         const wallet = await WalletService.getWalletByUserId(user._id);
        
        res.status(200).json({ status: true, token: token, wallet: wallet, userType: userType });
    } catch (error) {
        console.error('Login error:', error);
        res.status(500).json({ status: false, message: 'An error occurred during login' });
    }
};

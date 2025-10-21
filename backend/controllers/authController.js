const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const { pool } = require('../config/db');

// JWT oluşturma fonksiyonu (Tekrar kullanılacak)
const generateToken = (id) => {
   return jwt.sign ({id}, process.env.JWT_SECRET, {
         expiresIn: '30d', // Token 30 gün geçerli olacak
   });
};

// @desc    Yeni kullanıcı kaydı (Register)
// @route   POST /api/auth/register
// @access  Public

exports.registerUser= async (req, res) => {
    const { name, email, password } = req.body;

    // 1. Gerekli alanların doldurulduğunu kontrol et
    if(!email || !password) {
        return res.status(400).json({ message: 'Email ve şifre zorunludur.' });
    }

    try {
        // 2. Kullanıcının zaten kayıtlı olup olmadığını kontrol et
        const userCheck = await pool.query('SELECT * FROM users WHERE email = $1', [email]);
        if(userCheck.rows.length > 0) {
            return res.status(400).json({ message: 'Bu email zaten kayıtlı.' });
        }
        // 3. Şifreyi hash'le
        const salt = await bcrypt.genSalt(10);
        const hashedPassword = await bcrypt.hash(password, salt);

        // 4. Yeni kullanıcıyı veritabanına ekle
        const newUser = await pool.query(
            'INSERT INTO users (name, email, password) VALUES ($1, $2, $3) RETURNING id, name, email, created_at', [name, email, hashedPassword]
        );

        const user = newUser.rows[0];

        // 5. Başarılı yanıt gönder ve JWT token oluştur
        res.status(201).json({
            id: user.id,
            name: user.name,
            email: user.email,
            token: generateToken(user.id) // JWT Token oluştur
        });
    } catch(error) {
        console.error('Kayıt hatası:', error.message);
        res.status(500).json({ message: 'Sunucu hatası. Kayıt işlemi başarısız. Lütfen daha sonra tekrar deneyin.' });
    }
};

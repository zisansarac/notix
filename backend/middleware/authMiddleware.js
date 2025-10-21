const jwt = require('jsonwebtoken');
const { pool } = require('../config/db');

// Middleware fonksiyonu: İsteklerdeki JWT token'ını doğrular

const protect = async (req, res, next) => {
    let token;

    // 1. Authorization header'ını kontrol et
    if(
        req.headers.authorization &&
        req.headers.authorization.startsWith('Bearer')
    ) {
        try {
             
            // 1. Token'ı "Bearer" ifadesinden ayır
            token = req.headers.authorization.split(' ')[1];
            
            // 2. Token'ı doğrula
            const decoded = jwt.verify(token, process.env.JWT_SECRET);

            // 3. Token'daki kullanıcı ID'sine göre kullanıcıyı veritabanından çek (şifre hariç)
            const userResult = await pool.query(
                'SELECT id, name, email FROM users WHERE id = $1',
                [decoded.id]
            );

            // Kullanıcı bulunamazsa hata döndür
            if(userResult.rows.length === 0) {
                return res.status(401).json({ message: 'Yetkisiz: Token geçerli, ancak kullanıcı bulunamadı.' });
            }

            // Kullanıcı nesnesini request objesine ekle (req.user)
            // Böylece sonraki rotada hangi kullanıcının işlem yaptığını bileceğiz.
            req.user = userResult.rows[0];

            // 4. Sonraki Controller'a geç
            next();

        } catch (error) {
            console.error(error);
            return res.status(401).json({ message: 'Yetkisiz: Token doğrulanamadı veya süresi dolmuş.' });
        }
    }
    if(!token) {
        return res.status(401).json({ message: 'Yetkisiz: Token bulunamadı.' });
    }
    
};

module.exports = { protect };
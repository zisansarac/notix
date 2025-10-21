const { Pool } = require('pg');
const dotenv = require('dotenv');

dotenv.config();

// PostgreSQL bağlantı havuzunu (Pool) oluşturdum.
// dotenv'den okunan DATABASE_URL'i kullandım.
const pool = new Pool({
    connectionString: process.env.DATABASE_URL,
});

// Bağlantıyı test etme fonksiyonu

const connectDB = async () => {
    try {
        await pool.connect();
        console.log('PostgreSQL veritabanına başarıyla bağlanıldı.');
    } catch (err) {
        console.error('PostgreSQL veritabanına bağlanırken hata oluştu:', err.message);
        process.exit(1); // Bağlantı hatası durumunda uygulamayı sonlandır
    }
};

module.exports = {
    connectDB,
    pool,
};
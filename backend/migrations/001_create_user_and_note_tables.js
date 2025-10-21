const { pool } = require('../config/db');

// Tablolarımı oluşturacak olan SQL komutlarını tanımladım

const createTablesSQL = `
    CREATE TABLE IF NOT EXISTS users (
     id SERIAL PRIMARY KEY,
     name VARCHAR(100),
     email VARCHAR(100) UNIQUE NOT NULL,
     password VARCHAR(255) NOT NULL,
     created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
    );

    CREATE TABLE IF NOT EXISTS notes (
        id SERIAL PRIMARY KEY,
        user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
        title VARCHAR(255) NOT NULL,
        content TEXT NOT NULL,
        is_completed BOOLEAN DEFAULT FALSE,
        created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
    );
`;

// Migration fonksiyonunu tanımladım
const runMigrations = async () => {
    console.log('Veritabanı tabloları oluşturuluyor...');
    try {
        await pool.query(createTablesSQL);
        console.log('Veritabanı tabloları (users and notes) başarıyla oluşturuldu.');
    } catch (err) {
        console.error('Tablolar oluşturulurken hata oluştu:', err.message);
    } finally {
        pool.end(); // Bağlantı havuzunu sonlandır
    }
};

runMigrations();
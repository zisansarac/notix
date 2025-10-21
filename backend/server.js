const express = require('express');
const dotenv = require('dotenv');
const cors = require('cors');
// db.js dosyamızı içe aktar
const { connectDB } = require('./config/db');

// 1. Ortam değişkenlerini yükledim
dotenv.config();

// 2. Veritabanı bağlantısını kurdum
connectDB(); // Uygulama başlatılırken bağlantıyı dener

// 3. Express uygulamasını başlattım
const app = express();

// 4. JSON verilerini işlemek için ara katman yazılımı(middleware) ekledim
app.use(cors()); // CORS middleware'ini ekledim
app.use(express.json());

// 5. Temel bir başlangıç rotası (Root Route) tanımladım
app.get('/', (req, res) => {
    res.send('Notix API çalışıyor!');
}
);

// 6. Sunucuyu belirtilen portta dinlemeye başladım
const PORT = process.env.PORT || 5000;

app.listen(PORT, () => {
    console.log(`Sunucu http://localhost:${PORT} adresinde çalışıyor.`);
}
);

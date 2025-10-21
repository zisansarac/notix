const express = require('express');
const dotenv = require('dotenv');
const cors = require('cors');
const { connectDB } = require('./config/db');
const authRoutes = require('./routes/authRoutes');

// 1. Ortam değişkenlerini yükledim
dotenv.config();

// 2. Veritabanı bağlantısını kurdum
connectDB(); // Uygulama başlatılırken bağlantıyı dener

// 3. Express uygulamasını başlattım
const app = express();

// 4. JSON verilerini işlemek için ara katman yazılımı(middleware) ekledim
app.use(cors()); // CORS middleware'ini ekledim
app.use(express.json());

// 5. Rota tanımı: /api/auth altında authRoutes'ı kullan
app.use('/api/auth', authRoutes);

// 6. Temel bir başlangıç rotası (Root Route) tanımladım
app.get('/', (req, res) => {
    res.send('Notix API çalışıyor!');
}
);

// 7. Sunucuyu belirtilen portta dinlemeye başladım
const PORT = process.env.PORT || 5000;

app.listen(PORT, () => {
    console.log(`Sunucu http://localhost:${PORT} adresinde çalışıyor.`);
}
);

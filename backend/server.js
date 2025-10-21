const express = require('express');
const dotenv = require('dotenv');

// ortam değişkenlerini yükledim
dotenv.config();

//express uygulamasını başlattım
const app = express();

// JSON verilerini işlemek için ara katman yazılımı(middleware) ekledim
app.use(express.json());

// Temel bir başlangıç rotası (Root Route) tanımladım
app.get('/', (req, res) => {
    res.send('Notix API çalışıyor!');
}
);

// Sunucuyu belirtilen portta dinlemeye başladım
const PORT = process.env.PORT || 5000;

app.listen(PORT, () => {
    console.log(`Sunucu http://localhost:${PORT} adresinde çalışıyor.`);
}
);
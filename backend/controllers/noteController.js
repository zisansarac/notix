const { pool } = require('../config/db');

// @desc    Tüm notları getir (Sadece o kullanıcıya ait olanları)
// @route   GET /api/notes
// @access  Private (Koruma altında)
exports.getNotes = async (req, res) => {
    try { // req.user, authMiddleware tarafından eklenir.
        const result= await pool.query(
            'SELECT id, title, content, is_completed, created_at FROM notes WHERE user_id = $1 ORDER BY created_at DESC', 
            [req.user.id]
        );
        res.status(200).json(result.rows);
    } catch (error) {
        console.error('Notları Getirme Hatası:', error.message);
        res.status(500).json({ message: 'Sunucu hatası.' });
    }
};

// @desc    Yeni not oluştur
// @route   POST /api/notes
// @access  Private (Koruma altında)
exports.createNote = async (req, res) => {
    const { title, content } = req.body;

    if(!title || !content) {
        return res.status(400).json({ message: 'Başlık ve içerik gereklidir.' });
    }

    try {
        const result = await pool.query(
            'INSERT INTO notes (user_id, title, content) VALUES ($1, $2, $3) RETURNING *',
            [req.user.id, title, content]
        );
        //Oluşturulan notu döndür
        res.status(201).json(result.rows[0]);
    } catch (error) {
        console.error('Not Oluşturma Hatası:', error.message);
        res.status(500).json({ message: 'Sunucu hatası.' });
    }
};

// @desc    Notu güncelle
// @route   PUT /api/notes/:id
// @access  Private (Koruma altında)
exports.updateNote = async (req, res) => {
    const { id } = req.params;
    const { title, content, is_completed } = req.body;

    try {
        // 1. Notun kullanıcıya ait olup olmadığını kontrol et
        const noteCheck = await pool.query(
            'SELECT user_id FROM notes WHERE id = $1', [id]);
        
        if(noteCheck.rows.length === 0) {
            return res.status(404).json({ message: 'Not bulunamadı.' });
        }

        // Önemli güvenlik kontrolü: Notun sahibi, talepte bulunan kullanıcı mı?
        if(noteCheck.rows[0].user_id !== req.user.id) {
            return res.status(403).json({ message: 'Bu notu güncelleme yetkiniz yok.' });
        }

        // 2. Güncelleme işlemi
        const result = await pool.query(
            'UPDATE notes SET title = $1, content = $2, is_completed = $3 WHERE id = $4 RETURNING *',
            [title || noteCheck.rows[0].title, content || noteCheck.rows[0].content, is_completed, id]
        );
        res.status(200).json(result.rows[0]);
    } catch (error) {
        console.error('Not Güncelleme Hatası:', error.message);
        res.status(500).json({ message: 'Sunucu hatası.' });
    }
};

// @desc    Notu sil
// @route   DELETE /api/notes/:id
// @access  Private (Koruma altında)
exports.deleteNote = async (req, res) => {
    const { id } = req.params;   

    try {
        // 1. Notun kullanıcıya ait olup olmadığını kontrol et
        const noteCheck = await pool.query(
            'SELECT user_id FROM notes WHERE id = $1', [id]);
        if(noteCheck.rows.length === 0) {
            return res.status(404).json({ message: 'Not bulunamadı.' });
        }
        // Önemli güvenlik kontrolü: Notun sahibi, talepte bulunan kullanıcı mı?
        if(noteCheck.rows[0].user_id !== req.user.id) {
            return res.status(403).json({ message: 'Bu notu silme yetkiniz yok.' });
        }

        // 2. Silme işlemi
        await pool.query('DELETE FROM notes WHERE id = $1', [id]);
        
        res.status(200).json({ message: 'Not başarıyla silindi.' });
    } catch (error) {
        console.error('Not Silme Hatası:', error.message);
        res.status(500).json({ message: 'Sunucu hatası.' });
    }       
};
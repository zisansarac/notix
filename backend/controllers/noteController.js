const { pool } = require('../config/db');


exports.getNotes = async (req, res) => {
    try { 
        const userId = parseInt(req.user.id, 10);
        console.log(`DEBUG: Notlar aranıyor - Kullanıcı ID: ${userId}, Tipi: ${typeof userId}`);

        const result= await pool.query(
            'SELECT id, title, content, is_completed, created_at FROM notes WHERE user_id = $1 ORDER BY created_at DESC', 
            [userId]
        );
        console.log(`DEBUG: Kullanıcı ${req.user.id} için ${result.rows.length} not bulundu.`);

        res.status(200).json(result.rows);
    } catch (error) {
        console.error('Notları Getirme Hatası:', error.message);
        res.status(500).json({ message: 'Sunucu hatası.' });
    }
};


exports.createNote = async (req, res) => {
    const { title, content } = req.body;

    if(!title || !content) {
        return res.status(400).json({ message: 'Başlık ve içerik gereklidir.' });
    }

    const userId = parseInt(req.user.id, 10);

    try {
        const result = await pool.query(
            'INSERT INTO notes (user_id, title, content) VALUES ($1, $2, $3) RETURNING *',
            [userId, title, content]
        );
       
        res.status(201).json(result.rows[0]);
    } catch (error) {
        console.error('Not Oluşturma Hatası:', error.message);
        res.status(500).json({ message: 'Sunucu hatası.' });
    }
};


exports.updateNote = async (req, res) => {
    const { id } = req.params;
    const { title, content, isCompleted } = req.body;

    try {

        const userId = parseInt(req.user.id, 10);
        const noteId = parseInt(id, 10);

        
        const noteCheck = await pool.query(
            'SELECT user_id FROM notes WHERE id = $1', [id]);
        
        if(noteCheck.rows.length === 0) {
            return res.status(404).json({ message: 'Not bulunamadı.' });
        }

        if(noteCheck.rows[0].user_id !== req.user.id) {
            return res.status(403).json({ message: 'Bu notu güncelleme yetkiniz yok.' });
        }

        
        const result = await pool.query(
            'UPDATE notes SET title = $1, content = $2, is_completed = $3 WHERE id = $4 AND user_id = $5 RETURNING *',
            [title || noteCheck.rows[0].title, content || noteCheck.rows[0].content, isCompleted, noteId, userId]
        );
        res.status(200).json(result.rows[0]);
    } catch (error) {
        console.error('Not Güncelleme Hatası:', error.message);
        res.status(500).json({ message: 'Sunucu hatası.' });
    }
};


exports.deleteNote = async (req, res) => {
    const { id } = req.params;   

    try {

        const noteCheck = await pool.query(
            'SELECT user_id FROM notes WHERE id = $1', [id]);
        if(noteCheck.rows.length === 0) {
            return res.status(404).json({ message: 'Not bulunamadı.' });
        }
        
        if(noteCheck.rows[0].user_id !== req.user.id) {
            return res.status(403).json({ message: 'Bu notu silme yetkiniz yok.' });
        }

        await pool.query('DELETE FROM notes WHERE id = $1', [id]);
        
        res.status(200).json({ message: 'Not başarıyla silindi.' });
    } catch (error) {
        console.error('Not Silme Hatası:', error.message);
        res.status(500).json({ message: 'Sunucu hatası.' });
    }       
};
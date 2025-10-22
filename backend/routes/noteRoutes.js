const express = require('express');
const { getNotes, createNote, updateNote, deleteNote } = require('../controllers/noteController');
const { protect } = require('../middleware/authMiddleware');

const router = express.Router();

// Not rotaları, hepsi 'protect' middleware ile korunur
// Yalnızca geçerli JWT'si olan kullanıcılar erişebilir

// GET /api/notes ve POST /api/notes için tek bir satır
router.route('/')
    .get(protect, getNotes)
    .post(protect, createNote);

// PUT /api/notes/:id ve DELETE /api/notes/:id için tek bir satır
router.route('/:id')
    .put(protect, updateNote)
    .delete(protect, deleteNote);

module.exports = router;
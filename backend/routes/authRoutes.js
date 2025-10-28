const express = require('express');
const { registerUser, loginUser } = require('../controllers/authController');
const { protect } = require('../middleware/authMiddleware');

const router = express.Router();

// @route   POST /api/auth/register
router.post('/register', registerUser);

// @route   POST /api/auth/login
router.post('/login', loginUser);

router.get('/me', protect, (req, res) => {
    // req.user objesi, authMiddleware tarafından eklenir.
    // Bu obje kullanıcı ID, name, email içerir (password hariç).
    res.status(200).json({ 
        user: req.user,
        message: 'Token başarılı şekilde doğrulandı!'
    });
});


module.exports = router;
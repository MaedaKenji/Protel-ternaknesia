const express = require('express');
const router = express.Router();

// Route untuk login
router.post('/login', (req, res) => {
  const { email, password } = req.body;

  // Contoh sederhana pengecekan hardcoded
  if (email === 'test@example.com' && password === 'password123') {
    res.status(200).json({ success: true, message: 'Login berhasil!' });
  } else {
    res.status(401).json({ success: false, message: 'Email atau password salah' });
  }
});

module.exports = router;

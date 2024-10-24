const express = require('express');
const mongoose = require('mongoose');
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const cors = require('cors');
require('dotenv').config();

// Models
const Cow = require('./models/cow');
// Impor User model dari folder models
const User = require('./models/user');



const app = express();
app.use(express.json());

const PORT = process.env.PORT || 3000;
// const SERVER_URL = process.env.SERVER_URL || `http://localhost:${PORT}`;
const SERVER_URL = process.env.SERVER_URL || `http://localhost:${PORT}`;

function isSameDay(date1, date2) {
  return date1.getFullYear() === date2.getFullYear() &&
    date1.getMonth() === date2.getMonth() &&
    date1.getDate() === date2.getDate();
}


mongoose.connect(process.env.MONGODB_URI)
  .then(() => {
    console.log('Connected to MongoDB');
    console.log('Database Name:', mongoose.connection.name);
  })
  .catch(err => console.error('MongoDB connection error:', err));



app.use(cors({
  origin: '*',  // Mengizinkan semua domain, atau ganti dengan domain yang diizinkan
}));

app.post('/login', async (req, res) => {
  const { email, password } = req.body;

  try {
    const user = await User.findOne({ email });
    if (!user) {
      return res.status(400).json({ success: false, message: 'User not found' });
    }

    const isMatch = await bcrypt.compare(password, user.password);
    if (!isMatch) {
      return res.status(400).json({ success: false, message: 'Invalid credentials' });
    }

    const token = jwt.sign({ userId: user._id }, process.env.JWT_SECRET, { expiresIn: '1h' });
    res.json({ success: true, token });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Server error' });
  }
});

app.get('/users', async (req, res) => {
  try {
    const users = await User.find({});
    res.json({ success: true, users });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Server error', error: error.message });
  }
});

app.post('/register', async (req, res) => {
  try {
    const { email, password } = req.body;
    const newUser = new User({ email, password });
    await newUser.save();
    res.json({ success: true, message: 'User registered successfully' });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Server error', error: error.message });
  }
});

// API untuk mendapatkan data sapi
app.get('/cows', async (req, res) => {
  try {
    const Cows = await Cow.find();
    res.json(Cows);  // Mengirimkan semua data sapi sebagai JSON
  } catch (err) {
    console.error('Error fetching cow data:', err);
    res.status(500).json({ message: 'Server error', error: err.message });
  }
});

// API untuk menambahkan record baru berdasarkan ID sapi yang ada
app.post('/api/cows/:id', async (req, res) => {
  try {
    const cowId = req.params.id;
    const cowData = req.body; // Data baru yang akan ditambahkan

    // Cari sapi berdasarkan ID
    const cow = await Cow.findById(cowId);

    if (!cow) {
      // Jika sapi dengan ID tidak ditemukan, kembalikan error
      return res.status(404).json({ message: 'Sapi tidak ditemukan' });
    }

    // Tambahkan data baru ke array yang sesuai berdasarkan cowData
    if (cowData.health) {
      cow.health.push({ sehat: cowData.health.sehat });
    }
    if (cowData.birahi) {
      cow.birahi.push({ birahi: cowData.birahi.birahi });
    }
    if (cowData.hasilPerolehanSusu) {
      cow.hasilPerolehanSusu.push({ hasil: cowData.hasilPerolehanSusu.hasil });
    }
    if (cowData.beratPakanHijauan) {
      cow.beratPakanHijauan.push({
        beratPakanHijauan: cowData.beratPakanHijauan.beratPakanHijauan,
        beratPakanKonsentrat: cowData.beratPakanKonsentrat.beratPakanKonsentrat
      });
    }
    if (cowData.tingkatStress) {
      cow.tingkatStress.push({ stress: cowData.tingkatStress.stress });
    }
    if (cowData.catatanTambahan) {
      cow.catatanTambahan.push({ note: cowData.catatanTambahan.note });
    }

    // Simpan perubahan ke database
    const updatedCow = await cow.save();

    // Kirim response sukses
    res.status(200).json(updatedCow);
  } catch (error) {
    // Kirim response error
    res.status(400).json({ message: error.message });
  }
});

app.get('/api/cows/today', async (req, res) => {
  try {
    const data = await Cow.find();
    if (!data) {
      return res.status(404).json({ message: 'Data not found' });
    }
    // const allSusu = data.map(cow => {
    //   const lastEntry = cow.hasilPerahSusu[cow.hasilPerahSusu.length - 1];
    //   return {
    //     cowId: cow._id,
    //     lastMilkResult: lastEntry ? lastEntry.hasil : null,
    //     lastMilkTimestamp: lastEntry ? lastEntry.timestamp : null
    //   };
    // });
    // res.json({ allSusu });
    let totalMilk = 0;
    let sapiTelahDiperah = 0;
    let sapiTelahDiberipakan = 0;
    const timeNow = new Date();
    // console.log('timeNow', timeNow);

    const allSusu = data.map(cow => {
      const lastEntry = cow.hasilPerahSusu[cow.hasilPerahSusu.length - 1];
      const lastMilkResult = lastEntry ? lastEntry.hasil : 0;

      // Menambahkan hasil ke total jika timestamp-nya adalah hari ini
      if (lastEntry && isSameDay(new Date(lastEntry.timestamp), timeNow)) {
        totalMilk += lastMilkResult;
        sapiTelahDiperah++;
      }

      // Mendapatkan berat pakan hijauan terakhir
      const lastFeedEntry = cow.beratPakanHijauan[cow.beratPakanHijauan.length - 1];
      let lastFeedWeight = 0;

      // Memeriksa apakah timestamp pakan adalah hari ini
      if (lastFeedEntry && isSameDay(new Date(lastFeedEntry.timestamp), timeNow)) {
        lastFeedWeight = lastFeedEntry.berat;
        sapiTelahDiberipakan++;
      }

      return {
        cowId: cow._id,
        lastMilkResult: lastMilkResult,
        lastMilkTimestamp: lastEntry ? lastEntry.timestamp : null,
        lastFeedWeight: lastFeedWeight,
        lastFeedTimestamp: lastFeedEntry ? lastFeedEntry.timestamp : null
      };
    });

    res.json({
      totalMilk: totalMilk,
      sapiTelahDiberipakan: sapiTelahDiberipakan,
      sapiTelahDiperah: sapiTelahDiperah
    });
  } catch (err) {
    // console.error('Error fetching cow data:', err);
    res.status(500).json({ message: 'Server error', error: err.message });
  }
});

// Middleware untuk menangani error
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).json({
    error: 'Internal Server Error',
    message: 'Terjadi kesalahan pada server',
  });
});


// Start server with full URL
app.listen(PORT, SERVER_URL, () => console.log(`Server running on `));

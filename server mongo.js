const express = require('express');
const mongoose = require('mongoose');
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const cors = require('cors');
const axios = require('axios');
const moment = require('moment-timezone');
const { Pool } = require('pg');
require('dotenv').config();

// Models
const Cow = require('./models/cow');
const User = require('./models/user');
const Record = require('./models/record');
const RecordBulanan = require('./models/recordBulanan');

// Constants
const nowUtcPlus7 = moment.tz("Asia/Bangkok").format();



const app = express();
app.use(express.json());

const PORT = process.env.PORT || 3000;
const SERVER_URL = process.env.SERVER_URL;

function isSameDay(date1, date2) {
  return date1.getFullYear() === date2.getFullYear() &&
    date1.getMonth() === date2.getMonth() &&
    date1.getDate() === date2.getDate();
}


mongoose.connect(process.env.MONGODB_URI)
  .then(() => {
    console.log('Connected to MongoDB');
    console.log('Database Name:', mongoose.connection.name);
    console.log('Server & Database Up and Running');
  })
  .catch(err => console.error('MongoDB connection error:', err));

// PostgreSQL connection setup 
const pool = new Pool({ host: process.env.PGHOST, user: process.env.PGUSER, password: process.env.PGPASSWORD, database: process.env.PGDATABASE, port: process.env.PGPORT, });

// Test the connection 
pool.connect((err) => { if (err) { console.error('PostgreSQL connection error:', err); } else { console.log('Connected to PostgreSQL'); } });



app.use(cors({
  origin: '*',  // Mengizinkan semua domain, atau ganti dengan domain yang diizinkan
}));

app.post('/api/login', async (req, res) => {
  const { email, password } = req.body;
  console.log(email, password);
  const user2 = await User.findOne({ email });
  console.log(user2);

  try {
    const user = await User.findOne({ email });
    if (!user) {
      return res.status(400).json({ success: false, message: 'User not found' });
    }

    const isMatch = await bcrypt.compare(password, user.password);
    if (!isMatch) {
      return res.status(400).json({ success: false, message: 'Invalid credentials' });
    }

    res.json({ success: true, message: 'Login successful' });
  } catch (error) {
    console.error(error);
    res.status(500).json({ success: false, message: 'Server error', error: error.message });

  }
});

app.get('/api/users', async (req, res) => {
  try {
    const users = await User.find({});
    res.json({ success: true, users });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Server error', error: error.message });
  }
});

app.post('/api/register', async (req, res) => {
  try {
    const { email, password } = req.body;
    const newUser = new User({ email, password });
    await newUser.save();
    res.json({ success: true, message: 'User registered successfully' });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Server error', error: error.message });
  }
});





//-------------------------------api/cows/----------------------------------------
// API untuk mendapatkan data sapi
app.get('/api/cows', async (req, res) => {
  try {
    const Cows = await Cow.find();
    res.json(Cows);  // Mengirimkan semua data sapi sebagai JSON
  } catch (err) {
    console.error('Error fetching cow data:', err);
    res.status(500).json({ message: 'Server error', error: err.message });
  }
});

app.get('/api/cows/:id', async (req, res) => {
  try {
    const cow = await Cow.findOne({ id: req.params.id });
    if (!cow) {
      return res.status(404).json({ message: 'Cow not found', cow: cow });
    }
    res.json(cow);
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: 'Server error' });
  }
});

app.post('/api/cows/tambahdata/:id', async (req, res) => {
  try {
    // Dapatkan data berdasarkan `id` sapi
    let cow = await Cow.findOne({ id: req.params.id });
    console.log('API masuk')

    // Jika sapi tidak ditemukan, buat sapi baru
    if (!cow) {
      return res.status(404).json({ message: 'Cow not found' });
    }

    // Cek dan tambahkan data sesuai body yang dikirim
    if (req.body.beratAndSusu) {
      cow.beratAndSusu.push(req.body.beratAndSusu);
    }

    if (req.body.stressRecord) {
      cow.stressRecord.push(req.body.stressRecord);
    }

    if (req.body.birahiRecord) {
      cow.birahiRecord.push(req.body.birahiRecord);
    }

    if (req.body.healthRecord) {
      cow.healthRecord.push(req.body.healthRecord);
    }

    if (req.body.pakanRecord) {
      cow.pakanRecord.push(req.body.pakanRecord);
    }

    if (req.body.noteRecord) {
      cow.noteRecord.push(req.body.noteRecord);
    }

    // Simpan perubahan atau data baru ke database
    const updatedCow = await cow.save();

    res.json(updatedCow);
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: 'Server error' });
  }
});

app.get('/api/cows/today', async (req, res) => {
  try {
    const data = await Cow.find();
    if (!data) {
      return res.status(404).json({ message: 'Data not found' });
    }
    let totalMilk = 0;
    let sapiTelahDiperah = 0;
    let sapiTelahDiberipakan = 0;
    let beratPakanHijauan = 0;
    let beratPakanKonsentrat = 0;
    // const timeNow = new Date();
    const timeNow = moment.tz("Asia/Bangkok").format
    console.log(timeNow);


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

    // await axios.post(`${process.env.BASE_URL}/api/milk-records`, { totalMilk });

    res.json({
      totalMilk: totalMilk,
      sapiTelahDiberipakan: sapiTelahDiberipakan,
      sapiTelahDiperah: sapiTelahDiperah
    });
  } catch (err) {
    res.status(500).json({ message: 'Server error', error: err.message, url: process.env.BASE_URL });
  }
});

app.post('/api/cows/tambahsapi', async (req, res) => {
  try {
    const {id, gender, age, weight, healthRecord} = req.body;
    
    // Check if cow with the same ID already exists
    const existingCow = await Cow.findOne({ id });
    if (existingCow) {
      return res.status(400).json({ message: 'Cow with the same ID already exists' });
    }
  
    const cow = new Cow({
      id: id,
      gender: gender,
      age: age,
      weight: weight,
      healthRecord: [{ sehat: healthRecord }] // assuming healthRecord is a boolean value
    });

    await cow.save();
    res.status(201).json({ message: 'Cow added', cow: cow });
  } catch (err) {
    res.status(500).json({ message: 'Server error', error: err.message, req: req.body });
  }
});

app.get('/api/cows/data', async (req, res) => {
  try {
    const data = await Cow.find();
    if (!data) {
      return res.status(404).json({ message: 'Data not found' });
    }
    res.json(data);
  } catch (err) {
    res.status(500).json({ message: 'Server error', error: err.message });
  }
});

app.get('/api/cows/today/bulanan/susu', async (req, res) => {
  try {
    const data = await RecordBulanan.find();
    if (!data) {
      return res.status(404).json({ message: 'Data not found' });
    }
    let totalMilk = 0;
    let beratPakanHijauan = 0;
    let beratPakanKonsentrat = 0;
    const timeNow = moment.tz("Asia/Bangkok").format
    console.log(timeNow);
    console.log(data);

    const monthlyMilkResults = {};

    data.forEach(cow => {
      console.log(cow);
      if (cow.totalMilk === undefined) {
        console.log('Cow has no milk data');
      }
      else {
      cow.totalMilk.forEach(entry => {
        const milkAmount = entry.hasil || 0; // Ambil hasil perah atau 0 jika tidak ada
        const entryDate = new Date(entry.timestamp);
        const monthYear = entryDate.toLocaleString('default', { month: 'long', year: 'numeric' });

        // Jika bulan tahun belum ada di objek, inisialisasi
        if (!monthlyMilkResults[monthYear]) {
          monthlyMilkResults[monthYear] = 0;
        }

        // Tambahkan hasil perah ke bulan yang sesuai
        monthlyMilkResults[monthYear] += milkAmount;
        
      });
    }
    });

    // Format hasil menjadi string
    const resultString = Object.entries(monthlyMilkResults)
      .map(([monthYear, total]) => `${monthYear}: ${total}`)
      .join('; ');

    // Mengembalikan hasil
    return res.json(resultString);
  } catch (err) {
    res.status(500).json({ message: 'Server error', error: err.message, url: process.env.BASE_URL });
  }
});









// ---------------------------------------------------RECORDS--------------------------------------------------------------------
app.get('/api/records', async (req, res) => {
  try {
    const records = await Record.find();
    res.json(records);
  } catch (err) {
    res.status(500).json({ message: 'Server error', error: err.message });
  }
});

app.post('/api/records', async (req, res) => {
  try {
    const { hasilPerah, jumlahSapiSehat, beratHijauan, beratSentrat } = req.body;
    const timeNow = new Date(Date.now() + 7 * 60 * 60 * 1000);;
    // console.log(timeNow);

    // Cek record terakhir
    let record = await Record.findOne();

    if (!record) {
      // Jika tidak ada record, buat record baru
      record = new Record({
        hasilPerah: [],
        jumlahSapiSehat: [],
        beratHijauan: [],
        beratSentrat: []
      });
    }

    // Fungsi untuk menambahkan atau memperbarui data
    const addOrUpdateData = (array, newValue) => {
      const lastEntry = array[array.length - 1];
      if (!lastEntry) {
        // Jika array kosong, tambahkan entry baru
        array.push({ nilai: newValue, timestamp: timeNow });
      } else if (isSameDay(new Date(lastEntry.timestamp), timeNow) && timeNow > new Date(lastEntry.timestamp)) {
        // Jika timestamp sama (hari yang sama) dan timeNow lebih besar, perbarui nilai
        lastEntry.nilai = newValue;
        lastEntry.timestamp = timeNow; // Update timestamp juga
      } else if (!isSameDay(new Date(lastEntry.timestamp), timeNow)) {
        // Jika hari berbeda, tambahkan entry baru
        array.push({ nilai: newValue, timestamp: timeNow });
      } else {
        // Jika hari berbeda, tambahkan entry baru
        array.push({ nilai: newValue, timestamp: timeNow });
      }
    }
    const addNewData2 = (array, newValue) => {
      const lastEntry = array[array.length - 1];
      {
        const nextDay = new Date(timeNow);
        nextDay.setDate(nextDay.getDate() + 3);
        array.push({ nilai: newValue, timestamp: nextDay });
      }
    };


    // Tambahkan data baru ke masing-masing array
    if (hasilPerah !== undefined) addOrUpdateData(record.hasilPerah, hasilPerah);
    if (jumlahSapiSehat !== undefined) addOrUpdateData(record.jumlahSapiSehat, jumlahSapiSehat);
    if (beratHijauan !== undefined) addOrUpdateData(record.beratHijauan, beratHijauan);
    if (beratSentrat !== undefined) addOrUpdateData(record.beratSentrat, beratSentrat);
    // addNewData2(record.jumlahSapiSehat, jumlahSapiSehat);

    await record.save();
    res.status(201).json({ message: 'Record updated', record: record });
  } catch (err) {
    res.status(500).json({ message: 'Server error', error: err.message, req: req.body });
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

// Cek nilai dari BASE_URL
console.log(`Configured BASE_URL: ${process.env.BASE_URL}`);
console.log(`Please check if BASE_URL is correct`);

// Check if server is running
app.get('/', (req, res) => {
  res.send('Server is running');
});

// Start server with full URL
app.listen(PORT, SERVER_URL, () => console.log(`Server listening on ${SERVER_URL} \nConnecting to database...`));
console.log('Port:', PORT);

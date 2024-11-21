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

const PORT = process.env.PORT;
const SERVER_URL = process.env.SERVER_URL;

function isSameDay(date1, date2) {
  return date1.getFullYear() === date2.getFullYear() &&
    date1.getMonth() === date2.getMonth() &&
    date1.getDate() === date2.getDate();
}


// mongoose.connect(process.env.MONGODB_URI)
//   .then(() => {
//     console.log('Connected to MongoDB');
//     console.log('Database Name:', mongoose.connection.name);
//     console.log('Server & Database Up and Running');
//   })
//   .catch(err => console.error('MongoDB connection error:', err));

// PostgreSQL connection setup 
const pool = new Pool({ host: process.env.PGHOST, user: process.env.PGUSER, password: process.env.PGPASSWORD, database: process.env.PGDATABASE, port: process.env.PGPORT, });
// console.log("host:", process.env.PGHOST , "user:", process.env.PGUSER, "password:", process.env.PGPASSWORD, "database:", process.env.PGDATABASE, "port:", process.env.PGPORT, );

// Test the connection 
pool.connect((err) => { if (err) { console.error('PostgreSQL connection error:', err); } else { console.log('Connected to PostgreSQL'); } });


//-------------------------------api/users/----------------------------------------

app.use(cors({
  origin: '*',  // Mengizinkan semua domain, atau ganti dengan domain yang diizinkan
}));

app.post('/api/users/login', async (req, res) => {
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

app.get('/api/users/user', async (req, res) => {
  try {
    const users = await User.find({});
    res.json({ success: true, users });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Server error', error: error.message });
  }
});

app.post('/api/users/register', async (req, res) => {
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
app.get('/api/cows', async (req, res) => {
  try {
    const result = await pool.query(`
      SELECT c.cow_id, c.gender, c.age, c.health_record, c.stress_level, c.birahi, c.status, c.note, bw.weight AS weight, bw.date AS weight_date
      FROM cows c
      LEFT JOIN (
        SELECT cow_id, weight, date
        FROM body_weight
        WHERE (cow_id, date) IN (
          SELECT cow_id, MAX(date)
          FROM body_weight
          GROUP BY cow_id
        )
      ) bw ON c.cow_id = bw.cow_id
    `);
    res.json(result.rows);
  } catch (err) {
    console.error('Error fetching cow data:', err);
    res.status(500).json({ message: 'Server error', error: err.message });
  }
});

app.get('/api/cows/:id', async (req, res) => {
  try {
    const { id } = req.params;

    // Query untuk mendapatkan data sapi berdasarkan cow_id
    const cowQuery = 'SELECT * FROM cows WHERE cow_id = $1';
    const cowResult = await pool.query(cowQuery, [id]);
    const cow = cowResult.rows[0];

    if (!cow) {
      return res.status(404).json({ message: 'Cow not found' });
    }

    // Query untuk mendapatkan 5 weight terakhir dari tabel body_weight berdasarkan cow_id
    const weightQuery = `
      SELECT date, weight
      FROM body_weight
      WHERE cow_id = $1
      ORDER BY date DESC
      LIMIT 5
    `;
    const weightResult = await pool.query(weightQuery, [id]);

    // Query untuk mendapatkan 5 production_amount terakhir dari tabel milk_production berdasarkan cow_id
    const milkQuery = `
      SELECT date, production_amount
      FROM milk_production
      WHERE cow_id = $1
      ORDER BY date DESC
      LIMIT 5
    `;
    const milkResult = await pool.query(milkQuery, [id]);

    // Query untuk mendapatkan 5 data pakan hijauan terakhir dari tabel feed_hijauan berdasarkan cow_id
    const feedHijauanQuery = `
      SELECT date, amount
      FROM feed_hijauan
      WHERE cow_id = $1
      ORDER BY date DESC
      LIMIT 5
    `;
    const feedHijauanResult = await pool.query(feedHijauanQuery, [id]);

    // Query untuk mendapatkan 5 data pakan konsentrat terakhir dari tabel feed_sentrate berdasarkan cow_id
    const feedSentrateQuery = `
      SELECT date, amount
      FROM feed_sentrate
      WHERE cow_id = $1
      ORDER BY date DESC
      LIMIT 5
    `;
    const feedSentrateResult = await pool.query(feedSentrateQuery, [id]);

    // Gabungkan data sapi dengan data weight, milk production, dan pakan terakhir
    res.json({
      ...cow,
      recent_weights: weightResult.rows,
      recent_milk_production: milkResult.rows,
      recent_feed_hijauan: feedHijauanResult.rows,
      recent_feed_sentrate: feedSentrateResult.rows
    });
  } catch (err) {
    console.error('Error fetching cow by id:', err);
    res.status(500).json({ message: 'Server error', error: err.message });
  }
});

app.post('/api/cows/tambahsapi', async (req, res) => {
  const { id, gender, age, weight, healthRecord } = req.body; // Make sure 'id' is provided in the body
  console.log("Request Body:", req.body); // Log to check incoming data

  if (!id) {
    return res.status(400).json({ message: 'cow_id (id) is required' });
  }
  try {
    const result = await pool.query(
      'INSERT INTO cows (cow_id, gender, age, health_record) VALUES ($1, $2, $3, $4) RETURNING *',
      [id, gender, age, healthRecord]
    );

    // Setelah itu, masukkan data weight ke tabel body_weight dengan cow_id yang sudah didapatkan
    const insertWeightResult = await pool.query(
      'INSERT INTO body_weight (cow_id, date, weight) VALUES ($1, $2, $3) RETURNING *',
      [id, new Date(), weight]
    );

    console.log('Data bobot:', insertWeightResult.rows[0]);

    res.status(201).json({ message: 'Cow added', cow: result.rows[0] });
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: 'Server error', error: err.message });
  }
});

app.post('/api/cows/tambahdata/:id', async (req, res) => {
  const { id } = req.params; // cow_id
  const data = req.body; // Data dalam bentuk {key: value}
  const key = Object.keys(data)[0];
  const value = data[key];
  console.log("Request Body:", req.body);
  console.log("ID:", id);

  try {
    // Cek key untuk menentukan tabel dan kolom yang tepat
    if (key === 'produksiSusu') {
      // Menambahkan data ke tabel milk_production
      const result = await pool.query(
        'INSERT INTO milk_production (cow_id, date, production_amount) VALUES ($1, NOW(), $2) RETURNING *',
        [id, value]
      );
      res.status(201).json({ message: 'Milk production data added', data: result.rows[0] });
    } else if (key === 'beratBadan') {
      // Menambahkan data ke tabel body_weight
      const result = await pool.query(
        'INSERT INTO body_weight (cow_id, date, weight) VALUES ($1, NOW(), $2) RETURNING *',
        [id, value]
      );
      res.status(201).json({ message: 'Body weight data added', data: result.rows[0] });
    } else if (key === 'pakanHijau') {
      // Menambahkan data ke tabel feed_hijauan
      const result = await pool.query(
        'INSERT INTO feed_hijauan (cow_id, date, amount) VALUES ($1, NOW(), $2) RETURNING *',
        [id, value]
      );
      res.status(201).json({ message: 'Feed hijauan data added', data: result.rows[0] });
    } else if (key === 'pakanSentrat') {
      // Menambahkan data ke tabel feed_sentrate
      const result = await pool.query(
        'INSERT INTO feed_sentrate (cow_id, date, amount) VALUES ($1, NOW(), $2) RETURNING *',
        [id, value]
      );
      res.status(201).json({ message: 'Feed sentrate data added', data: result.rows[0] });
    } else {
      res.status(400).json({ message: 'Invalid data key' });
    }
  } catch (err) {
    console.error('Error adding data:', err);
    res.status(500).json({ message: 'Server error', error: err.message });
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

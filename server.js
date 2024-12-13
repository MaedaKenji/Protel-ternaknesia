const express = require('express');
const mongoose = require('mongoose');
const { exec } = require('child_process');
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const cors = require('cors');
const axios = require('axios');
const moment = require('moment-timezone');
const { Pool } = require('pg');
const { PythonShell } = require('python-shell');

require('dotenv').config();

// Models
const Cow = require('./models/cow');
const User = require('./models/user');
const Record = require('./models/record');
const RecordBulanan = require('./models/recordBulanan');

// Constants
const nowUtcPlus7 = moment.tz("Asia/Bangkok").format();



const app = express();
const FLASK_API_URL = 'http://localhost:5000/predict_productivity'; // URL Flask
app.use(express.json());

const PORT = process.env.PORT;
const SERVER_URL = process.env.SERVER_URL;

function isSameDay(date1, date2) {
  return date1.getFullYear() === date2.getFullYear() &&
    date1.getMonth() === date2.getMonth() &&
    date1.getDate() === date2.getDate();
}


// PostgreSQL connection setup 
// const pool = new Pool({ host: process.env.PGHOST, user: process.env.PGUSER, password: process.env.PGPASSWORD, database: process.env.PGDATABASE, port: process.env.PGPORT, });
const pool = new Pool({
  host: process.env.PGHOST,
  user: process.env.PGUSER,
  password: process.env.PGPASSWORD,
  database: process.env.PGDATABASE,
  port: process.env.PGPORT,
});

const poolTernaknesiaRelational = new Pool({
  user: process.env.PGUSER,  // Ganti dengan username PostgreSQL Anda
  host: process.env.PGHOST,  // Ganti dengan host PostgreSQL Anda
  database: process.env.PGDATABASERELATIONAL,  // Ganti dengan nama database kedua Anda
  password: process.env.PGPASSWORD,  // Ganti dengan password PostgreSQL Anda
  port: process.env.PGPORT,
});

// Test the connection 
pool.connect((err) => { if (err) { console.error('PostgreSQL connection error:', err); } else { console.log('Connected to PostgreSQL ternaknesia'); } });
poolTernaknesiaRelational.connect((err) => { if (err) { console.error('PostgreSQL connection error:', err); } else { console.log('Connected to PostgreSQL ternaknesia_relational'); } });

app.use(cors({
  origin: '*',  // Mengizinkan semua domain, atau ganti dengan domain yang diizinkan
}));



//-------------------------------api/cows/----------------------------------------
app.get('/api/cattles-relational', async (req, res) => {
  try {
    // Fetch all cows
    const result = await poolTernaknesiaRelational.query('SELECT * FROM cows');

    // Fetch weight records for each cow
    const weightResult = await poolTernaknesiaRelational.query('SELECT * FROM public.berat_badan ORDER BY cow_id, tanggal ASC');

    // Fetch the latest health status for each cow
    const healthResult = await poolTernaknesiaRelational.query(
      'SELECT DISTINCT ON (cow_id) * FROM public.kesehatan ORDER BY cow_id, tanggal DESC'
    );

    // Create a map for weight records by cow_id
    const weightMap = new Map();
    weightResult.rows.forEach(weight => {
      weightMap.set(weight.cow_id, weight.berat); // Assuming 'berat' is the field for weight
    });

    // Create a map for health statuses by cow_id
    const healthMap = new Map();
    healthResult.rows.forEach(health => {
      healthMap.set(health.cow_id, health.status_kesehatan); // Assuming 'status_kesehatan' is the field for health status
    });

    // Fungsi untuk menghitung produktivitas
    const hitungProduktivitas = async (cow_id) => {
      const dataBerat = await poolTernaknesiaRelational.query('SELECT * FROM berat_badan WHERE cow_id = $1 ORDER BY tanggal ASC', [cow_id]);

      const derivatif = [];
      for (let i = 1; i < dataBerat.rows.length; i++) {
        const beratSekarang = dataBerat.rows[i].berat;
        const beratSebelum = dataBerat.rows[i - 1].berat;
        const tanggalSekarang = new Date(dataBerat.rows[i].tanggal);
        const tanggalSebelum = new Date(dataBerat.rows[i - 1].tanggal);
        const selisihHari = (tanggalSekarang - tanggalSebelum) / (1000 * 3600 * 24);
        const derivatifSekarang = (beratSekarang - beratSebelum) / selisihHari;
        derivatif.push(derivatifSekarang);
      }

      const rataRataDerivatif = derivatif.reduce((a, b) => a + b, 0) / derivatif.length;

      return rataRataDerivatif < -0.5 ? false : true;
    };

    // Map the database rows to the desired JSON structure
    const formattedResult = await Promise.all(result.rows.map(async cow => ({
      id: cow.cow_id,
      weight: weightMap.get(cow.cow_id),
      age: cow.umur,
      gender: cow.gender,
      healthStatus: healthMap.get(cow.cow_id) || 'unknown',
      isProductive: await hitungProduktivitas(cow.cow_id),
      isConnectedToNFCTag: cow.nfc_id !== null,
    })));

    // Send the formatted result as JSON
    res.json(formattedResult);

  } catch (err) {
    console.error('Error executing query on ternaknesia_relational', err.stack);
    res.status(500).json({ message: 'Error fetching data from ternaknesia_relational' });
  }
});

app.get('/api/cattles-relationalAsli', async (req, res) => {
  try {
    // Fetch all cows
    const result = await poolTernaknesiaRelational.query('SELECT * FROM cows');

    // Fetch weight records for each cow
    const weightResult = await poolTernaknesiaRelational.query('SELECT DISTINCT ON (cow_id) * FROM public.berat_badan ORDER BY cow_id, tanggal DESC');

    // Fetch the latest health status for each cow
    const healthResult = await poolTernaknesiaRelational.query(
      'SELECT DISTINCT ON (cow_id) * FROM public.kesehatan ORDER BY cow_id, tanggal DESC'
    );

    // Create a map for weight records by cow_id
    const weightMap = new Map();
    weightResult.rows.forEach(weight => {
      weightMap.set(weight.cow_id, weight.berat); // Assuming 'berat' is the field for weight
    });

    // Create a map for health statuses by cow_id
    const healthMap = new Map();
    healthResult.rows.forEach(health => {
      healthMap.set(health.cow_id, health.status_kesehatan); // Assuming 'status_kesehatan' is the field for health status
    });

    // Map the database rows to the desired JSON structure
    const formattedResult = result.rows.map(cow => ({
      id: cow.cow_id, // Assuming 'cow_id' is a string in your database
      weight: weightMap.get(cow.cow_id), // Assuming 'weight' is an integer
      age: cow.umur, // Assuming 'umur' is an integer
      gender: cow.gender, // Assuming 'gender' is a string
      healthStatus: healthMap.get(cow.cow_id) || 'unknown', // Get health status or default to 'unknown'
      isConnectedToNFCTag: cow.nfc_id !== null // Check if nfc_id is not null
    }));

    // Send the formatted result as JSON
    res.json(formattedResult);


  } catch (err) {
    console.error('Error executing query on ternaknesia_relational', err.stack);
    res.status(500).json({ message: 'Error fetching data from ternaknesia_relational' });
  }
});


app.get('/api/cattles-relational/predict/:cow_id', async (req, res) => {
  const numpy = require('numpy');
  const { LinearRegression, LogisticRegression } = require('scikit-learn');

  // Inisialisasi model
  const modelLR = new LinearRegression();
  const modelLogR = new LogisticRegression();

  // Muat data dari database
  const data = await poolTernaknesiaRelational.query('SELECT * FROM berat_badan');

  // Persiapan data
  const X = data.rows.map(row => [row.berat, row.umur]);
  const y = data.rows.map(row => row.produktif ? 1 : 0);

  // Latih model
  modelLR.fit(X, y);
  modelLogR.fit(X, y);

  try {
    const cow_id = req.params.cow_id;
    const sapiData = await poolTernaknesiaRelational.query(`SELECT * FROM cows WHERE cow_id = $1`, [cow_id]);

    if (!sapiData.rows[0]) {
      return res.status(404).json({ message: 'Sapi tidak ditemukan' });
    }

    const sapi = sapiData.rows[0];
    const berat = weightMap.get(sapi.cow_id);
    const umur = sapi.umur;

    // Prediksi menggunakan model
    const prediction = modelLogR.predict([[berat, umur]]);

    res.json({ produktif: prediction[0] === 1 });
  } catch (err) {
    console.error('Error executing query', err.stack);
    res.status(500).json({ message: 'Error fetching data' });
  }
});

app.get('/api/cattles-relationalflaskTapiJelek', async (req, res) => {
  try {
    // Fetch all cows
    const result = await poolTernaknesiaRelational.query('SELECT * FROM cows');

    // Fetch weight records for each cow
    const weightResult = await poolTernaknesiaRelational.query(
      'SELECT DISTINCT ON (cow_id) * FROM public.berat_badan ORDER BY cow_id, tanggal DESC'
    );

    // Fetch the latest health status for each cow
    const healthResult = await poolTernaknesiaRelational.query(
      'SELECT DISTINCT ON (cow_id) * FROM public.kesehatan ORDER BY cow_id, tanggal DESC'
    );

    const milkResult = await poolTernaknesiaRelational.query('SELECT * FROM public.produksi_susu ORDER BY id ASC');
    console.log(milkResult.rows);

    const health_recordResult = await poolTernaknesiaRelational.query('SELECT * FROM public.kesehatan ORDER BY id ASC');
    console.log(health_recordResult.rows);
    const stress_levelResult = await poolTernaknesiaRelational.query('SELECT * FROM public.stress_level ORDER BY id ASC');
    console.log(stress_levelResult.rows);
    const birahi_statusResult = await poolTernaknesiaRelational.query('SELECT * FROM public.birahi ORDER BY id ASC');
    console.log(birahi_statusResult.rows);
    const pakan_hijauResult = await poolTernaknesiaRelational.query('SELECT * FROM public.pakan_hijauan ORDER BY id ASC');
    console.log(pakan_hijauResult.rows);
    const pakan_sentratResult = await poolTernaknesiaRelational.query('SELECT * FROM public.pakan_sentrat ORDER BY id ASC');
    console.log(pakan_sentratResult.rows);


    // Create a map for weight records by cow_id
    const weightMap = new Map();
    weightResult.rows.forEach(weight => {
      weightMap.set(weight.cow_id, weight.berat); // Assuming 'berat' is the field for weight
    });

    // Create a map for health statuses by cow_id
    const healthMap = new Map();
    healthResult.rows.forEach(health => {
      healthMap.set(health.cow_id, health.status_kesehatan); // Assuming 'status_kesehatan' is the field for health status
    });

    // Prepare an array to hold the results with productivity classification
    const formattedResult = [];

    for (const cow of result.rows) {
      const cowId = cow.cow_id;
      const weight = weightMap.get(cowId);
      const healthStatus = healthMap.get(cowId) || 'unknown';
      const isConnectedToNFCTag = cow.nfc_id !== null;

      // Call the Flask classification API to determine if the cow is productive
      const isProductive = await classifyCow(cowId, weight, healthStatus);

      formattedResult.push({
        id: cowId,
        weight: weight,
        age: cow.umur, // Assuming 'umur' is an integer
        gender: cow.gender, // Assuming 'gender' is a string
        healthStatus: healthStatus,
        isProductive: isProductive,
        isConnectedToNFCTag: isConnectedToNFCTag,
      });
    }

    // Send the formatted result as JSON
    res.json(formattedResult);
  } catch (err) {
    console.error('Error executing query on ternaknesia_relational', err.stack);
    res.status(500).json({ message: 'Error fetching data from ternaknesia_relational' });
  }
});

async function classifyCow(cowId, weight, healthStatus) {
  try {
    const response = await axios.post('http://your-flask-api-url/classify', {
      cow_id: cowId,
      weight: weight,
      health_status: healthStatus,
    });

    return response.data.is_productive; // Adjust based on the actual response structure
  } catch (error) {
    console.error(`Error classifying cow ID ${cowId}:`, error);
    return false; // Default to false if there's an error
  }
}

app.get('/api/cows', async (req, res) => {
  try {
    const result = await pool.query(`
      SELECT c.cow_id, c.gender, c.age, c.health_record, c.stress_level, c.birahi, c.note, bw.weight AS weight, bw.date AS weight_date
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
    console.log(result.rows);
  } catch (err) {
    console.error('Error fetching cow data:', err);
    res.status(500).json({ message: 'Server error', error: err.message });
  }
});

app.get('/api/cowsASLI', async (req, res) => {
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

app.get('/api/cows/data/sapi_diperah', async (req, res) => {
  // console.log("MASUK");
  try {
    const query = `
      SELECT COUNT(DISTINCT cow_id) AS cows_milked
      FROM milk_production
      WHERE date = CURRENT_DATE;
    `;
    const result = await pool.query(query);
    // console.log(result.rows[0].cows_milked);
    res.json({ value: result.rows[0].cows_milked });
  } catch (err) {
    console.error(err);
    res.status(500).send('Server error');
  }
});

app.get('/api/cows/data/sapi_diberi_pakan', async (req, res) => {
  try {
    const query = `
      SELECT COUNT(DISTINCT cow_id) AS cows_fed
      FROM (
        SELECT cow_id FROM feed_hijauan WHERE date = CURRENT_DATE
        UNION
        SELECT cow_id FROM feed_sentrate WHERE date = CURRENT_DATE
      ) AS fed_cows;
    `;
    const result = await pool.query(query);
    res.json({ value: result.rows[0].cows_fed });
  } catch (err) {
    console.error(err);
    res.status(500).send('Server error');
  }
});

app.get('/api/cows/data/susu', async (req, res) => {
  try {
    const query = `
      SELECT SUM(production_amount) AS total_milk
      FROM milk_production
      WHERE date = CURRENT_DATE;
    `;
    const result = await pool.query(query);
    if (result.rows.length === 0) {
      return res.json({ value: 0 });
    }
    if (result.rows[0].total_milk === null) {
      return res.json({ value: 0 });
    }
    res.json({ value: result.rows[0].total_milk });
    console.log(result.rows[0].total_milk);
  } catch (err) {
    console.error(err);
    res.status(500).send('Server error');
  }
});


//-----------------------------------------------CHART-------------------------
app.get('/api/data/chart', async (req, res) => {
  try {
    const query = `
      SELECT
        date,
        COALESCE(SUM(hijauan_amount), 0) AS hijauan,
        COALESCE(SUM(sentrate_amount), 0) AS sentrate,
        COALESCE(SUM(milk_amount), 0) AS milk
      FROM (
        SELECT
          date,
          SUM(amount) AS hijauan_amount,
          0 AS sentrate_amount,
          0 AS milk_amount
        FROM feed_hijauan
        GROUP BY date
        UNION ALL
        SELECT
          date,
          0 AS hijauan_amount,
          SUM(amount) AS sentrate_amount,
          0 AS milk_amount
        FROM feed_sentrate
        GROUP BY date
        UNION ALL
        SELECT
          date,
          0 AS hijauan_amount,
          0 AS sentrate_amount,
          SUM(production_amount) AS milk_amount
        FROM milk_production
        GROUP BY date
      ) AS aggregated_data
      GROUP BY date
      ORDER BY date ASC;
    `;

    const result = await pool.query(query);


    // Format hasil query agar cocok dengan format frontend
    const formattedResult = result.rows.map(row => ({
      date: row.date, // Tanggal
      hijauan: parseFloat(row.hijauan), // Total hijauan
      sentrate: parseFloat(row.sentrate), // Total sentrat
      milk: parseFloat(row.milk), // Total susu
    }));

    res.json(formattedResult); // Kirimkan data ke frontend
  } catch (err) {
    console.error('Error fetching chart data:', err);
    res.status(500).send('Server error');
  }
});



// ---------------------------------------------------RECORDS--------------------------------------------------------------------
app.post('/api/records', async (req, res) => {
  try {
    const { hasilPerah, jumlahSapiSehat, beratHijauan, beratSentrat } = req.body;
    const timeNow = new Date(Date.now() + 7 * 60 * 60 * 1000);;

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


// ---------------------------------------------------ANALYTICS--------------------------------------------------------------------
app.get('/api/cluster', (req, res) => {
  exec('python kmeans.py', (err, stdout, stderr) => {
    if (err) {
      console.error('Error running Python script:', stderr);
      return res.status(500).json({ error: 'Error executing clustering analysis.' });
    }

    try {
      const bestCombinations = JSON.parse(stdout);
      res.json({ success: true, data: bestCombinations });
    } catch (parseError) {
      console.error('Error parsing Python output:', parseError);
      res.status(500).json({ error: 'Invalid JSON from Python script.' });
    }
  });
});

// Route untuk DBSCAN
app.get('/api/dbscan', (req, res) => {
  exec('python dbscan.py', (err, stdout, stderr) => {
    if (err) {
      console.error('Error running Python script:', stderr);
      return res.status(500).json({ error: 'Error executing DBSCAN analysis.' });
    }

    try {
      const bestCombinations = JSON.parse(stdout);
      if (bestCombinations.length === 0) {
        return res.status(404).json({ error: 'No best combinations found.' });
      }
      res.json({ success: true, data: bestCombinations });
    } catch (parseError) {
      console.error('Error parsing Python output:', parseError);
      res.status(500).json({ error: 'Invalid JSON from Python script.' });
    }
  });
});


// Endpoint untuk mendapatkan data produksi susu bulanan dan prediksi bulan depan
app.get('/api/predict/monthly', async (req, res) => {
  const query = `
    SELECT
      DATE_TRUNC('month', tanggal) AS bulan,
      SUM(produksi) AS total_produksi
    FROM
      public.produksi_susu
    GROUP BY
      DATE_TRUNC('month', tanggal)
    ORDER BY
      bulan ASC;
  `;

  try {
    // 1. Query data dari database
    const result = await poolTernaknesiaRelational.query(query);

    // Format data ke dalam bentuk JSON
    const data = result.rows.map(row => ({
      bulan: row.bulan.toISOString().slice(0, 7), // Format bulan menjadi "YYYY-MM"
      totalProduksi: Number(row.total_produksi),
    }));

    // 2. Ambil 3 data produksi terakhir untuk prediksi
    const last3Months = data.slice(-3).map(row => row.totalProduksi);

    if (last3Months.length < 3) {
      return res.status(400).json({
        success: false,
        error: 'Insufficient data for prediction. At least 3 months of data are required.',
      });
    }

    // 3. Kirim data ke Flask untuk prediksi
    const flaskResponse = await axios.post('http://127.0.0.1:5000/predict_monthly_milk', {
      last_3_months: last3Months,
    });

    // 4. Tambahkan hasil prediksi ke respons
    const prediction = flaskResponse.data.next_month_prediction;

    res.json({
      success: true,
      data,
      nextMonthPrediction: prediction, // Prediksi bulan depan
    });

  } catch (error) {
    console.error('Error:', error.message);
    res.status(500).json({
      success: false,
      error: error.message,
    });
  }
});


app.get('/api/predict/monthlyAsli2', async (req, res) => {
  const query = `
    SELECT
      DATE_TRUNC('month', tanggal) AS bulan,
      SUM(produksi) AS total_produksi
    FROM
      public.produksi_susu
    GROUP BY
      DATE_TRUNC('month', tanggal)
    ORDER BY
      bulan ASC;
  `;

  try {
    const result = await poolTernaknesiaRelational.query(query);

    // Format data ke dalam bentuk JSON
    const data = result.rows.map(row => ({
      bulan: row.bulan.toISOString().slice(0, 7), // Format bulan menjadi "YYYY-MM"
      totalProduksi: Number(row.total_produksi),
    }));

    // Kirimkan respons
    res.json({
      success: true,
      data,
    });
    
  } catch (error) {
    res.status(500).json({ error: 'Error while predicting monthly milk production' });
  }
});

app.post('/api/predict/monthlyAsli', async (req, res) => {
  try {
    const inputData = req.body;
    const flaskResponse = await axios.post("http://localhost:5000/predict_monthly_milk", inputData);
    res.json(flaskResponse.data);
  } catch (error) {
    res.status(500).json({ error: 'Error while predicting monthly milk production' });
  }
});


app.post('/api/predict/daily', async (req, res) => {
  try {
    const inputData = req.body;
    const flaskResponse = await axios.post("http://localhost:5000/predict_daily_milk", inputData);
    res.json(flaskResponse.data);
  } catch (error) {
    res.status(500).json({ error: 'Error while predicting daily milk production' });
  }
});

app.post('/api/classify/cattle', async (req, res) => {
  try {
    const cattleData = req.body; // Data sapi dari client
    const classifiedCattle = [];

    for (const cow of cattleData) {
      // Kirim data sapi satu per satu ke Flask API
      const flaskResponse = await axios.post("http://localhost:5000/predict_productivity", cow);
      classifiedCattle.push({
        ...cow,
        is_productive: flaskResponse.data.is_productive
      });
    }

    res.json(classifiedCattle); // Mengembalikan data sapi dengan prediksi
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Error while classifying cattle productivity' });
  }
});


app.post('/api/predict/productivity', async (req, res) => {
  try {
    const inputData = req.body;
    const flaskResponse = await axios.post("http://localhost:5000/predict_productivity", inputData);
    res.json(flaskResponse.data);
  } catch (error) {
    res.status(500).json({ error: 'Error while predicting productivity' });
  }
});


// ---------------------------------------------------------USERS---------------------------------------------------------------
app.post('/api/register', async (req, res) => {
  let { username, password, email, role, phone, cage_location } = req.body;


  // Validasi input
  if (!username || !password || !email || !role || !phone) {
    return res.status(400).json({ error: 'Missing required fields' });
  }

  try {
    // Hash password sebelum menyimpan ke database
    const hashedPassword = await bcrypt.hash(password, 10); // 10 adalah jumlah salt rounds

    // Query untuk menyimpan data
    if (cage_location === '') cage_location = 'null';
    const query = `
    INSERT INTO users (username, password, email, role, created_at, updated_at, phone, cage_location)
    VALUES ($1, $2, $3, $4, NOW(), NOW(), $5, $6) RETURNING id;`;

    const values = [username, hashedPassword, email, role, phone, cage_location];
    // Eksekusi query dan ambil hasilnya
    const result = await pool.query(query, values);

    // Mengirimkan response sukses dengan ID user yang baru
    res.status(201).json({ id: result.rows[0].id, message: 'User registered successfully' });
  } catch (err) {
    console.error('Error inserting data', err);
    res.status(500).json({ error: 'Internal server error' });
  }
});

app.post('/api/login', async (req, res) => {
  const { username, password } = req.body;

  if (!username || !password) {
    return res.status(400).json({ error: 'Username and password are required' });
  }

  try {
    // Query untuk mengambil user berdasarkan username
    const query = 'SELECT id, username, password, role, email, phone, cage_location FROM users WHERE username = $1';
    const result = await pool.query(query, [username]);


    // Jika user tidak ditemukan
    if (result.rows.length === 0) {
      return res.status(401).json({ error: 'Invalid username or password' });
    }

    const user = result.rows[0];

    // Verifikasi password yang dimasukkan dengan hash yang ada di database
    const match = await bcrypt.compare(password, user.password);

    if (!match) {
      return res.status(401).json({ error: 'Invalid username or password' });
    }

    // Jika password cocok, login berhasil
    res.status(200).json({ message: 'Login successful', userId: user.id, username: user.username, role: user.role, email: user.email, phone: user.phone, cage_location: user.cage_location });
  } catch (err) {
    console.error('Error logging in', err);
    res.status(500).json({ error: 'Internal server error' });
  }
});




// ---------------------------------------------------------SERVER---------------------------------------------------------------
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

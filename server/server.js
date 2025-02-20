const express = require("express");
const { exec } = require("child_process");
const bcrypt = require("bcrypt");
const cors = require("cors");
const axios = require("axios");
const moment = require("moment-timezone");
const { Pool } = require("pg");
const path = require("path");
const { title } = require("process");
const nowUtcPlus7 = moment.tz("Asia/Bangkok").format();


require('dotenv').config({ path: path.resolve(__dirname, '.env') });


const app = express();
app.use(express.json());

const PORT = process.env.PORT;
const SERVER_URL = process.env.SERVER_URL;

function isSameDay(date1, date2) {
  return (
    date1.getFullYear() === date2.getFullYear() &&
    date1.getMonth() === date2.getMonth() &&
    date1.getDate() === date2.getDate()
  );
}

let pool;

// PostgreSQL connection setup
if(process.env.NODE_ENV === 'production') {
  pool = new Pool({
    host: process.env.PGHOST,
    user: process.env.PGUSER,
    password: process.env.PGPASSWORD,
    database: process.env.PGDATABASE,
    // port: process.env.PGPORT,
    ssl: {
      rejectUnauthorized: false,
    },
  });

  poolTernaknesiaRelational = new Pool({
    user: process.env.PGUSER, // Ganti dengan username PostgreSQL Anda
    host: process.env.PGHOST, // Ganti dengan host PostgreSQL Anda
    database: process.env.PGDATABASE, // Ganti dengan nama database kedua Anda
    password: process.env.PGPASSWORD, // Ganti dengan password PostgreSQL Anda
    // port: process.env.PGPORT,
    ssl: {
      rejectUnauthorized: false,
    },
  });
}
else {
 pool = new Pool({
    host: process.env.PGHOST,
    user: process.env.PGUSER,
    password: process.env.PGPASSWORD,
    database: process.env.PGDATABASE,
    port: process.env.PGPORT,
  });

 poolTernaknesiaRelational = new Pool({
    user: process.env.PGUSER, // Ganti dengan username PostgreSQL Anda
    host: process.env.PGHOST, // Ganti dengan host PostgreSQL Anda
    database: process.env.PGDATABASE, // Ganti dengan nama database kedua Anda
    password: process.env.PGPASSWORD, // Ganti dengan password PostgreSQL Anda
    port: process.env.PGPORT,
  });
}

// Test the connection
// poolTernaknesiaRelational.connect();
pool.connect();

app.use(
  cors({
    origin: "*", // Mengizinkan semua domain, atau ganti dengan domain yang diizinkan
  })
);

//-------------------------------COWS----------------------------------------
app.get("/api/cattles-relational", async (req, res) => {
  try {
    const result = await poolTernaknesiaRelational.query("SELECT * FROM cows");
    const weightResult = await poolTernaknesiaRelational.query(
      "SELECT * FROM public.berat_badan ORDER BY cow_id, tanggal ASC"
    );
    const healthResult = await poolTernaknesiaRelational.query(
      "SELECT DISTINCT ON (cow_id) * FROM public.kesehatan_status ORDER BY cow_id, tanggal DESC"
    );

    const weightMap = new Map();
    weightResult.rows.forEach((weight) => {
      weightMap.set(weight.cow_id, weight.value);
    });

    const healthMap = new Map();
    healthResult.rows.forEach((health) => {
      healthMap.set(health.cow_id, health.value);
    });

    const hitungProduktivitas = async (cow_id) => {
      const dataSusu = await poolTernaknesiaRelational.query(
        "SELECT * FROM susu WHERE cow_id = $1 ORDER BY tanggal ASC",
        [cow_id]
      );

      const derivatif = [];
      for (let i = 1; i < dataSusu.rows.length; i++) {
        const beratSekarang = dataSusu.rows[i].produksi;
        const beratSebelum = dataSusu.rows[i - 1].produksi;
        const tanggalSekarang = new Date(dataSusu.rows[i].tanggal);
        const tanggalSebelum = new Date(dataSusu.rows[i - 1].tanggal);
        const selisihHari =
          (tanggalSekarang - tanggalSebelum) / (1000 * 3600 * 24);
        const derivatifSekarang = (beratSekarang - beratSebelum) / selisihHari;
        derivatif.push(derivatifSekarang);
      }

      const rataRataDerivatif =
        derivatif.reduce((a, b) => a + b, 0) / derivatif.length;

      return rataRataDerivatif > 0 ? true : false;
    };

    const formattedResult = await Promise.all(
      result.rows.map(async (cow) => ({
        id: cow.cow_id,
        weight: weightResult.rows.find(
          (weight) => String(weight.cow_id) === String(cow.cow_id)
        )?.value,
        age: cow.umur,
        gender: cow.gender,
        healthStatus: healthMap.get(cow.cow_id) || "unknown",
        isProductive: await hitungProduktivitas(cow.cow_id),
        isConnectedToNFCTag: cow.nfc_id !== null,
      }))
    );

    // Sort by cow_id
    formattedResult.sort((a, b) => a.id - b.id);

    res.json(formattedResult);
  } catch (err) {
    res.status(500).json({
      message: "Error fetching data from database",
      error: {
        name: err.name, // Error name (e.g., 'TypeError', 'QueryFailedError')
        message: err.message, // Error message
        stack: err.stack, // Error stack trace (can be removed in production for security)
      },
    });
  }
});

app.get("/api/cattles-relational/predict/:cow_id", async (req, res) => {
  const numpy = require("numpy");
  const { LinearRegression, LogisticRegression } = require("scikit-learn");

  // Inisialisasi model
  const modelLR = new LinearRegression();
  const modelLogR = new LogisticRegression();

  // Muat data dari database
  const data = await poolTernaknesiaRelational.query(
    "SELECT * FROM berat_badan"
  );

  // Persiapan data
  const X = data.rows.map((row) => [row.berat, row.umur]);
  const y = data.rows.map((row) => (row.produktif ? 1 : 0));

  // Latih model
  modelLR.fit(X, y);
  modelLogR.fit(X, y);

  try {
    const cow_id = req.params.cow_id;
    const sapiData = await poolTernaknesiaRelational.query(
      `SELECT * FROM cows WHERE cow_id = $1`,
      [cow_id]
    );

    if (!sapiData.rows[0]) {
      return res.status(404).json({ message: "Sapi tidak ditemukan" });
    }

    const sapi = sapiData.rows[0];
    const berat = weightMap.get(sapi.cow_id);
    const umur = sapi.umur;

    // Prediksi menggunakan model
    const prediction = modelLogR.predict([[berat, umur]]);

    res.json({ produktif: prediction[0] === 1 });
  } catch (err) {
    res.status(500).json({ message: "Error fetching data" });
  }
});

app.post("/api/cows/update-catatan/dokter", async (req, res) => {
  const { cow_id, catatan } = req.body;
  console.log("Catatan doker api call update", req.body);

  // Validasi data yang diterima
  if (!cow_id || !catatan) {
    return res
      .status(400)
      .json({ message: "Data cow_id dan catatan wajib diisi" });
  }

  try {
    // Mulai transaksi
    await poolTernaknesiaRelational.query("BEGIN");

    // Periksa apakah cow_id sudah ada
    const checkExistence = await poolTernaknesiaRelational.query(
      "SELECT 1 FROM catatan_dokter WHERE cow_id = $1",
      [cow_id]
    );

    let result;
    if (checkExistence.rows.length > 0) {
      // Update jika cow_id ditemukan
      result = await poolTernaknesiaRelational.query(
        `
        UPDATE catatan_dokter
        SET value = $2,
            tanggal = NOW()
        WHERE cow_id = $1
        RETURNING *;
        `,
        [cow_id, catatan]
      );
    } else {
      // Insert jika cow_id tidak ditemukan
      result = await poolTernaknesiaRelational.query(
        `
        INSERT INTO catatan_dokter (cow_id, tanggal, value)
        VALUES ($1, NOW(), $2)
        RETURNING *;
        `,
        [cow_id, catatan]
      );
    }

    // Selesaikan transaksi
    await poolTernaknesiaRelational.query("COMMIT");

    // Kirim respons jika berhasil
    res.status(201).json({
      message: "catatan dokter berhasil diperbarui atau ditambahkan",
      data: result.rows[0],
    });
  } catch (err) {
    // Rollback transaksi jika terjadi error
    await poolTernaknesiaRelational.query("ROLLBACK");
    res
      .status(500)
      .json({
        message: "Gagal memperbarui atau menambahkan catatan dokter",
        error: err.message
      });
  }
});


app.get("/api/cows/dokter-home", async (req, res) => {
  try {
    const result = await poolTernaknesiaRelational.query(`
WITH 
latest_kesehatan AS (
    SELECT 
        cow_id, 
        tanggal AS kesehatan_tanggal, 
        value,
        ROW_NUMBER() OVER (PARTITION BY cow_id ORDER BY tanggal DESC) AS rn
    FROM public.kesehatan_status
),
latest_catatan AS (
    SELECT 
        cow_id, 
        tanggal AS catatan_tanggal, 
        value,
        ROW_NUMBER() OVER (PARTITION BY cow_id ORDER BY tanggal DESC) AS rn
    FROM public.catatan_peternak
),
catatan_exists AS (
    SELECT DISTINCT cow_id
    FROM public.catatan_dokter
)
SELECT 
    c.cow_id,
    c.gender,
    c.umur,
    c.nfc_id,
    lc.value AS catatan_terakhir,
    lk.value AS kesehatan_terakhir,
    lk.kesehatan_tanggal AS tanggal_kesehatan_terakhir,
    CASE 
        WHEN ce.cow_id IS NOT NULL THEN true
        ELSE false
    END AS checked
FROM 
    public.cows c
JOIN 
    latest_kesehatan lk ON c.cow_id = lk.cow_id AND lk.rn = 1 AND lk.value = 'sakit'
LEFT JOIN 
    latest_catatan lc ON c.cow_id = lc.cow_id AND lc.rn = 1
LEFT JOIN 
    catatan_exists ce ON c.cow_id = ce.cow_id
ORDER BY 
    c.cow_id ASC;
`);

    // Format the result
    const formattedResponse = result.rows.map((row) => ({
      id: row.cow_id.toString(), // Format ID to 3 digits with leading zeros
      gender: row.gender, // Capitalize first letter
      info: row.catatan_terakhir || "Tidak ada catatan", // Default if no notes available
      checked: row.checked, // Value from query
      isConnectedToNFCTag: row.nfc_id !== null, // Determine connection to NFC tag
      age: row.umur.toString(), // Convert age in months to years
    }));

    res.json(formattedResponse);
  } catch (err) {
    res.status(500).json({ message: "Server error", error: err.message });
  }
});

app.get("/api/data/summary/dokter", async (req, res) => {
  try {
    const result = await poolTernaknesiaRelational.query(`
      WITH LatestStatus AS (
    SELECT 
        cow_id, 
        value, 
        tanggal
    FROM kesehatan_status
    WHERE (cow_id, tanggal) IN (
        SELECT 
            cow_id, 
            MAX(tanggal) AS latest_date
        FROM kesehatan_status
        GROUP BY cow_id
    )
)
SELECT 
    value,
    COUNT(*) AS total
FROM LatestStatus
GROUP BY value;
    `);

    res.json(
      result.rows.map((row) => ({
        status_kesehatan: row.value.toLowerCase(),
        total: row.total,

      }))
    );
  } catch (err) {
    res.status(500).json({ message: "Server error", error: err.message });
  }
});




app.post("/api/cows/kondisi/:id", async (req, res) => {
  const cowId = req.params.id; // Mendapatkan cow_id dari URL parameter
  const { stress_level, sakit, birahi, catatan } = req.body; // Mengambil data yang dikirim di body request
  console.log("Kondisi sapi api call update", req.body);

  const client = await poolTernaknesiaRelational.connect();

  try {
    await client.query("BEGIN"); // Mulai transaksi

    // Validasi data yang diterima (pastikan semua data yang diperlukan ada)
    if (
      sakit === undefined ||
      birahi === undefined ||
      stress_level === undefined
    ) {
      await client.query("ROLLBACK");
      console.log("Terdapat data tidak valid di kondisi ternak api post call, data:", sakit, birahi, stress_level);
      return res.status(400).json({ message: "Data tidak lengkap" });
    }

    // UPSERT untuk status kesehatan
    let healthUpdateResult = null;
    if (sakit && sakit.trim() !== "") {
      const upsertHealthQuery = `
      INSERT INTO public.kesehatan_status (cow_id, value, tanggal)
      VALUES ($1, $2, NOW() AT TIME ZONE 'UTC' + INTERVAL '7 hours')
      ON CONFLICT (cow_id, tanggal) DO UPDATE
      SET value = EXCLUDED.value, tanggal = NOW() AT TIME ZONE 'UTC' + INTERVAL '7 hours'
      RETURNING *;
    `;
      const healthUpdateResult = await client.query(upsertHealthQuery, [
        cowId,
        sakit,
      ]);
    }

    // UPSERT untuk level stres
    let stressLevelUpdateResult = null;
    if (stress_level && stress_level.trim() !== "") {
      const upsertStressLevelQuery = `
      INSERT INTO public.stress (cow_id, value, tanggal)
      VALUES ($1, $2, NOW() AT TIME ZONE 'UTC' + INTERVAL '7 hours')
      ON CONFLICT (cow_id, tanggal) DO UPDATE
      SET value = EXCLUDED.value, tanggal = NOW() AT TIME ZONE 'UTC' + INTERVAL '7 hours'
      RETURNING *;
    `;
      stressLevelUpdateResult = await client.query(upsertStressLevelQuery, [
        cowId,
        stress_level,
      ]);
    }

    // UPSERT untuk status birahi
    let birahiUpdateResult = null;
    if (birahi && birahi.trim() !== "") {
      upsertBirahiQuery = `
      INSERT INTO public.birahi (cow_id, value, tanggal)
      VALUES ($1, $2, NOW() AT TIME ZONE 'UTC' + INTERVAL '7 hours')
      ON CONFLICT (cow_id, tanggal) DO UPDATE
      SET value = EXCLUDED.value, tanggal = NOW() AT TIME ZONE 'UTC' + INTERVAL '7 hours'
      RETURNING *;
    `;
      birahiUpdateResult = await client.query(upsertBirahiQuery, [
        cowId,
        birahi,
      ]);
    }


    // UPSERT untuk catatan jika tidak kosong
    let catatanUpdateResult = null;
    if (catatan && catatan.trim() !== "") {
      const upsertCatatanQuery = `
        INSERT INTO public.catatan_peternak (cow_id, value, tanggal)
        VALUES ($1, $2, NOW() AT TIME ZONE 'UTC' + INTERVAL '7 hours')
        ON CONFLICT (cow_id, tanggal) DO UPDATE
        SET value = EXCLUDED.value, tanggal = NOW() AT TIME ZONE 'UTC' + INTERVAL '7 hours'
        RETURNING *;
      `;
      catatanUpdateResult = await client.query(upsertCatatanQuery, [
        cowId,
        catatan,
      ]);
    }

    // Commit transaksi jika semua berhasil
    await client.query("COMMIT");
    res.status(200).json({
      message: "Data kondisi ternak berhasil diperbarui",
      data: {
        kesehatan: healthUpdateResult ? healthUpdateResult.rows[0] : null,
        stress_level: stressLevelUpdateResult ? stressLevelUpdateResult.rows[0] : null,
        birahi: birahiUpdateResult ? birahiUpdateResult[0] : null,
        catatan: catatanUpdateResult ? catatanUpdateResult.rows[0] : null,
      },
    });
    console.log("API kondisi dari ternak berhasil diperbarui");
  } catch (err) {
    await client.query("ROLLBACK"); // Batalkan transaksi jika ada error
    console.error(err);
    res.status(500).json({ message: "Terjadi kesalahan saat mengupdate data" });
  } finally {
    client.release(); // Pastikan koneksi dilepas
  }
});

app.get("/api/cows", async (req, res) => {
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
  } catch (err) {
    res.status(500).json({ message: "Server error", error: err.message });
  }
});

app.get("/api/cows/:id", async (req, res) => {
  try {
    const { id } = req.params;

    // Ambil data sapi
    const cowQuery = "SELECT * FROM cows WHERE cow_id = $1";
    const cowResult = await poolTernaknesiaRelational.query(cowQuery, [id]);
    const cow = cowResult.rows[0];

    if (!cow) {
      return res.status(404).json({ message: "Cow not found" });
    }

    // Query data berat badan
    const weightQuery = `
      SELECT tanggal, value
      FROM berat_badan
      WHERE cow_id = $1
      ORDER BY tanggal DESC
      LIMIT 5
    `;
    const weightResult = await poolTernaknesiaRelational.query(weightQuery, [
      id,
    ]);
    const formattedWeights = weightResult.rows.map((row) => ({
      ...row,
      tanggal: moment
        .utc(row.tanggal)
        .tz("Asia/Jakarta")
        .format("YYYY-MM-DD HH:mm:ss"),
    }));

    // Query data produksi susu
    const milkQuery = `
      SELECT tanggal, value
      FROM susu
      WHERE cow_id = $1
      ORDER BY tanggal DESC
      LIMIT 5
    `;
    const milkResult = await poolTernaknesiaRelational.query(milkQuery, [id]);
    const formattedMilk = milkResult.rows.map((row) => ({
      ...row,
      tanggal: moment
        .utc(row.tanggal)
        .tz("Asia/Jakarta")
        .format("YYYY-MM-DD HH:mm:ss"),
    }));

    // Query data pakan hijauan
    const feedHijauanQuery = `
      SELECT tanggal, value
      FROM pakan_hijauan
      WHERE cow_id = $1
      ORDER BY tanggal DESC
      LIMIT 5
    `;
    const feedHijauanResult = await poolTernaknesiaRelational.query(
      feedHijauanQuery,
      [id]
    );
    const formattedFeedHijauan = feedHijauanResult.rows.map((row) => ({
      ...row,
      tanggal: moment
        .utc(row.tanggal)
        .tz("Asia/Jakarta")
        .format("YYYY-MM-DD HH:mm:ss"),
    }));

    // Query data pakan sentrat
    const feedSentrateQuery = `
      SELECT tanggal, value
      FROM pakan_sentrat
      WHERE cow_id = $1
      ORDER BY tanggal DESC
      LIMIT 5
    `;
    const feedSentrateResult = await poolTernaknesiaRelational.query(
      feedSentrateQuery,
      [id]
    );
    const formattedFeedSentrate = feedSentrateResult.rows.map((row) => ({
      ...row,
      tanggal: moment
        .utc(row.tanggal)
        .tz("Asia/Jakarta")
        .format("YYYY-MM-DD HH:mm:ss"),
    }));

    const stressLevelQuery = `
      SELECT tanggal, value
      FROM stress
      WHERE cow_id = $1
      ORDER BY tanggal DESC
      LIMIT 5
    `;

    const stressLevelResult = await poolTernaknesiaRelational.query(
      stressLevelQuery,
      [id]
    );
    const formattedStressLevel = stressLevelResult.rows.map((row) => ({
      ...row,
      tanggal: moment
        .utc(row.tanggal)
        .tz("Asia/Jakarta")
        .format("YYYY-MM-DD HH:mm:ss"),
    }));

    const birahiQuery = `
      SELECT tanggal, value
      FROM birahi
      WHERE cow_id = $1
      ORDER BY tanggal DESC
      LIMIT 5
    `;
    const birahiResult = await poolTernaknesiaRelational.query(birahiQuery, [
      id,
    ]);

    const formattedBirahi = birahiResult.rows.map((row) => ({
      ...row,
      tanggal: moment
        .utc(row.tanggal)
        .tz("Asia/Jakarta")
        .format("YYYY-MM-DD HH:mm:ss"),
    }));

    const kesehatanQuery = `
    SELECT tanggal, value
    FROM kesehatan_status
    WHERE cow_id = $1
    ORDER BY tanggal DESC
    LIMIT 5
  `;
    const kesehatanResult = await poolTernaknesiaRelational.query(
      kesehatanQuery,
      [id]
    );
    const formattedKesehatan = kesehatanResult.rows.map((row) => ({
      ...row,
      tanggal: moment
        .utc(row.tanggal)
        .tz("Asia/Jakarta")
        .format("YYYY-MM-DD HH:mm:ss"),
    }));

    const noteQuery = `
      SELECT tanggal, value
      FROM catatan_peternak
      WHERE cow_id = $1
      ORDER BY tanggal DESC
      LIMIT 5
    `;
    const noteResult = await poolTernaknesiaRelational.query(noteQuery, [id]);
    const formattedNotes = noteResult.rows.map((row) => ({
      ...row,
      tanggal: moment
        .utc(row.tanggal)
        .tz("Asia/Jakarta")
        .format("YYYY-MM-DD HH:mm:ss"),
    }));

    const catatan_dokterQuery = `
      SELECT tanggal, value
      FROM catatan_dokter
      WHERE cow_id = $1
      ORDER BY tanggal DESC
      LIMIT 5
    `;
    const catatan_dokterResult = await poolTernaknesiaRelational.query(
      catatan_dokterQuery,
      [id]
    );
    const formattedCatatanDokter = catatan_dokterResult.rows.map((row) => ({
      ...row,
      tanggal: moment
        .utc(row.tanggal)
        .tz("Asia/Jakarta")
        .format("YYYY-MM-DD HH:mm:ss"),
    }));


    res.json({
      ...cow,
      recent_weights: formattedWeights,
      recent_milk_production: formattedMilk,
      recent_feed_hijauan: formattedFeedHijauan,
      recent_feed_sentrate: formattedFeedSentrate,
      recent_stress_level: formattedStressLevel,
      recent_birahi: formattedBirahi,
      recent_notes: formattedNotes,
      recent_kesehatan: formattedKesehatan,
      recent_diagnosis: formattedCatatanDokter,
    });
  } catch (err) {
    res.status(500).json({ message: "Server error", error: err.message });
  }
});


app.get("/api/cows/predict-milk/:id", async (req, res) => {
  try {
    const { id } = req.params;

    // Ambil data value susu dari database
    const result = await poolTernaknesiaRelational.query(
      "SELECT id, cow_id, tanggal, value FROM susu WHERE cow_id = $1 ORDER BY tanggal DESC LIMIT 3",
      [id]
    );

    if (result.rows.length < 3) {
      return res.status(400).json({
        message:
          "Not enough data for prediction. At least 3 records are required.",
      });
    }

    // Format data untuk dikirim ke Flask
    var last_3_days = result.rows.map((row) => row.value);
    var flaskResponse;
    console.log("Last 3 days:", last_3_days);

    try {
      // Kirim data ke Flask menggunakan axios
       flaskResponse = await axios.put(
      "http://127.0.0.1:5000/susu-harian",
      {
        last_3_days: last_3_days,
      },
      {
        headers: {
        "Content-Type": "application/json", // Set content type to application/json
        },
      }
      );

      // Log the Flask response
      console.log("Flask response: ", flaskResponse.data);
    } catch (error) {
      // Handle errors (e.g., network issues, Flask server errors)
      console.error("Error sending data to Flask:", error.message);
    }

    // Gabungkan data asli dengan hasil prediksi
    const predicted_daily_milk = flaskResponse.data.result;

    res.json({
      data: result.rows,
      predicted_daily_milk: predicted_daily_milk,
    });
  } catch (err) {
    res.status(500).json({ message: "Server error", error: err.message });
  }
});

app.get("/api/cows/milk-production/:id", async (req, res) => {
  try {
    const { id } = req.params;
    const result = await poolTernaknesiaRelational.query(
      "SELECT * FROM susu WHERE cow_id = $1",
      [id]
    );
    res.json(result.rows);
  } catch (err) {
    res.status(500).json({ message: "Server error", error: err.message });
  }
});

app.post("/api/cows/tambahsapi", async (req, res) => {
  const { gender, age, weight, health } = req.body; // Tidak perlu menerima `id` karena akan di-generate otomatis

  const client = await poolTernaknesiaRelational.connect(); // Dapatkan koneksi database untuk transaksi

  try {
    // Mulai transaksi
    await client.query("BEGIN");

    const lowerCaseGender = gender.toLowerCase(); // Pastikan gender diubah menjadi lowercase

    // Query untuk menambahkan sapi ke tabel cows
    const insertCowQuery =
      "INSERT INTO cows (gender, umur) VALUES ($1, $2) RETURNING *";
    const cowResult = await client.query(insertCowQuery, [
      lowerCaseGender,
      age,
    ]);

    const cowId = cowResult.rows[0].cow_id; // Ambil cow_id yang dihasilkan secara otomatis

    // Query untuk menambahkan berat badan sapi ke tabel berat_badan
    const insertWeightQuery =
      "INSERT INTO berat_badan (cow_id, tanggal, value) VALUES ($1, $2, $3) RETURNING *";
    const weightResult = await client.query(insertWeightQuery, [
      cowId,
      new Date(),
      weight,
    ]);

    // Query untuk menambahkan status kesehatan ke tabel kesehatan
    const healthLower = health.toLowerCase(); // Pastikan status kesehatan diubah menjadi lowercase
    const insertHealthQuery =
      "INSERT INTO kesehatan_status (cow_id, tanggal, value) VALUES ($1, $2, $3) RETURNING *";
    const healthResult = await client.query(insertHealthQuery, [
      cowId,
      new Date(),
      healthLower,
    ]);

    // Komit transaksi jika semua berhasil
    await client.query("COMMIT");

    // Kirimkan response jika semua berhasil
    res.status(201).json({
      message: "Cow, weight, and health record added successfully",
      cow: cowResult.rows[0],
      weight: weightResult.rows[0],
      health: healthResult.rows[0],
    });
  } catch (err) {
    // Rollback jika terjadi error
    await client.query("ROLLBACK");

    res.status(500).json({
      message: "Error adding cow, weight, and health record",
      error: err.message,
    });
  } finally {
    // Pastikan koneksi database dilepaskan
    client.release();
  }
});



app.post("/api/cows/tambahsapi", async (req, res) => {
  const { id, gender, age, weight, healthRecord } = req.body; // Make sure 'id' is provided in the body

  if (!id) {
    return res.status(400).json({ message: "cow_id (id) is required" });
  }
  try {
    const result = await pool.query(
      "INSERT INTO cows (cow_id, gender, age, health_record) VALUES ($1, $2, $3, $4) RETURNING *",
      [id, gender, age, healthRecord]
    );

    // Setelah itu, masukkan data weight ke tabel body_weight dengan cow_id yang sudah didapatkan
    const insertWeightResult = await pool.query(
      "INSERT INTO body_weight (cow_id, date, weight) VALUES ($1, $2, $3) RETURNING *",
      [id, new Date(), weight]
    );

    res.status(201).json({ message: "Cow added", cow: result.rows[0] });
  } catch (err) {
    res.status(500).json({ message: "Server error", error: err.message });
  }
});

app.post("/api/cows/tambahdata/:id", async (req, res) => {
  const { id } = req.params; // cow_id
  const data = req.body; // Data dalam bentuk {key: value}
  const key = Object.keys(data)[0];
  const value = data[key];

  if (!data || !key || !value) {
    return res.status(400).json({ message: "Invalid data in request body" });
  }

  const queries = {
    produksiSusu: `
      INSERT INTO susu(cow_id, tanggal, value)
      VALUES($1, CURRENT_DATE, $2)
      ON CONFLICT(cow_id, tanggal)
      DO UPDATE SET value = EXCLUDED.value
      RETURNING *;
    `,
    beratBadan: `
      INSERT INTO berat_badan(cow_id, tanggal, value)
      VALUES($1, CURRENT_DATE, $2)
      ON CONFLICT(cow_id, tanggal)
      DO UPDATE SET value = EXCLUDED.value
      RETURNING *;
    `,
    pakanHijau: `
      INSERT INTO pakan_hijauan(cow_id, tanggal, value)
      VALUES($1, CURRENT_DATE, $2)
      ON CONFLICT(cow_id, tanggal)
      DO UPDATE SET value = EXCLUDED.value
      RETURNING *;
    `,
    pakanSentrat: `
      INSERT INTO pakan_sentrat(cow_id, tanggal, value)
      VALUES($1, CURRENT_DATE, $2)
      ON CONFLICT(cow_id, tanggal)
      DO UPDATE SET value = EXCLUDED.value
      RETURNING *;
    `,
  };

  const query = queries[key];

  if (!query) {
    return res.status(400).json({ message: "Invalid data key" });
  }

  try {
    const result = await poolTernaknesiaRelational.query(query, [id, value]);
    if (result.rows.length === 0) {
      return res.status(404).json({ message: "Database error" });
    }
    res
      .status(201)
      .json({ message: `${key} data added`, data: result.rows[0] });
  } catch (err) {
    res.status(500).json({ message: "Server error", error: err.message });
  }
});

app.put("/api/cows/updatedata/:id", async (req, res) => {
  const { id } = req.params; // cow_id
  const body = req.body;
  let tanggal = body.tanggal;
  const formattedDate = new Date(tanggal).toISOString().split("T")[0];
  const data = body.data;
  const key = body.key;



  if (!data || !key || !tanggal || !id) {
    console.log("Invalid data in request body api/cows/updatedata/:id");
    console.log("Here is the details: ", { id, data, key, tanggal });
    return res.status(400).json({ message: "Invalid data in request body" });
  }


  const queries = {
    produksi_susu: `
      UPDATE susu
      SET value = $2
      WHERE cow_id = $1 AND tanggal = $3
      RETURNING *;
    `,
    berat_badan: `
      UPDATE berat_badan
      SET value = $2
      WHERE cow_id = $1 AND tanggal = $3
      RETURNING *;
    `,
    pakan_hijau: `
      UPDATE pakan_hijauan
      SET value = $2
      WHERE cow_id = $1 AND tanggal = $3
      RETURNING *;
    `,
    pakan_sentrat: `
      UPDATE pakan_sentrat
      SET value = $2
      WHERE cow_id = $1 AND tanggal = $3
      RETURNING *;
    `,
    birahi: `
      UPDATE birahi
      SET value = $2
      WHERE cow_id = $1 AND tanggal = $3
      RETURNING *;
    `,
    kesehatan: `
      INSERT INTO kesehatan_status (cow_id, value, tanggal)
VALUES ($1, $2, $3)
ON CONFLICT (cow_id, tanggal) DO UPDATE
SET value = EXCLUDED.value
RETURNING *;
    `,
    stress_level: `
      INSERT INTO stress (cow_id, value, tanggal)
VALUES ($1, $2, $3)
ON CONFLICT (cow_id, tanggal) DO UPDATE
SET value = EXCLUDED.value
RETURNING *;
`,
    catatan: `
      INSERT INTO catatan_peternak (cow_id, value, tanggal)
VALUES ($1, $2, $3)
ON CONFLICT (cow_id, tanggal) DO UPDATE
SET value = EXCLUDED.value
RETURNING *;
`,

    pengobatan: `
      INSERT INTO catatan_dokter (cow_id, value, tanggal)
VALUES ($1, $2, $3)
ON CONFLICT (cow_id, tanggal) DO UPDATE
SET value = EXCLUDED.value
RETURNING *;
`,
  };

  const query = queries[key];
  console.log("Query: ", query);

  if (!query) {
    console.log("Invalid data key in request body api/cows/updatedata/:id");
    return res.status(400).json({ message: "Invalid data key" });
  }

  try {
    const result = await poolTernaknesiaRelational.query(query, [
      id,
      data,
      tanggal,
    ]);
    if (result.rows.length === 0) {
      console.log("Updatedata error: ", result);
      console.log("Parameters:", { id, data, tanggal });
      return res.status(404).json({ message: "Database error" });
    }
    res
      .status(200)
      .json({ message: `${key} data updated`, data: result.rows[0] });
  } catch (err) {
    console.log("Server error in request body api/cows/updatedata/:id");
    res.status(500).json({ message: "Server error", error: err.message });
  }
});

app.delete("/api/cows/deletedata/:id", async (req, res) => {
  const { id } = req.params;
  let { tanggal, key } = req.body;

  if (!tanggal || !key || !id) {
    console.error("Invalid data in request body", { id, tanggal, key });
    return res.status(400).json({
      message: "Missing required fields. Ensure 'tanggal', 'key', and 'id' are provided.",
    });
  }

  const formattedDate = moment(tanggal).format('YYYY-MM-DD');
  let date = formattedDate;
  tanggal = date;

  const queries = {
    produksi_susu: `
      DELETE FROM susu
      WHERE cow_id = $1 AND tanggal = $2
      RETURNING *;
    `,
    berat_badan: `
      DELETE FROM berat_badan
      WHERE cow_id = $1 AND tanggal = $2
      RETURNING *;
    `,
    pakan_hijau: `
      DELETE FROM pakan_hijauan
      WHERE cow_id = $1 AND tanggal = $2
      RETURNING *;
    `,
    pakan_sentrat: `
      DELETE FROM pakan_sentrat
      WHERE cow_id = $1 AND tanggal = $2
      RETURNING *;
    `,
    birahi: `
      DELETE FROM birahi
      WHERE cow_id = $1 AND tanggal = $2
      RETURNING *;
    `,
    kesehatan: `
      DELETE FROM kesehatan_status
      WHERE cow_id = $1 AND tanggal = $2
      RETURNING *;
    `,
    stress_level: `
      DELETE FROM stress
      WHERE cow_id = $1 AND tanggal = $2
      RETURNING *;
    `,
    catatan: `
      DELETE FROM catatan_peternak
      WHERE cow_id = $1 AND tanggal = $2
      RETURNING *;
    `,
    pengobatan: `
      DELETE FROM catatan_dokter
      WHERE cow_id = $1 AND tanggal = $2
      RETURNING *;
    `,
  };

  const query = queries[key];

  if (!query) {
    console.error("Invalid data key in request body");
    return res.status(400).json({ message: "Invalid data key" });
  }

  try {
    const result = await poolTernaknesiaRelational.query(query, [id, formattedDate]);
    if (result.rows.length === 0) {
      console.error("Delete data error", { id, tanggal, key });
      console.error("Delete data error result", result);
      return res.status(404).json({ message: "Data not found or already deleted" });
    }
    res
      .status(200)
      .json({ message: `${key} data deleted`, data: result.rows[0] });
  } catch (err) {
    console.error("Server error", err.message);
    res.status(500).json({ message: "Server error", error: err.message });
  }
});


app.get("/api/cows/data/sapi_diperah", async (req, res) => {
  try {
    const query = `
      SELECT COUNT(DISTINCT cow_id) AS cows_milked
      FROM susu
      WHERE tanggal = CURRENT_DATE;
  `;
    const result = await poolTernaknesiaRelational.query(query);
    res.json({ value: result.rows[0].cows_milked });
  } catch (err) {
    res.status(500).send("Server error");
  }
});

app.get("/api/cows/data/sapi_diperah", async (req, res) => {
  try {
    const query = `
      SELECT COUNT(DISTINCT cow_id) AS cows_milked
      FROM milk_production
      WHERE date = CURRENT_DATE;
  `;
    const result = await pool.query(query);
    res.json({ value: result.rows[0].cows_milked });
  } catch (err) {
    res.status(500).send("Server error");
  }
});

app.get("/api/cows/data/sapi_diberi_pakan", async (req, res) => {
  try {
    const query = `
      SELECT COUNT(DISTINCT cow_id) AS cows_fed
  FROM(
    SELECT cow_id FROM pakan_hijauan WHERE tanggal = CURRENT_DATE
        UNION
        SELECT cow_id FROM pakan_sentrat WHERE tanggal = CURRENT_DATE
  ) AS fed_cows;
  `;
    const result = await poolTernaknesiaRelational.query(query);
    res.json({ value: result.rows[0].cows_fed });
  } catch (err) {
    res.status(500).send("Server error");
  }
});

app.get("/api/cows/data/susu", async (req, res) => {
  try {
    const query = `
      SELECT SUM(value) AS total_milk
      FROM susu
      WHERE tanggal = CURRENT_DATE;
  `;
    const result = await poolTernaknesiaRelational.query(query);
    if (result.rows.length === 0) {
      return res.json({ value: 0 });
    }
    if (result.rows[0].total_milk === null) {
      return res.json({ value: 0 });
    }
    res.json({ value: result.rows[0].total_milk });
  } catch (err) {
    res.status(500).send("Server error");
  }
});

app.get("/api/cows/data/susu", async (req, res) => {
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
  } catch (err) {
    res.status(500).send("Server error");
  }
});

//-----------------------------------------------CHART-------------------------
app.get("/api/data/chart", async (req, res) => {
  try {
    const query = `
  SELECT
  date,
    COALESCE(SUM(hijauan_amount), 0) AS hijauan,
      COALESCE(SUM(sentrate_amount), 0) AS sentrate,
        COALESCE(SUM(milk_amount), 0) AS milk
  FROM(
    SELECT
          tanggal AS date,
    SUM(value) AS hijauan_amount,
    0 AS sentrate_amount,
    0 AS milk_amount
        FROM pakan_hijauan
        GROUP BY date
        UNION ALL
        SELECT
          tanggal AS date,
    0 AS hijauan_amount,
    SUM(value) AS sentrate_amount,
    0 AS milk_amount
        FROM pakan_sentrat
        GROUP BY tanggal
        UNION ALL
        SELECT
          tanggal AS date,
    0 AS hijauan_amount,
    0 AS sentrate_amount,
    SUM(value) AS milk_amount
        FROM susu
        GROUP BY date
  ) AS aggregated_data
      GROUP BY date
      ORDER BY date ASC;
  `;

    const result = await poolTernaknesiaRelational.query(query);

    // Format hasil query agar cocok dengan format frontend
    const formattedResult = result.rows.map((row) => ({
      date: row.date, // Tanggal
      hijauan: parseFloat(row.hijauan), // Total hijauan
      sentrate: parseFloat(row.sentrate), // Total sentrat
      milk: parseFloat(row.milk), // Total susu
    }));

    res.json(formattedResult); // Kirimkan data ke frontend
  } catch (err) {
    res.status(500).send("Server error");
  }
});

// ---------------------------------------------------RECORDS--------------------------------------------------------------------
app.post("/api/records", async (req, res) => {
  try {
    const { hasilPerah, jumlahSapiSehat, beratHijauan, beratSentrat } =
      req.body;
    const timeNow = new Date(Date.now() + 7 * 60 * 60 * 1000);

    // Cek record terakhir
    let record = await Record.findOne();

    if (!record) {
      // Jika tidak ada record, buat record baru
      record = new Record({
        hasilPerah: [],
        jumlahSapiSehat: [],
        beratHijauan: [],
        beratSentrat: [],
      });
    }

    // Fungsi untuk menambahkan atau memperbarui data
    const addOrUpdateData = (array, newValue) => {
      const lastEntry = array[array.length - 1];
      if (!lastEntry) {
        // Jika array kosong, tambahkan entry baru
        array.push({ nilai: newValue, timestamp: timeNow });
      } else if (
        isSameDay(new Date(lastEntry.timestamp), timeNow) &&
        timeNow > new Date(lastEntry.timestamp)
      ) {
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
    };
    const addNewData2 = (array, newValue) => {
      const lastEntry = array[array.length - 1];
      {
        const nextDay = new Date(timeNow);
        nextDay.setDate(nextDay.getDate() + 3);
        array.push({ nilai: newValue, timestamp: nextDay });
      }
    };

    // Tambahkan data baru ke masing-masing array
    if (hasilPerah !== undefined)
      addOrUpdateData(record.hasilPerah, hasilPerah);
    if (jumlahSapiSehat !== undefined)
      addOrUpdateData(record.jumlahSapiSehat, jumlahSapiSehat);
    if (beratHijauan !== undefined)
      addOrUpdateData(record.beratHijauan, beratHijauan);
    if (beratSentrat !== undefined)
      addOrUpdateData(record.beratSentrat, beratSentrat);
    // addNewData2(record.jumlahSapiSehat, jumlahSapiSehat);

    await record.save();
    res.status(201).json({ message: "Record updated", record: record });
  } catch (err) {
    res
      .status(500)
      .json({ message: "Server error", error: err.message, req: req.body });
  }
});

// ---------------------------------------------------ANALYTICS--------------------------------------------------------------------
app.get("/api/cluster", async (req, res) => {
  try {
    const flaskResponse = await axios.get(
      "http://localhost:5000/get-optimal-feed"
    );

    const data = flaskResponse.data;

    if (data["status"] == "success") {
      const optimalFeed = {
        success: true,
        data: {
          hijauan_weight: data["optimal_pakan_hijauan"],
          sentrat_weight: data["optimal_pakan_sentrat"],
          max_milk_production: data["max_milk_production"],
        },
      };

      res.json(optimalFeed);
    } else {
      res
        .status(500)
        .json({ error: "Error while predicting monthly milk production" });
    }
  } catch (error) {
    res
      .status(500)
      .json({ error: "Error while predicting monthly milk production" });
  }
});

app.get("/api/cluster", (req, res) => {
  exec("python kmeans.py", (err, stdout, stderr) => {
    if (err) {
      return res
        .status(500)
        .json({ error: "Error executing clustering analysis." });
    }

    try {
      const bestCombinations = JSON.parse(stdout);
      res.json({ success: true, data: bestCombinations });
    } catch (parseError) {
      res.status(500).json({ error: "Invalid JSON from Python script." });
    }
  });
});

// Route untuk DBSCAN
app.get("/api/dbscan", (req, res) => {
  exec("python dbscan.py", (err, stdout, stderr) => {
    if (err) {
      return res
        .status(500)
        .json({ error: "Error executing DBSCAN analysis." });
    }

    try {
      const bestCombinations = JSON.parse(stdout);
      if (bestCombinations.length === 0) {
        return res.status(404).json({ error: "No best combinations found." });
      }
      res.json({ success: true, data: bestCombinations });
    } catch (parseError) {
      res.status(500).json({ error: "Invalid JSON from Python script." });
    }
  });
});

app.get("/api/predict/monthly", async (req, res) => {
  const query = `
  SELECT
    DATE_TRUNC('month', tanggal) AS bulan,
    SUM(value) AS total_produksi
  FROM
    public.susu
  GROUP BY
    DATE_TRUNC('month', tanggal)
  ORDER BY
    bulan DESC
  LIMIT 8;
  `;

  try {
    const result = await poolTernaknesiaRelational.query(query);

    const data = result.rows.map((row) => ({
      bulan: row.bulan.toISOString().slice(0, 7),
      totalProduksi: Number(row.total_produksi),
    })).reverse();
    console.log(data);

    const last3Months = data.slice(-3).map((row) => row.totalProduksi);

    let prediction = 0;

    try {
      const flaskResponse = await axios.post(
      "http://127.0.0.1:5000/predict_monthly_milk",
      {
        last_3_months: last3Months,
      }
      );
      prediction = flaskResponse.data.next_month_prediction;
    } catch (error) {
      console.error("Error predicting monthly milk production:", error.message);
    }

    res.json({
      success: true,
      data,
      nextMonthPrediction: prediction,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      error: error.message,
    });
  }
});

app.post("/api/predict/daily", async (req, res) => {
  try {
    const inputData = req.body;
    const flaskResponse = await axios.post(
      "http://localhost:5000/predict_daily_milk",
      inputData
    );
    res.json(flaskResponse.data);
  } catch (error) {
    res
      .status(500)
      .json({ error: "Error while predicting daily milk production" });
  }
});

app.post("/api/data/nfc", async (req, res) => {
  const nfc_id = req.body.nfc_id;
  try {
    const query = `
WITH LatestWeight AS(
    SELECT
        bb.cow_id,
    bb.berat,
    bb.tanggal,
    ROW_NUMBER() OVER(PARTITION BY bb.cow_id ORDER BY bb.tanggal DESC) AS rn
    FROM public.berat_badan bb
  ),
    LatestHealth AS(
      SELECT
        k.cow_id,
      k.status_kesehatan,
      k.tanggal,
      ROW_NUMBER() OVER(PARTITION BY k.cow_id ORDER BY k.tanggal DESC) AS rn
    FROM public.kesehatan k
    )
  SELECT
  c.cow_id AS id,
    lw.berat AS weight,
      c.umur AS age,
        c.gender,
        lh.status_kesehatan AS healthStatus,
          c.nfc_id
  FROM
  public.cows c
LEFT JOIN LatestWeight lw ON c.cow_id = lw.cow_id AND lw.rn = 1
LEFT JOIN LatestHealth lh ON c.cow_id = lh.cow_id AND lh.rn = 1
  WHERE
  c.nfc_id LIKE $1;
  `;

    const result = await poolTernaknesiaRelational.query(query, [
      `% ${nfc_id}% `,
    ]);

    // Map hasil query ke format yang diminta
    const response = result.rows.map((row) => ({
      id: row.id,
      weight: row.weight || null,
      age: row.age || null,
      gender: row.gender || null,
      healthStatus: row.healthstatus || null,
      isProductive: false,
      isConnectedToNFCTag: row.nfc_id !== null, // Mengatur true jika nfc_id tidak null
      nfc_id: row.nfc_id || nfc_id, // Menggunakan nilai dari database jika tersedia, jika tidak, gunakan input
    }));

    res.json(response);
  } catch (error) {
    res.status(500).json({ error: "Error while fetching NFC data" });
  }
});
// NFC + JWT
app.post("/api/data/nfc/jwt", async (req, res) => {
  const nfc_id = req.body.nfc_id;
  try {
    const query = `
WITH LatestWeight AS(
    SELECT
        bb.cow_id,
    bb.berat,
    bb.tanggal,
    ROW_NUMBER() OVER(PARTITION BY bb.cow_id ORDER BY bb.tanggal DESC) AS rn
    FROM public.berat_badan bb
  ),
    LatestHealth AS(
      SELECT
        k.cow_id,
      k.status_kesehatan,
      k.tanggal,
      ROW_NUMBER() OVER(PARTITION BY k.cow_id ORDER BY k.tanggal DESC) AS rn
    FROM public.kesehatan k
    )
  SELECT
  c.cow_id AS id,
    lw.berat AS weight,
      c.umur AS age,
        c.gender,
        lh.status_kesehatan AS healthStatus,
          c.nfc_id
  FROM
  public.cows c
LEFT JOIN LatestWeight lw ON c.cow_id = lw.cow_id AND lw.rn = 1
LEFT JOIN LatestHealth lh ON c.cow_id = lh.cow_id AND lh.rn = 1
  WHERE
  c.nfc_id LIKE $1;
  `;

    const result = await poolTernaknesiaRelational.query(query, [
      `% ${nfc_id}% `,
    ]);

    // Map hasil query ke format yang diminta
    const response = result.rows.map((row) => ({
      id: row.id,
      weight: row.weight || null,
      age: row.age || null,
      gender: row.gender || null,
      healthStatus: row.healthstatus || null,
      isProductive: false,
      isConnectedToNFCTag: row.nfc_id !== null, // Mengatur true jika nfc_id tidak null
      nfc_id: row.nfc_id || nfc_id, // Menggunakan nilai dari database jika tersedia, jika tidak, gunakan input
    }));

    res.json(response);
  } catch (error) {
    res.status(500).json({ error: "Error while fetching NFC data" });
  }
});
  

app.post("/api/cows/update-nfc", async (req, res) => {
  const { cow_id, nfc_id } = req.body;

  // Validasi input
  if (!cow_id || !nfc_id) {
    return res.status(400).json({ error: "cow_id and nfc_id are required" });
  }

  try {
    // Query update nfc_id
    const query = `
      UPDATE cows
      SET nfc_id = $1
      WHERE cow_id = $2
      RETURNING *;
    `;
    const values = [nfc_id, cow_id];

    const result = await poolTernaknesiaRelational.query(query, values);

    if (result.rowCount === 0) {
      return res.status(404).json({ error: "Cow not found" });
    }

    res.status(200).json({
      message: "NFC ID updated successfully",
      cow: result.rows[0],
    });
  } catch (err) {
    res.status(500).json({ error: "Internal server error" });
  }
});

app.post("/api/predict/productivity", async (req, res) => {
  try {
    const inputData = req.body;
    const flaskResponse = await axios.post(
      "http://localhost:5000/predict_productivity",
      inputData
    );
    res.json(flaskResponse.data);
  } catch (error) {
    res.status(500).json({ error: "Error while predicting productivity" });
  }
});

// ---------------------------------------------------------USERS---------------------------------------------------------------
app.post("/api/users/register", async (req, res) => {
  let { email, password, nama, no_hp, alamat, role } = req.body;

  // Validasi input
  if (!email || !password || !nama || !no_hp || !alamat || !role) {
    console.log("User registration failed: Missing required fields");
    return res.status(400).json({ error: "Missing required fields" });
  }

  // Validate password strength (example: minimum 8 characters)
  if (password.length < 8) {
    return res.status(400).json({ error: "Password must be at least 8 characters long" });
  }

  const client = await pool.connect();

  try {
    await client.query("BEGIN");

    // Check if email already exists
    const emailCheckQuery = "SELECT email FROM users WHERE email = $1";
    const emailCheckResult = await client.query(emailCheckQuery, [email]);

    if (emailCheckResult.rows.length > 0) {
      await client.query("ROLLBACK");
      return res.status(409).json({ error: "Email already exists" });
    }

    // Hash password sebelum menyimpan ke database
    const hashedPassword = await bcrypt.hash(password, 10); // 10 adalah jumlah salt rounds

    const query = `
      INSERT INTO users(nama, password, email, role, no_hp, alamat)
      VALUES($1, $2, $3, $4, $5, $6) RETURNING id;
    `;

    const values = [nama, hashedPassword, email, role, no_hp, alamat];

    const result = await client.query(query, values);

    await client.query("COMMIT");

    res.status(201).json({ id: result.rows[0].id, message: "User registered successfully" });
  } catch (err) {
    await client.query("ROLLBACK");
    console.error("Error while registering user:", err.stack); // Log the full error stack trace
    res.status(500).json({ error: "Internal server error" });
  } finally {
    client.release();
  }
});



app.post("/api/login", async (req, res) => {
  const { username, password } = req.body;

  if (!username || !password) {
    return res
      .status(400)
      .json({ error: "Username and password are required" });
  }

  try {
    // Query untuk mengambil user berdasarkan email (username)
    const query =
      "SELECT id, email, password, nama, role, no_hp, alamat FROM users WHERE email = $1";
    const result = await pool.query(query, [username]);

    // Jika user tidak ditemukan
    if (result.rows.length === 0) {
      return res.status(401).json({ error: "Invalid email" });
    }

    const user = result.rows[0];


    // Verifikasi password yang dimasukkan dengan hash yang ada di database
    const match = await bcrypt.compare(password, user.password);


    if (!match) {
      return res.status(401).json({ error: "Invalid password" });
    }

    // Jika password cocok, login berhasil
    res.status(200).json({
      message: "Login successful",
      userId: user.id,
      nama: user.nama,
      role: user.role,
      email: user.email,
      no_hp: user.no_hp,
      alamat: user.alamat,
    });
  } catch (err) {
    console.error("Error while logging in:", err.stack);
    res.status(500).json({ error: "Internal server error saat login" });
  }
});

app.put("/api/users/updateprofile", async (req, res) => {
  const { userId, username, email, phone, cageLocation } = req.body;

  if (!email) {
    return res.status(400).json({ error: "Email is required" });
  }

  const client = await pool.connect();

  try {
    await client.query("BEGIN");

    const query = `
      UPDATE users
      SET email = $1, no_hp = $2, alamat = $3
      WHERE email = $1
      RETURNING *;
    `;

    const values = [email, phone, cageLocation];
    const result = await client.query(query, values);

    if (result.rows.length === 0) {
      await client.query("ROLLBACK");
      return res.status(404).json({ error: "User not found" });
    }

    await client.query("COMMIT");
    res.json({ message: "Profile updated", user: result.rows[0] });
  } catch (err) {
    await client.query("ROLLBACK");
    console.error("Error while updating profile:", err.stack);
    res.status(500).json({ error: "Internal server error while updating profile" });
  } finally {
    client.release();
  }
});

// ---------------------------------------------------------SERVER---------------------------------------------------------------
app.use((err, req, res, next) => {
  res.status(500).json({
    error: "Internal Server Error",
    message: "Terjadi kesalahan pada server",
  });
});

// ---------------------------------------------------------FUNGSI---------------------------------------------------------------


// Check if server is running
app.get("/", (req, res) => {
  res.send("Server is running");
});

// Start server with full URL
app.listen(process.env.PORT, () => {
  console.log(`Server is running on port:${process.env.PORT}`);
});

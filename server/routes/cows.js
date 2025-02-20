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
const mongoose = require('mongoose');
const Cow = require('./models/cow'); // pastikan path ini mengarah ke model yang kamu buat
const faker = require('faker'); // gunakan faker untuk membuat data acak
require('dotenv').config();

// Fungsi untuk membuat data random sehat atau tidak
function getRandomBoolean() {
  return Math.random() >= 0.5; // Menghasilkan true atau false secara acak
}

// Fungsi untuk membuat data timestamp berurutan per hari
function generateTimestamps(startDate, count) {
  const timestamps = [];
  let currentDate = new Date(startDate);
  
  for (let i = 0; i < count; i++) {
    timestamps.push(new Date(currentDate));
    currentDate.setDate(currentDate.getDate() + 1); // Tambah 1 hari setiap iterasi
  }
  return timestamps;
}

// Fungsi untuk membuat data sapi dummy
function generateCowData() {
  const cows = [];
  
  // Ambil tanggal sekarang sebagai tanggal awal
  const startDate = new Date();
  
  // Buat 10 sapi
  for (let i = 0; i < 10; i++) {
    const cow = {
      health: [],
      birahi: [],
      hasilPerolehanSusu: [],
      beratPakanHijauan: [],
      beratPakanKonsentrat: [],
      hasilPerahSusu: [],
      tingkatStress: [],
      catatanTambahan: []
    };
    
    // Buat 30 catatan untuk setiap sapi dengan timestamp berurutan
    const timestamps = generateTimestamps(startDate, 30);
    
    for (let j = 0; j < 30; j++) {
      cow.health.push({
        sehat: getRandomBoolean(),
        timestamp: timestamps[j]
      });
      cow.birahi.push({
        birahi: getRandomBoolean(),
        timestamp: timestamps[j]
      });
      cow.hasilPerolehanSusu.push({
        hasil: faker.datatype.number({ min: 5, max: 15 }), // Angka hasil susu acak
        timestamp: timestamps[j]
      });
      cow.beratPakanHijauan.push({
        beratPakanHijauan: faker.datatype.number({ min: 20, max: 50 }), // Berat hijauan acak
        beratPakanKonsentrat: faker.datatype.number({ min: 5, max: 15 }), // Berat konsentrat acak
        timestamp: timestamps[j]
      });
      cow.hasilPerahSusu.push({
        hasil: faker.datatype.number({ min: 10, max: 20 }), // Hasil perah susu acak
        timestamp: timestamps[j]
      });
      cow.tingkatStress.push({
        stress: faker.random.arrayElement(['Rendah', 'Sedang', 'Tinggi']), // Stress acak
        timestamp: timestamps[j]
      });
      cow.catatanTambahan.push({
        note: faker.lorem.sentence(), // Catatan acak
        timestamp: timestamps[j]
      });
    }
    
    cows.push(cow);
  }
  
  return cows;
}

// Fungsi untuk menyimpan sapi ke database
async function saveCowsToDB() {
  try {
    const cows = generateCowData();
    await Cow.insertMany(cows);
    console.log('Data sapi berhasil disimpan ke database');
  } catch (error) {
    console.error('Gagal menyimpan sapi:', error);
  }
}

  mongoose.connect(process.env.MONGODB_URI)
  .then(() => {
    console.log('Connected to MongoDB');
    saveCowsToDB();
  })
  .catch(err => console.error('MongoDB connection error:', err));

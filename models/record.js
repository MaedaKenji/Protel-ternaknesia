const mongoose = require('mongoose');

const recordSchema = new mongoose.Schema({
  hasilPerah: [{
    nilai: Number,
    timestamp: { type: Date, default: Date.now }
  }],
  jumlahSapiSehat: [{
    nilai: Number,
    timestamp: { type: Date, default: Date.now }
  }],
  beratHijauan: [{
    nilai: Number,
    timestamp: { type: Date, default: Date.now }
  }],
  beratSentrat: [{
    nilai: Number,
    timestamp: { type: Date, default: Date.now }
  }],
  month: {
    type: String,
    required: true,
    enum: [
      'Januari', 'Februari', 'Maret', 'April', 'Mei',
      'Juni', 'Juli', 'Agustus', 'September',
      'Oktober', 'November', 'Desember'
    ]
  },
  year: {
    type: Number,
    required: true,
    min: 1900, // Anda dapat menyesuaikan batasan tahun sesuai kebutuhan
    max: new Date().getFullYear() // Batasan tahun maksimum adalah tahun saat ini
  },
  totalMilk: {
    type: Number,
    required: true,
    min: 0 // Nilai total susu tidak boleh negatif
  }
});

module.exports = mongoose.model('Record', recordSchema);
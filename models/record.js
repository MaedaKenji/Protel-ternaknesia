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
});

module.exports = mongoose.model('Record', recordSchema);

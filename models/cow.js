const mongoose = require('mongoose');

const recordSchema = new mongoose.Schema({
  hasil: {
    type: Number,
    required: true
  },
  timestamp: {
    type: Date,
    default: Date.now
  }
});

const stressRecordSchema = new mongoose.Schema({
  stress: {
    type: String,
    enum: ['Rendah', 'Sedang', 'Tinggi'],
    required: true
  },
  timestamp: {
    type: Date,
    default: Date.now
  }
});

const noteRecordSchema = new mongoose.Schema({
  note: {
    type: String,
    required: true
  },
  timestamp: {
    type: Date,
    default: Date.now
  }
});

const birahiRecordSchema = new mongoose.Schema({
  birahi: {
    type: Boolean,
    required: true
  },
  timestamp: {
    type: Date,
    default: Date.now
  }
});

const healthRecordSchema = new mongoose.Schema({
  sehat: {
    type: Boolean,
    required: true
  },
  timestamp: {
    type: Date,
    default: Date.now
  }
});



const pakanRecordSchema = new mongoose.Schema({
  beratPakanHijauan: {
    type: Number,
    required: true
  },
  beratPakanKonsentrat: {
    type: Number,
    required: true
  },
  timestamp: {
    type: Date,
    default: Date.now
  }
});

const cowSchema = new mongoose.Schema({
  health: [healthRecordSchema],
  birahi: [birahiRecordSchema],
  hasilPerolehanSusu: [recordSchema],
  beratPakanHijauan: [pakanRecordSchema],
  beratPakanKonsentrat: [pakanRecordSchema],
  hasilPerahSusu: [recordSchema],
  tingkatStress: [stressRecordSchema],
  catatanTambahan: [noteRecordSchema]
});

const Cow = mongoose.model('Cow', cowSchema);

module.exports = Cow;

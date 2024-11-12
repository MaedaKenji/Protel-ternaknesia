const { tr } = require('faker/lib/locales');
const mongoose = require('mongoose');


const stressRecordSchema = new mongoose.Schema({
  stress: {
    type: String,
    enum: ['Rendah', 'Sedang', 'Tinggi']
  },
  timestamp: {
    type: Date,
    default: Date.now
  }
});

const noteRecordSchema = new mongoose.Schema({
  note: {
    type: String
  },
  timestamp: {
    type: Date,
    default: Date.now
  }
});

const birahiRecordSchema = new mongoose.Schema({
  birahi: {
    type: Boolean
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
    type: Number
  },
  beratPakanKonsentrat: {
    type: Number,
    timestamp: {
      type: Date,
      default: Date.now
    }
  },
  timestamp: {
    type: Date,
    default: Date.now
  }
});


const beratAndSusuSchema = new mongoose.Schema({
  weight: {
    type: Number,
    required: true

  },
  perah: {
    type: Number,
    timestamp: {
      type: Date,
      default: Date.now
    }
  },
  timestamp: {
    type: Date,
    default: Date.now
  }
});


const cowSchema = new mongoose.Schema({
  id: {
    type: String,
    required: true
  },
  gender: {
    type: String,
    enum: ['Jantan', 'Betina'],
    required: true
  },
  age: {
    type: Number,
    required: true
  },
  isKandang: {
    type: Boolean,
    required: true,
    default: true
  },
  beratAndSusu: [beratAndSusuSchema],
  stressRecord: [stressRecordSchema],
  birahiRecord: [birahiRecordSchema],
  healthRecord: [healthRecordSchema],
  pakanRecord: [pakanRecordSchema],
  noteRecord: [noteRecordSchema],
});


const Cow = mongoose.model('Cow', cowSchema);

module.exports = Cow;

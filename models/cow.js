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

// const healthRecordSchema = new mongoose.Schema({
//   sehat: {
//     type: Boolean
//   },
//   timestamp: {
//     type: Date,
//     default: Date.now
//   }
// });

const healthRecordSchema = new mongoose.Schema({
  sehat: {
    type: Boolean,
    required: true
  }
});

const pakanRecordSchema = new mongoose.Schema({
  beratPakanHijauan: {
    type: Number
  },
  beratPakanKonsentrat: {
    type: Number
  },
  timestamp: {
    type: Date,
    default: Date.now
  }
});


const idSchema = new mongoose.Schema({
  id: {
    type: String,
    required: true
  }
});

const genderSchema = new mongoose.Schema({
  gender: {
    type: String,
    enum: ['Jantan', 'Betina'],
    required: true
  }
});

const ageSchema = new mongoose.Schema({
  age: {
    type: Number,
    required: true
  }
});


const weightSchema = new mongoose.Schema({
  weight: {
    type: Number,
    required: true
  }
});

const isKandangSchema = new mongoose.Schema({
  isKandang: {
    type: Boolean,
    required: true
  }
});

// const cowSchema = new mongoose.Schema({
//   id: idSchema,
//   gender: genderSchema,
//   age: ageSchema,
//   weight: weightSchema,
//   isKandang: isKandangSchema,
//   stressRecord: [stressRecordSchema],
//   birahiRecord: [birahiRecordSchema],
//   healthRecord: healthRecordSchema,
//   pakanRecord: [pakanRecordSchema],
//   noteRecord: [noteRecordSchema],
// });

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
  weight: {
    type: Number,
    required: true
  },
  isKandang: {
    type: Boolean,
    required: true,
    default: true
  },
  stressRecord: [stressRecordSchema],
  birahiRecord: [birahiRecordSchema],
  healthRecord: [healthRecordSchema],
  pakanRecord: [pakanRecordSchema],
  noteRecord: [noteRecordSchema],
});


const Cow = mongoose.model('Cow', cowSchema);

module.exports = Cow;

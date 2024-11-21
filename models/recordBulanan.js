const mongoose = require('mongoose');

const recordSchema = new mongoose.Schema({
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

const RecordBulanan = mongoose.model('RecordBulanan', recordSchema);

// Fungsi untuk memeriksa koleksi
async function checkCollectionConnection() {
    try {
        const data = await RecordBulanan.find();
        console.log("Connected to collection: RecordBulanan");
        console.log("Data from collection:", data);
        return data;
    } catch (error) {
        console.error("Failed to connect to collection or retrieve data:", error);
    }
}

// checkCollectionConnection(); // Panggil fungsi ini untuk memeriksa koneksi

module.exports = RecordBulanan;

const mongoose = require('mongoose');
const Record = require('./models/record'); // Pastikan path ini mengarah ke model yang kamu buat
require('dotenv').config();

// Fungsi untuk menginsert data ke database
const insertDataToDatabase = async (data) => {
    try {
        await Record.insertMany(data);
        console.log('Data berhasil diinsert ke database');
    } catch (err) {
        console.error('Error inserting data:', err);
    }
};

// Fungsi untuk menghasilkan data sementara
const generateTemporaryData = (year) => {
    const months = [
        { name: 'Januari' },
        { name: 'Februari' },
        { name: 'Maret' },
        { name: 'April' },
        { name: 'Mei' },
        { name: 'Juni' },
        { name: 'Juli' },
        { name: 'Agustus' },
        { name: 'September' },
        { name: 'Oktober' },
        { name: 'November' },
        { name: 'Desember' }
    ];

    // Mengisi data dengan nilai acak untuk setiap bulan
    const randomMilkData = months.map(month => {
        return {
            month: month.name,
            year: year,
            totalMilk: Math.floor(Math.random() * 2000) // Menghasilkan nilai acak antara 0 - 2000
        };
    });

    return randomMilkData;
};

// Fungsi utama untuk menjalankan script
const main = async () => {
    // Koneksi ke database
    try {
        await mongoose.connect(process.env.MONGODB_URI);
        console.log('Koneksi ke database berhasil');

        // Menghasilkan data sementara untuk tahun 2023
        const temporaryData = generateTemporaryData(2023);

        // Menginsert data ke database
        await insertDataToDatabase(temporaryData);
    } catch (err) {
        console.error('Error connecting to database:', err);
    } finally {
        // Menutup koneksi setelah selesai
        mongoose.connection.close();
    }
};

// Menjalankan fungsi utama
main();
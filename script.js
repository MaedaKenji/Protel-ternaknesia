// Import env
// Saya mau import env
require('dotenv').config();


// URL dari API
const apiUrl = `${process.env.BASE_URL}:${process.env.PORT}/api/cows/tambahdata`;
apiUrl);

// Fungsi untuk melakukan push data ke API
async function pushDataCow(id) {
    try {
        for (let i = 0; i < 10; i++) {
            // Buat data yang akan dikirim
            const data = {
                beratAndSusu: {
                    berat: 70 + i * 10,         // Contoh data berat
                    susu: 20 + i * 10           // Contoh data produksi susu
                },
                stressRecord: {
                    level: i % 2 === 0 ? 'Normal' : 'Tinggi',  // Contoh data stress level
                    tanggal: new Date().toISOString()          // Tanggal saat ini
                },
                birahiRecord: {
                    status: i % 3 === 0 ? 'Aktif' : 'Tidak',   // Contoh data birahi status
                    tanggal: new Date().toISOString()
                },
                healthRecord: {
                    status: i % 2 === 0 ? 'SEHAT' : 'SAKIT',   // Contoh data kesehatan
                    tanggal: new Date().toISOString()
                },
                pakanRecord: {
                    pakanHijau: 15 + i * 10,    // Contoh jumlah pakan hijauan
                    pakanSentrat: 10 + i * 10   // Contoh jumlah pakan sentrat
                },
                noteRecord: `Catatan ke-${i + 1}`  // Catatan
            };

            // Kirim request POST ke API dengan data yang telah dibuat
            `${apiUrl}/${id}`);
            const response = await fetch(`${apiUrl}/${id}`, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                },
                body: JSON.stringify(data)
            });

            if (!response.ok) {
                throw new Error(`Gagal mengirim data ke API. Status: ${response.status}`);
            }

            const result = await response.json();
            
        }
    } catch (error) {
        console.error('Error:', error);
    }
}

// Panggil fungsi dengan ID sapi yang diinginkan
pushDataCow('2');

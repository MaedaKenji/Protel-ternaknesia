import psycopg2
import time

# Konfigurasi koneksi PostgreSQL
db_config = {
    "dbname": "my_database",
    "user": "postgres",
    "password": "agus",
    "host": "127.0.0.1",  # Ganti sesuai dengan host Anda
    "port": 5432          # Port yang digunakan
}


def measure_connection_time():
    try:
        # Catat waktu mulai
        start_time = time.time()

        # Buat koneksi ke database
        conn = psycopg2.connect(**db_config)

        # Catat waktu selesai
        end_time = time.time()

        # Tutup koneksi
        conn.close()

        # Hitung durasi koneksi
        duration = end_time - start_time
        print(f"Koneksi berhasil. Waktu yang dibutuhkan: {
              duration:.4f} detik.")

    except Exception as e:
        print("Gagal terhubung ke database.")
        print(f"Error: {e}")


# Jalankan fungsi pengukuran
measure_connection_time()

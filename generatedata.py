import psycopg2
import random
from datetime import datetime, timedelta

# Fungsi untuk menghasilkan tanggal acak dalam rentang 3 bulan terakhir


# Fungsi untuk menghasilkan tanggal acak dalam rentang waktu tertentu
jumlah_sapi = 10
jumlah_data_per_sapi = 5

def generate_random_date(start_date, end_date):
    delta = end_date - start_date
    random_days = random.randint(0, delta.days)
    return start_date + timedelta(days=random_days)

# Fungsi untuk menghasilkan data berat badan


def generate_berat_badan_data(jumlah_sapi, jumlah_data_per_sapi):
    start_date = datetime(2023, 10, 1)
    end_date = datetime(2023, 12, 31)

    berat_badan_data = []
    for cow_id in range(1, jumlah_sapi + 1):
        for _ in range(jumlah_data_per_sapi):
            tanggal = generate_random_date(
                start_date, end_date).strftime('%Y-%m-%d')
            # Berat badan dalam rentang 300-700 kg
            berat_badan = round(random.uniform(300, 700), 2)
            berat_badan_data.append({
                "cow_id": cow_id,
                "tanggal": tanggal,
                "berat_badan": berat_badan
            })

    return berat_badan_data


# Menghasilkan data berat badan
berat_badan_data = generate_berat_badan_data(jumlah_sapi, jumlah_data_per_sapi)

# Menampilkan hasil
print("Data Berat Badan:")
for data in berat_badan_data:
    print(data)

def generate_random_date(start_date, end_date):
    delta = end_date - start_date
    random_days = random.randint(0, delta.days)
    return start_date + timedelta(days=random_days)

# Fungsi untuk menghasilkan data birahi
def generate_birahi_data(jumlah_sapi, jumlah_data_per_sapi):
    start_date = datetime(2023, 10, 1)  # Tanggal mulai
    end_date = datetime(2023, 12, 31)   # Tanggal akhir

    data_birahi = []
    for cow_id in range(1, jumlah_sapi + 1):
        for _ in range(jumlah_data_per_sapi):
            tanggal = generate_random_date(
                start_date, end_date).strftime('%Y-%m-%d')
            status_birahi = random.choice(['ya', 'tidak'])
            

            data_birahi.append({
                "cow_id": cow_id,
                "tanggal": tanggal,
                "status_birahi": status_birahi
            })

    return data_birahi


birahi_data = generate_birahi_data(10, 5)

# Menampilkan hasil data birahi
for data in birahi_data:
    print(data)
    

# Fungsi untuk menghasilkan catatan acak
def generate_random_note():
    notes = [
        "Sapi dalam kondisi sehat.",
        "Sapi memerlukan pemeriksaan lebih lanjut.",
        "Sapi menunjukkan tanda-tanda stres ringan.",
        "Sapi perlu diberi pakan tambahan.",
        "Sapi telah divaksinasi pada tanggal ini.",
        "Sapi dalam masa pemulihan setelah pengobatan.",
        "Tidak ada masalah yang ditemukan saat pemeriksaan.",
        "Sapi terlihat lebih aktif dari biasanya.",
        "Suhu tubuh sapi sedikit meningkat.",
        "Sapi telah diperiksa oleh dokter hewan."
    ]
    return random.choice(notes)

# Fungsi untuk menghasilkan data catatan


def generate_catatan_data(jumlah_sapi, jumlah_catatan_per_sapi):
    start_date = datetime(2023, 10, 1)  # Tanggal mulai
    end_date = datetime(2023, 12, 31)   # Tanggal akhir

    catatan_data = []
    for cow_id in range(1, jumlah_sapi + 1):
        for _ in range(jumlah_catatan_per_sapi):
            tanggal = generate_random_date(
                start_date, end_date).strftime('%Y-%m-%d')
            catatan = generate_random_note()

            catatan_data.append({
                "cow_id": cow_id,
                "tanggal": tanggal,
                "catatan": catatan
            })

    return catatan_data


# Menghasilkan data catatan
catatan_data = generate_catatan_data(10, 5)

# Menampilkan hasil data catatan
for data in catatan_data:
    print(data)
    
    
# Fungsi untuk menghasilkan catatan kesehatan acak
def generate_health_note(status_kesehatan):
    if status_kesehatan == "sehat":
        notes = [
            "Sapi dalam kondisi prima.",
            "Tidak ditemukan gejala penyakit.",
            "Pemeriksaan menunjukkan kesehatan yang baik.",
            "Sapi aktif dan nafsu makan bagus.",
            "Sapi dalam kondisi sehat tanpa masalah."
        ]
    else:
        notes = [
            "Sapi menunjukkan gejala demam.",
            "Ditemukan luka kecil pada kaki sapi.",
            "Sapi mengalami penurunan nafsu makan.",
            "Pemeriksaan menunjukkan tanda-tanda infeksi.",
            "Sapi dalam kondisi sakit dan perlu pengobatan."
        ]
    return random.choice(notes)

# Fungsi untuk menghasilkan data kesehatan


def generate_kesehatan_data(jumlah_sapi, jumlah_kesehatan_per_sapi):
    start_date = datetime(2023, 10, 1)  # Tanggal mulai
    end_date = datetime(2023, 12, 31)   # Tanggal akhir

    kesehatan_data = []
    for cow_id in range(1, jumlah_sapi + 1):
        for _ in range(jumlah_kesehatan_per_sapi):
            tanggal = generate_random_date(
                start_date, end_date).strftime('%Y-%m-%d')
            status_kesehatan = random.choice(['sehat', 'sakit'])
            kesehatan_data.append({
                "cow_id": cow_id,
                "tanggal": tanggal,
                "status_kesehatan": status_kesehatan
            })

    return kesehatan_data


# Menghasilkan data kesehatan
kesehatan_data = generate_kesehatan_data(
    10, 5)

# Menampilkan hasil data kesehatan
for data in kesehatan_data:
    print(data)

# Fungsi untuk menghasilkan data acak


def generate_random_data(jumlah_sapi, jumlah_data_per_sapi, min_value, max_value, unit):
    start_date = datetime(2023, 10, 1)  # Tanggal mulai
    end_date = datetime(2023, 12, 31)   # Tanggal akhir

    data = []
    for cow_id in range(1, jumlah_sapi + 1):
        for _ in range(jumlah_data_per_sapi):
            tanggal = generate_random_date(
                start_date, end_date).strftime('%Y-%m-%d')
            # Nilai acak dalam rentang tertentu
            value = round(random.uniform(min_value, max_value), 2)
            data.append({
                "cow_id": cow_id,
                "tanggal": tanggal,
                "jumlah": value,
                "unit": unit
            })
    return data

jumlah_sapi = 10
jumlah_data_per_sapi = 5

# Menghasilkan data pakan hijauan
pakan_hijauan_data = generate_random_data(
    jumlah_sapi, jumlah_data_per_sapi, min_value=5, max_value=20, unit="kg"
)

# Menghasilkan data pakan sentrat
pakan_sentrat_data = generate_random_data(
    jumlah_sapi, jumlah_data_per_sapi, min_value=1, max_value=5, unit="kg"
)

# Menghasilkan data produksi susu
produksi_susu_data = generate_random_data(
    jumlah_sapi, jumlah_data_per_sapi, min_value=5, max_value=15, unit="liter"
)

# Menampilkan hasil
print("Data Pakan Hijauan:")
for data in pakan_hijauan_data:
    print(data)

print("\nData Pakan Sentrat:")
for data in pakan_sentrat_data:
    print(data)

print("\nData Produksi Susu:")
for data in produksi_susu_data:
    print(data)

# Fungsi untuk menghasilkan riwayat pengobatan acak


def generate_treatment_history():
    treatments = [
        "Pengobatan antibiotik untuk infeksi.",
        "Pemberian vitamin tambahan.",
        "Pemeriksaan luka dan pemberian salep.",
        "Pengobatan cacingan menggunakan obat anthelmintik.",
        "Suntikan vaksin tahunan.",
        "Pemberian obat penurun demam.",
        "Pengobatan diare dengan cairan infus.",
        "Pembersihan luka dan antiseptik.",
        "Pengobatan gangguan pencernaan.",
        "Perawatan khusus setelah melahirkan."
    ]
    return random.choice(treatments)

# Fungsi untuk menghasilkan level stres acak


def generate_stress_level():
    levels = ['tidak', 'ringan', 'berat']
    return random.choice(levels)

# Fungsi untuk menghasilkan data riwayat pengobatan


def generate_riwayat_pengobatan_data(jumlah_sapi, jumlah_data_per_sapi):
    start_date = datetime(2023, 10, 1)
    end_date = datetime(2023, 12, 31)

    pengobatan_data = []
    for cow_id in range(1, jumlah_sapi + 1):
        for _ in range(jumlah_data_per_sapi):
            tanggal = generate_random_date(
                start_date, end_date).strftime('%Y-%m-%d')
            pengobatan = generate_treatment_history()

            pengobatan_data.append({
                "cow_id": cow_id,
                "tanggal": tanggal,
                "riwayat_pengobatan": pengobatan
            })

    return pengobatan_data

# Fungsi untuk menghasilkan data stress level


def generate_stress_level_data(jumlah_sapi, jumlah_data_per_sapi):
    start_date = datetime(2023, 10, 1)
    end_date = datetime(2023, 12, 31)

    stress_data = []
    for cow_id in range(1, jumlah_sapi + 1):
        for _ in range(jumlah_data_per_sapi):
            tanggal = generate_random_date(
                start_date, end_date).strftime('%Y-%m-%d')
            stress_level = generate_stress_level()

            stress_data.append({
                "cow_id": cow_id,
                "tanggal": tanggal,
                "stress_level": stress_level
            })

    return stress_data


# Menghasilkan data riwayat pengobatan dan stress level
riwayat_pengobatan_data = generate_riwayat_pengobatan_data(
    jumlah_sapi, jumlah_data_per_sapi)
stress_level_data = generate_stress_level_data(
    jumlah_sapi, jumlah_data_per_sapi)

# Menampilkan hasil
print("Data Riwayat Pengobatan:")
for data in riwayat_pengobatan_data:
    print(data)

print("\nData Stress Level:")
for data in stress_level_data:
    print(data)
    
# Fungsi untuk menghasilkan data umur dalam bulan


def generate_umur_data(jumlah_sapi):
    umur_data = []
    for cow_id in range(1, jumlah_sapi + 1):
        # Umur dalam rentang 6 hingga 120 bulan
        umur_bulan = random.randint(6, 120)
        umur_data.append({
            "cow_id": cow_id,
            "umur_bulan": umur_bulan
        })
    return umur_data


# Menghasilkan data umur
umur_data = generate_umur_data(jumlah_sapi)

# Menampilkan hasil
print("Data Umur (dalam bulan):")
for data in umur_data:
    print(data)


# Fungsi untuk menghubungkan ke database

def connect_db():
    return psycopg2.connect(
        dbname='ternaknesia_relational',
        user='postgres',  # Ganti dengan username Anda
        password='agus',  # Ganti dengan password Anda
        host='127.0.0.1',  # Ganti jika perlu
        port='5432'  # Ganti jika perlu
    )

# Fungsi untuk insert data ke tabel


def insert_data(table_name, data):
    conn = connect_db()
    cursor = conn.cursor()

    for entry in data:
        if table_name == 'berat_badan':
            cursor.execute("""
                INSERT INTO berat_badan (cow_id, tanggal, berat)
                VALUES (%s, %s, %s);
            """, (entry['cow_id'], entry['tanggal'], entry['berat_badan']))
        elif table_name == 'birahi':
            cursor.execute("""
                INSERT INTO birahi (cow_id, tanggal, status_birahi)
                VALUES (%s, %s, %s);
            """, (entry['cow_id'], entry['tanggal'], entry['status_birahi']))
        elif table_name == 'catatan':
            cursor.execute("""
                INSERT INTO catatan (cow_id, tanggal, catatan)
                VALUES (%s, %s, %s);
            """, (entry['cow_id'], entry['tanggal'], entry['catatan']))
        elif table_name == 'kesehatan':
            cursor.execute("""
                INSERT INTO kesehatan (cow_id, tanggal, status_kesehatan)
                VALUES (%s, %s, %s);
            """, (entry['cow_id'], entry['tanggal'], entry['status_kesehatan']))
        elif table_name == 'pakan_hijauan':
            cursor.execute("""
                INSERT INTO pakan_hijauan (cow_id, tanggal, pakan)
                VALUES (%s, %s, %s);
            """, (entry['cow_id'], entry['tanggal'], entry['jumlah']))
        elif table_name == 'pakan_sentrat':
            cursor.execute("""
                INSERT INTO pakan_sentrat (cow_id, tanggal, pakan)
                VALUES (%s, %s, %s);
            """, (entry['cow_id'], entry['tanggal'], entry['jumlah']))
        elif table_name == 'produksi_susu':
            cursor.execute("""
                INSERT INTO produksi_susu (cow_id, tanggal, produksi)
                VALUES (%s, %s, %s);
            """, (entry['cow_id'], entry['tanggal'], entry['jumlah']))
        elif table_name == 'riwayat_pengobatan':
            cursor.execute("""
                INSERT INTO riwayat_pengobatan (cow_id, tanggal, pengobatan)
                VALUES (%s, %s, %s);
            """, (entry['cow_id'], entry['tanggal'], entry['riwayat_pengobatan']))
        elif table_name == 'stress_level':
            cursor.execute("""
                INSERT INTO stress_level (cow_id, tanggal, level_stres)
                VALUES (%s, %s, %s);
            """, (entry['cow_id'], entry['tanggal'], entry['stress_level']))

    conn.commit()
    cursor.close()
    conn.close()

# Fungsi untuk insert data ke tabel cows


def insert_cows_data(umur_data):
    conn = connect_db()
    cursor = conn.cursor()

    for entry in umur_data:
        # Cek apakah cow_id sudah ada
        cursor.execute(
            "SELECT COUNT(*) FROM cows WHERE cow_id = %s;", (entry['cow_id'],))
        count = cursor.fetchone()[0]

        if count == 0:  # Jika cow_id belum ada
            cursor.execute("""
                INSERT INTO cows (cow_id, umur)
                VALUES (%s, %s);
            """, (entry['cow_id'], entry['umur_bulan']))
        else:
            print(f"cow_id {entry['cow_id']} sudah ada, tidak bisa diinsert.")

    conn.commit()
    cursor.close()
    conn.close()


def update_random_genders(dbname, user, password, host, port):
    # Establish a database connection
    try:
        connection = psycopg2.connect(
            dbname=dbname,
            user=user,
            password=password,
            host=host,
            port=port
        )
        cursor = connection.cursor()

        # Generate random genders and update the cows
        for cow_id in range(1, 11):
            gender = random.choice(['jantan', 'betina'])
            cursor.execute(
                "UPDATE cows SET gender = %s WHERE cow_id = %s",
                (gender, cow_id)
            )

        # Commit the changes
        connection.commit()
        print("Random genders assigned to cows with IDs 1 to 10.")

    except Exception as e:
        print("An error occurred:", e)

    finally:
        # Close the cursor and connection
        cursor.close()
        connection.close()


# Example usage
update_random_genders('ternaknesia_relational', 'postgres',
                      'agus', '127.0.0.1', '5432')

# Menginsert semua data yang dihasilkan
# insert_cows_data(umur_data)
# insert_data('berat_badan', berat_badan_data)
# insert_data('birahi', birahi_data)
# insert_data('catatan', catatan_data)
# insert_data('kesehatan', kesehatan_data)
# insert_data('pakan_hijauan', pakan_hijauan_data)
# insert_data('pakan_sentrat', pakan_sentrat_data)
# insert_data('produksi_susu', produksi_susu_data)
# insert_data('riwayat_pengobatan', riwayat_pengobatan_data)
# insert_data('stress_level', stress_level_data)
# Generate random genders and update the cows


import pandas as pd
from sklearn.cluster import DBSCAN
from sklearn.preprocessing import StandardScaler
import psycopg2
import json
from dotenv import load_dotenv
import os

def fetch_data_from_postgres():
    # Koneksi ke database PostgreSQL
    load_dotenv()
    conn = psycopg2.connect(host=os.getenv("PGHOST"), 
                            database=os.getenv("PGDATABASE"), 
                            user=os.getenv("PGUSER"), 
                            password=os.getenv("PGPASSWORD"), 
                            port=os.getenv("PGPORT"))
    
    query = """
    SELECT 
        b.weight AS weight_gain,
        f_h.amount AS hijauan_weight,
        f_s.amount AS sentrat_weight,
        c.stress_level,
        c.health_record->>'health_status' AS health_status,
        m.production_amount AS milk_production
    FROM body_weight b
    JOIN feed_hijauan f_h ON b.cow_id = f_h.cow_id AND b.date = f_h.date
    JOIN feed_sentrate f_s ON b.cow_id = f_s.cow_id AND b.date = f_s.date
    JOIN cows c ON b.cow_id = c.cow_id
    JOIN milk_production m ON b.cow_id = m.cow_id AND b.date = m.date
    """

    # Eksekusi query
    data = pd.read_sql_query(query, conn)
    data = data.dropna()

    # Ubah kolom `health_status` menjadi numeric jika diperlukan
    data['health_status'] = pd.to_numeric(data['health_status'], errors='coerce')

    # Ubah kolom `stress_level` menjadi numeric jika diperlukan
    data['stress_level'] = pd.to_numeric(data['stress_level'], errors='coerce')

    # Tampilkan data

    # Tutup koneksi
    conn.close()

    return data

def find_best_combination_dbscan():
    # Ambil data dari PostgreSQL
    data = fetch_data_from_postgres()

    # Ubah kolom `health_status` menjadi numeric jika diperlukan
    data['health_status'] = pd.to_numeric(data['health_status'], errors='coerce')

    # Features for clustering
    features = data[["hijauan_weight", "sentrat_weight", "stress_level", "health_status", "weight_gain", "milk_production"]]

    # Standardize data
    scaler = StandardScaler()
    scaled_features = scaler.fit_transform(features)

    # DBSCAN Clustering
    dbscan = DBSCAN(eps=3, min_samples=2)
    clusters = dbscan.fit_predict(scaled_features)

    # Add cluster labels to data
    data["cluster"] = clusters

    # Filter valid clusters (exclude noise points with label -1)
    valid_clusters = data[data["cluster"] != -1]

    # Find best cluster based on max milk production and weight gain
    if not valid_clusters.empty:
        best_cluster = valid_clusters.groupby("cluster")[["milk_production", "weight_gain"]].mean().idxmax().to_dict()
        best_combinations = valid_clusters[valid_clusters["cluster"] == best_cluster["milk_production"]].to_dict(orient="records")
    else:
        best_combinations = []  # No valid clusters found

    return best_combinations

if __name__ == "__main__":
    # Find and print best combinations
    result = find_best_combination_dbscan()
    print(json.dumps(result, indent=4))

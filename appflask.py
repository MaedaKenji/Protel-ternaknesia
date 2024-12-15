import numpy as np
import pandas as pd
from flask import Flask, jsonify, request
from sklearn.preprocessing import StandardScaler

import joblib
import tensorflow as tf
import psycopg2
from sklearn.model_selection import train_test_split
from sklearn.ensemble import RandomForestRegressor
from scipy.optimize import differential_evolution


class MilkProductionOptimizer:
    def __init__(self, db_params):
        # Parameter koneksi database
        self.db_params = db_params

        # Inisiasi variabel untuk model dan scaler
        self.model = None
        self.scaler = None
        self.optimal_feed = None
        self.max_milk_production = None

    def fetch_data(self):
        # Query untuk mengambil data
        query = """
        SELECT 
          pakan_hijauan.cow_id,
          pakan_hijauan.pakan as pakan_hijauan,
          pakan_sentrat.pakan as pakan_sentrat,
          produksi_susu.produksi as produksi_susu
        FROM 
          pakan_hijauan
          LEFT JOIN pakan_sentrat 
            ON pakan_hijauan.cow_id = pakan_sentrat.cow_id
          LEFT JOIN produksi_susu 
            ON pakan_sentrat.cow_id = produksi_susu.cow_id
        LIMIT 10
        """

        # Koneksi dan ambil data
        try:
            conn = psycopg2.connect(**self.db_params)
            df = pd.read_sql(query, conn)
            conn.close()
            return df
        except Exception as e:
            print(f"Error fetching data: {e}")
            return None

    def train_model(self):
        # Ambil data dari database
        data = self.fetch_data()

        if data is None or data.empty:
            raise ValueError("Tidak ada data untuk dilatih")

        # Pisahkan fitur dan target
        X = data[['pakan_hijauan', 'pakan_sentrat']]
        y = data['produksi_susu']

        # Bagi data training dan testing
        X_train, X_test, y_train, y_test = train_test_split(
            X, y, test_size=0.2, random_state=42
        )

        # Scaling
        self.scaler = StandardScaler()
        X_train_scaled = self.scaler.fit_transform(X_train)
        X_test_scaled = self.scaler.transform(X_test)

        # Inisiasi dan latih model
        self.model = RandomForestRegressor(n_estimators=100, random_state=42)
        self.model.fit(X_train_scaled, y_train)

        # Evaluasi model
        train_score = self.model.score(X_train_scaled, y_train)
        test_score = self.model.score(X_test_scaled, y_test)

        print("Model Performance:"  )
        print(f"R² Score (Training): {train_score:.4f}")
        print(f"R² Score (Testing): {test_score:.4f}")

        return train_score, test_score

    def optimize_feed_combination(self):
        if self.model is None or self.scaler is None:
            raise ValueError(
                "Model belum dilatih. Jalankan train_model() terlebih dahulu.")

        # Fungsi objektif untuk optimasi
        def objective_function(x):
            # Transformasi input yang akan dioptimasi
            input_scaled = self.scaler.transform(np.array(x).reshape(1, -1))
            # Prediksi produksi susu (negatif karena kita mencari maksimum)
            return -self.model.predict(input_scaled)[0]

        # Ambil data untuk batasan
        data = self.fetch_data()

        # Batasan untuk pakan hijauan dan sentrat
        bounds = [
            (data['pakan_hijauan'].min(), data['pakan_hijauan'].max()),
            (data['pakan_sentrat'].min(), data['pakan_sentrat'].max())
        ]

        # Gunakan Differential Evolution untuk optimasi
        result = differential_evolution(
            objective_function,
            bounds,
            strategy='best1bin',
            popsize=15,
            tol=1e-7
        )

        # Simpan hasil
        self.optimal_feed = result.x
        self.max_milk_production = -result.fun

        return self.optimal_feed, self.max_milk_production

    def save_model(self, model_path='milk_production_model.pkl', scaler_path='milk_production_scaler.pkl'):
        # Simpan model dan scaler
        joblib.dump(self.model, model_path)
        joblib.dump(self.scaler, scaler_path)

    def predict_milk_production(self, pakan_hijauan, pakan_sentrat):
        # Load model dan scaler jika belum ada
        if self.model is None or self.scaler is None:
            try:
                self.model = joblib.load('milk_production_model.pkl')
                self.scaler = joblib.load('milk_production_scaler.pkl')
            except FileNotFoundError:
                raise ValueError("Model belum dilatih atau disimpan")

        # Transformasi input
        input_data = np.array([[pakan_hijauan, pakan_sentrat]])
        input_scaled = self.scaler.transform(input_data)

        # Prediksi
        prediction = self.model.predict(input_scaled)
        return prediction[0]



app = Flask(__name__)

# Konfigurasi koneksi database
DB_PARAMS = {
    'dbname': 'ternaknesia_relational',
    'user': 'postgres',
    'password': 'agus',
    'host': 'localhost',
    'port': '5432'
}

optimizer = MilkProductionOptimizer(DB_PARAMS)


model_bulanan = tf.keras.models.load_model('lstm_produksi_susu_bulanan.keras')
scaler_bulanan = joblib.load('scaler_produksi_susu_bulanan.pkl')
model_harian = tf.keras.models.load_model('lstm_produksi_susu_harian.keras')
scaler_harian = joblib.load('scaler_produksi_susu_harian.pkl')


# =========================
# Bagian 1: Regresi Linear untuk Prediksi Susu
# =========================


# def train_linear_model():
#     # Dataset statis untuk pelatihan model
#     data = pd.DataFrame({
#         'hijauan_weight': [30, 25, 35, 20, 40],
#         'sentrat_weight': [15, 20, 25, 10, 30],
#         'stress_level': [20, 40, 30, 60, 10],
#         'health_status': [90, 80, 85, 70, 95],
#         'weight_gain': [500, 480, 520, 450, 550],
#         'milk_production': [30, 28, 32, 25, 35]
#     })

#     # Features and target variable
#     X = data[['hijauan_weight', 'sentrat_weight',
#               'stress_level', 'health_status']]
#     y = data['milk_production']

#     # Train the model
#     model = LinearRegression()
#     model.fit(X, y)

#     return model


# linear_model = train_linear_model()


@app.route('/predict_daily_milk', methods=['POST'])
def predict_daily_milk():
    try:
        data = request.get_json()
        if not data or 'last_3_days' not in data:
            return jsonify({'error': 'Invalid input, expected "last_3_days" with 3 values.'}), 400
        
        
        
        model = model_harian
        scaler = scaler_harian

        last_3_days = np.array(data['last_3_days'])
        last_3_days_scaled = scaler.transform(last_3_days.reshape(-1, 1))
        
        last_3_days_scaled = last_3_days_scaled.reshape(-1, 1)
        
        last_3_days_scaled = last_3_days_scaled.reshape(1, 3, 1)
        

        input_data = last_3_days_scaled
        prediction_scaled = model.predict(input_data)
        prediction = scaler.inverse_transform(prediction_scaled)
        
        return jsonify({'predicted_daily_milk': float(prediction[0][0])})

    
    except Exception as e:
        return jsonify({'error': str(e)}), 500

    

@app.route('/predict_monthly_milk', methods=['POST'])
def predict_monthly_milk():
    data = request.get_json()
    scaler = joblib.load('scaler_produksi_susu_bulanan.pkl')

    try:
        # Ambil data dari request
        data = request.get_json()
        if not data or 'last_3_months' not in data:
            return jsonify({'error': 'Invalid input, expected "last_3_months" with 3 values.'}), 400

        model = model_bulanan
        scaler = scaler_bulanan
        
        last_3_months = np.array(data['last_3_months'])        
        last_3_months_scaled = scaler.transform(last_3_months.reshape(-1, 1))
        last_3_months_scaled = last_3_months_scaled.reshape(-1, 1)
        last_3_months_scaled = last_3_months_scaled.reshape(1,3,1)
        
        input_data = last_3_months_scaled.reshape(1, 3, 1)
        prediction_scaled = model.predict(input_data)
        prediction = scaler.inverse_transform(prediction_scaled)

        # Kembalikan hasil prediksi
        return jsonify({'next_month_prediction': float(prediction[0][0])})
    except Exception as e:
        return jsonify({'error': str(e)}), 500


@app.route('/train-model', methods=['POST'])
def train_model():
    try:
        # Latih model
        train_score, test_score = optimizer.train_model()

        # Optimasi kombinasi pakan
        optimal_feed, max_production = optimizer.optimize_feed_combination()

        # Simpan model
        optimizer.save_model()

        return jsonify({
            'status': 'success',
            'train_score': train_score,
            'test_score': test_score,
            'optimal_pakan_hijauan': optimal_feed[0],
            'optimal_pakan_sentrat': optimal_feed[1],
            'max_milk_production': max_production
        })
    except Exception as e:
        return jsonify({'status': 'error', 'message': str(e)}), 500
    

@app.route('/predict-milk-production', methods=['POST'])
def predict_milk_production():
    try:
        # Ambil data dari request
        data = request.get_json()
        pakan_hijauan = data.get('pakan_hijauan')
        pakan_sentrat = data.get('pakan_sentrat')

        # Validasi input
        if pakan_hijauan is None or pakan_sentrat is None:
            return jsonify({'status': 'error', 'message': 'Pakan hijauan dan sentrat harus diisi'}), 400

        # Prediksi
        prediction = optimizer.predict_milk_production(
            pakan_hijauan, pakan_sentrat)

        return jsonify({
            'status': 'success',
            'pakan_hijauan': pakan_hijauan,
            'pakan_sentrat': pakan_sentrat,
            'predicted_milk_production': prediction
        })
    except Exception as e:
        return jsonify({'status': 'error', 'message': str(e)}), 500


@app.route('/get-optimal-feed', methods=['GET'])
def get_optimal_feed():
    try:
        # Jika belum ada optimasi, lakukan training terlebih dahulu
        if optimizer.optimal_feed is None:
            optimizer.train_model()
            optimizer.optimize_feed_combination()

        return jsonify({
            'status': 'success',
            'optimal_pakan_hijauan': optimizer.optimal_feed[0],
            'optimal_pakan_sentrat': optimizer.optimal_feed[1],
            'max_milk_production': optimizer.max_milk_production
        })
    except Exception as e:
        return jsonify({'status': 'error', 'message': str(e)}), 500

@app.route('/save-model', methods=['GET'])
def save_model():
    try:
        optimizer.save_model()
        return jsonify({'status': 'success'})
    except Exception as e:
        return jsonify({'status': 'error', 'message': str(e)}), 500

# =========================
# Menjalankan Aplikasi Flask
# =========================

if __name__ == '__main__':
    app.run(debug=True)
    
    
# @app.route('/predict_daily_milk_ASLI', methods=['POST'])
# def predict_daily_milkasli():
#     data = request.get_json()

#     features = np.array([
#         data['hijauan_weight'],
#         data['sentrat_weight'],
#         data['stress_level'],
#         data['health_status']
#     ]).reshape(1, -1)

#     predicted_milk = linear_model.predict(features)[0]

#     return jsonify({'predicted_daily_milk': predicted_milk})


# @app.route('/predict_monthly_milkasli', methods=['POST'])
# def predict_monthly_milkasli():
#     data = request.get_json()

#     features = np.array([
#         data['hijauan_weight'],
#         data['sentrat_weight'],
#         data['stress_level'],
#         data['health_status']
#     ]).reshape(1, -1)

#     predicted_daily_milk = linear_model.predict(features)[0]
#     predicted_monthly_milk = predicted_daily_milk * 30

#     return jsonify({'predicted_monthly_milk': predicted_monthly_milk})


# =========================
# Bagian 2: Logistic Regression dan KMeans
# =========================

# Data untuk klasifikasi produktivitas
# data = pd.DataFrame([
#     {"hijauan_weight": 30, "sentrat_weight": 15, "stress_level": 20,
#         "health_status": 90, "weight_gain": 500, "milk_production": 30},
#     {"hijauan_weight": 25, "sentrat_weight": 20, "stress_level": 40,
#         "health_status": 80, "weight_gain": 480, "milk_production": 28},
#     {"hijauan_weight": 35, "sentrat_weight": 25, "stress_level": 30,
#         "health_status": 85, "weight_gain": 520, "milk_production": 32},
#     {"hijauan_weight": 20, "sentrat_weight": 10, "stress_level": 60,
#         "health_status": 70, "weight_gain": 450, "milk_production": 25},
#     {"hijauan_weight": 40, "sentrat_weight": 30, "stress_level": 15,
#         "health_status": 95, "weight_gain": 540, "milk_production": 35},
#     {"hijauan_weight": 28, "sentrat_weight": 18, "stress_level": 25,
#         "health_status": 85, "weight_gain": 490, "milk_production": 30}
# ])

# data['productive'] = data['milk_production'].apply(
#     lambda x: 1 if x > 25 else 0)

# features = data[["hijauan_weight", "sentrat_weight",
#                  "stress_level", "health_status", "milk_production"]]
# target = data["productive"]

# # KMeans untuk clustering
# kmeans = KMeans(n_clusters=2)
# data['cluster'] = kmeans.fit_predict(
#     features[["hijauan_weight", "sentrat_weight"]])

# # Logistic Regression untuk klasifikasi
# scaler = StandardScaler()
# features_scaled = scaler.fit_transform(features)
# logistic_model = LogisticRegression()
# logistic_model.fit(features_scaled, target)


# @app.route('/get_clusters', methods=['GET'])
# def get_clusters():
#     best_combination = data.groupby('cluster').mean()[
#         ['hijauan_weight', 'sentrat_weight']]
#     best_cluster = data[data['productive'] == 1].groupby(
#         'cluster')['milk_production'].mean().idxmax()
#     best_combination_data = best_combination.loc[best_cluster].to_dict()

#     return jsonify({
#         "success": True,
#         "data": {
#             "hijauan_weight": best_combination_data['hijauan_weight'],
#             "sentrat_weight": best_combination_data['sentrat_weight'],
#         }
#     })


# @app.route('/predict_productivity', methods=['POST'])
# def predict_productivity():
#     input_data = request.get_json()
#     input_df = pd.DataFrame([input_data])
#     input_scaled = scaler.transform(input_df)
#     prediction = logistic_model.predict(input_scaled)

#     return jsonify({"is_productive": bool(prediction[0])})


# =========================
# Bagian 3: Kombinasi Pakan
# =========================

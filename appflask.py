import numpy as np
import pandas as pd
from flask import Flask, jsonify, request
from sklearn.linear_model import LinearRegression, LogisticRegression
from sklearn.preprocessing import StandardScaler, MinMaxScaler
from sklearn.cluster import KMeans
from tensorflow.keras.models import load_model
import joblib
import sys
import tensorflow as tf


app = Flask(__name__)

# model = load_model('lstm_produksi_susu_bulanan.keras')
# scaler = joblib.load('scaler_produksi_susu_bulanan.pkl')
# print(sys.version)

model = tf.keras.models.load_model('lstm_produksi_susu_bulanan.keras')
scaler = joblib.load('scaler_produksi_susu_bulanan.pkl')

# last_3_months = np.array([100, 200, 300])
# print(last_3_months)

# print("-------------------------------------------------------------------")
# print("\n\n\n")
# last_3_months_scaled = scaler.transform(last_3_months.reshape(-1, 1))
# print(last_3_months_scaled)
# last_3_months_scaled = last_3_months_scaled.reshape(-1, 1)
# print(last_3_months)
# last_3_months_scaled = last_3_months_scaled.reshape(1, 3, 1)
# print(last_3_months_scaled)


# =========================
# Bagian 1: Regresi Linear untuk Prediksi Susu
# =========================


def train_linear_model():
    # Dataset statis untuk pelatihan model
    data = pd.DataFrame({
        'hijauan_weight': [30, 25, 35, 20, 40],
        'sentrat_weight': [15, 20, 25, 10, 30],
        'stress_level': [20, 40, 30, 60, 10],
        'health_status': [90, 80, 85, 70, 95],
        'weight_gain': [500, 480, 520, 450, 550],
        'milk_production': [30, 28, 32, 25, 35]
    })

    # Features and target variable
    X = data[['hijauan_weight', 'sentrat_weight',
              'stress_level', 'health_status']]
    y = data['milk_production']

    # Train the model
    model = LinearRegression()
    model.fit(X, y)

    return model


linear_model = train_linear_model()


@app.route('/predict_daily_milk', methods=['POST'])
def predict_daily_milk():
    data = request.get_json()

    features = np.array([
        data['hijauan_weight'],
        data['sentrat_weight'],
        data['stress_level'],
        data['health_status']
    ]).reshape(1, -1)

    predicted_milk = linear_model.predict(features)[0]

    return jsonify({'predicted_daily_milk': predicted_milk})

@app.route('/predict_monthly_milk', methods=['POST'])
def predict_monthly_milk():
    data = request.get_json()
    if not data or 'last_3_months' not in data:
        return jsonify({'error': 'Invalid input, expected "last_3_months" with 3 values.'}), 400
    scaler = joblib.load('scaler_produksi_susu_bulanan.pkl')


    print("\n\n\n")
    print("---------------------------------------------------------")
    # Ambil input data (3 bulan terakhir)
    last_3_months = np.array(data['last_3_months'])
    last_3_months = np.array([100, 200, 300])
    last_3_months = np.array([100, 200, 300])

    print(last_3_months)

    if len(last_3_months) != 3:
        return jsonify({'error': 'Input must contain exactly 3 months of data.'}), 400
    print("-------------------------------------------------------------------")
    print("\n\n\n")
    last_3_months_scaled = scaler.transform(last_3_months.reshape(-1, 1))
    print(last_3_months_scaled)
    last_3_months_scaled = last_3_months_scaled.reshape(-1, 1)
    print(last_3_months)
    last_3_months_scaled = last_3_months_scaled.reshape(1, 3,1)
    print(last_3_months_scaled)
    try:
        # Ambil data dari request
        data = request.get_json()
        if not data or 'last_3_months' not in data:
            return jsonify({'error': 'Invalid input, expected "last_3_months" with 3 values.'}), 400

        
        
        print("\n\n\n")
        print("---------------------------------------------------------")
        # Ambil input data (3 bulan terakhir)
        last_3_months = np.array(data['last_3_months'])
        last_3_months = np.array([100, 200, 300])
        last_3_months = np.array([100, 200, 300])

        print(last_3_months)

        if len(last_3_months) != 3:
            return jsonify({'error': 'Input must contain exactly 3 months of data.'}), 400
        print("-------------------------------------------------------------------")
        print("\n\n\n")
        last_3_months_scaled = scaler.transform(last_3_months.reshape(-1, 1))
        print(last_3_months_scaled)
        last_3_months_scaled = last_3_months_scaled.reshape(-1, 1)
        print(last_3_months)
        last_3_months_scaled = last_3_months_scaled.reshape(1,3,1)
        print(last_3_months_scaled)
        
        

        
        input_data = last_3_months_scaled.reshape(1, 3, 1)

        # Prediksi
        prediction_scaled = model.predict(input_data)
        prediction = scaler.inverse_transform(prediction_scaled)

        # Kembalikan hasil prediksi
        return jsonify({'next_month_prediction': float(prediction[0][0])})
    except Exception as e:
        return jsonify({'error': str(e)}), 500



@app.route('/predict_monthly_milkasli', methods=['POST'])
def predict_monthly_milkasli():
    data = request.get_json()

    features = np.array([
        data['hijauan_weight'],
        data['sentrat_weight'],
        data['stress_level'],
        data['health_status']
    ]).reshape(1, -1)

    predicted_daily_milk = linear_model.predict(features)[0]
    predicted_monthly_milk = predicted_daily_milk * 30

    return jsonify({'predicted_monthly_milk': predicted_monthly_milk})


# =========================
# Bagian 2: Logistic Regression dan KMeans
# =========================

# Data untuk klasifikasi produktivitas
data = pd.DataFrame([
    {"hijauan_weight": 30, "sentrat_weight": 15, "stress_level": 20,
        "health_status": 90, "weight_gain": 500, "milk_production": 30},
    {"hijauan_weight": 25, "sentrat_weight": 20, "stress_level": 40,
        "health_status": 80, "weight_gain": 480, "milk_production": 28},
    {"hijauan_weight": 35, "sentrat_weight": 25, "stress_level": 30,
        "health_status": 85, "weight_gain": 520, "milk_production": 32},
    {"hijauan_weight": 20, "sentrat_weight": 10, "stress_level": 60,
        "health_status": 70, "weight_gain": 450, "milk_production": 25},
    {"hijauan_weight": 40, "sentrat_weight": 30, "stress_level": 15,
        "health_status": 95, "weight_gain": 540, "milk_production": 35},
    {"hijauan_weight": 28, "sentrat_weight": 18, "stress_level": 25,
        "health_status": 85, "weight_gain": 490, "milk_production": 30}
])

data['productive'] = data['milk_production'].apply(
    lambda x: 1 if x > 25 else 0)

features = data[["hijauan_weight", "sentrat_weight",
                 "stress_level", "health_status", "milk_production"]]
target = data["productive"]

# KMeans untuk clustering
kmeans = KMeans(n_clusters=2)
data['cluster'] = kmeans.fit_predict(
    features[["hijauan_weight", "sentrat_weight"]])

# Logistic Regression untuk klasifikasi
scaler = StandardScaler()
features_scaled = scaler.fit_transform(features)
logistic_model = LogisticRegression()
logistic_model.fit(features_scaled, target)


@app.route('/get_clusters', methods=['GET'])
def get_clusters():
    best_combination = data.groupby('cluster').mean()[
        ['hijauan_weight', 'sentrat_weight']]
    best_cluster = data[data['productive'] == 1].groupby(
        'cluster')['milk_production'].mean().idxmax()
    best_combination_data = best_combination.loc[best_cluster].to_dict()

    return jsonify({
        "success": True,
        "data": {
            "hijauan_weight": best_combination_data['hijauan_weight'],
            "sentrat_weight": best_combination_data['sentrat_weight'],
        }
    })


@app.route('/predict_productivity', methods=['POST'])
def predict_productivity():
    input_data = request.get_json()
    print(input_data)
    input_df = pd.DataFrame([input_data])
    input_scaled = scaler.transform(input_df)
    prediction = logistic_model.predict(input_scaled)

    return jsonify({"is_productive": bool(prediction[0])})


# =========================
# Menjalankan Aplikasi Flask
# =========================

if __name__ == '__main__':
    app.run(debug=True)
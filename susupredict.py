from flask import Flask, request, jsonify
import pandas as pd
from sklearn.linear_model import LinearRegression
import numpy as np

app = Flask(__name__)

# Model sederhana untuk prediksi susu (menggunakan regresi linear sebagai contoh)
def train_model():
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
    X = data[['hijauan_weight', 'sentrat_weight', 'stress_level', 'health_status', 'weight_gain']]
    y = data['milk_production']
    
    # Train the model
    model = LinearRegression()
    model.fit(X, y)
    
    return model

# Model untuk prediksi susu
model = train_model()


@app.route('/predict_daily_milk', methods=['POST'])
def predict_daily_milk():
    # Ambil data dari request
    data = request.get_json()
    
    # Data yang diinginkan untuk prediksi (sapi)
    features = np.array([
        data['hijauan_weight'],
        data['sentrat_weight'],
        data['stress_level'],
        data['health_status'],
        data['weight_gain']
    ]).reshape(1, -1)

    # Prediksi susu harian menggunakan model
    predicted_milk = model.predict(features)[0]
    
    # Kembalikan hasil prediksi dalam format JSON
    return jsonify({'predicted_daily_milk': predicted_milk})


@app.route('/predict_monthly_milk', methods=['POST'])
def predict_monthly_milk():
    # Ambil data dari request
    data = request.get_json()
    
    # Prediksi susu harian menggunakan model
    predicted_daily_milk = model.predict(np.array([
        data['hijauan_weight'],
        data['sentrat_weight'],
        data['stress_level'],
        data['health_status'],
        data['weight_gain']
    ]).reshape(1, -1))[0]
    
    # Perkiraan susu bulanan (30 hari dalam sebulan)
    predicted_monthly_milk = predicted_daily_milk * 30
    
    # Kembalikan hasil prediksi dalam format JSON
    return jsonify({'predicted_monthly_milk': predicted_monthly_milk})

if __name__ == "__main__":
    # Jalankan Flask app pada port 5000
    app.run(debug=True, port=5000)

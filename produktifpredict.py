import pandas as pd
from sklearn.linear_model import LogisticRegression
from sklearn.preprocessing import StandardScaler
from flask import Flask, jsonify, request

# Data statis tentang produksi susu dan status produktivitas
data = pd.DataFrame([
    {"hijauan_weight": 30, "sentrat_weight": 15, "stress_level": 20, "health_status": 90, "weight_gain": 500, "milk_production": 30},
    {"hijauan_weight": 25, "sentrat_weight": 20, "stress_level": 40, "health_status": 80, "weight_gain": 480, "milk_production": 28},
    {"hijauan_weight": 35, "sentrat_weight": 25, "stress_level": 30, "health_status": 85, "weight_gain": 520, "milk_production": 32},
    {"hijauan_weight": 20, "sentrat_weight": 10, "stress_level": 60, "health_status": 70, "weight_gain": 450, "milk_production": 25},
    {"hijauan_weight": 40, "sentrat_weight": 30, "stress_level": 15, "health_status": 95, "weight_gain": 540, "milk_production": 35},
    {"hijauan_weight": 28, "sentrat_weight": 18, "stress_level": 25, "health_status": 85, "weight_gain": 490, "milk_production": 30}
])

# Menambahkan label produktif: 1 jika susu > 25 liter, 0 jika susu <= 25 liter
data['productive'] = data['milk_production'].apply(lambda x: 1 if x > 25 else 0)

# Fitur yang digunakan untuk klasifikasi
features = data[["hijauan_weight", "sentrat_weight", "stress_level", "health_status", "weight_gain"]]
target = data["productive"]

# Latih model
scaler = StandardScaler()
features_scaled = scaler.fit_transform(features)
model = LogisticRegression()
model.fit(features_scaled, target)

# Membuat aplikasi Flask untuk API
app = Flask(__name__)

@app.route('/predict_productivity', methods=['POST'])
def predict_productivity():
    # Mengambil data input dari request JSON
    input_data = request.get_json()
    input_df = pd.DataFrame([input_data])
    
    # Standarisasi data input
    input_scaled = scaler.transform(input_df)
    
    # Prediksi produktivitas sapi
    prediction = model.predict(input_scaled)
    
    # Mengembalikan hasil prediksi dalam format JSON
    return jsonify({"is_productive": bool(prediction[0])})

if __name__ == '__main__':
    app.run(debug=True)

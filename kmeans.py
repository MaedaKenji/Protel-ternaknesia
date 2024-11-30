import pandas as pd
from sklearn.cluster import KMeans
from sklearn.preprocessing import StandardScaler
import json

def find_best_combination():
    # Dataset
    data = pd.DataFrame([
        {"hijauan_weight": 30, "sentrat_weight": 15, "stress_level": 20, "health_status": 90, "weight_gain": 500, "milk_production": 30},
        {"hijauan_weight": 25, "sentrat_weight": 20, "stress_level": 40, "health_status": 80, "weight_gain": 480, "milk_production": 28},
        {"hijauan_weight": 35, "sentrat_weight": 25, "stress_level": 30, "health_status": 85, "weight_gain": 520, "milk_production": 32},
        {"hijauan_weight": 20, "sentrat_weight": 10, "stress_level": 60, "health_status": 70, "weight_gain": 450, "milk_production": 25}
    ])

    # Features for clustering
    features = data[["hijauan_weight", "sentrat_weight", "stress_level", "health_status", "weight_gain", "milk_production"]]

    # Standardize data
    scaler = StandardScaler()
    scaled_features = scaler.fit_transform(features)

    # K-Means Clustering
    kmeans = KMeans(n_clusters=2, random_state=42)
    clusters = kmeans.fit_predict(scaled_features)

    # Add cluster labels to data
    data["cluster"] = clusters

    # Find best cluster based on maximum milk production
    cluster_avg = data.groupby("cluster")[["milk_production", "weight_gain"]].mean()
    best_cluster_label = cluster_avg["milk_production"].idxmax()

    # Filter data for the best cluster
    best_combinations = data[data["cluster"] == best_cluster_label].to_dict(orient="records")
    return best_combinations

if __name__ == "__main__":
    # Find and print best combinations
    result = find_best_combination()
    print(json.dumps(result))

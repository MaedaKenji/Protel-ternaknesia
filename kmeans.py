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
    cluster_avg = data.groupby("cluster")["milk_production"].mean()
    best_cluster_label = cluster_avg.idxmax()

    # Filter data for the best cluster
    best_cluster_data = data[data["cluster"] == best_cluster_label]

    # Find the best single combination with maximum milk production
    best_combination = best_cluster_data.loc[best_cluster_data["milk_production"].idxmax()]

    return best_combination.to_dict()

if __name__ == "__main__":
    # Find and print the best combination
    result = find_best_combination()
    print(json.dumps(result, indent=4))

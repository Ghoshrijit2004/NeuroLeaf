from flask import Flask, request, jsonify
import tensorflow as tf
import numpy as np
from PIL import Image

app = Flask(__name__)

# ✅ Load model
model = tf.keras.models.load_model("leaf_model_tf")

# ✅ Inference function
infer = model.signatures["serving_default"]

# ✅ Class names
class_names = [
    "Pepper__bell___Bacterial_spot", "Pepper__bell___healthy", "PlantVillage",
    "Potato___Early_blight", "Potato___Late_blight", "Potato___healthy",
    "Tomato_Bacterial_spot", "Tomato_Early_blight", "Tomato_Late_blight",
    "Tomato_Leaf_Mold", "Tomato_Septoria_leaf_spot",
    "Tomato_Spider_mites_Two_spotted_spider_mite", "Tomato__Target_Spot",
    "Tomato__Tomato_YellowLeaf__Curl_Virus", "Tomato__Tomato_mosaic_virus",
    "Tomato_healthy"
]

# ✅ Disease info (MOVED OUTSIDE)
disease_info = {
    "Pepper__bell___Bacterial_spot": {
        "description": "Bacterial disease causing dark, water-soaked spots on leaves and fruits.",
        "solution": "Use copper-based sprays and avoid overhead watering."
    },
    "Pepper__bell___healthy": {
        "description": "The plant is healthy.",
        "solution": "No action needed."
    },
    "PlantVillage": {
        "description": "Invalid or background image.",
        "solution": "Upload a proper leaf image."
    },
    "Potato___Early_blight": {
        "description": "Fungal disease causing concentric rings.",
        "solution": "Apply fungicide and remove infected leaves."
    },
    "Potato___Late_blight": {
        "description": "Serious fungal disease causing decay.",
        "solution": "Remove infected plants immediately."
    },
    "Potato___healthy": {
        "description": "Healthy plant.",
        "solution": "No action required."
    },
    "Tomato_Bacterial_spot": {
        "description": "Bacterial infection causing spots.",
        "solution": "Use copper sprays."
    },
    "Tomato_Early_blight": {
        "description": "Fungal disease with brown spots.",
        "solution": "Remove infected leaves."
    },
    "Tomato_Late_blight": {
        "description": "Severe fungal disease.",
        "solution": "Destroy infected plants."
    },
    "Tomato_Leaf_Mold": {
        "description": "Fungal infection causing yellow patches.",
        "solution": "Improve airflow and use fungicide."
    },
    "Tomato_Septoria_leaf_spot": {
        "description": "Small dark circular spots.",
        "solution": "Avoid water splash and remove leaves."
    },
    "Tomato_Spider_mites_Two_spotted_spider_mite": {
        "description": "Pest infestation.",
        "solution": "Use neem oil or insecticide."
    },
    "Tomato__Target_Spot": {
        "description": "Target-shaped lesions.",
        "solution": "Apply fungicide."
    },
    "Tomato__Tomato_YellowLeaf__Curl_Virus": {
        "description": "Viral disease causing yellow curling.",
        "solution": "Control whiteflies."
    },
    "Tomato__Tomato_mosaic_virus": {
        "description": "Mosaic pattern on leaves.",
        "solution": "Remove infected plants."
    },
    "Tomato_healthy": {
        "description": "Healthy plant.",
        "solution": "No action needed."
    }
}

@app.route('/')
def home():
    return "NeuroLeaf AI API Running 🌿"

@app.route('/predict', methods=['POST'])
def predict():
    try:
        if 'file' not in request.files:
            return jsonify({"error": "No file uploaded"}), 400

        file = request.files['file']

        # 🖼 Image processing
        img = Image.open(file).convert('RGB')
        img = img.resize((128, 128))

        img_array = np.array(img, dtype=np.float32) / 255.0
        img_array = np.expand_dims(img_array, axis=0)

        # 🤖 Prediction
        output = infer(tf.constant(img_array))
        predictions = list(output.values())[0].numpy()

        score = predictions[0]
        predicted_index = int(np.argmax(score))
        confidence = float(np.max(score))

        disease = class_names[predicted_index]

        # ✅ FIXED INDENTATION HERE
        info = disease_info.get(disease.strip(), {})

        print("DEBUG:", disease, info)  # 🔍 debug

        return jsonify({
            "prediction": disease,
            "confidence": confidence,
            "description": info.get("description", "No info"),
            "solution": info.get("solution", "No solution")
        })

    except Exception as e:
        print("🔥 ERROR:", e)
        return jsonify({"error": str(e)}), 500


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5001, debug=True)

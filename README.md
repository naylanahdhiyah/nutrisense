# NutriSense

NutriSense is a mobile application designed to classify nitrogen levels in rice plants based on leaf color. This app leverages a hybrid model combining YOLOv8 for object detection and Random Forest for classification. Integrated with Firebase for data storage and Flask for model inference, NutriSense also provides fertilizer dosage recommendations to support more precise farming.

## Application Workflow

<img width="3032" height="1924" alt="image" src="https://github.com/user-attachments/assets/666952ba-7775-496d-9770-d9d47e7c9a13" />


## Dataset & Training
<img width="1380" height="922" alt="image" src="https://github.com/user-attachments/assets/60e2dd38-9601-4e9e-9462-88f352659529" />

1. Custom dataset of rice leaf images with 4 nitrogen-level categories.
2. Trained YOLOv8 on bounding box annotations for leaf localization.
3. Trained Random Forest on color-based features from cropped leaf regions.

## Evaluation Metrics

| Metric       | Value   |
|--------------|---------|
| Accuracy     | 0.9073  |
| Precision    | 0.9858  |
| Recall       | 0.9746  |
| F1-Score     | 0.9801  |
| mAP (YOLOv8) | 0.872   |

## Installation & Usage

1. **Clone this repository**
   ```bash
   git clone https://github.com/naylanahdhiyah/nutrisense.git
   cd nutrisense
   ```

2. **Install Flutter dependencies**
   ```bash
   flutter pub get
   ```

3. **Set up Firebase configuration**
   - Download `google-services.json` (for Android) or `GoogleService-Info.plist` (for iOS) from your Firebase Console.
   - Place them in the appropriate directories:
     - `android/app/` → for `google-services.json`
     - `ios/Runner/` → for `GoogleService-Info.plist`

4. **Run the app on your device or emulator**
   ```bash
   flutter run
   ```

5. **Configure Flask API route**
   - Open the file at `lib/services/prediction.dart`.
   - Replace the default HTTP address with the one you get after running your Flask API server (usually on `http://127.0.0.1:5000` or similar).

---

### Flask Backend Setup

1. **Create a separate directory** for your Flask backend (e.g., `nutrisense-backend`).
2. **Create a virtual environment** and install Flask and required Python packages:
   ```bash
   python -m venv venv
   source venv/bin/activate  # For Linux/macOS
   venv\Scripts\activate     # For Windows

   pip install flask numpy scikit-learn
   ```
3. **Save your trained model** (e.g., `model.pkl`) in the backend directory.
4. **Create your Flask app** (e.g., `app.py`) and implement your prediction route.
5. **Run the Flask server**
   ```bash
   python app.py
   ```
6. After running, you’ll see a local server address (usually `http://127.0.0.1:5000`). Use this address in the Flutter app.

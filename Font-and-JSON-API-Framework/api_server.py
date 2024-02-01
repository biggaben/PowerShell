from flask import Flask, request, jsonify
import subprocess
import speech_recognition as sr
from sklearn.linear_model import LinearRegression
import numpy as np

app = Flask(__name__)

@app.route('/execute/python', methods=['POST'])
def execute_python():
    data = request.json
    code = data['code']
    try:
        output = subprocess.check_output(['python', '-c', code], text=True)
        return jsonify({"output": output})
    except subprocess.CalledProcessError as e:
        return jsonify({"error": str(e)})

@app.route('/predict', methods=['POST'])
def predict():
    data = request.json
    X = np.array(data['X']).reshape(-1, 1)
    y = np.array(data['y'])
    model = LinearRegression()
    model.fit(X, y)
    prediction = model.predict(X).tolist()
    return jsonify({"prediction": prediction})

@app.route('/voice-command', methods=['GET'])
def voice_command():
    recognizer = sr.Recognizer()
    with sr.Microphone() as source:
        print("Listening for a command...")
        audio = recognizer.listen(source)
        try:
            command_text = recognizer.recognize_google(audio)
            return jsonify({"command": command_text})
        except sr.UnknownValueError:
            return jsonify({"error": "Could not understand audio"})
        except sr.RequestError as e:
            return jsonify({"error": "Could not request results from the service."})

if __name__ == '__main__':
    app.run(port=5000)
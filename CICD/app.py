from flask import Flask, jsonify, request
from flask_cors import CORS
import random
import string

app = Flask(__name__)
CORS(app)  # Allow all origins (use with caution in production)

@app.route('/generate', methods=['GET'])
def generate_random_string():
    try:
        length = int(request.args.get('length', 10))  # Default length is 10
        random_str = ''.join(random.choices(string.ascii_letters + string.digits, k=length))
        return jsonify({"random_string": random_str})
    except ValueError:
        return jsonify({"error": "Invalid length parameter"}), 400

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=80)

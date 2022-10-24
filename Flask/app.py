from flask import Flask
import requests

app = Flask(__name__)

@app.route('/<path:url>')
def index(url):
    r = requests.get("https://api.github.com/repos/" + url + "/releases/latest")
    return str(r.json()["name"])

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8080)

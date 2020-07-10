from flask import Flask, render_template, request
from falabella.src.logic import get_payload_stats

app = Flask(__name__)


@app.route('/')
def echo():
    return render_template("echo.html")


@app.route('/echoed', methods=["POST"])
def echoed():
    payload = request.form["payload"]
    return render_template("echoed.html", **get_payload_stats(payload))

#!/usr/bin/env wolframscript

from flask import Flask
from waitress import serve

app = Flask(__name__)

@app.route("/")
def serve_heart():

    return app.send_static_file("fsoth0.html")

app.run('127.0.0.1', 8080)
#serve(app, host='0.0.0.0', port=8080)

#print('running')
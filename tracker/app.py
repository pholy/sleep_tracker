import sqlite3

from flask import Flask, g, render_template

from config import DB_PATH

app = Flask(__name__)


def open_connection():
    connection = getattr(g, "_connection", None)
    if connection is None:
        connection = g._connection = sqlite3.connect(DB_PATH)
    connection.row_factory = sqlite3.Row
    return connection


def execute_sql(sql, values=(), commit=False, single=False):
    connection = open_connection()
    cursor = connection.execute(sql, values)
    if commit is True:
        results = connection.commit()
    else:
        results = cursor.fetchone() if single else cursor.fetchall()
    cursor.close()
    return results


@app.teardown_appcontext
def close_connection(exception):
    connection = getattr(g, "_connection", None)
    if connection is not None:
        connection.close()


@app.route("/")
@app.route("/tracking_type")
def home():
    tracking_types = execute_sql(
        "select tracker_type.tracker_type_code from tracker_type"
    )
    return render_template("index.html", tracking_types=tracking_types)

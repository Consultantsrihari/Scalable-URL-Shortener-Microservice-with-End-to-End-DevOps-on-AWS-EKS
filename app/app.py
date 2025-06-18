import os
import random
import string
from flask import Flask, request, redirect, render_template, url_for, flash
import psycopg2
from psycopg2 import sql
from dotenv import load_dotenv

# Load environment variables from .env file
load_dotenv()

app = Flask(__name__)
app.secret_key = os.getenv('FLASK_SECRET_KEY', 'supersecretkey') # For flash messages

# Database connection details
DB_NAME = os.getenv('DB_NAME', 'urlshortenerdb')
DB_USER = os.getenv('DB_USER', 'user')
DB_PASSWORD = os.getenv('DB_PASSWORD', 'password')
DB_HOST = os.getenv('DB_HOST', 'localhost')
DB_PORT = os.getenv('DB_PORT', '5432')

def get_db_connection():
    conn = psycopg2.connect(
        dbname=DB_NAME,
        user=DB_USER,
        password=DB_PASSWORD,
        host=DB_HOST,
        port=DB_PORT
    )
    return conn

def create_table_if_not_exists():
    conn = None
    try:
        conn = get_db_connection()
        cur = conn.cursor()
        cur.execute(
            """
            CREATE TABLE IF NOT EXISTS urls (
                id SERIAL PRIMARY KEY,
                long_url TEXT NOT NULL,
                short_code VARCHAR(10) UNIQUE NOT NULL,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            );
            """
        )
        conn.commit()
        cur.close()
    except Exception as e:
        print(f"Error creating table: {e}")
        if conn:
            conn.rollback()
    finally:
        if conn:
            conn.close()

# Ensure table exists on startup
with app.app_context():
    create_table_if_not_exists()

def generate_short_code(length=6):
    characters = string.ascii_letters + string.digits
    while True:
        code = ''.join(random.choice(characters) for _ in range(length))
        conn = get_db_connection()
        cur = conn.cursor()
        cur.execute("SELECT id FROM urls WHERE short_code = %s", (code,))
        if cur.fetchone() is None:
            cur.close()
            conn.close()
            return code
        cur.close()
        conn.close()

@app.route('/')
def index():
    return render_template('index.html')

@app.route('/shorten', methods=['POST'])
def shorten_url():
    long_url = request.form['long_url']
    if not long_url:
        flash('Please enter a URL to shorten.', 'error')
        return redirect(url_for('index'))

    # Check if URL already exists
    conn = get_db_connection()
    cur = conn.cursor()
    cur.execute("SELECT short_code FROM urls WHERE long_url = %s", (long_url,))
    existing_short_code = cur.fetchone()
    if existing_short_code:
        short_url = request.url_root + existing_short_code[0]
        flash(f'URL already shortened! Your short URL is: <a href="{short_url}" target="_blank">{short_url}</a>', 'info')
        cur.close()
        conn.close()
        return redirect(url_for('index'))

    short_code = generate_short_code()
    try:
        cur.execute(
            sql.SQL("INSERT INTO urls (long_url, short_code) VALUES (%s, %s)"),
            (long_url, short_code)
        )
        conn.commit()
        short_url = request.url_root + short_code
        flash(f'Your short URL is: <a href="{short_url}" target="_blank">{short_url}</a>', 'success')
    except Exception as e:
        conn.rollback()
        flash(f'An error occurred: {e}', 'error')
    finally:
        cur.close()
        conn.close()
    return redirect(url_for('index'))

@app.route('/<short_code>')
def redirect_to_long_url(short_code):
    conn = None
    try:
        conn = get_db_connection()
        cur = conn.cursor()
        cur.execute("SELECT long_url FROM urls WHERE short_code = %s", (short_code,))
        result = cur.fetchone()
        cur.close()
        conn.close()
        if result:
            return redirect(result[0])
        else:
            flash('Short URL not found.', 'error')
            return render_template('404.html'), 404
    except Exception as e:
        print(f"Error redirecting: {e}")
        flash('An error occurred during redirection.', 'error')
        if conn:
            conn.close()
        return render_template('404.html'), 500

@app.errorhandler(404)
def page_not_found(e):
    return render_template('404.html'), 404

if __name__ == '__main__':
    # Use Gunicorn in production via Docker, Flask's built-in server for local dev
    app.run(debug=True, host='0.0.0.0', port=5000)

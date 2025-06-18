# Use a slim Buster base image for a smaller footprint
FROM python:3.9-slim-buster

# Set the working directory
WORKDIR /app

# Copy requirements.txt and install Python dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy the Flask application code
COPY . .

# Expose the port Flask runs on (Gunicorn will run on 5000)
EXPOSE 5000

# Command to run the application using Gunicorn
# Gunicorn is a WSGI HTTP Server for UNIX, excellent for production Flask apps.
# Bind to 0.0.0.0 to make it accessible from outside the container.
CMD ["gunicorn", "-w", "4", "-b", "0.0.0.0:5000", "app:app"]

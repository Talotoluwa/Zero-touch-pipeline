# Use a lightweight official Python image
FROM python:3.9-slim

# Set the working directory inside the container
WORKDIR /app

# Copy requirements first to leverage Docker layer caching
COPY requirements.txt .

# Install dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy the remaining application code
COPY . .

# Expose the port the app runs on
EXPOSE 5000

# Command to execute when the container starts
CMD ["python", "app.py"]

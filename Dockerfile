# Use a slim Python base image
FROM python:3.13-slim

# Set working directory
WORKDIR /app

# Copy dependencies first (for layer caching)
COPY requirements.txt .

# Install dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy API code
COPY api/ ./api
# Alternatively, app code
# COPY app/ ./app

# Entrypoint for FastAPI
CMD ["uvicorn", "api.main:app", "--host", "0.0.0.0", "--port", "8080"]
# Alternatively, for Flask:
# CMD ["gunicorn", "-b", "0.0.0.0:8080", "app.main:server"]

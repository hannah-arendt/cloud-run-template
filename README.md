# Google Cloud Run Webapp or API

This is a template for deploying a web application or API to Google Cloud Run. It includes a Dockerfile and a sample application.

## Prerequisites

- Google Cloud account
- Google Cloud CLI installed and authenticated
- Docker installed
- Terraform installed

## Deployment Steps

Create a Google Cloud project or use an existing one; let us assume the project name is `kerfuffle`.

### Steps for FastAPI API

1. Create the `api` directory and add your FastAPI `main.py` there.
2. Create a virtual environment called `venv` in the root directory and install all the required packages, for example:
   ```bash
   python3 -m venv venv
   source venv/bin/activate
   pip install fastapi uvicorn google-cloud-storage google-cloud-secret-manager
   ```
3. Replace `my-project-1234` with your actual Google Cloud project ID, e.g. `kerfuffle-443622` in the `Makefile`. Replace `my-region` with your actual region, e.g. `us-west2` and replace `my-project` with `kerfuffle` in the .tf files.
4. Run `make init`. The service will fail to start because we haven't pushed the Docker image yet (since we need to create the artifact registry first).
5. Run `make`. This will build the Docker image, push it to the Google Artifact Registry, and deploy it to Cloud Run.

### Steps for a Flask Web Application

1. Create the `app` directory and add your Flask `main.py` there.
2. Replace the last two commands in `Dockerfile` with the commented-out versions (using `gunicorn` instead of `uvicorn`).
3. Go to steps 2-5 of the FastAPI API deployment steps.

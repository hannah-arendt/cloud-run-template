provider "google" {
  project = var.project_id
  region  = var.region
}

resource "google_artifact_registry_repository" "repo" {
  repository_id = var.repository_id
  format        = "DOCKER"
  location      = var.region
}

resource "google_storage_bucket" "data" {
  name                        = "${var.project_id}-data"
  location                    = var.region
  uniform_bucket_level_access = true
  #   force_destroy               = true # Change later to avoid losing session data
}

resource "google_cloud_run_v2_service" "my-project" {
  name     = "my-project"
  location = var.region
  project  = var.project_id
  deletion_protection = false

  template {
    service_account = google_service_account.my-project_sa.email

    containers {
      image = "${var.region}-docker.pkg.dev/${var.project_id}/${var.repository_id}/my-project:latest"
      ports {
        container_port = 8080
      }

      env {
        name  = "DATA_BUCKET"
        value = google_storage_bucket.data.name
      }

      env {
        name = "API_KEY"
        value_source {
          secret_key_ref {
            secret  = google_secret_manager_secret.api_key.id
            version = "latest"
          }
        }
      }
    }

    max_instance_request_concurrency = 80  # or 1 if you want strict serial
    scaling {
      max_instance_count = 1              # restrict to one instance
    }
  }

  traffic {
    type    = "TRAFFIC_TARGET_ALLOCATION_TYPE_LATEST"
    percent = 100
  }
}

resource "google_service_account" "my-project_sa" {
  account_id   = "my-project-sa"
  display_name = "my-project Cloud Run Service Account"
}

resource "google_cloud_run_service_iam_member" "invoker" {
  location = google_cloud_run_v2_service.my-project.location
  project  = google_cloud_run_v2_service.my-project.project
  service  = google_cloud_run_v2_service.my-project.name

  role   = "roles/run.invoker"
  member = "allUsers"
}

resource "google_storage_bucket_iam_member" "my-project_session_rw" {
  bucket = google_storage_bucket.data
  role   = "roles/storage.objectAdmin"
  member = "serviceAccount:${google_service_account.my-project_sa.email}"
}

resource "google_secret_manager_secret" "api_key" {
  secret_id = "my-project-api-key"
  replication {
    user_managed {
      replicas {
        location = var.region
      }
    }
  }
}

resource "google_secret_manager_secret_version" "api_key_version" {
  secret      = google_secret_manager_secret.api_key.id
  secret_data = var.api_key
}

resource "google_secret_manager_secret_iam_member" "my-project_sa_access" {
  secret_id = google_secret_manager_secret.api_key.id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.my-project_sa.email}"
}

output "cloud_run_url" {
  value       = google_cloud_run_v2_service.my-project.uri
  description = "URL of the deployed Cloud Run service"
}

output "data_bucket_name" {
  value       = google_storage_bucket.data.name
  description = "Name of the GCS bucket storing our data"
}
output "cluster_name" {
  value = google_container_cluster.primary.name
}

output "region" {
  value = var.region
}

output "artifact_registry_repo" {
  value = google_artifact_registry_repository.docker_repo.repository_id
}

output "artifact_registry_location" {
  value = google_artifact_registry_repository.docker_repo.location
}

output "artifact_registry_hostname" {
  value = "${google_artifact_registry_repository.docker_repo.location}-docker.pkg.dev"
}

output "image_repository" {
  value = "${google_artifact_registry_repository.docker_repo.location}-docker.pkg.dev/${var.project_id}/${google_artifact_registry_repository.docker_repo.repository_id}/mission-status-api"
}

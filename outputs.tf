output "static_ip_address" {
  description = "The static IP address of the compute instance"
  value       = data.google_compute_address.existing_static_ip.address
}

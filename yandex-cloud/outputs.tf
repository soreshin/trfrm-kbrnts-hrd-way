######################################################
#                  Output block                      #
######################################################

output "external_cluster_IP" {
  value = yandex_lb_network_load_balancer.kubernetes-load-balancer.listener.*.external_address_spec[0].*.address[0]
}

output "controllers_internal_ip_addresses" {
  value = yandex_compute_instance.controllers.*.network_interface.0.ip_address
}

output "workers_internal_ip_addresses" {
  value = yandex_compute_instance.workers.*.network_interface.0.ip_address
}

output "controllers_external_ip_addresses" {
  value = yandex_compute_instance.controllers.*.network_interface.0.nat_ip_address
}

output "workers_external_ip_addresses" {
  value = yandex_compute_instance.workers.*.network_interface.0.nat_ip_address
}
######################################################
#                  Output block                      #
######################################################

output "external_cluster_IP" {
  value = yandex_lb_network_load_balancer.kubernetes-load-balancer.listener.*.external_address_spec[0].*.address[0]
}

output "internal_ip_address_controller-0" {
  value = yandex_compute_instance.controller-0.network_interface.0.ip_address
}
output "internal_ip_address_controller-1" {
  value = yandex_compute_instance.controller-1.network_interface.0.ip_address
}
output "internal_ip_address_controller-2" {
  value = yandex_compute_instance.controller-2.network_interface.0.ip_address
}

output "internal_ip_address_worker-0" {
  value = yandex_compute_instance.worker-0.network_interface.0.ip_address
}
output "internal_ip_address_worker-1" {
  value = yandex_compute_instance.worker-1.network_interface.0.ip_address
}
output "internal_ip_address_worker-2" {
  value = yandex_compute_instance.worker-2.network_interface.0.ip_address
}


output "external_ip_address_controller-0" {
  value = yandex_compute_instance.controller-0.network_interface.0.nat_ip_address
}
output "external_ip_address_controller-1" {
  value = yandex_compute_instance.controller-1.network_interface.0.nat_ip_address
}
output "external_ip_address_controller-2" {
  value = yandex_compute_instance.controller-2.network_interface.0.nat_ip_address
}

output "external_ip_address_worker-0" {
  value = yandex_compute_instance.worker-0.network_interface.0.nat_ip_address
}
output "external_ip_address_worker-1" {
  value = yandex_compute_instance.worker-1.network_interface.0.nat_ip_address
}
output "external_ip_address_worker-2" {
  value = yandex_compute_instance.worker-2.network_interface.0.nat_ip_address
}

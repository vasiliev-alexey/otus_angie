output "instance_external_ip" {
  value = yandex_compute_instance.linux-vm.network_interface.0.nat_ip_address
}
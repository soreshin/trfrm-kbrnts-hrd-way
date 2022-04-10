terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  required_version = ">= 0.13"
}

provider "yandex" {
  token     = var.yc_token
  cloud_id  = var.yc_project.cloud_id
  folder_id = var.yc_project.folder_id
  zone      = var.yc_zone
}

######################################################
#                   DataSources                      #
######################################################

data "yandex_compute_image" "ubuntu20_04" {
  family = "ubuntu-2004-lts"
}


# yc compute instance create \
#     --async \
#     --name controller-${i} \
#     --hostname controller-${i} \
#     --zone $(yc config get compute-default-zone) \
#     --cores 2 --memory 8 \
#     --create-boot-disk size=30,image-folder-id=standard-images,image-family=ubuntu-2004-lts \
#     --network-interface subnet-name=kubernetes,nat-ip-version=ipv4,ipv4-address=10.240.0.1${i} \
#     --labels type=controller,project=kubernetes-the-hard-way \
#     --ssh-key ~/.ssh/id_rsa.pub

######################################################
#                   Controllers                      #
######################################################
resource "yandex_compute_instance" "controllers" {
  count = 3

  name                      = "controller-${count.index}"
  hostname                  = "controller-${count.index}"
  allow_stopping_for_update = true

  labels = {
    type    = "controller"
    project = "kubernetes-the-hard-way"
  }

  resources {
    cores  = 2
    memory = 8
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu20_04.image_id
    }
  }

  network_interface {
    subnet_id  = yandex_vpc_subnet.kubernetes.id
    nat        = true
    ip_address = "10.240.0.1${count.index}"
  }

  metadata = {
    user-data = templatefile("user-data.tfpl", {
      ssh_public_key = var.ssh_public_key
    })
  }
}

# yc compute instance create \
#     --async \
#     --name worker-${i} \
#     --hostname worker-${i} \
#     --zone $(yc config get compute-default-zone) \
#     --cores 2 --memory 8 \
#     --create-boot-disk size=30,image-folder-id=standard-images,image-family=ubuntu-2004-lts \
#     --network-interface subnet-name=kubernetes,nat-ip-version=ipv4,ipv4-address=10.240.0.2${i} \
#     --metadata pod-cidr=10.200.${i}.0/24 \
#     --labels type=worker,project=kubernetes-the-hard-way \
#     --ssh-key ~/.ssh/id_rsa.pub

######################################################
#                      Workers                       #
######################################################
resource "yandex_compute_instance" "workers" {
  count = 3

  name                      = "worker-${count.index}"
  hostname                  = "worker-${count.index}"
  allow_stopping_for_update = true

  labels = {
    type    = "worker"
    project = "kubernetes-the-hard-way"
  }

  resources {
    cores  = 2
    memory = 8
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu20_04.image_id
    }
  }

  network_interface {
    subnet_id  = yandex_vpc_subnet.kubernetes.id
    nat        = true
    ip_address = "10.240.0.2${count.index}"
  }

  metadata = {
    user-data = templatefile("user-data.tfpl", {
      ssh_public_key = var.ssh_public_key
    })
    pod-cidr  = "10.200.0.0/24"
  }
}

######################################################
#                  Load balancer                    #
######################################################
resource "yandex_lb_network_load_balancer" "kubernetes-load-balancer" {
  name = "kubernetes-load-balancer"

  listener {
    name        = "kubernetes-listener"
    port        = 6443
    target_port = 6443
    external_address_spec {
      ip_version = "ipv4"
    }
  }

  attached_target_group {
    target_group_id = yandex_lb_target_group.kubernetes-target-pool.id

    healthcheck {
      name                = "http"
      interval            = 2
      timeout             = 1
      unhealthy_threshold = 2
      healthy_threshold   = 2
      http_options {
        path = "/"
        port = 80
      }
    }
  }
}

resource "yandex_lb_target_group" "kubernetes-target-pool" {
  name      = "kubernetes-target-pool"
  region_id = "ru-central1"

  dynamic "target" {
    for_each = yandex_compute_instance.controllers.*.network_interface.0.ip_address

    content {
      subnet_id = yandex_vpc_subnet.kubernetes.id
      address   = target.value
    }
  }
}


######################################################
#                  Network block                     #
######################################################
resource "yandex_vpc_network" "kubernetes-the-hard-way" {
  name = "kubernetes-the-hard-way"
}

resource "yandex_vpc_subnet" "kubernetes" {
  name           = "kubernetes"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.kubernetes-the-hard-way.id
  v4_cidr_blocks = ["10.240.0.0/24"]
  route_table_id = yandex_vpc_route_table.kubernetes-route-table.id
}

resource "yandex_vpc_route_table" "kubernetes-route-table" {
  network_id = yandex_vpc_network.kubernetes-the-hard-way.id

  dynamic "static_route" {
    for_each = ["0", "1", "2"]

    content {
      destination_prefix = "10.200.${static_route.value}.0/24"
      next_hop_address   = "10.240.0.2${static_route.value}"
    }
  }
}
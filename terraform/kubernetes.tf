resource "kubernetes_namespace" "app" {
  metadata {
    name = "app-namespace"
  }
}

resource "kubernetes_deployment" "app" {
  metadata {
    name      = "time-api"
    namespace = kubernetes_namespace.app.metadata[0].name
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "time-api"
      }
    }

    template {
      metadata {
        labels = {
          app = "time-api"
        }
      }

      spec {
        container {
          image = "gcr.io/${var.project_id}/shortlet-app-image:latest"
          name  = "time-api"

          port {
            container_port = 3000
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "app" {
  metadata {
    name      = "time-api-service"
    namespace = kubernetes_namespace.app.metadata[0].name
  }

  spec {
    selector = {
      app = "time-api"
    }

    port {
      port        = 80
      target_port = 3000
    }

    type = "LoadBalancer"  # Ensure this is set to LoadBalancer
  }

  depends_on = [
    kubernetes_deployment.app
  ]
}

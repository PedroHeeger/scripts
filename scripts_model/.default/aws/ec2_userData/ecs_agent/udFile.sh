#!/bin/bash
echo "ECS_CLUSTER=${var.clusterName}" | sudo tee -a /etc/ecs/ecs.config
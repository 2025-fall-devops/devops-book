resource "aws_eks_cluster" "cluster" {
  name     = var.name
  role_arn = data.aws_iam_role.lab_role.arn
  version  = var.eks_version

  vpc_config {
    subnet_ids = data.aws_subnets.default.ids
  }
}

resource "aws_eks_node_group" "nodes" {
  cluster_name    = aws_eks_cluster.cluster.name
  node_group_name = var.name
  node_role_arn   = data.aws_iam_role.lab_role.arn
  subnet_ids      = data.aws_subnets.default.ids
  instance_types  = [var.instance_type]

  scaling_config {
    min_size     = var.min_worker_nodes
    max_size     = var.max_worker_nodes
    desired_size = var.min_worker_nodes
  }

  lifecycle {
    ignore_changes = [scaling_config[0].desired_size]
  }
}

data "aws_iam_role" "lab_role" {
  name = "LabRole"
}

resource "aws_eks_addon" "eks_pod_identity_agent" {
  count        = var.enable_eks_pod_identity_agent ? 1 : 0
  cluster_name = aws_eks_cluster.cluster.name
  addon_name   = "eks-pod-identity-agent"
}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

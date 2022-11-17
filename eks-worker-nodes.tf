#
# EKS Worker Nodes Resources
#  * IAM role allowing Kubernetes actions to access other AWS services
#  * EKS Node Group to launch worker nodes
#

resource "aws_iam_role" "percipient-citizen-node" {
  name = "terraform-eks-percipient-citizen-node"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "percipient-citizen-node-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.percipient-citizen-node.name
}

resource "aws_iam_role_policy_attachment" "percipient-citizen-node-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.percipient-citizen-node.name
}

resource "aws_iam_role_policy_attachment" "percipient-citizen-node-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.percipient-citizen-node.name
}

resource "aws_eks_node_group" "percipient-citizen" {
  cluster_name    = aws_eks_cluster.percipient-citizen.name
  node_group_name = "percipient-citizen"
  node_role_arn   = aws_iam_role.percipient-citizen-node.arn
  subnet_ids      = aws_subnet.percipient-citizen[*].id

  scaling_config {
    desired_size = 2
    max_size     = 3
    min_size     = 2
  }

  depends_on = [
    aws_iam_role_policy_attachment.percipient-citizen-node-AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.percipient-citizen-node-AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.percipient-citizen-node-AmazonEC2ContainerRegistryReadOnly,
  ]
}

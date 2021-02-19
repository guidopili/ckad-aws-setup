# ckad-aws-setup

This is just a weekend experiment to get started with CKAD course, but without using the provided scripts since they use docker as runtime provided, and it has been deprecated by k8s.

To get started, use terraform to create the skeleton of the infrastructure:
```
export AWS_PROFILE=<YOUR PROFILE>
export AWS_DEFAULT_REGION=<YOUR REGION>

cd terraform
terraform init
terraform apply
```

This will creare a VPC with one subnet, one security group that allows all traffic from everywhere and two EC2 instances, one master and one slave. 
In addition, it will create in the root of your project a file called `hosts.ini` that can be used for ansible.

To run ansible, just run, from the root folder:
```
ansible-playbook --inventory hosts.ini ansible/main.yaml
```

If you want to use cri-o as container runtime, instead of using `containerd`, you can pass an extra var to the ansible command, such as:
```
ansible-playbook --inventory hosts.ini ansible/main.yaml -e "use_crio=yes"
```

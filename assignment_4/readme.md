Assignment 4:
-------------------
#### Problem Statement
1. Write Ansible playbook to install and configure Jenkins on EC2 instance
2. Write Ansible playbook to install and configure Tomcat 8 on EC2 instance
   1. Set tomcat application user name as admin and password as Welcome123
3. Write Ansible playbook to install and configure Nexus on EC2 instance

#### Solution
   
#### Step 1: Provision Ansible Controller node on EC2 ubuntu instance
1. Provision EC2 ubuntu instance on EC2 console and name it Ansible-Controller
2. SSH to EC2 instance (Ansible-Controller)
```
$ ssh -i .ssh/devopsworkslab_ssh_keys.pem ubuntu@ec2-3-109-56-4.ap-south-1.compute.amazonaws.com
```
3. Install Ansible, PIP & BOTO3 SDK
```
sudo apt-get update && sudo apt-add-repository -y ppa:ansible/ansible && sudo apt-get update && sudo apt-get install -y ansible && sudo apt install python3-pip -y && sudo pip install boto boto3
```
4. Verify the installation
```
ubuntu@ip-172-31-4-218:~$ python3 --version
Python 3.8.10
ubuntu@ip-172-31-4-218:~$ pip list boto | grep boto
boto                   2.49.0
boto3                  1.20.46
botocore               1.23.46
ubuntu@ip-172-31-4-218:~$ ansible --version
ansible [core 2.12.1]
  config file = /etc/ansible/ansible.cfg
  configured module search path = ['/home/ubuntu/.ansible/plugins/modules', '/usr/share/ansible/plugins/modules']
  ansible python module location = /usr/lib/python3/dist-packages/ansible
  ansible collection location = /home/ubuntu/.ansible/collections:/usr/share/ansible/collections
  executable location = /usr/bin/ansible
  python version = 3.8.10 (default, Nov 26 2021, 20:14:08) [GCC 9.3.0]
  jinja version = 2.10.1
  libyaml = True
ubuntu@ip-172-31-4-218:~$ 
```
#### Step 2: Provision EC2 instance to host Jenkins using Ansible playbook
1. Create IAM role "EC2Admin" with AmazonEC2FullAccess policy and attach to EC2 instance (Ansible-Controller)
2. SSH to Ansible-Controller node, Add host definition for localhost
```
sudo vi /etc/ansible/hosts
Add the following lines at the bottom of the file
[localhost]
local
```
3. Copy playbook to home directory on Ansible-Controller
4. Launch playbook
```
ubuntu@ip-172-31-4-218:~/playbooks$ sudo ansible-playbook create_ec2.yml

PLAY [provisioning EC2 instances using Ansible] ***********************************************************************************************************************

TASK [Create Security group] ******************************************************************************************************************************************
changed: [local -> localhost]

TASK [Launch EC2 instance] ********************************************************************************************************************************************
[DEPRECATION WARNING]: amazon.aws.ec2 has been deprecated. The ec2 module is based upon a deprecated version of the AWS SDKs and is deprecated in favor of the
ec2_instance module. Please update your tasks. This feature will be removed from amazon.aws in version 4.0.0. Deprecation warnings can be disabled by setting
deprecation_warnings=False in ansible.cfg.
[DEPRECATION WARNING]: The 'ec2' module has been deprecated and replaced by the 'ec2_instance' module'. This feature will be removed from amazon.aws in version 4.0.0. 
 Deprecation warnings can be disabled by setting deprecation_warnings=False in ansible.cfg.
changed: [local -> localhost]

TASK [Add Tags EC2 instance] ******************************************************************************************************************************************
changed: [local -> localhost] => (item={'id': 'i-0bf73b1bd6d6a98b0', 'ami_launch_index': '0', 'private_ip': '172.31.3.78', 'private_dns_name': 'ip-172-31-3-78.ap-south-1.compute.internal', 'public_ip': '65.1.108.80', 'dns_name': 'ec2-65-1-108-80.ap-south-1.compute.amazonaws.com', 'public_dns_name': 'ec2-65-1-108-80.ap-south-1.compute.amazonaws.com', 'state_code': 16, 'architecture': 'x86_64', 'image_id': 'ami-0851b76e8b1bce90b', 'key_name': 'devopsworkslab_ssh_keys', 'placement': 'ap-south-1b', 'region': 'ap-south-1', 'kernel': None, 'ramdisk': None, 'launch_time': '2022-01-30T08:01:33.000Z', 'instance_type': 't2.small', 'root_device_type': 'ebs', 'root_device_name': '/dev/sda1', 'state': 'running', 'hypervisor': 'xen', 'tags': {}, 'groups': {'sg-0170d6cdd35727584': 'jenkins-security-grp'}, 'virtualization_type': 'hvm', 'ebs_optimized': False, 'block_device_mapping': {'/dev/sda1': {'status': 'attached', 'volume_id': 'vol-077836f9c6cf98d01', 'delete_on_termination': True}}, 'tenancy': 'default'})

PLAY RECAP ************************************************************************************************************************************************************
local                      : ok=3    changed=3    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0

```

#### Step 3: Generate & Deploy SSH public key of ubuntu user from Ansible-Controller instance to JenkinsMaster instance
1. SSH to Ansible-Controller instance and generate SSH key pair
2. SSH to JenkinsMaster instance and Add SSH public key of ubuntu user from Ansible-Controller node to ~/.ssh/authorized_keys

#### Step 4: Add host detail of JenkinsMaster instance to Ansible inventory file
1. On Ansible-Controller instance, Add JenkinsMaster identity in /etc/ansible/hosts
```
[jenkins]
65.0.32.239 ansible_ssh_user=ubuntu ansible_ssh_private_key_file=/home/ubuntu/.ssh/id_rsa ansible_python_interpreter=/usr/bin/python3
```
2. Verify connectivity to JenkinsMaster instance
```
ubuntu@ip-172-31-4-218:~$ ansible jenkins -m ping
65.0.32.239 | SUCCESS => {
    "changed": false,
    "ping": "pong"
}
```
#### Step 5: Install Tomcat 8 using Ansible role on JenkinsMaster instance
1. On Ansible-Controller, Create a role for tomcat
```
ubuntu@ip-172-31-4-218:~/tomcat$ ansible-galaxy init tomcat --offline
- Role tomcat was created successfully

ubuntu@ip-172-31-4-218:~/ansible_roles$ tree .
.
└── tomcat
    ├── README.md
    ├── defaults
    │   └── main.yml
    ├── files
    ├── handlers
    │   └── main.yml
    ├── meta
    │   └── main.yml
    ├── tasks
    │   └── main.yml
    ├── templates
    ├── tests
    │   ├── inventory
    │   └── test.yml
    └── vars
        └── main.yml

9 directories, 8 files
```
2. Launch tomcat installation by executing
```
ansible-playbook site.yml
```
#### Validation
Tomcat instance can be reached at http://ec2-65-0-32-239.ap-south-1.compute.amazonaws.com:9090/

#### Step 6: Install Jenkins using Ansible role on JenkinsMaster instance
1. On Ansible-Controller, Create a role for jenkins
```
ubuntu@ip-172-31-4-218:~/ansible_roles$ ansible-galaxy init jenkins --offline
- Role jenkins was created successfully
```
2. Launch Jenkins installation by executing
```
ansible-playbook site.yml
```
#### Validation
Jenkins can be reached at http://ec2-65-0-32-239.ap-south-1.compute.amazonaws.com:8080/

For initialAdmin password, SSH to JenkinsMaster instance and cat /var/lib/jenkins/secrets/initialAdminPassword
Go for recommended plugin installation

#### Step 7: Install Nexus OSS using Ansible role on JenkinsMaster instance
1. On Ansible-Controller, Create a role for nexus-oss
```
ubuntu@ip-172-31-4-218:~/ansible_roles$ ansible-galaxy init nexus-oss --offline   
- Role nexus-oss was created successfully
```
2. Launch Nexus OSS installation by executing
```
ansible-playbook site.yml
```
#### Validation
Nexus OSS can be reached at http://ec2-65-0-32-239.ap-south-1.compute.amazonaws.com:7070/
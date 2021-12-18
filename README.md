#Project 1
## Automated ELK Stack Deployment

The files in this repository were used to configure the network depicted below.

![diagram](https://github.com/mbaig801/project/blob/main/diagram/Cloud%20Security%20project.drawio.png)

These files have been tested and used to generate a live ELK deployment on Azure. They can be used to either recreate the entire deployment pictured above. Alternatively, select portions of the playbook file may be used to install only certain pieces of it, such as Filebeat.

  - filebeat-playbook.yml
 
---
  - name: installing and launching filebeat
    hosts: web
    become: yes
    tasks:

    - name: download filebeat deb
      command: curl -L -O https://artifacts.elastic.co/downloads/beats/filebeat/filebeat-7.6.1-amd64.deb 
               
    - name: install filebeat deb
      command: sudo dpkg -i filebeat-7.6.1-amd64.deb

    - name: drop in filebeat.yml 
      copy:
        src: /etc/ansible/filebeat-config.yml
        dest: /etc/filebeat/filebeat.yml

    - name: enable and configure system module
      command: sudo filebeat modules enable system

    - name: setup filebeat
      command: sudo filebeat setup

    - name: start filebeat service
      command: sudo service filebeat start

    - name: enable service filebeat on boot
      systemd:
        name: filebeat 
        enabled: yes


Metricbeat-playbook.yml 

---
  - name: Install metric beat
    hosts: web
    become: true
    tasks:
    
    - name: download metricbeat
      command: curl -L -O https://artifacts.elastic.co/downloads/beats/metricbeat/metricbeat-7.6.1-amd64.deb

    - name: install metricbeat
      command: dpkg -i metricbeat-7.6.1-amd64.deb
  
    - name: drop in metricbeat config
      copy:
        src: /etc/ansible/metricbeat-config.yml
        dest: /etc/metricbeat/metricbeat.yml

    - name: enable and configure docker module for metric beat
      command: metricbeat modules enable docker

    - name: setup metricbeat
      command: metricbeat setup

    - name: start metricbeat
      command: service metricbeat start

    - name: enable service metricbeat on boot
      systemd:
        name: metricbeat
        enabled: yes


install-elk.yml

---
  - name: config with elk vm 
    hosts: elk   
    become: True
    tasks: 
    - name: Config_map_count
      sysctl:   
        name: vm.max_map_count
        value: 262144
        sysctl_set: yes

    - name: docker.io
      apt:
        force_apt_get: yes
        update_cache: yes
        name: docker.io

    - name: install pip3
      apt:
        force_apt_get: yes
        name: python3-pip
        state: present

    - name: install docker python module
      pip:
        name: docker
        state: present

    - name: download and launch a docker web container
      docker_container:
        name: elk
        image: sebp/elk:761
        state: started
        restart_policy: always
        published_ports: 
          - 5601:5601
          - 9200:9200
          - 5044:5044

    - name: enable docker service
      systemd:
        name: docker
        enabled: yes 


Setup2.yml

---
  - name: Configure web servers
    hosts: web
    become: yes
    tasks: 

    - name: Install docker.io
      apt: 
        update_cache: yes
        name: docker.io 
        state: present 

    - name: Install pip3
      apt: 
        force_apt_get: yes
        name: python3-pip
        state: present 

    - name: Install Python Docker module
      pip: 
        name: docker
        state: present
         
    - name: Install Docker python module
      pip: 
        name: docker
        state: present

    - name: download and launch a docker web container
      docker_container:
        name: dvwa
        image: cyberxsecurity/dvwa
        state: started
        published_ports: 80:80

    - name: Enable docker service
      systemd:
        name: docker
        enabled: yes

This document contains the following details:
- Description of the Topologu
- Access Policies
- ELK Configuration
  - Beats in Use
  - Machines Being Monitored
- How to Use the Ansible Build


### Description of the Topology

The main purpose of this network is to expose a load-balanced and monitored instance of DVWA, the D*mn Vulnerable Web Application.

Load balancing ensures that the application will be highly available, in addition to restricting access to the network.
- Load balancers protect application from availability, allowing multiple client request to be shared across a number of servers.
- The advantage of using a Jump Box is that it reduces the attack surface by ensuring remote connections to the cloud network come through a single virtual machine. In addition, it also allows remote connections to the Jump Box that can be monitored easily to identify irregular remote connections. 


Integrating an ELK server allows users to easily monitor the vulnerable VMs for changes to the configuration and system files.
- Filebeat is used for monitoring log files
- Metricbeat is used for collecting operating systems and also service statistics from monitored virtual machines

The configuration details of each machine may be found below.


| Name     | Function | IP Address | Operating System |
|----------|----------|------------|------------------|
| Jump Box | Gateway  | 10.2.0.5   | Linux            |
| Web-1    | DVWA     | 10.2.0.8   | Linux            |
| Web-2    | DVWA     | 10.2.0.9   | Linux            |
| Elk-VM   | ELK      | 10.0.0.4   | Linux            |

### Access Policies

The machines on the internal network are not exposed to the public Internet. 

Only the Jump Box machine can accept connections from the Internet. Access to this machine is only allowed from the following IP addresses:
- 20.102.85.105

Machines within the network can only be accessed by jump box.
- The Jump Box can be accessed by the Elk-VM (Elk-VM) using the SSH command. The Jump Box’s IP address is 10.2.0.5

A summary of the access policies in place can be found in the table below.

| Name     | Publicly Accessible | Allowed IP Addresses | Allowed ports|
|----------|---------------------|----------------------|--------------|
| Jump-Box | Yes (SSH)           |     73.44.104.81     |  22          |
|  Web-1   | Yes (HTTP)          |     73.44.104.81     |  80          |
|  Web-2   | Yes (HTTP)          |     73.44.104.81     |  80          |
|  Elk-VM  | Yes (HTTP)          |     73.44.104.81     |  5601        |

### Elk Configuration

Ansible was used to automate configuration of the ELK machine. No configuration was performed manually, which is advantageous because...
- To help facilitate the operating system and software updates
- Build and deployment is performed automatically, quickly and consistenly 
- To deploy the virtual machines consistently, and rapid configurations of the virtual machine. To make sure that all the security measures can be scripted to minimize the attack while also enabling the use of more or fewer virtual machines in a cluster to meet the demand of the company.


The playbook implements the following tasks:

Playbook 1 setup2.yml 
 - Setup2.yml is used to set up the DVWA servers running in a Docker container on each of the web services. It is implemented in the following order:
 - Installs Docker
 - Installs Python
 - Installs Docker’s Python Module
 - Downloads and Launches the DVWA Docker container 
 - Enables the Docker service

Playbook 2: Install-elk.yml

 - Install-elk.yml is used to set up and launch the elk repository server which is inside a docker container on the Elk server. It is implemented in the following order:
 - Installs Docker
 - Installs Python
 - Installs Docker’s Python Module
 - Increase a virtual memory to support the Elk stack
 - Increase memory to support the Elk stack
 - Download and also launch the docker Elk container

Playbook 3: Filebeat-playbook.yml

 - Filebeat-playbook.yml is used for filebeat on each of the web servers so that they can be tracked using the Elk services which are running on the Elk-VM. It is implemented in the following order:
 - Downloads and Installs Filebeat
 - Enables and also configures the system module
 - Configures and launches Filebeat

The following screenshot displays the result of running `docker ps` after successfully configuring the ELK instance.

![TODO: Update the path with the name of your screenshot of docker ps output](https://github.com/mbaig801/project/blob/main/diagram/Sudo%20docker%20ps.drawio.png)

### Target Machines & Beats
This ELK server is configured to monitor the following machines:
- Web-1 IP: 10.2.0.8
- Web-2 IP: 10.2.0.9 

We have installed the following Beats on these machines:
- Filebeat-7.6.1-darwin-x86_64.tar.gz
- Metricbeat-7.6.1-darwin-x86_64.tar.gz
 
These Beats allow us to collect the following information from each machine:
- Filebeat collects and sends logs from the virtual machines that are running to the filebeat agent
- Metricbeat collects and sends system metric from the operating system and services of the virtual machines that are running the metricbeat


### Using the Playbook
In order to use the playbook, you will need to have an Ansible control node already configured. Assuming you have such a control node provisioned: 

SSH into the control node and follow the steps below:
- Copy the filebeat config file to Elk VM.
- Update the hosts file to include the correct IP which is located in the (/etc/ansible/)
- Run the playbook, and navigate to kibana to check that the installation worked as expected.


- Filebeat.yml 
- Install-elk.yml
- metricbeat.yml


- You would update the hosts file (/etc/ansible/) to include the virtual machines that ansible is going to be run on, in addition to this you also list the web/elk servers IP  

- To make sure that the Elk server is running you go to the http://[your.VM.IP]:5601/app/kibana


- Run the playbook ansible-playbook filebeat.yml
- Edit the playbook using nano (name the yml file)


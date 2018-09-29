# ansible zabbix-agent in centos7

chenag hosts ....
```
[zabbix_agent]
192.168.0.11
```

產生 ssh key
```
rm -rf /root/.ssh
ssh-keygen -t rsa -f /root/.ssh/id_rsa -q -N ""
```
複製 key .....
```
yum install -y sshpass
sshpass -p "vagrant" ssh-copy-id -i ~/.ssh/id_rsa.pub -o StrictHostKeyChecking=no root@192.168.0.11
```

install ansible
```
yum install -y epel-release
yum install -y python-pip python-netaddr ansible git
pip install --upgrade pip
pip install --upgrade Jinja2
```
cheange zabbix_agentd.conf
```
sed -i 's/192.168.0.200/192.168.0.100/g' zabbix_agentd.conf
```

# ansible -i hosts all -m ping

# ansible-playbook zabbix_agent.yml





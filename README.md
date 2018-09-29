# ansible zabbix-agent in centos7

chenag hosts list ....
```
[zabbix_agent]
192.168.0.11
```

build ssh key
```
rm -rf /root/.ssh
ssh-keygen -t rsa -f /root/.ssh/id_rsa -q -N ""
```
copy key to all client
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
cheange Zabbix Server IP as new noe 192.168.0.100 (zabbix_agentd.conf)
```
sed -i 's/192.168.0.200/192.168.0.100/g' zabbix_agentd.conf
```
check client ...
```
# ansible -i hosts all -m ping

192.168.0.11 | SUCCESS => {
    "changed": false,
    "ping": "pong"
}
```

install now ...
```
# ansible-playbook -i hosts zabbix_agent.yml

PLAY [Install zabbix_agent] *****************************************************************************************************************************************

TASK [Gathering Facts] **********************************************************************************************************************************************
ok: [192.168.0.11]

TASK [zabbix-release] ***********************************************************************************************************************************************
changed: [192.168.0.11]

TASK [install zabbix-release rpm from a local file] *****************************************************************************************************************
changed: [192.168.0.11]

TASK [zabbix-agent] *************************************************************************************************************************************************
changed: [192.168.0.11]

TASK [install zabbix-agent rpm from a local file] *******************************************************************************************************************
changed: [192.168.0.11]

TASK [copy zabbix configuration file] *******************************************************************************************************************************
changed: [192.168.0.11]

TASK [Start zabbix-agent] *******************************************************************************************************************************************
changed: [192.168.0.11]

PLAY RECAP **********************************************************************************************************************************************************
192.168.0.11               : ok=7    changed=6    unreachable=0    failed=0

```



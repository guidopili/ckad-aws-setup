[master]
${master_ip} new_hostname=master

[minion]
%{ for agent in agents ~}
${agent.ip} new_hostname=${agent.hostname}
%{ endfor ~}

[all:children]
master
minion

[all:vars]
ansible_connection=ssh
ansible_user=ubuntu

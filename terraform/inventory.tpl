[master]
${master_ip}

[minion]
%{ for agent in agents ~}
${agent.ip} minion_hostname=${agent.hostname}
%{ endfor ~}

[all:children]
master
minion

[all:vars]
ansible_connection=ssh
ansible_user=ubuntu

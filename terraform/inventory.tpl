[master]
${master_ip}

[minion]
%{ for agent_ip in agent_ips ~}
${agent_ip}
%{ endfor ~}

[all:children]
master
minion

[all:vars]
ansible_connection=ssh
ansible_user=ubuntu

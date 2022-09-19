[masters]
${master_ip}

[workers]
%{ for ip in workers_ip ~}
${ip}
%{ endfor ~}
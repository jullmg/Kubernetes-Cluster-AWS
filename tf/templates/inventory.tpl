[masters]
%{ for ip in master_ip ~}
${ip}
%{ endfor ~}

[workers]
%{ for ip in workers_ip ~}
${ip}
%{ endfor ~}
---
- hosts: localhost
  vars:
    configfile: ~/.ssh/config
    dnsfile: /tmp/dnsfile
    marker: "Auto Terraform ${hosts}"
    sshkey: /etc/keys/ohq-${env}.key
    hosts: ${hosts}
    user: azureuser
    pub_ip: "${ip}"
    pip: "${pip}"
  tasks:
  - name: Show IP address
    debug:
      msg: "{{ hosts }} IP address: {{ pub_ip }}"
  - name: Create SSH config file if not exists
    file:
      path: "{{ configfile }}"
      mode: 0644
      state: touch
  - name: Add VM connection to the SSH config
    blockinfile:
      dest: "{{configfile}}"
      marker: "# {mark} {{ marker }}"
      block: |
        Host {{ hosts }}
          User {{user}}
          StrictHostKeyChecking no
          UserKnownHostsFile /dev/null
          IdentityFile {{ sshkey }}
          Hostname {{ pub_ip }}
          # Hostname {{ pip }}
          Port 22
  - name: DNS settings
    shell: |
      echo "{{ hosts }}:{{ pip }}" >> {{ dnsfile }}

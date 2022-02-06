---
- hosts: localhost
  vars:
    configfile: ~/.ssh/config
    dnsfile: /tmp/dnsfile
    marker: "Auto Terraform ${hosts}"
    sshkey: /etc/keys/azure-ssh.key
    hosts: ${hosts}
    user: ${user}
    passwd: "${passwd}"
    pip: "${pip}"
    pvtip: "${pvtip}"
  tasks:
  - name: Show IP address
    debug:
      msg: "{{ hosts }} IP address: {{ pip }}"
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
          User {{ user }}
          StrictHostKeyChecking no
          UserKnownHostsFile /dev/null
          IdentityFile {{ sshkey }}
          Hostname {{ pip }}
          # Hostname {{ pvtip }}
          Port 22
  - name: DNS settings
    shell: |
      echo "{{ hosts }}:{{ pip }}" >> {{ dnsfile }}

  - name: Update vars and hosts
    shell: |
      echo "{{ pip }}" >> ../ansible/hosts
      echo "ansible_password: {{ passwd }}" >> ../ansible/vars.yml

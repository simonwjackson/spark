#while true
#do
  autossh \
    -M 0                    `# Disable the built-in AutoSSH monitoring` \
    -o "ServerAliveInterval 30" \
    -o "ServerAliveCountMax 2147483" \
    -N                      `# No commands` \
    -C                      `# Compress` \
    -D 9999                 `# SOCKS5 Dynmic Port` \
    -L 3000:localhost:3000  `# Forward DBIQP` \
    simonwjackson@10.10.15.18
#done

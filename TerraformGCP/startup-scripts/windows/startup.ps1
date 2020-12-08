Set-Location "C:\"

Set-DnsClientServerAddress -InterfaceIndex 12 -ServerAddresses 10.28.41.208, 10.27.43.60, 10.26.10.80, 10.28.10.80

wget https://downloads.puppetlabs.com/windows/puppet-agent-x64-latest.msi -OutFile C:\puppet-agent-x64-latest.msi

msiexec /qn /norestart /i C:/puppet-agent-x64-latest.msi PUPPET_MASTER_SERVER=uspup-mom.us.deloitte.com PUPPET_AGENT_CERTNAME=HOSTNAME.us.deloitte.com


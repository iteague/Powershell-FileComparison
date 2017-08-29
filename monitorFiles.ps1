function list($filesList){
    $ls_List = @()
    foreach ($item in $filesList){
        $ls_List += ls $item
    }
    return $ls_List
}

function watch($f, $interval) {
    $sha1 = New-Object System.Security.Cryptography.SHA1CryptoServiceProvider
    $hashfunction = '[System.BitConverter]::ToString($sha1.ComputeHash([System.IO.File]::ReadAllBytes($file)))'
    $files = @{}
    $altered = @()
    $missing = @()
    $count = 0
    foreach ($file in $f) {
        $hash = iex $hashfunction
        $files[$file.Name] = $hash
        echo "$hash`t$($file.FullName)"
    }
    while ($count -lt 10) {
        sleep $interval
        foreach ($file in $f) {
            if(Test-Path $file){
                if ($file -notin $altered){
                    $hash = iex $hashfunction
                    if ($files[$file.Name] -ne $hash) {
                        $altered += $file
                        $altered += "`n"
                        $count = 1
                    }
                }
            }
            elseif($file -notin $missing){
                $missing += $file 
                $missing += "`n"  
                $count = 1          
            }
        if ($altered.Count -gt 0 -Or $missing.Count -gt 0){
                $count += 1
        }
        }
    }
    
    $body = "CHANGES TO FILES: `n`n Altered Files: `n" + $altered + "`n `n Missing Files:`n" + $missing
    $PSEmailServer = "smtp.gmail.com"                                                                         #REPLACE smtp.gmail.com WITH YOUR SMTP SERVER
    Send-MailMessage -To "youremail@email.com" -From "fileAlert@powershell.com" -Subject "PowerShell Script Reporting File Changes" -Body $body #REPLACE youremail@email.com WITH YOUR EMAIL
    
}

$filesList = Get-Content "C:\Users\iteague\Desktop\file verification in powershell\filesList.txt"
$f = list $filesList

watch $f 10
# Define your email settings
$SMTPServer = "smtp.gmail.com"
$SMTPPort = 25
$SMTPUsername = ""
$SMTPPassword = ""
$EmailTo = ""
$EmailFrom = ""
$EmailSubjectDown = "Switch Down Notification"
$EmailSubjectUp = "Switch Up Notification"
$EmailSubjectReminder = "Switch Down Reminder"
$EmailBodyDown = "One of the switches is down."
$EmailBodyUp = "The switch is back up."
$EmailBodyReminder = "The switch is still down after three days."

$CSVFilePath = "" #Path to where you have the CSV saved.

# Read the list of switch IPs and hostnames from the CSV file
$Switches = Import-Csv -Path $CSVFilePath #Feel free to change the variables, this started as a switch monitoring project.

# Create a hashtable to store the state and last notification time of each switch
$SwitchState = @{}

while ($true) {
    Write-Host "Checking Switches..." #this is really just a comment at the beggining of the loop to ensure it was still running, when working correctly, you can remove.
    foreach ($Switch in $Switches) {
        $IP = $Switch.IP
        $Hostname = $Switch.Hostname
        
        if ($IP -eq $null -or $IP -eq "") {
            Write-Host "Error: IP address is null or empty."
            continue
        }

        if (Test-Switch -IP $IP) {
            # Switch is up
            if ($SwitchState.ContainsKey($IP) -and $SwitchState[$IP] -eq "Down") {
                # Switch was previously down; send an "Up" notification
                Write-Host "Sending email notification for $Hostname ($IP) being up."
                Send-Email -To $EmailTo -Subject $EmailSubjectUp -Body "$Hostname ($IP) is up. $EmailBodyUp"
            }
            $SwitchState[$IP] = "Up" # Update the switch state
        }
        else {
            # Switch is down
            if (-not $SwitchState.ContainsKey($IP) -or $SwitchState[$IP] -eq "Up") {
                # Switch was previously up or not tracked; send a "Down" notification
                Write-Host "Sending email notification for $Hostname ($IP) being down."
                Send-Email -To $EmailTo -Subject $EmailSubjectDown -Body "$Hostname ($IP) is down. $EmailBodyDown"
                $SwitchState[$IP] = "Down" # Update the switch state
                $SwitchState["NotificationTime_$IP"] = (Get-Date)
            }
            else {
                # Switch is still down; check if it's been down for three days
                $NotificationTime = $SwitchState["NotificationTime_$IP"]
                $TimeDown = (Get-Date) - $NotificationTime
                if ($TimeDown.TotalDays -ge 3) {
                    # Send a reminder after three days
                    Write-Host "Sending email reminder for $Hostname ($IP) being down for three days."
                    Send-Email -To $EmailTo -Subject $EmailSubjectReminder -Body "$Hostname ($IP) is still down after three days. $EmailBodyReminder"
                    $SwitchState["NotificationTime_$IP"] = (Get-Date) # Update the notification time
                }
            }
        }
    }
    
    # Wait for 5 minutes
    Start-Sleep -Seconds 300
}

# Function to send email
function Send-Email {
    param (
        [string]$To,
        [string]$Subject,
        [string]$Body
    )
    
    $SMTPClient = New-Object Net.Mail.SmtpClient($SMTPServer)
    $SMTPClient.EnableSsl = $true
    $SMTPClient.Port = $SMTPPort
    $SMTPClient.Credentials = New-Object System.Net.NetworkCredential($SMTPUsername, $SMTPPassword)
    
    $MailMessage = New-Object System.Net.Mail.MailMessage
    $MailMessage.From = $EmailFrom
    $MailMessage.Subject = $Subject
    $MailMessage.Body = $Body
    $MailMessage.To.Add($To)
    
    $SMTPClient.Send($MailMessage)
}
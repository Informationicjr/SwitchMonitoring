# SwitchMonitoring
# Switch monitoring script in PowerShell / IP Monitoring

# Basically, this was created because I didn't have a switch monitoring tool. So, I made one. When finished I realized this can be used to track the status of any device that responds to ICMP requests.

# What this script does is it takes the list of IP addresses provided, and pings it, if it gets a reply with 100% it will mark it as up, and record the activity time. If it is down, it will send an email, and record the activity time. If the IP comes back up, you'll receive an update email
# Ensure to update the SMTP Server and port, in this example, it uses a Gmail account, so you will need to allow less secure apps. So if using in an organization I recommend creating an account that is specific for this and does not have any other permissions. 
# The web address to allow less secure apps is "https://support.google.com/accounts/answer/6010255?hl=en" You'll click if less secure apps are off, and then it redirects you and allows you to turn it on.

# After allowing less secure apps, you'll be able to send emails from that account to any specified email. 
# Use the Example of CSV and insert your IPs and Hostnames, Hostnames can be left blank, but you'll only receive the IP address in the email and hostname may appear as NULL. 

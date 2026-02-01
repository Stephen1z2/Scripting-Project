# Connect to Exchange Online
Write-Host "Connecting to Exchange Online..."
Connect-ExchangeOnline

# Prompt for user email
$user = Read-Host "Enter the user's email address"

# Get all distribution groups the user is a member of
$groups = Get-DistributionGroup | Where-Object {
    (Get-DistributionGroupMember -Identity $_.Identity -ResultSize Unlimited | Where-Object {$_.PrimarySmtpAddress -eq $user})
}

if ($groups.Count -eq 0) {
    Write-Host "$user is not a member of any distribution groups."
    Disconnect-ExchangeOnline -Confirm:$false
    return
}

Write-Host "$user is a member of the following distribution groups:"
$groups | ForEach-Object { Write-Host $_.DisplayName }

# Confirm removal
$remove = Read-Host "Do you want to remove $user from all these groups? (Y/N)"
if ($remove -eq "Y" -or $remove -eq "y") {
    foreach ($group in $groups) {
        Remove-DistributionGroupMember -Identity $group.Identity -Member $user -Confirm:$false
        Write-Host "Removed from $($group.DisplayName)"
    }
} else {
    Write-Host "No changes made."
}

# Disconnect session
Disconnect-ExchangeOnline -Confirm:$false
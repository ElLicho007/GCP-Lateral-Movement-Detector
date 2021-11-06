# GCP Lateral Movement Detector 

This script iterates through all the available projects in your GCP account and extracts the vms that can access other vms.
It based on the misconfiguration of a vm instance configured with the default service account and all cloud api access scope.
The script uses the user's GCP login account.
Deploying vms instances with a default service account is a bad practice and should be avoided at all times.
Review your instances and eliminate this misconfiguration and stay safe!
The author is an offensice security researcher @ Orca Security.

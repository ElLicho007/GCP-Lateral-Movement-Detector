# GCP Lateral Movement Detector 

This script iterates through all the available projects in your GCP account and extracts the vms that can access other vms (e.g. can use the command gcloud compute ssh).

It based on the misconfiguration of a vm instance configured with the default service account and all cloud api access scope.

The script uses the user's GCP login account.

Deploying vms instances with a permissive permissions of the default service account is a bad practice and should be avoided at all times.

Review the output to eliminate this misconfiguration and stay safe!

The author is an offensive security researcher @ Orca Security.

# Dependencies
Install the gcloud sdk prior running the script.
You can get the installation instructions for your OS here:
https://cloud.google.com/sdk/docs/install#deb

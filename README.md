# GCP Lateral Movement Detector 

The script iterates through all the available projects in your GCP account and extracts the compute engine instances that can access other compute engine instances (e.g. can use the command gcloud compute ssh).

It is based on the misconfiguration of a compute engine instance configured with the default service account and all cloud api access scope.

Deploying compute engine instances with permissive permissions (editor role) of the default service account is a bad practice and should be avoided at all times.

Review the output to easily analyze this misconfiguration in order to prevent attackers from spread in your GCP environment and stay safe!

# Disclaimer
This tool is for testing and educational purposes only. 

Any other usage for this code is not allowed. 

Use at your own risk.

The author bears NO responsibility for misuse of this tool.

By using this you accept the fact that any damage caused by the use of this tool is your responsibility.

# Dependencies
Install the gcloud sdk prior running the script.

You can get the installation instructions for your OS here:
https://cloud.google.com/sdk/docs/install

# TODO
Add iteration for organizations level

# Author
<a href="https://twitter.com/ellicho007">Liat Vaknin</a> is an offensive security researcher @ <a href="https://twitter.com/orcasec?s=11">Orca Security</a>.

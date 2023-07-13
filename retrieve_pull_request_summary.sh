#!/bin/bash

# Set the repository URL
repo_url="https://github.com/octocat/Hello-World"

# Get the current time
now=$(date +"%Y-%m-%dT%H:%M:%SZ")

# Get a list of all pull requests in the last week
pull_requests=$(curl -s "https://api.github.com/repos/$repo_url/pulls?per_page=100&since=$now" | jq -r ".[] | {title, state, created_at}")

# Create an email summary report
email_body="
Hi [MANAGER/SCRUM-MASTER NAME],

Here is a summary of all pull requests in the last week for the repository [REPO_NAME]:

* Opened:
    * [TITLE] ([STATE]) - Created on [CREATED_AT]
* Closed:
    * [TITLE] ([STATE]) - Closed on [CREATED_AT]
* In progress:
    * [TITLE] ([STATE]) - Created on [CREATED_AT]

Please let me know if you have any questions.

Thanks,
[YOUR NAME]
"

# Print the email summary report to the console
echo $email_body

# Send the email summary report
#mail -s "[REPO_NAME] Pull Request Summary" [MANAGER/SCRUM-MASTER EMAIL] < $email_body

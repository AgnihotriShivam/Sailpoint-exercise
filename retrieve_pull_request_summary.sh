#!/bin/bash

# Prompt user for repository owner and name
read -p "Enter the repository owner: " REPO_OWNER
read -p "Enter the repository name: " REPO_NAME

# Date range for the last week
START_DATE=$(date -d "1 week ago" +%Y-%m-%d)
END_DATE=$(date +%Y-%m-%d)

# GitHub API endpoint for pull requests
API_URL="https://api.github.com/repos/$REPO_OWNER/$REPO_NAME/pulls?state=all&sort=created&direction=desc"

# Fetch pull requests from the GitHub API
pull_requests=$(curl -s -H "Authorization: token <GITHUB_TOKEN>" $API_URL)

# Process pull requests
opened=0
closed=0
in_progress=0

for pr in $(echo "$pull_requests" | jq -r '.[] | @base64'); do
  pr_info=$(echo "$pr" | base64 --decode)
  
  pr_created=$(echo "$pr_info" | jq -r '.created_at | sub("Z$"; "") | strptime("%Y-%m-%dT%H:%M:%S") | mktime')
  if (( pr_created < $(date -d $START_DATE +%s) )); then
    break
  fi
  
  pr_state=$(echo "$pr_info" | jq -r '.state')
  
  if (( pr_created >= $(date -d $START_DATE +%s) )); then
    case $pr_state in
      "open")
        ((opened++))
        ;;
      "closed")
        ((closed++))
        ;;
    esac
  else
    ((in_progress++))
  fi
done

# Print the summary
echo "Pull Request Summary for $REPO_OWNER/$REPO_NAME"
echo "--------------------------------------------------"
echo "Opened: $opened"
echo "Closed: $closed"
echo "In Progress: $in_progress"

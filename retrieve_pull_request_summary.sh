#!/bin/bash

# Read repository owner and name from user input
read -p "Enter the repository owner: " REPO_OWNER
read -p "Enter the repository name: " REPO_NAME

# Make API request to retrieve pull requests
response=$(curl -s "https://api.github.com/repos/$REPO_OWNER/$REPO_NAME/pulls")
echo $response

# Extract summary details from the API response
pr_count=$(echo "$response" | jq length)
echo "Pull Requests Summary for $REPO_OWNER/$REPO_NAME:"
echo "---------------------------------------------"
echo "Total Pull Requests: $pr_count"

# Loop through the pull requests and print their details
for ((i = 0; i < pr_count; i++)); do
  pr_number=$(echo "$response" | jq -r ".[$i].number")
  pr_title=$(echo "$response" | jq -r ".[$i].title")
  pr_author=$(echo "$response" | jq -r ".[$i].user.login")
  pr_state=$(echo "$response" | jq -r ".[$i].state")
  pr_created=$(echo "$response" | jq -r ".[$i].created_at")
  pr_updated=$(echo "$response" | jq -r ".[$i].updated_at")

  echo
  echo "Pull Request #$pr_number"
  echo "Title: $pr_title"
  echo "Author: $pr_author"
  echo "State: $pr_state"
  echo "Created: $pr_created"
  echo "Updated: $pr_updated"
done

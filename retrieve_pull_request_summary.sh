#!/bin/bash

# Read repository owner and name from user input
read -p "Enter the repository owner: " REPO_OWNER
read -p "Enter the repository name: " REPO_NAME

# Calculate the date one week ago
ONE_WEEK_AGO=$(date -d "7 days ago" +%Y-%m-%d)

# Make API request to retrieve pull requests
response=$(curl -s "https://api.github.com/repos/$REPO_OWNER/$REPO_NAME/pulls")

echo $response > response.json

# Filter pull requests created within the last week
filtered_response=$(echo "$response" | jq --arg ONE_WEEK_AGO "$ONE_WEEK_AGO" '. | map(select(.created_at >= $ONE_WEEK_AGO))')

echo $filtered_response > filtered_response.json

# Extract summary details from the filtered API response
pr_count=$(echo "$filtered_response" | jq length)
closed_count=0
in_progress_count=0

echo "Pull Requests Summary for $REPO_OWNER/$REPO_NAME (Last Week):"
echo "----------------------------------------------------------"
echo "Total Pull Requests: $pr_count"

# Loop through the filtered pull requests and print their details
for ((i = 0; i < pr_count; i++)); do
  pr_number=$(echo "$filtered_response" | jq -r ".[$i].number")
  pr_title=$(echo "$filtered_response" | jq -r ".[$i].title")
  pr_author=$(echo "$filtered_response" | jq -r ".[$i].user.login")
  pr_state=$(echo "$filtered_response" | jq -r ".[$i].state")
  pr_created=$(echo "$filtered_response" | jq -r ".[$i].created_at")
  pr_updated=$(echo "$filtered_response" | jq -r ".[$i].updated_at")

  echo
  echo "Pull Request #$pr_number"
  echo "Title: $pr_title"
  echo "Author: $pr_author"
  echo "State: $pr_state"
  echo "Created: $pr_created"
  echo "Updated: $pr_updated"

  # Count closed and in-progress pull requests
  if [[ "$pr_state" == "closed" ]]; then
    ((closed_count++))
  elif [[ "$pr_state" == "open" ]]; then
    ((in_progress_count++))
  fi
done

echo
echo "Summary:"
echo "----------------------------------------------------------"
echo "Closed Pull Requests: $closed_count"
echo "Pull Requests In Progress: $in_progress_count"

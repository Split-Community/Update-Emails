#!/bin/bash
# A bash script to change the user's email address using the Split API

# Read the API key from a file named api_key.txt
API_KEY=$(cat api_key.txt)

# Read the limit of users to be changed from the first argument to the script, defaulting to 1 if not provided
LIMIT=${1:-1}

# Old and new email addresses as arguments to the script
OLD_EMAIL_DOMAIN=${2:-"@test.com"}
NEW_EMAIL_DOMAIN=${3:-"@custom.com"}

# Initialize a counter variable to keep track of the number of users changed
COUNTER=0

# Use curl to send a GET request to the Split API, passing the API key as a header, to get the list of UserIDs
# Capture the response body in a variable
USER_LIST=$(curl -s -X GET "https://api.split.io/internal/api/v2/users?status=ACTIVE&limit=200" \
  -H "Authorization: Bearer $API_KEY")

# Loop through each UserID in the response body, which is a JSON array
for user in $(echo "$USER_LIST" | jq -r '.data[] | .id'); do
  # Check if the counter has reached the limit
  if [ "$COUNTER" -ge "$LIMIT" ]; then
    # Break out of the loop
    break
  fi

  # Sleep for one second to not trip the rate limiter
  sleep 1
  
  # Use curl to send a GET request to the Split API, passing the API key as a header, to get the user details
  # Capture the response body in a variable
  USER_DETAILS=$(curl -s -X GET "https://api.split.io/internal/api/v2/users/$user" \
    -H "Authorization: Bearer $API_KEY")

  # Extract the email address from the user details, which is a JSON object
  EMAIL=$(echo "$USER_DETAILS" | jq -r '.email')

  # Check if the email address ends with the old domain
  if [[ "$EMAIL" == *"$OLD_EMAIL_DOMAIN" ]]; then
    # Replace the old domain with the new domain
    NEW_EMAIL="${EMAIL/$OLD_EMAIL_DOMAIN/$NEW_EMAIL_DOMAIN}"
    # Use curl to send a PUT request to the Split API, passing the API key as a header and the new email as a data field
    # Capture the HTTP status code and the response body in variables
    RESPONSE=$(curl -s -w "%{http_code}" -X PUT "https://api.split.io/internal/api/v2/users/$user" \
      -H "Authorization: Bearer $API_KEY" \
      -H "Content-Type: application/json" \
      -d "{\"email\": \"$NEW_EMAIL\"}")
    # Extract the status code and the body from the response
    STATUS=${RESPONSE:(-3)}
    BODY=${RESPONSE%???}
    # Check if the status code is 200 (OK)
    if [ "$STATUS" == "200" ]; then
      # Print a message indicating the success of the request
      echo "Changed $EMAIL to $NEW_EMAIL"
      # Increment the counter by one
      COUNTER=$((COUNTER + 1))
    else
      # Print a message indicating the failure of the request, along with the status code and the response body
      echo "Failed to change $EMAIL to $NEW_EMAIL"
      echo "Status code: $STATUS"
      echo "Response body: $BODY"
    fi
  fi
done

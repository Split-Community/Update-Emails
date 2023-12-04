# Update-Emails
Bash Script to update email addresses

A basic shell script that should update user email addresses. It takes 3 arguments.
 
 1. The first is the number of email addresses to change, which defaults to 1.
 
 2. The second argument is the old email domain to check for (defaults to @test.com)
 
 3. The third is the new email domain to use (defaults to @custom.com)
 
You will need the command line utilities `jq` and `curl` installed on your machine.
 
You will also need a text file with the api key in it called `api_key.txt`
 
I’d recommend running this with just 1 or 2 users to confirm that it works and they can log in. All permissions and other information should be maintained as these are just changing the email address and leaving the user id consistent. If you encounter any issues with rate limiting, it should be safe to run again, as it will simply pick up back where it left off. There’s a default sleep for 1 second between iterations.

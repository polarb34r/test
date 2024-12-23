$jsonData = @{
    maxResults = 5
    startAt = 0
    total = 11
    isLast = $false
    values = @(
        @{
            required = $false
            schema = @{
                type = "user"
                system = "assignee"
            }
            name = "Assignee"
            fieldId = "assignee"
            autoCompleteUrl = "http://localhost:8080/rest/api/latest/user/assignable/search?issueKey=null&username="
            hasDefaultValue = $false
            operations = @("set")
        },
        @{
            required = $false
            schema = @{
                type = "array"
                items = "attachment"
                system = "attachment"
            }
            name = "Attachment"
            fieldId = "attachment"
            hasDefaultValue = $false
            operations = @("set")
        },
        @{
            required = $true
            schema = @{
                type = "issuetype"
                system = "issuetype"
            }
            name = "Issue Type"
            fieldId = "issuetype"
            hasDefaultValue = $false
            operations = @()
            allowedValues = @(
                @{
                    self = "http://localhost:8080/rest/api/2/issuetype/10000"
                    id = "10000"
                    description = "A task that needs to be done."
                    iconUrl = "http://localhost:8080/secure/viewavatar?size=large&avatarId=10318"
                }
            )
        }
    )
}

# Convert the JSON data to a string
$json = ConvertTo-Json -InputObject $jsonData -Depth 10

# Output the JSON string
Write-Host $json


# Create a hashtable with the request headers
$headers = @{
    "Content-Type" = "application/json"
}

# Send the POST request to the webhook
Invoke-WebRequest -Uri $webhookUrl -Method Post -Headers $headers -Body $json

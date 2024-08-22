# test

name: Notify Teams on PR

on:
  pull_request:
    types: [opened, reopened, synchronize]

jobs:
  notify:
    runs-on: ubuntu-latest
    steps:
      - name: Get PR Author Details
        id: get-user-details
        shell: pwsh
        run: |
          $userResponse = Invoke-RestMethod -Uri "https://api.github.com/users/${{ github.event.pull_request.user.login }}" -Headers @{ Authorization = "token ${{ secrets.GITHUB_TOKEN }}" }
          $name = $userResponse.name
          $email = $userResponse.email
          echo "name=$name" >> $env:GITHUB_ENV
          echo "email=$email" >> $env:GITHUB_ENV

      - name: Get PR Reviewers
        id: get-reviewers
        shell: pwsh
        run: |
          $prUrl = "${{ github.event.pull_request.url }}"  # Use the API URL, not the HTML URL
          $reviewersResponse = Invoke-RestMethod -Uri "$prUrl/requested_reviewers" -Headers @{ Authorization = "token ${{ secrets.GITHUB_TOKEN }}" }
          $reviewers = $reviewersResponse.users.login -join ', '  # Joining reviewers into a string
          echo "reviewers=$reviewers" >> $env:GITHUB_ENV

      - name: Send PR Notification to Teams
        shell: pwsh
        run: |
          $prUrl = "${{ github.event.pull_request.html_url }}"
          $prTitle = "${{ github.event.pull_request.title }}"
          $prAuthor = "${{ github.event.pull_request.user.login }}"
          $prAuthorName = "${{ env.name }}"
          $prAuthorEmail = "${{ env.email }}"
          $prReviewers = "${{ env.reviewers }}"
          $webhookUrl = "YOUR_TEAMS_WEBHOOK_URL"          
          $prAuthorInfo = if ($prAuthorName -and $prAuthorEmail) { "$prAuthorName <$prAuthorEmail>" } else { $prAuthor }

          Invoke-RestMethod -Uri $webhookUrl -Method Post -ContentType 'application/json' -Body (@{
              title = "New Pull Request Opened"
              text  = "A new pull request titled `'$prTitle'` has been opened by $prAuthorInfo. Reviewers: $prReviewers. [View PR]($prUrl)"
          } | ConvertTo-Json)

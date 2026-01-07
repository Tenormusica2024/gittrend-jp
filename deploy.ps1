param (
    [string]$message = "Update"
)

git add .
git commit -m "$message"
git push

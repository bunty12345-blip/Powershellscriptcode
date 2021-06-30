# Constants
$sourceDrive = "C:\"
$sourceFolder = "ImportantFiles"
$sourcePath = $sourceDrive + $sourceFolder
$s3Bucket = "Backups"
$s3Folder = "Archive"

# Constants – Amazon S3 Credentials
$accessKeyID="AKIAIOSFODNN7EXAMPLE"
$secretAccessKey="wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY"

# Constants – Amazon S3 Configuration
$config=New-Object Amazon.S3.AmazonS3Config
$config.RegionEndpoint=[Amazon.RegionEndpoint]::"us-west-2"
$config.ServiceURL = "https://s3-us-west-2.amazonaws.com/"

# Instantiate the AmazonS3Client object
$client=[Amazon.AWSClientFactory]::CreateAmazonS3Client($accessKeyID,$secretAccessKey,$config)

# FUNCTION – Iterate through subfolders and upload files to S3
function RecurseFolders([string]$path) {
  $fc = New-Object -com Scripting.FileSystemObject
  $folder = $fc.GetFolder($path)
  foreach ($i in $folder.SubFolders) {
    $thisFolder = $i.Path

    # Transform the local directory path to notation compatible with S3 Buckets and Folders
    # 1. Trim off the drive letter and colon from the start of the Path
    $s3Path = $thisFolder.ToString()
    $s3Path = $s3Path.SubString(2)
    # 2. Replace back-slashes with forward-slashes
    # Escape the back-slash special character with a back-slash so that it reads it literally, like so: "\\"
    $s3Path = $s3Path -replace "\\", "/"
    $s3Path = "/" + $s3Folder + $s3Path

    # Upload directory to S3
    Write-S3Object -BucketName $s3Bucket -Folder $thisFolder -KeyPrefix $s3Path
  }

  # If subfolders exist in the current folder, then iterate through them too
  foreach ($i in $folder.subfolders) {
    RecurseFolders($i.path)
  }
}

# Upload root directory files to S3
$s3Path = "/" + $s3Folder + "/" + $sourceFolder
Write-S3Object -BucketName $s3Bucket -Folder $sourcePath -KeyPrefix $s3Path

# Upload subdirectories to S3
RecurseFolders($sourcePath)
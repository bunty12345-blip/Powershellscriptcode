#powershell script to delete files and directories from local drive after uploading them to AWS S3 Bucket which is 1 day older.
Get-ChildItem –Path "C:\path\to\folder" -Recurse | Where-Object {($_.LastWriteTime -lt (Get-Date).AddDays(-1))} | Remove-Item

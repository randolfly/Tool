function Get-OldFiles {
    # 获取桌面上所有的文件信息
    $all_files = Get-ChildItem $env:USERPROFILE\Desktop -Recurse -File

    # 循环文件信息，返回其文件名，路径，以及没有访问的天数
    foreach ($file in $all_files) {
        $not_access_day = ((Get-Date) - $file.LastAccessTime).Days
        if ($not_access_day -ge 8) {
            $value = [PSCustomObject] @{
                Name          = ""
                NotAccessDays = 0
                Path          = ""
            }
            $value.Name = $file.Name
            $value.Path = $file.FullName
            $value.NotAccessDays = $not_access_day
            Write-Output $value
        }
    }
}
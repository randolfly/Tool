#===============Auxiliary Function===============

function Run-Step([string] $Desciption, [ScriptBlock]$script) {
    Write-Host -NoNewline "Loading " $Desciption.PadRight(20)
    & $script
    Write-Host "`u{2705}"
}

[System.Console]::InputEncoding = [System.Console]::OutputEncoding = New-Object System.Text.UTF8Encoding

Write-Host "Loading Powershell $($PSVersionTable.PSVersion)..." -ForegroundColor 3
Write-Host

#===============PS Setting===============

Run-Step "PSReadLine" {
    # PSOption Setting
    Import-Module PSReadLine

    $PSOption = @{
        PredictionSource    = 'History'
        PredictionViewStyle = 'ListView'
        ShowToolTips        = $false
    }
    Set-PSReadlineKeyHandler -Chord Tab -Function MenuComplete
    Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
    Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward

    Set-PSReadLineOption @PSOption

    # PowerShell parameter completion shim for the dotnet CLI
    Register-ArgumentCompleter -Native -CommandName dotnet -ScriptBlock {
        param($commandName, $wordToComplete, $cursorPosition)
        dotnet complete --position $cursorPosition "$wordToComplete" | ForEach-Object {
            [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
        }
    }
}

Run-Step "oh-my-posh" {
    # theme
    oh-my-posh init pwsh --config D:\Work\Scoop\apps\oh-my-posh\current\themes\night-owl.omp.json | Invoke-Expression
    # oh-my-posh init powershell --config ~\pwsh-randolf.json | Invoke-Expression
    Enable-PoshTooltips
}


#===============ALIAS===============
$ShortName = @{
    'IP' = 'Get-IPInfo'
    's'  = 'Select-Object'
}
$ShortName.Keys | ForEach-Object { Set-Alias $_ $ShortName.$_ }

function 2ico { magick $args[0] -set filename:name '%t' -resize '128x128>' '%[filename:name].ico' } 
function dl { youtube-dl $args[0] --write-sub --write-thumbnail --skip-download --quiet }
function nf { New-Item $args[0] -ItemType File }

# 打开当前工作目录
function OpenCurrentFolder {
    param
    (
        # 输入要打开的路径
        # 用法示例：open C:\
        # 默认路径：当前工作文件夹
        $Path = '.'
    )
    Invoke-Item $Path
}
Set-Alias -Name ocf -Value OpenCurrentFolder

# 当前目录下搜索文件名
function SearchTargetFile {
    param
    (
        # 输入要打开的路径
        # 用法示例：open C:\
        # 默认路径：当前工作文件夹
        $FileName = 'file'
    )
    ls -File -Recurse | ?{$_.Name -like "*$FileName*"} | %{$_.FullName}
}
Set-Alias -Name stf -Value SearchTargetFile

function BackupConfig {
    param
    (
        # 输入要打开的路径
        # 用法示例：open C:\
        # 默认路径：当前工作文件夹
        $Name,
        $Target = $Name,
        $Path = 'E:\Backup\软件配置\Config\'
    )
    New-Item -Name $Name -Path $Path -ItemType SymbolicLink -Target $Target
}

Set-Alias -Name bc -Value BackupConfig

# generate gitignore For PowerShell v3
Function gig {
    param(
      [Parameter(Mandatory=$true)]
      [string[]]$list
    )
    $params = ($list | ForEach-Object { [uri]::EscapeDataString($_) }) -join ","
    Invoke-WebRequest -Uri "https://www.toptal.com/developers/gitignore/api/$params" | select -ExpandProperty content | Out-File -FilePath $(Join-Path -path $pwd -ChildPath ".gitignore") -Encoding ascii
  }


#===============System functionality===============

#===============NETWORK===============
# 1. 获取所有 Network Interface
function Get-AllNic {
    Get-NetAdapter | Sort-Object -Property MacAddress
}
Set-Alias -Name getnic -Value Get-AllNic

# 2. 获取 IPv4 关键路由
function Get-IPv4Routes {
    Get-NetRoute -AddressFamily IPv4 | Where-Object -FilterScript { $_.NextHop -ne '0.0.0.0' }
}
Set-Alias -Name getip -Value Get-IPv4Routes

# 3. 获取 IPv6 关键路由
function Get-IPv6Routes {
    Get-NetRoute -AddressFamily IPv6 | Where-Object -FilterScript { $_.NextHop -ne '::' }
}
Set-Alias -Name getip6 -Value Get-IPv6Routes

#===============FILE SYSTEM===============

function ShowFileSize {
    param
    (
        [string]$Directory
    )
    get-childitem $Directory | 
    % { $f = $_ ; 
        get-childitem -r $_.FullName | 
        measure-object -property length -sum | 			
        select @{Name = "Name"; Expression = { $f } }, @{Name = "Sum (MB)"; Expression = { "{0:N1}" -f ($_.sum / 1MB) } } }
}

Set-Alias -Name getSize -Value ShowFileSize
$localBin = "$env:USERPROFILE\.local\bin"
if ($env:PATH -notlike "*$localBin*") {
    $env:PATH = "$localBin;$env:PATH"
}

function Invoke-ClearLs {
    Clear-Host
    Get-ChildItem
}

Set-Alias -Name l -Value Invoke-ClearLs
Set-Alias -Name c -Value Clear-Host
Set-Alias -Name n -Value nvim
function Invoke-Claude { claude --effort max @args }
Set-Alias -Name cl -Value Invoke-Claude
Set-Alias -Name co -Value codex
Set-Alias -Name t -Value todoist

function Invoke-GlowDark {
    glow --style dark @args
}

Set-Alias -Name g -Value Invoke-GlowDark

function Invoke-ListAll {
    Get-ChildItem -Force @args
}

Set-Alias -Name la -Value Invoke-ListAll

function Invoke-Tree {
    param(
        [int]$L = 0,
        [switch]$a,
        [switch]$d,
        [switch]$f,
        [Parameter(ValueFromRemainingArguments)]
        [string[]]$Remaining
    )

    $targetPath = if ($Remaining) { $Remaining[0] } else { "." }
    $targetPath = Resolve-Path $targetPath

    # Box-drawing characters (PS 5.1 compatible)
    $tee    = [char]0x251C # |-
    $elbow  = [char]0x2514 # L-
    $pipe   = [char]0x2502 # |
    $dash   = [char]0x2500 # -
    $branch = "${dash}${dash}"

    $script:dirCount = 0
    $script:fileCount = 0

    function Show-Tree {
        param(
            [string]$Path,
            [string]$Prefix,
            [int]$Depth
        )

        if ($L -gt 0 -and $Depth -ge $L) { return }

        $getArgs = @{ Path = $Path; ErrorAction = "SilentlyContinue" }
        if ($a) { $getArgs["Force"] = $true }

        $items = Get-ChildItem @getArgs | Sort-Object { -not $_.PSIsContainer }, Name
        if ($d) { $items = $items | Where-Object { $_.PSIsContainer } }

        $count = ($items | Measure-Object).Count
        $i = 0

        foreach ($item in $items) {
            $i++
            $isLast = ($i -eq $count)
            $connector = if ($isLast) { "${elbow}${branch}" } else { "${tee}${branch}" }
            $displayName = if ($f) { $item.FullName } else { $item.Name }

            Write-Host "${Prefix}${connector} ${displayName}"

            if ($item.PSIsContainer) {
                $script:dirCount++
                $childPrefix = if ($isLast) { "${Prefix}    " } else { "${Prefix}${pipe}   " }
                Show-Tree -Path $item.FullName -Prefix $childPrefix -Depth ($Depth + 1)
            } else {
                $script:fileCount++
            }
        }
    }

    Write-Host "."
    Show-Tree -Path $targetPath -Prefix "" -Depth 0

    $summary = "`n${script:dirCount} directories"
    if (-not $d) { $summary += ", ${script:fileCount} files" }
    Write-Host $summary
}

Set-Alias -Name tree -Value Invoke-Tree

$readableWhite = $PSStyle.Foreground.White

$PSStyle.FileInfo.Directory = $readableWhite
$PSStyle.FileInfo.SymbolicLink = $readableWhite

if (Get-Module -ListAvailable -Name PSReadLine) {
    Set-PSReadLineOption -Colors @{
        String  = "White"
        Comment = "`e[36m"
    }
}

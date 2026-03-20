$script:BaseUri = 'https://api.todoist.com/api/v1'
$script:ConfigPath = Join-Path $PSScriptRoot 'config.json'

function Get-TodoistAuthHeader {
    if (-not (Test-Path $script:ConfigPath)) {
        throw "APIトークンが未設定です。Set-TodoistToken を実行してください。"
    }
    $config = Get-Content $script:ConfigPath -Raw | ConvertFrom-Json
    $secureToken = $config.Token | ConvertTo-SecureString
    $bstr = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($secureToken)
    $plainToken = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($bstr)
    [System.Runtime.InteropServices.Marshal]::ZeroFreeBSTR($bstr)
    @{ Authorization = "Bearer $plainToken" }
}

function Set-TodoistToken {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false)]
        [string]$Token
    )

    if (-not $Token) {
        $secureInput = Read-Host -Prompt 'Todoist APIトークンを入力' -AsSecureString
    } else {
        $secureInput = ConvertTo-SecureString $Token -AsPlainText -Force
    }

    $encrypted = $secureInput | ConvertFrom-SecureString
    @{ Token = $encrypted } | ConvertTo-Json | Set-Content $script:ConfigPath -Encoding UTF8
    Write-Host 'APIトークンを保存しました。' -ForegroundColor Green
}

function Get-TodoistTask {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false)]
        [string]$Filter,

        [Parameter(Mandatory = $false)]
        [string]$ProjectId
    )

    $headers = Get-TodoistAuthHeader
    $uri = "$($script:BaseUri)/tasks"
    $query = @{}
    if ($Filter)    { $query['filter']     = $Filter }
    if ($ProjectId) { $query['project_id'] = $ProjectId }

    if ($query.Count -gt 0) {
        $qs = ($query.GetEnumerator() | ForEach-Object {
            "$([uri]::EscapeDataString($_.Key))=$([uri]::EscapeDataString($_.Value))"
        }) -join '&'
        $uri = "$uri?$qs"
    }

    $response = Invoke-RestMethod -Uri $uri -Headers $headers -Method Get
    if ($response.results) { $response.results } else { $response }
}

function New-TodoistTask {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Content,

        [Parameter(Mandatory = $false)]
        [string]$Description,

        [Parameter(Mandatory = $false)]
        [string]$ProjectId,

        [Parameter(Mandatory = $false)]
        [string]$DueString,

        [Parameter(Mandatory = $false)]
        [ValidateRange(1, 4)]
        [int]$Priority,

        [Parameter(Mandatory = $false)]
        [string[]]$Labels
    )

    $headers = Get-TodoistAuthHeader
    $headers['Content-Type'] = 'application/json'

    $body = @{ content = $Content }
    if ($Description) { $body['description'] = $Description }
    if ($ProjectId)   { $body['project_id']  = $ProjectId }
    if ($DueString)   { $body['due_string']  = $DueString }
    if ($Priority)    { $body['priority']     = $Priority }
    if ($Labels)      { $body['labels']       = $Labels }

    Invoke-RestMethod -Uri "$($script:BaseUri)/tasks" -Headers $headers -Method Post -Body ($body | ConvertTo-Json -Depth 5)
}

function Complete-TodoistTask {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Id
    )

    $headers = Get-TodoistAuthHeader
    Invoke-RestMethod -Uri "$($script:BaseUri)/tasks/$Id/close" -Headers $headers -Method Post
    Write-Host "タスク $Id を完了しました。" -ForegroundColor Green
}

function Remove-TodoistTask {
    [CmdletBinding(SupportsShouldProcess = $true)]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Id
    )

    if ($PSCmdlet.ShouldProcess("Task $Id", "Delete")) {
        $headers = Get-TodoistAuthHeader
        Invoke-RestMethod -Uri "$($script:BaseUri)/tasks/$Id" -Headers $headers -Method Delete
        Write-Host "タスク $Id を削除しました。" -ForegroundColor Yellow
    }
}

function Get-TodoistProject {
    [CmdletBinding()]
    param()

    $headers = Get-TodoistAuthHeader
    $response = Invoke-RestMethod -Uri "$($script:BaseUri)/projects" -Headers $headers -Method Get
    if ($response.results) { $response.results } else { $response }
}

Export-ModuleMember -Function Set-TodoistToken, Get-TodoistTask, New-TodoistTask, Complete-TodoistTask, Remove-TodoistTask, Get-TodoistProject

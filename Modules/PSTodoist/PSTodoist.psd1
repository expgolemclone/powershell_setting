@{
    RootModule        = 'PSTodoist.psm1'
    ModuleVersion     = '1.0.0'
    GUID              = 'a3f7c8e1-4b2d-4e6f-9a1c-3d5e7f8b0c2a'
    Author            = 'User'
    Description       = 'PowerShell module for Todoist REST API v2'
    PowerShellVersion = '7.0'
    FunctionsToExport = @(
        'Set-TodoistToken'
        'Get-TodoistTask'
        'New-TodoistTask'
        'Complete-TodoistTask'
        'Remove-TodoistTask'
        'Get-TodoistProject'
    )
    CmdletsToExport   = @()
    VariablesToExport  = @()
    AliasesToExport    = @()
}

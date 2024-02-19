function WriteLog {
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Message,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [ValidateRange(1,3)]
        [int]$Level = 1
    )

    $ErrorActionPreference = 'Stop'
    
    $callingFunctionName = (Get-PSCallStack)[1].Command
    switch ($Level) {
        1 {
            Write-Verbose -Message "$callingFunctionName : $Message"
            break
        }
        2 {
            break
        }
        3 {
            Write-Error -Message $Message
            ## Add-Content -Path (Join-Path -Path $script:bricklinkConfiguration.app.log_folder_path -ChildPath
            break
        }
        default {
            throw "Unrecognized log level: [$_]"
        }
    }
    
    
}
function Get-SupersetsWeb {
    [CmdletBinding(DefaultParameterSetName = 'Color')]
    param
    (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [ValidateSet('PART')]
        [string]$Type,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$ItemNumber,

        [Parameter(ParameterSetName = 'ColorID')]
        [ValidateNotNullOrEmpty()]
        [string]$ColorId,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [ValidateSet('SET')]
        [string]$SuperSetType = 'SET'

    )

    $ErrorActionPreference = 'Stop'

    # $paramToApiParamMap = @{
    #     SuperSetType = @{
    #         Key   = 'in'
    #         Value = 'S'
    #     }
    #     ItemNumber   = @{
    #         Key   = 'P'
    #         Value = $ItemNumber
    #     }
    #     ColorId      = @{
    #         Key   = 'colorID'
    #         Value = $ColorId
    #     }
    # }

    # $invParams = @{
    #     Uri    = 'https://www.bricklink.com/catalogItemIn.asp'
    #     Method = 'GET'
    #     Body   = @{
    #         $paramToApiParamMap['SuperSetType']['Key'] = $paramToApiParamMap['SuperSetType']['Value']
    #         $paramToApiParamMap['ItemNumber']['Key']   = $paramToApiParamMap['ItemNumber']['Value']
    #         $paramToApiParamMap['ColorId']['Key']      = $paramToApiParamMap['ColorId']['Value']
    #         'ov'                                       = 'Y'
    #         'v'                                        = '0'
    #         'srt'                                      = '0'
    #         'srtAsc'                                   = 'A'
    #     }
    # }

    # WriteLog -Message "Getting Bricklink supersets of item number [$($ItemNumber)]/ColorID [$($ColorId)] of type [$($Type)]..."
    # $response = InvokeBricklinkWebCall @invParams

    ## parse the HTML table here and return with an embeeded $_.item.no to mimic Get-SuperSets
}
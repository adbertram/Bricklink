Set-StrictMode -Version Latest

$script:rootModuleFolderPath = $PSScriptRoot

$configFileParentFolder = if ($PSVersionTable.PSVersion -lt [Version]"6.0" -or $IsWindows) {
    $env:APPDATA
} elseif ($IsMacOS) {
    "$HOME/Library/Application Support"
} elseif ($IsLinux) {
    "$HOME/.config"
}

$script:apiCallCountTrackingFilePath = "$configFileParentFolder\api_call_count.json"

$script:maxDailyApiCallCount = 5000

# Ensuring the path ends with 'Bricklink' directory.
$configFileParentFolder = Join-Path -Path $configFileParentFolder -ChildPath 'Bricklink'

$exampleConfigFilePath = Join-Path -Path $PSScriptRoot -ChildPath "configuration.example.json"
$script:configFilePath = Join-Path -Path $configFileParentFolder -ChildPath "configuration.json"

# Check if 'Bricklink' folder exists, if not, create it.
if (-not (Test-Path $configFileParentFolder)) {
    Write-Warning -Message "It looks like this is your first time importing the Bricklink module. Be sure to use Save-BlBricklinkConfiguration to save your API keys and authentication information next."
    New-Item -Path $configFileParentFolder -ItemType Directory
}

# Now that the folder definitely exists, copy the file.
if (-not (Test-Path $script:configFilePath)) {
    Copy-Item -Path $exampleConfigFilePath -Destination $script:configFilePath -Force
}

# Get public and private function definition files.
$Public = @(Get-ChildItem -Path $PSScriptRoot\Public\*.ps1 -ErrorAction SilentlyContinue)
$Private = @(Get-ChildItem -Path $PSScriptRoot\Private\*.ps1 -ErrorAction SilentlyContinue)

# Dot source the files.
foreach ($import in @($Public + $Private)) {
    try {
        Write-Verbose "Importing $($import.FullName)"
        . $import.FullName
    } catch {
        Write-Error "Failed to import function $($import.FullName): $_"
    }
}

foreach ($file in $Public) {
    Export-ModuleMember -Function $file.BaseName
}

$script:bricklinkConfiguration = Get-BricklinkConfiguration

enum Color {
    Black
    Blue
    BlueViolet
    BrightGreen
    BrightLightBlue
    BrightLightOrange
    BrightLightYellow
    BrightPink
    Brown
    ChromeSilver
    Copper
    Coral
    DarkAzure
    DarkBlue
    DarkBluishGray
    DarkBrown
    DarkGray
    DarkGreen
    DarkOrange
    DarkPink
    DarkPurple
    DarkRed
    DarkTan
    DarkTurquoise
    FlatDarkGold
    FlatSilver
    GlitterTransClear
    GlitterTransDarkPink
    GlitterTransLightBlue
    GlitterTransNeonGreen
    GlitterTransOrange
    GlitterTransPurple
    GlowInDarkWhite
    Green
    Lavender
    LightAqua
    LightBluishGray
    LightGray
    LightNougat
    Lime
    Magenta
    MediumAzure
    MediumBlue
    MediumLavender
    MediumNougat
    MetallicGold
    MetallicSilver
    NeonGreen
    NeonOrange
    NeonYellow
    Nougat
    OliveGreen
    Orange
    PearlDarkGray
    PearlGold
    Purple
    Red
    ReddishBrown
    Rust
    SandBlue
    SandGreen
    SandPurple
    SandRed
    Tan
    TransBrightGreen
    TransClear
    TransDarkBlue
    TransDarkPink
    TransGreen
    TransMediumBlue
    TransNeonGreen
    TransNeonOrange
    TransNeonYellow
    TransOrange
    TransPurple
    TransRed
    TransYellow
    VeryLightBluishGray
    Violet
    White
    Yellow
    YellowishGreen
}

enum ItemType {
    MINIFIG
    PART
    SET
    BOOK
    GEAR
    CATALOG
    INSTRUCTION
    UNSORTED_LOT
    ORIGINAL_BOX
}


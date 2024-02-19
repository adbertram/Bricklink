Set-StrictMode -Version Latest

$script:rootModuleFolderPath = $PSScriptRoot

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

$script:bricklinkConfiguration = Get-BricklinkConfigurationItem

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


<# #glaxxie v0.1
    .DESCRIPTION
    Script to generate required file for a powershell exercise on Exercism.
#>

Function Get-FilesPath() {
    $projectRoot = (Get-Location).Path

    $ConfigPath = Join-Path     -Path $projectRoot  -ChildPath "/.meta/config.json"
    $config     = Get-Content   -Path $ConfigPath   -Raw | ConvertFrom-Json

    $SolutionPath   = Join-Path -Path $projectRoot  -ChildPath $config.Files.Solution[0]
    $TestFilePath   = Join-Path -Path $projectRoot  -ChildPath $config.Files.Test[0]
    $ExamplePath    = Join-Path -Path $projectRoot  -ChildPath $config.Files.Example[0]
    $TestCasesPath  = Join-Path -Path $projectRoot  -ChildPath "/.meta/tests.toml"
    
    return $ConfigPath, $SolutionPath, $TestFilePath, $ExamplePath, $TestCasesPath
}

Function Add-AuthorToConfig() {
    param($ConfigPath)
    $content = Get-Content -Path $ConfigPath -Raw | ConvertFrom-Json
    $author  = Read-Host -Prompt 'Adding author name'
    $author = $author ? $author : "glaxxie"
    if ($content.Authors -contains $author) {
        Write-Host 'Author already exist'
    }else {
        $content.Authors += $author
    }
    $content
}

Function Add-SolutionContent() {
    param($SolutionPath)
    $filename = Split-Path $SolutionPath -LeafBase

    $content = @(
        "Function Invoke-$filename() {",
        "    <#",
        "    .SYNOPSIS`n",
        "    .DESCRIPTION`n",
        "    .PARAMETER #Name`n",
        "    .EXAMPLE",
        "     #>",
        "    [CmdletBinding()]",
        "    Param(`n",
        "    )",
        "    Throw 'Please implement this function'",
        "}") -join "`n"
    $content
    #Might add class template so user can pick between function and class
    #This doesnt account for exercise that require multiple functions.
}

Function Add-TestContent() {
    param($TestFilePath, $TestCasesPath, $SolutionPath)

    $file     = Split-Path $SolutionPath -Leaf
    $filename = Split-Path $SolutionPath -LeafBase

    $testCasesToml = Get-Content -Path $TestCasesPath

    # Adding test cases description
    $tests = ($testCasesToml | ForEach-Object {
        if ($_ -match "description = (`".*`")") {
            ("    It $($matches[1]) {`n", "    }`n") -join "`n"
        }
    }) -join "`n"

    $content = @(
        "BeforeAll {",
        "    . `"./$file`"",
        "}`n",
        "Describe `"$filename test cases`" {",
        $tests,
        "}") -join "`n"
    $content

    #This will add all the tests generate from canonical file,
    #but you might need to group them base on context for easier access
}

Function Add-Files() {
    param($FilesPath)

    $ConfigPath, $SolutionPath, $TestFilePath, $ExamplePath, $TestCasesPath = Get-FilesPath

    Add-AuthorToConfig  $ConfigPath     | ConvertTo-Json -Depth 3 | Set-Content -Path $ConfigPath
    Add-TestContent     $TestFilePath $TestCasesPath $SolutionPath  | Set-Content -Path $TestFilePath
    Add-SolutionContent $SolutionPath   | Set-Content -Path $SolutionPath

    if( -not (Test-Path $ExamplePath)) {
        New-Item -Path $ExamplePath -ItemType File
    }
}

Add-Files


#Maybe add a selection menu.
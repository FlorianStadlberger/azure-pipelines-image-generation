################################################################################
##  File:  Validate-Ruby.ps1
##  Team:  CI-X
##  Desc:  Verify that Ruby is on the path and output version information.
################################################################################

# Function that gets the version of Ruby at the specified path
function Get-RubyVersion
{
    Param
    (
        [String]$rubyRootPath
    )

    # Prepend to the path like: C:\hostedtoolcache\windows\Ruby\2.5.0\x64\bin
    $env:Path = "$rubyRootPath;" + $env:Path

    # Extract the version from Ruby output like: ruby 2.5.1p57 (2018-03-29 revision 63029) [x64-mingw32]
    if( $(ruby --version) -match 'ruby (?<version>.*) \(.*' )
    {
        $rubyVersion = $Matches.version
        return $rubyVersion
    }

    Write-Host "Unable to determine Ruby version at " + $rubyRootPath
    exit 1
}

# Verify that ruby is on the path
if(Get-Command -Name 'ruby')
{
    Write-Host "$(ruby --version) is on the path."
}
else
{
    Write-Host "Ruby is not on the path."
    exit 1
}

# Get available versions of Ruby
# Tool cache Ruby Path
$toolcacheRubyPath = 'C:\hostedtoolcache\windows\Ruby'

# Default Ruby Version on Path
$rubyVersionOnPath = (Get-Command -Name 'ruby').Path

# Markdown Output
$rubyVersionOutput = Get-ChildItem -Path $toolcacheRubyPath -Directory | Foreach-Object {
	$rubyBinPath = Join-Path $_.FullName 'x64\bin'
	$rubyVersion = Get-RubyVersion -rubyRootPath $rubyBinPath

	if ($rubyVersionOnPath.Contains($rubyBinPath)) {
		"#### {0} `r`n_Environment:_ `r`n* Location: {1} `r`n* PATH: contains the location of ruby.exe version {0}" -f $rubyVersion, $rubyBinPath
	} else {
		"#### {0} `r`n_Location:_ {1}" -f $rubyVersion, $rubyBinPath
	}
} | Out-String

# Add details of available versions in Markdown
$SoftwareName = "Ruby (x64)"
$Description = @"
{0}
"@ -f $rubyVersionOutput

Add-SoftwareDetailsToMarkdown -SoftwareName $SoftwareName -DescriptionMarkdown $Description

##########################################################################
# Picassio is a provisioning/deployment script which uses a single linear
# JSON file to determine what commands to execute.
#
# Copyright (c) 2015, Matthew Kelly (Badgerati)
# Company: Cadaeic Studios
# License: MIT (see LICENSE for details)
#########################################################################

# Opens a new Powershell host, and runs the node command on the passed file
Import-Module $env:PicassioTools -DisableNameChecking

function Start-Module($colour, $variables) {
	Test-Module $colour $variables

	if (!(Test-Software 'node.exe -v' 'nodejs')) {
        Write-Errors 'Node.js is not installed'
        Install-AdhocSoftware 'nodejs.install' 'node.js'
    }

	$npm = Replace-Variables $colour.npmInstall $variables
	if (![string]::IsNullOrWhiteSpace($npm) -and $npm -eq $true) {
		if (!(Test-Software 'npm help' 'npm')) {
			Write-Errors 'npm is not installed'
			Install-AdhocSoftware 'npm' 'npm'
		}
	}

    $file = Replace-Variables $colour.file $variables
	if (!(Test-Path $file)) {
		throw "Path to file to run for node does not exist: '$file'"
	}

	Push-Location (Split-Path -Parent $file)

	if ($npm -eq $true) {
		Write-Information 'Installing nodejs modules.'
		npm install

		if (!$?) {
			Pop-Location
			throw "Failed to run npm install for: '$file'."
		}
	}

	$_file = (Split-Path -Leaf $file)
	Start-Process powershell.exe -ArgumentList "node $_file"
	    
    if (!$?) {
		Pop-Location
        throw "Failed to run node for: '$file'."
    }
	
	Pop-Location
    Write-Message 'Node ran successfully.'
}

function Test-Module($colour, $variables) {
	$file = Replace-Variables $colour.file $variables
    if ([string]::IsNullOrWhiteSpace($file)) {
        throw 'No file passed to run for node.'
    }

	$npm = Replace-Variables $colour.npmInstall $variables
	if (![string]::IsNullOrWhiteSpace($npm) -and $npm -ne $true -and $npm -ne $false) {
		throw "Invalid value for npmInstall: '$npm'. Should be either true or false."
	}
}
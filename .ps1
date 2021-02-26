<#
    .SYNOPSIS
        No title
    .DESCRIPTION
        No description
    .NOTES
        Author: Volodymyr Matviienko
    .PARAMETER a
        Action
    .EXAMPLE
        .ps1 -a Run
#>

[CmdletBinding()]
param(
    [string]$a
)
BEGIN {
  
}
PROCESS {
    
    switch ($a) {
        'Run' {
          docker-compose -f docker-compose.yml down
          docker-compose -f docker-compose.yml up -d --build --force-recreate
        }
        default {
          Write-Output "Error: Please include -a <Action> attribute:`n`twhere 'Action' is one of: Run"
        }
    }
}
  


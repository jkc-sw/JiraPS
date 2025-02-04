function Get-JiraIssueType {
    # .ExternalHelp ..\JiraPS-help.xml
    [CmdletBinding( DefaultParameterSetName = '_All' )]
    param(
        [Parameter( Position = 0, Mandatory, ValueFromPipeline, ParameterSetName = '_Search' )]
        [String[]]
        $IssueType,

        [Parameter()]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential = [System.Management.Automation.PSCredential]::Empty
    )

    begin {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Function started"

        $server = Get-JiraConfigServer -ErrorAction Stop

        $resourceURi = "$server/rest/api/2/issuetype"
    }

    process {
        Write-DebugMessage "[$($MyInvocation.MyCommand.Name)] ParameterSetName: $($PsCmdlet.ParameterSetName)"
        Write-DebugMessage "[$($MyInvocation.MyCommand.Name)] PSBoundParameters: $($PSBoundParameters | Out-String)"

        switch ($PSCmdlet.ParameterSetName) {
            '_All' {
                $parameter = @{
                    URI        = $resourceURi
                    Method     = "GET"
                    Credential = $Credential
                }
                Write-Debug "[$($MyInvocation.MyCommand.Name)] Invoking JiraMethod with `$parameter"
                $result = Invoke-JiraMethod @parameter

                Write-Output (ConvertTo-JiraIssueType -InputObject $result)
            }
            '_Search' {
                foreach ($_issueType in $IssueType) {
                    Write-Verbose "[$($MyInvocation.MyCommand.Name)] Processing [$_issueType]"
                    Write-Debug "[$($MyInvocation.MyCommand.Name)] Processing `$_issueType [$_issueType]"

                    $allIssueTypes = Get-JiraIssueType -Credential $Credential

                    Write-Output ($allIssueTypes | Where-Object -FilterScript { $_.Id -eq $_issueType })
                    Write-Output ($allIssueTypes | Where-Object -FilterScript { $_.Name -like $_issueType })
                }
            }
        }
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }
}

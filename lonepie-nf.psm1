#requires -Version 2 -Modules posh-git

function Write-Theme {
    param(
        [bool]
        $lastCommandFailed,
        [string]
        $with
    )

    #random colours in Hyperterm (for funsies)
    if($env:TERM_PROGRAM -eq "Hyper") {
        $randColor = [ConsoleColor](Get-Random -InputObject 1,2,3,4,5,6,8,9,10,11,12,13,14)
        $sl.Colors.SessionInfoBackgroundColor = $randColor
    }

    $lastColor = $sl.Colors.PathBackgroundColor

    Write-Prompt -Object $sl.PromptSymbols.StartSymbol -ForegroundColor $sl.Colors.PromptForegroundColor -BackgroundColor $sl.Colors.SessionInfoBackgroundColor

    $user = [Environment]::UserName
    $computer = $env:computername
    # $path = Get-FullPath -dir $pwd
    if (Test-NotDefaultUser($user)) {
        Write-Prompt -Object "$user@$computer " -ForegroundColor $sl.Colors.SessionInfoForegroundColor -BackgroundColor $sl.Colors.SessionInfoBackgroundColor
        Write-Prompt -Object "$($sl.PromptSymbols.SegmentForwardSymbol) " -ForegroundColor $sl.Colors.SessionInfoBackgroundColor -BackgroundColor $sl.Colors.PathBackgroundColor
    }
    else {
        Write-Prompt -Object "$($sl.PromptSymbols.SegmentForwardSymbol) " -ForegroundColor $sl.Colors.SessionInfoBackgroundColor -BackgroundColor $sl.Colors.PathBackgroundColor
    }

    # if (Test-VirtualEnv) {
    #     Write-Prompt -Object "$($sl.PromptSymbols.SegmentForwardSymbol) " -ForegroundColor $sl.Colors.SessionInfoBackgroundColor -BackgroundColor $sl.Colors.VirtualEnvBackgroundColor
    #     Write-Prompt -Object "$($sl.PromptSymbols.VirtualEnvSymbol) $(Get-VirtualEnvName) " -ForegroundColor $sl.Colors.VirtualEnvForegroundColor -BackgroundColor $sl.Colors.VirtualEnvBackgroundColor
    #     Write-Prompt -Object "$($sl.PromptSymbols.SegmentForwardSymbol) " -ForegroundColor $sl.Colors.VirtualEnvBackgroundColor -BackgroundColor $sl.Colors.PromptBackgroundColor
    # }
    # else {
    #     Write-Prompt -Object "$($sl.PromptSymbols.SegmentForwardSymbol) " -ForegroundColor $sl.Colors.SessionInfoBackgroundColor -BackgroundColor $sl.Colors.PromptBackgroundColor
    # }

    # Writes the drive portion
    #Write-Prompt -Object "$path " -ForegroundColor $sl.Colors.PromptForegroundColor -BackgroundColor $sl.Colors.PromptBackgroundColor
    # $path = Get-ShortPath -dir $pwd
    $path = Get-FullPath -dir $pwd
    if($path.Contains("~")) {
        # $path = [char]::ConvertFromUtf32(0xF015) + ' ' + $path
        $path = $path.Replace("~", $sl.PromptSymbols.HomeSymbol + " ~")
    }
    else {
        $path = $sl.PromptSymbols.DriveRootSymbol + ' ' + $path
    }
    Write-Prompt -Object "$($path) " -ForegroundColor $sl.Colors.PathForegroundColor -BackgroundColor $sl.Colors.PathBackgroundColor

    $status = Get-VCSStatus
    if ($status) {
        $themeInfo = Get-VcsInfo -status ($status)
        $lastColor = $themeInfo.BackgroundColor
        Write-Prompt -Object $($sl.PromptSymbols.SegmentForwardSymbol) -ForegroundColor $sl.Colors.PathBackgroundColor -BackgroundColor $lastColor
        Write-Prompt -Object " $($themeInfo.VcInfo) " -BackgroundColor $lastColor -ForegroundColor $sl.Colors.GitForegroundColor
    }

    # Writes the postfix to the prompt
    Write-Prompt -Object $sl.PromptSymbols.SegmentForwardSymbol -ForegroundColor $lastColor

    $timeStamp = Get-Date -UFormat %T
    $timeStamp = " $($sl.PromptSymbols.TimeStampSymbol) $timeStamp "
    $timeStampLength = $timeStamp.Length + 2

    Set-CursorForRightBlockWrite -textLength $timeStampLength

    #check the last command state and indicate if failed
    If ($lastCommandFailed) {
        Write-Prompt -Object "$($sl.PromptSymbols.FailedCommandSymbol) " -ForegroundColor $sl.Colors.CommandFailedIconForegroundColor
    }
    else {
        Write-Prompt -Object "$($sl.PromptSymbols.SucceedCommandSymbol) " -ForegroundColor $sl.Colors.CommandSucceededIconForegroundColor
    }

    Write-Prompt -Object $sl.PromptSymbols.SegmentBackwardSymbol -ForegroundColor $sl.Colors.TimeBackgroundColor
    Write-Host $timeStamp -ForegroundColor $sl.Colors.PromptForegroundColor -BackgroundColor $sl.Colors.TimeBackgroundColor

    if ($with) {
        Write-Prompt -Object "$($with.ToUpper()) " -BackgroundColor $sl.Colors.WithBackgroundColor -ForegroundColor $sl.Colors.WithForegroundColor
    }

    #check for elevated prompt
    If (([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] 'Administrator')) {
        Write-Prompt -Object "$($sl.PromptSymbols.ElevatedSymbol) " -ForegroundColor $sl.Colors.AdminIconForegroundColor
    }
    Write-Prompt -Object $sl.PromptSymbols.PromptIndicator -ForegroundColor $sl.Colors.PromptBackgroundColor
}

$sl = $global:ThemeSettings #local settings
#Symbols
$sl.PromptSymbols.StartSymbol = ' ' + [char]::ConvertFromUtf32(0xF17A) + ' '
$sl.PromptSymbols.ElevatedSymbol = [char]::ConvertFromUtf32(0xF0E7)
$sl.PromptSymbols.PromptIndicator = [char]::ConvertFromUtf32(0x276F)
$sl.PromptSymbols.SegmentForwardSymbol = [char]::ConvertFromUtf32(0xE0B0)
$sl.PromptSymbols.SegmentBackwardSymbol = [char]::ConvertFromUtf32(0xE0B2)
$sl.PromptSymbols.SegmentSeparatorForwardSymbol = [char]::ConvertFromUtf32(0xE0B1)
$sl.PromptSymbols.SegmentSeparatorBackwardSymbol = [char]::ConvertFromUtf32(0xE0B3)
$sl.PromptSymbols.FailedCommandSymbol = [char]::ConvertFromUtf32(0xF00D)
$sl.PromptSymbols.TruncatedFolderSymbol = [char]::ConvertFromUtf32(0xE5FF)
# $sl.PromptSymbols.PathSeparator = ' ' + [char]::ConvertFromUtf32(0xE0B1) + ' '
$sl.PromptSymbols.PathSeparator = ' ' + [char]::ConvertFromUtf32(0xE0B1) + ' ' + $sl.PromptSymbols.TruncatedFolderSymbol + ' '
#Colors
$sl.Colors.PromptForegroundColor = [ConsoleColor]::White
$sl.Colors.PromptSymbolColor = [ConsoleColor]::White
$sl.Colors.PromptHighlightColor = [ConsoleColor]::DarkBlue
$sl.Colors.GitForegroundColor = [ConsoleColor]::Black
$sl.Colors.WithForegroundColor = [ConsoleColor]::DarkRed
$sl.Colors.WithBackgroundColor = [ConsoleColor]::Magenta
$sl.Colors.VirtualEnvBackgroundColor = [System.ConsoleColor]::Red
$sl.Colors.VirtualEnvForegroundColor = [System.ConsoleColor]::White
$sl.Colors.SessionInfoBackgroundColor = [ConsoleColor]::Green
$sl.Colors.AdminIconForegroundColor = [System.ConsoleColor]::Yellow

#Customizations
$sl.PromptSymbols.HomeSymbol = [char]::ConvertFromUtf32(0xF015)
$sl.PromptSymbols.DriveRootSymbol = [char]::ConvertFromUtf32(0xF67C)
$sl.PromptSymbols.TimeStampSymbol = [char]::ConvertFromUtf32(0xF017)
$sl.PromptSymbols.SucceedCommandSymbol = [char]::ConvertFromUtf32(0xF00C)
$sl.Colors.CommandSucceededIconForegroundColor = [ConsoleColor]::DarkGreen
$sl.Colors.PathBackgroundColor = [System.ConsoleColor]::DarkGray
$sl.Colors.PathForegroundColor = [ConsoleColor]::White
$sl.Colors.TimeBackgroundColor = [ConsoleColor]::DarkGray

#Terminal-specific
if ($env:TERM_PROGRAM -eq "Hyper") {
    $sl.GitSymbols.BranchIdenticalStatusToSymbol = [char]::ConvertFromUtf32(0xF4A6)
    # $sl.Colors.SessionInfoBackgroundColor = [ConsoleColor]::DarkMagenta
}
elseif($env:PROMPT -or $env:ConEmuANSI) {
    $sl.PromptSymbols.PromptIndicator = [char]::ConvertFromUtf32(0xF460)
}
elseif ($env:TERM_PROGRAM -eq "vscode") {
}

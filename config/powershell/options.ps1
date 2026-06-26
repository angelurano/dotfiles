# ::::::::::::::::::::::::::::::::::::::::::::::::::::::::: PSReadLine Configuration
if ($Host.Name -eq 'ConsoleHost') {
    try {
        Import-Module PSReadLine -ErrorAction Stop

        # Enable History Predictions (similar to zsh autosuggestions)
        Set-PSReadLineOption -PredictionSource History -ErrorAction SilentlyContinue

        # ListView style shows predictions in a nice dropdown list
        Set-PSReadLineOption -PredictionViewStyle InlineView -ErrorAction SilentlyContinue

        # Keybindings for autocomplete/predictions
        Set-PSReadLineKeyHandler -Key RightArrow -Function ForwardChar -ErrorAction SilentlyContinue

        # Improve Tab Completion behavior (press Tab once to show menu, Arrow keys to navigate)
        Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete -ErrorAction SilentlyContinue
    }
    catch {
        # Fail silently if PSReadLine cannot be fully initialized (e.g. non-interactive or redirected stdout context)
    }
}

# ::::::::::::::::::::::::::::::::::::::::::::::::::::::::: General Shell Options
# Use concise view for cleaner and less verbose error messages (PowerShell 7+)
if ($PSVersionTable.PSVersion.Major -ge 7) {
    $ErrorView = 'ConciseView'
}

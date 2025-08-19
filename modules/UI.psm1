# --- Variables de Diseño para la Interfaz de Usuario en Consola ---
$script:Version = 'v1.0'
$script:IndentTextLength = 11
$script:IndentText = ' ' * $script:IndentTextLength
$script:TextLength = 80
$script:TextLine = ' ' * $script:TextLength
$script:MarginLength = 5
$script:MarginText = ' ' * $script:MarginLength
$script:LineLength = $script:TextLength + ($script:MarginLength * 2)
$script:BlankLine = ' ' * $script:LineLength
# Se reemplazan los caracteres de borde por ASCII para evitar errores de codificación
$script:HorizontalBorderChar = '-'
$script:VerticalBorderChar = '|'
$script:TopLeftCornerChar = '+'
$script:TopRightCornerChar = '+'
$script:BottomLeftCornerChar = '+'
$script:BottomRightCornerChar = '+'
$script:TextCenter = [Math]::Floor($script:TextLength / 2)

# --- Funciones de la Interfaz de Usuario ---
function Write-MenuLine {
    [CmdletBinding()]
    param(
        [string]$Contents,
        [switch]$Center,
        [switch]$NoBorders
    )
    
    $lineContents = $Contents
    $maxLength = $script:TextLength
    if ($lineContents.Length -gt $maxLength) {
        $lineContents = $lineContents.Substring(0, $maxLength - 3) + "..."
    }

    $Line = $lineContents.PadRight($script:TextLength)

    if ($Center) {
        $padding = [Math]::Max(0, [Math]::Floor(($script:TextLength - $lineContents.Length) / 2))
        $Line = (' ' * $padding) + $lineContents
        $Line = $Line.PadRight($script:TextLength)
    }
    
    $Line = $script:MarginText + $Line + $script:MarginText
    
    if ($NoBorders) {
        $Result = $script:IndentText + $Line
    }
    else {
        $Result = $script:IndentText + $script:VerticalBorderChar + $Line + $script:VerticalBorderChar
    }
    
    Write-Host $Result
}

function Write-BlankMenuLine { Write-MenuLine -Contents '' }

function Write-TopBorder {
    $border = $script:TopLeftCornerChar + ($script:HorizontalBorderChar * ($script:LineLength + 2)) + $script:TopRightCornerChar
    Write-Host ($script:IndentText + $border)
}

function Write-BottomBorder {
    $border = $script:BottomLeftCornerChar + ($script:HorizontalBorderChar * ($script:LineLength + 2)) + $script:BottomRightCornerChar
    Write-Host ($script:IndentText + $border)
}

function Write-TextBorder {
    $border = $script:HorizontalBorderChar * $script:TextLength
    Write-MenuLine -Contents $border -Center
}

function Show-Menu {
    [CmdletBinding()]
    param(
        [string]$Title,
        [string[]]$Header,
        [string[]]$Description,
        [hashtable[]]$Options,
        [switch]$IsSubMenu,
        [switch]$VerCredit
    )
    do {
        Clear-Host
        $Host.UI.RawUI.WindowTitle = "Parche v1.0 - $Title"
        Write-Host "`n"
        Write-TopBorder
        Write-BlankMenuLine

        # --- Lógica de Renderizado Manual del Banner ---
        $bannerLines = @(
            " ____       _     _ _ _                   ",
            "|  _ \ __ _| |__ | (_) |_ _   _ ___       ",
            "| |_) / _`  | '_ \| | | __| | | / __|      ",
            "|  __/ (_| | |_) | | | |_| |_| \__ \_ _ _ ",
            "|_|   \__,_|_.__/|_|_|\__|\__,_|___(_|_|_)",
            ""
        )
        $bannerWidth = 46 # Ancho de la línea más larga del banner
        $padding = ' ' * [Math]::Floor(($script:LineLength - $bannerWidth) / 2)

        foreach ($line in $bannerLines) {
            $fullLineContent = ($padding + $line).PadRight($script:LineLength)
            $fullLine = $script:IndentText + $script:VerticalBorderChar + $fullLineContent + $script:VerticalBorderChar
            Write-Host $fullLine
        }
        # --- Fin de la Lógica del Banner ---
        Write-BlankMenuLine
        Write-TextBorder
        Write-BlankMenuLine
        Write-MenuLine -Contents "PARCHE V-1.0" -Center
        Write-TextBorder # Add underline
        Write-BlankMenuLine
        if ($Header) {
            foreach ($Line in $Header) {
                Write-MenuLine -Contents $Line -Center
            }
        }
        if ($Description) {
            Write-BlankMenuLine
            foreach ($TxtBlock in $Description) {
                Write-MenuLine -Contents $TxtBlock
            }
        }
        if ($Options.Length -gt 0) {
            Write-BlankMenuLine
            Write-TextBorder
            Write-BlankMenuLine
        }
        
        foreach ($Option in $Options) {
            $Num = $Options.IndexOf($Option) + 1
            $nameLine = "[{0}] {1}" -f $Num, $Option.Name
            $descLine = "      {0}" -f $Option.Description
            
            Write-MenuLine -Contents $nameLine
            Write-MenuLine -Contents $descLine
            if ($Option -ne $Options[-1]) {
                Write-BlankMenuLine
            }
        }

        Write-BlankMenuLine
        Write-TextBorder
        Write-BlankMenuLine
        $ExitText = if ($IsSubMenu) { 'Volver' } else { 'Salir' }
        Write-MenuLine -Contents "[Q] $ExitText"
        Write-BlankMenuLine
        Write-BottomBorder
        Write-Host "`n"
        $Choice = Read-Choice -ChoiceCount $Options.Length
        if ($Choice -eq 'Q') {
            if ($IsSubMenu) { return 'Back' }
            else { return 'Exit' }
        }
        $InvalidChoice = $true
        if ($Choice -ne -1) {
            Invoke-Command -ScriptBlock $Options[$Choice - 1].Action
            $InvalidChoice = $false
        }
    } until (-not $InvalidChoice)
}

function Read-Choice {
    param ([int]$ChoiceCount)
    
    # Generar la cadena de opciones explícitamente para evitar errores
    $optionsArray = @()
    for ($i = 1; $i -le $ChoiceCount; $i++) {
        $optionsArray += $i
    }
    $optionsString = $optionsArray -join '-'
    $promptText = "Selecciona [$optionsString, Q para salir]"
    $fullPrompt = "${promptText}: "
    
    $totalWidth = $script:LineLength + $script:IndentTextLength + 4
    $promptPadding = [Math]::Max(0, [Math]::Floor(($totalWidth - $fullPrompt.Length) / 2))
    $indentedPrompt = (' ' * $promptPadding) + $fullPrompt

    [Console]::Out.Write($indentedPrompt)
    $KeyPress = [System.Console]::ReadKey($true)
    Write-Host $KeyPress.KeyChar -NoNewline
    Write-Host "`n"
    
    if ($KeyPress.Key -eq 'q') { return 'Q' } # Aceptar 'q' minúscula también
    $Choice = 0
    if ([int]::TryParse($KeyPress.KeyChar, [ref]$Choice)) {
        if ($Choice -gt 0 -and $Choice -le $ChoiceCount) {
            return $Choice
        }
    }
    return -1
}

function Show-CreditsAndRepo {
    Clear-Host
    $Host.UI.RawUI.WindowTitle = "Parche v1.0 - Créditos"
    Write-Host "`n"
    Write-TopBorder
    Write-BlankMenuLine
    Write-MenuLine -Contents "PARCHE V 1.0" -Center
    Write-BlankMenuLine
    Write-TextBorder
    Write-BlankMenuLine
    Write-MenuLine -Contents "CRÉDITOS" -Center
    Write-BlankMenuLine
    Write-TextBorder
    Write-BlankMenuLine
    Write-MenuLine -Contents "Este proyecto no sería posible sin las valiosas contribuciones"
    Write-MenuLine -Contents "de la comunidad que lo prueba, apoya y mejora constantemente."
    Write-BlankMenuLine
    Write-MenuLine -Contents "Creador y Mantenedor: Pablitus"
    Write-BlankMenuLine
    Write-MenuLine -Contents "¡Gracias a ti por reportar errores y apoyar el proyecto!"
    Write-BlankMenuLine
    Write-TextBorder
    Write-BlankMenuLine
    Write-MenuLine -Contents "[1] Repositorio en GitHub"
    Write-MenuLine -Contents "    https://github.com/Pablitus666/Proyecto-Parche.git"
    Write-BlankMenuLine
    Write-TextBorder
    Write-BlankMenuLine
    Write-MenuLine -Contents "[Q] Volver"
    Write-BlankMenuLine
    Write-BottomBorder
    Write-Host "`n"
    
    $Choice = Read-Choice -ChoiceCount 1
    if ($Choice -eq 1) {
        Start-Process "https://github.com/Pablitus666/Proyecto-Parche.git"
        # Pausa para que el usuario vea que se abrió el enlace
        Show-Pause -Message "Presiona Enter para volver al menú..."
    }
}

Export-ModuleMember -Function Show-Menu, Show-CreditsAndRepo
# --- Variables de Módulo ---
$script:HostsFilePath = Join-Path -Path $Env:SystemRoot -ChildPath "System32\drivers\etc\hosts"
$script:HostsBlockComment = "# BEGIN Adobe Patcher Block List"
$script:HostsBlockCommentEnd = "# END Adobe Patcher Block List"
$script:FirewallRules = @(
    @{ Name = "AdobePatcher-ADS"; Path = Join-Path ${Env:ProgramFiles(x86)} "Common Files\Adobe\Adobe Desktop Common\ADS\Adobe Desktop Service.exe" },
    @{ Name = "AdobePatcher-LicensingWF"; Path = Join-Path $Env:ProgramFiles "Common Files\Adobe\Adobe Desktop Common\NGL\adobe_licensing_wf.exe" },
    @{ Name = "AdobePatcher-LicensingWPH"; Path = Join-Path $Env:ProgramFiles "Common Files\Adobe\Adobe Desktop Common\NGL\adobe_licensing_wf_helper.exe" }
)

# --- Funciones de Inicialización y Ayuda ---
function Initialize-Patcher {
    [CmdletBinding()]
    param(
        [string]$Title,
        [string]$MainScriptPath
    )
    if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        $arguments = "-ExecutionPolicy Bypass -File `"$MainScriptPath`""
        Start-Process powershell -Verb runAs -ArgumentList $arguments
        exit
    }
    $scriptPath = Split-Path -Parent $MainScriptPath
    Set-Location $scriptPath
}

function Show-Pause {
    param([string]$Message = "Presiona una tecla para continuar...")
    Write-Host $Message
    [void][System.Console]::ReadKey($true)
}

function Restart-Explorer {
    Write-Host "Se necesita reiniciar el Explorador de Windows para aplicar los cambios." -ForegroundColor Yellow
    $choice = Read-Host "¿Deseas hacerlo ahora? (S/N)"
    if ($choice -eq 'S') {
        Write-Host "Reiniciando el Explorador de Windows..."
        Stop-Process -Name explorer -Force
        $script:ExplorerRestartRequired = $false
        Write-Host "El Explorador de Windows se ha reiniciado."
    } else {
        Write-Host "Los cambios se aplicarán la próxima vez que reinicies el Explorador manualmente."
    }
}

# --- Funciones para Detener Procesos ---
function Stop-AdobeProcess {
    [CmdletBinding()]
    param()
    Write-Host "Deteniendo servicios de Adobe..." -ForegroundColor Yellow
    Get-Service -DisplayName Adobe* | Stop-Service -ErrorAction SilentlyContinue
    Write-Host "Deteniendo procesos de Adobe..." -ForegroundColor Yellow
    $Processes = Get-Process | Where-Object { $_.CompanyName -match "Adobe" -or $_.Path -match "Adobe" }
    if ($Processes) {
        $Processes | Stop-Process -Force -ErrorAction SilentlyContinue
        Write-Host "Se han detenido $($Processes.Count) procesos." -ForegroundColor Green
    } else {
        Write-Host "No se encontraron procesos de Adobe en ejecución." -ForegroundColor Green
    }
    Show-Pause
}

# --- Funciones para el Archivo Hosts ---
function Get-HostFileStatus {
    [CmdletBinding()]
    param()
    if (-not (Test-Path $script:HostsFilePath)) { return "No Encontrado" }
    $content = Get-Content $script:HostsFilePath
    if ($content -match [regex]::Escape($script:HostsBlockComment)) {
        return "Bloqueado"
    } else {
        return "Limpio"
    }
}

function Set-HostFileBlock {
    [CmdletBinding()]
    param([string]$DataFilePath)
    if (-not (Test-Path $DataFilePath)) {
        Write-Host "Error: El archivo de datos '$DataFilePath' no se encuentra." -ForegroundColor Red
        Show-Pause
        return
    }
    if ((Get-HostFileStatus) -eq "Bloqueado") {
        Write-Host "El archivo hosts ya está bloqueado." -ForegroundColor Yellow
        Show-Pause
        return
    }
    try {
        $addresses = Get-Content -Path $DataFilePath
        $blockContent = "`n$($script:HostsBlockComment)`n"
        foreach ($address in $addresses) {
            if ($address.Trim() -ne "") {
                $blockContent += "0.0.0.0 $($address.Trim())`n"
            }
        }
        $blockContent += "$($script:HostsBlockCommentEnd)`n"
        Add-Content -Path $script:HostsFilePath -Value $blockContent -Force -Encoding ASCII
        Write-Host "Se han añadido las reglas al archivo hosts." -ForegroundColor Green
    } catch {
        Write-Host "Error al modificar el archivo hosts. Asegúrate de ejecutar como Administrador." -ForegroundColor Red
        Write-Host $_.Exception.Message
    }
    Show-Pause
}

function Remove-HostFileBlock {
    [CmdletBinding()]
    param()
    if ((Get-HostFileStatus) -ne "Bloqueado") {
        Write-Host "No se encontraron reglas de bloqueo en el archivo hosts." -ForegroundColor Yellow
        Show-Pause
        return
    }
    try {
        $originalContent = Get-Content $script:HostsFilePath -Raw
        $blockStart = [regex]::Escape($script:HostsBlockComment)
        $blockEnd = [regex]::Escape($script:HostsBlockCommentEnd)
        $cleanedContent = $originalContent -replace "(?s)$blockStart.*?$blockEnd", ""
        Set-Content -Path $script:HostsFilePath -Value $cleanedContent.Trim() -Force -Encoding ASCII
        Write-Host "Se han eliminado las reglas del archivo hosts." -ForegroundColor Green
    } catch {
        Write-Host "Error al modificar el archivo hosts." -ForegroundColor Red
        Write-Host $_.Exception.Message
    }
    Show-Pause
}

# --- Funciones para el Firewall ---
function Get-FirewallStatus {
    [CmdletBinding()]
    param()
    $rule = $script:FirewallRules[0]
    $existingRule = Get-NetFirewallRule -DisplayName $rule.Name -ErrorAction SilentlyContinue
    if ($existingRule) {
        return "Bloqueado"
    } else {
        return "Limpio"
    }
}

function Set-FirewallBlock {
    [CmdletBinding()]
    param()
    if ((Get-FirewallStatus) -eq "Bloqueado") {
        Write-Host "Las reglas del firewall ya existen." -ForegroundColor Yellow
        Show-Pause
        return
    }
    Write-Host "Creando reglas de firewall..." -ForegroundColor Yellow
    foreach ($rule in $script:FirewallRules) {
        if (Test-Path $rule.Path) {
            try {
                New-NetFirewallRule -DisplayName $rule.Name -Direction Outbound -Program $rule.Path -Action Block
                Write-Host "Regla creada para $($rule.Name)." -ForegroundColor Green
            } catch {
                Write-Host "Error al crear la regla para $($rule.Name)." -ForegroundColor Red
            }
        } else {
            Write-Host "Archivo no encontrado, omitiendo regla para: $($rule.Path)" -ForegroundColor Gray
        }
    }
    Show-Pause
}

function Remove-FirewallBlock {
    [CmdletBinding()]
    param()
    if ((Get-FirewallStatus) -ne "Bloqueado") {
        Write-Host "No se encontraron reglas de firewall para eliminar." -ForegroundColor Yellow
        Show-Pause
        return
    }
    Write-Host "Eliminando reglas de firewall..." -ForegroundColor Yellow
    foreach ($rule in $script:FirewallRules) {
        Remove-NetFirewallRule -DisplayName $rule.Name -ErrorAction SilentlyContinue
        Write-Host "Regla eliminada: $($rule.Name)." -ForegroundColor Green
    }
    Show-Pause
}

# --- Funciones para Parches de Sistema ---
function Get-AdobeGenuineServiceStatus {
    [CmdletBinding()]
    param()
    $agsPath = Join-Path ${Env:ProgramFiles(x86)} "Common Files\Adobe\AdobeGCClient"
    if (Test-Path "$agsPath.bak") {
        return "Bloqueado"
    } elseif (Test-Path $agsPath) {
        return "Activo"
    } else {
        return "No Encontrado"
    }
}

function Set-AdobeGenuineServiceBlock {
    [CmdletBinding()]
    param()
    $agsPath = Join-Path ${Env:ProgramFiles(x86)} "Common Files\Adobe\AdobeGCClient"
    if ((Get-AdobeGenuineServiceStatus) -ne "Activo") {
        Write-Host "AGS no está activo o ya está bloqueado." -ForegroundColor Yellow
        Show-Pause
        return
    }
    try {
        Write-Host "Bloqueando Adobe Genuine Service..." -ForegroundColor Yellow
        Rename-Item -Path $agsPath -NewName "$agsPath.bak" -Force
        New-Item -Path $agsPath -ItemType Directory -Force | Out-Null
        $acl = Get-Acl -Path $agsPath
        $rule = New-Object System.Security.AccessControl.FileSystemAccessControlRule("Everyone", "FullControl", "Deny")
        $acl.SetAccessRule($rule)
        Set-Acl -Path $agsPath -AclObject $acl
        Write-Host "Adobe Genuine Service ha sido bloqueado." -ForegroundColor Green
    } catch {
        Write-Host "Error al bloquear AGS. Asegúrate de tener permisos de administrador." -ForegroundColor Red
        Write-Host $_.Exception.Message
    }
    Show-Pause
}

function Remove-AdobeGenuineServiceBlock {
    [CmdletBinding()]
    param()
    $agsPath = Join-Path ${Env:ProgramFiles(x86)} "Common Files\Adobe\AdobeGCClient"
    if ((Get-AdobeGenuineServiceStatus) -ne "Bloqueado") {
        Write-Host "AGS no está bloqueado." -ForegroundColor Yellow
        Show-Pause
        return
    }
    try {
        Write-Host "Restaurando Adobe Genuine Service..." -ForegroundColor Yellow
        $acl = Get-Acl -Path $agsPath
        $acl.Access | ForEach-Object { $acl.RemoveAccessRule($_) } | Out-Null
        Set-Acl -Path $agsPath -AclObject $acl
        Remove-Item -Path $agsPath -Force -Recurse
        Rename-Item -Path "$agsPath.bak" -NewName $agsPath -Force
        Write-Host "Adobe Genuine Service ha sido restaurado." -ForegroundColor Green
    } catch {
        Write-Host "Error al restaurar AGS." -ForegroundColor Red
        Write-Host $_.Exception.Message
    }
    Show-Pause
}

function Get-CreativeCloudFolderVisibility {
    [CmdletBinding()]
    param()
    $clsidPath = "HKCU:\SOFTWARE\Classes\CLSID"
    $ccFolderKey = Get-ChildItem $clsidPath -Recurse -ErrorAction SilentlyContinue | Where-Object { $_.PSChildName -like '*{0E270DAA-1BE6-48F2-AC49-*}*' }
    if (-not $ccFolderKey) { return "No Encontrada" }

    $value = (Get-ItemProperty -Path $ccFolderKey.PSPath)."System.IsPinnedToNameSpaceTree"
    if ($value -eq 1) {
        return "Visible"
    } else {
        return "Oculta"
    }
}

function Set-CreativeCloudFolderVisibility {
    [CmdletBinding()]
    param(
        [bool]$Hidden
    )
    $clsidPath = "HKCU:\SOFTWARE\Classes\CLSID"
    $ccFolderKey = Get-ChildItem $clsidPath -Recurse -ErrorAction SilentlyContinue | Where-Object { $_.PSChildName -like '*{0E270DAA-1BE6-48F2-AC49-*}*' }
    if (-not $ccFolderKey) {
        Write-Host "No se encontró la clave de registro de la carpeta de Creative Cloud." -ForegroundColor Yellow
        Show-Pause
        return
    }

    $newValue = if ($Hidden) { 0 } else { 1 }
    try {
        Set-ItemProperty -Path $ccFolderKey.PSPath -Name "System.IsPinnedToNameSpaceTree" -Value $newValue
        $status = if($Hidden) { "ocultado" } else { "hecho visible" }
        Write-Host "La carpeta de Creative Cloud se ha $status." -ForegroundColor Green
        Restart-Explorer
    } catch {
        Write-Host "Error al modificar el registro." -ForegroundColor Red
        Write-Host $_.Exception.Message
    }
    Show-Pause
}

# --- Funciones para Detección de Software ---
function Get-InstalledAdobeApps {
    [CmdletBinding()]
    param()
    $uninstallPaths = @(
        'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*',
        'HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*'
    )
    $adobeApps = @()
    foreach ($path in $uninstallPaths) {
        $apps = @()
        try {
            $apps = Get-ItemProperty $path -ErrorAction Stop | Where-Object { $_.Publisher -like '*Adobe*' -and $_.DisplayName -and $_.InstallLocation }
        } catch {
            Write-Warning "No se pudo acceder a la ruta del registro: $path"
        }
        foreach ($app in $apps) {
            $adobeApps += [PSCustomObject]@{
                Name    = $app.DisplayName
                Path    = $app.InstallLocation
                Version = $app.DisplayVersion
            }
        }
    }
    return $adobeApps | Sort-Object -Property Name -Unique
}

# --- Exportar Funciones Públicas ---
Export-ModuleMember -Function Initialize-Patcher, Stop-AdobeProcess, Get-HostFileStatus, Set-HostFileBlock, Remove-HostFileBlock, Get-FirewallStatus, Set-FirewallBlock, Remove-FirewallBlock, Get-InstalledAdobeApps, Get-AdobeGenuineServiceStatus, Set-AdobeGenuineServiceBlock, Remove-AdobeGenuineServiceBlock, Get-CreativeCloudFolderVisibility, Set-CreativeCloudFolderVisibility, Show-Pause, Restart-Explorer
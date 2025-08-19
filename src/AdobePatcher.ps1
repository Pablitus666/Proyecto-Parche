# ----------------------------------------------------------------------------------
# Adobe Patcher (Script Mejorado por Gemini)
# ----------------------------------------------------------------------------------
# Script principal para gestionar parches de aplicaciones de Adobe.
# ----------------------------------------------------------------------------------

# --- CONFIGURACIÓN INICIAL ---
$originalColor = $Host.UI.RawUI.ForegroundColor
$Host.UI.RawUI.ForegroundColor = 'Green'
$OutputEncoding = [System.Text.Encoding]::UTF8
[System.Console]::OutputEncoding = [System.Text.Encoding]::UTF8


# --- INICIALIZACIÓN ---
Import-Module "$PSScriptRoot\..\modules\Core.psm1" -Force
Import-Module "$PSScriptRoot\..\modules\UI.psm1" -Force

Initialize-Patcher -Title "Menú Principal" -MainScriptPath $PSCommandPath
$script:ExplorerRestartRequired = $false

# Initialize status variables to default values for immediate menu display
$script:hostStatus = "N/A"
$script:firewallStatus = "N/A"
$script:agsStatus = "N/A"
$script:ccFolderStatus = "N/A"
$detectedApps = @() # Initialize as empty array

# --- DEFINICIÓN DE MENÚS ---
$mainMenuOptions = @(
    @{ Name = "Detener Procesos de Adobe"; Description = "Finaliza todos los servicios y procesos de Adobe en ejecución."; Action = { 
        Stop-AdobeProcess 
    }},
    @{ Name = "Gestionar Archivo hosts"; Description = "Bloquea la conexión a los servidores de Adobe."; Action = { 
        while ($true) {
            $hostsMenuOptions = @(
                @{ Name = "Aplicar Bloqueo"; Description = "Añade los dominios de Adobe al archivo hosts."; Action = { 
                    Set-HostFileBlock -DataFilePath "$PSScriptRoot\..\data\Hosts.txt"
                    $script:hostStatus = Get-HostFileStatus
                } },
                @{ Name = "Eliminar Bloqueo"; Description = "Limpia las reglas de bloqueo del archivo hosts."; Action = { 
                    Remove-HostFileBlock
                    $script:hostStatus = Get-HostFileStatus
                } }
            )
            $selection = Show-Menu -Title "Gestión de Hosts" -Header "Archivo hosts" -Options $hostsMenuOptions -IsSubMenu
            if ($selection -eq 'Back') {
                break
            }
        }
    }},
    @{ Name = "Gestionar Firewall"; Description = "Bloquea el acceso a internet de ejecutables clave."; Action = { 
        while ($true) {
            $firewallMenuOptions = @(
                @{ Name = "Aplicar Bloqueo"; Description = "Crea reglas en el firewall para bloquear aplicaciones de Adobe."; Action = { 
                    Set-FirewallBlock
                    $script:firewallStatus = Get-FirewallStatus
                } },
                @{ Name = "Eliminar Bloqueo"; Description = "Elimina las reglas de bloqueo del firewall."; Action = { 
                    Remove-FirewallBlock
                    $script:firewallStatus = Get-FirewallStatus
                } }
            )
            $selection = Show-Menu -Title "Gestión de Firewall" -Header "Firewall de Windows" -Options $firewallMenuOptions -IsSubMenu
            if ($selection -eq 'Back') {
                break
            }
        }
    }},
    @{ Name = "Parches de Sistema"; Description = "Aplica parches específicos como el bloqueo de AGS."; Action = {
        while ($true) {
            $systemPatchesMenuOptions = @(
                @{ 
                    Name = "Bloquear/Restaurar Adobe Genuine Service"; 
                    Description = "Estado actual: $script:agsStatus"; 
                    Action = { 
                        if ($script:agsStatus -eq 'Activo') { Set-AdobeGenuineServiceBlock }
                        elseif ($script:agsStatus -eq 'Bloqueado') { Remove-AdobeGenuineServiceBlock }
                        else { 
                            Write-Host 'AGS no encontrado.' -ForegroundColor Yellow
                            Show-Pause
                        }
                        $script:agsStatus = Get-AdobeGenuineServiceStatus
                    }
                },
                @{
                    Name = "Ocultar/Mostrar Carpeta de Creative Cloud";
                    Description = "Estado actual: $script:ccFolderStatus";
                    Action = {
                        if ($script:ccFolderStatus -eq 'Visible') { 
                            Set-CreativeCloudFolderVisibility -Hidden:$true
                            $script:ExplorerRestartRequired = $true
                        }
                        elseif ($script:ccFolderStatus -eq 'Oculta') { 
                            Set-CreativeCloudFolderVisibility -Hidden:$false
                            $script:ExplorerRestartRequired = true
                        }
                        else { 
                            Write-Host 'La carpeta de Creative Cloud no fue encontrada.' -ForegroundColor Yellow
                            Show-Pause
                        }
                        $script:ccFolderStatus = Get-CreativeCloudFolderVisibility
                    }
                }
            )
            $selection = Show-Menu -Title "Parches de Sistema" -Header "Parches Adicionales" -Options $systemPatchesMenuOptions -IsSubMenu
            if ($selection -eq 'Back') {
                break
            }
        }
    }},
    @{ Name = "Créditos"; Description = "Muestra los agradecimientos y el enlace al repositorio."; Action = { 
        Show-CreditsAndRepo
    }}
)

# --- BUCLE PRINCIPAL DE LA APLICACIÓN ---
try {
    $detectedApps = Get-InstalledAdobeApps
    $script:hostStatus = Get-HostFileStatus
    $script:firewallStatus = Get-FirewallStatus
    $script:agsStatus = Get-AdobeGenuineServiceStatus
    $script:ccFolderStatus = Get-CreativeCloudFolderVisibility

    while ($true) {

        $mainMenuHeader = @("MENÚ PRINCIPAL")
        $mainMenuDescription = @(
            "Estado actual de los parches:",
            "",
            "  - Archivo hosts: $script:hostStatus",
            "  - Reglas de Firewall: $script:firewallStatus",
            "  - Adobe Genuine Service: $script:agsStatus",
            "  - Carpeta Creative Cloud: $script:ccFolderStatus",
            ""
        )
        if ($detectedApps) {
            $mainMenuDescription += ""
            $mainMenuDescription += "Se detectaron $($detectedApps.Count) aplicaciones de Adobe."
        }

        if ($script:ExplorerRestartRequired) {
            $mainMenuDescription += ""
            $mainMenuDescription += "ADVERTENCIA: Se requiere reiniciar el Explorador para aplicar todos los cambios."
        }

        $selection = Show-Menu -Title "Menú Principal" -Header $mainMenuHeader -Description $mainMenuDescription -Options $mainMenuOptions
        
        if ($selection -eq "Exit") {
            break
        }
    }
} catch {
    Write-Host "Se ha producido un error inesperado:" -ForegroundColor Red
    Write-Host $_.Exception.ToString() -ForegroundColor Red
    # Pause-Script # Removed for faster exit
} finally {
    $Host.UI.RawUI.ForegroundColor = $originalColor
    
}
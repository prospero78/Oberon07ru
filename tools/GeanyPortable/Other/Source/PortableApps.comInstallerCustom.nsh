Var strCustomUpgradeFrom

!macro CustomCodePreInstall	
	ReadINIStr $strCustomUpgradeFrom "$INSTDIR\App\AppInfo\appinfo.ini" "Version" "PackageVersion"
	${If} $strUpgradeFrom == ""
		;Ensure we never upgrade a fresh install
		StrCpy $strCustomUpgradeFrom "999.9.9.9"
	${EndIf}

	;=== Check for upgrade from 0.20 or earlier as GTK handling changed
	${VersionCompare} $strCustomUpgradeFrom "0.20.0.0" $0
	${If} $0 == 1
	${AndIf} ${FileExists} "EXEDIR\Data\settings\*.*"
		Rename "$INSTDIR\App\GTK\etc\gtk-2.0\gtkrc" "$INSTDIR\Data\settings\gtkrc"
	${ElseIf} ${FileExists} "$INSTDIR\App\Geany\etc\gtk-2.0\gtkrc"
	${AndIf} ${FileExists} "EXEDIR\Data\settings\*.*"
		Rename "$INSTDIR\App\Geany\etc\gtk-2.0\gtkrc" "$INSTDIR\Data\settings\gtkrc"
	${EndIf}
!macroend

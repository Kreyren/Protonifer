#!/bin/bash
	# We have to use since this RegEx is used and i'm currently lazy to translate it on POSIX-compatible (fixme)
# Created by Jacob Hrbek <kreyren@rixotstudio.cz> under GPL-3 license (https://www.gnu.org/licenses/gpl-3.0.en.html) in 2020

: "
Abstract: Suffix command with '%command%' in steam command line to nuke proton and use wine

# Test string:
'''
/home/kreyren/.local/share/Steam/steamapps/common/Proton 4.11/proton waitforexitandrun /home/kreyren/.local/share/Steam/steamapps/common/Assassin's Creed IV Black Flag/AC4BFSP.exe -uplay_steam_mode
'''

Expecting to strip the proton part to be replaced with 'wine start /home/kreyren/.local/share/Steam/steamapps/common/Assassin's Creed IV Black Flag/AC4BFSP.exe -uplay_steam_mode'

NOTICE: Steam has to have '%command%' in the launch arguments otherwise it uses default

HOW TO USE
- parse 'protonifer --winefy %command%' in Steam Launch Options and Play!

RESULT:
- Fuck you Valve
- This way it runs everything in new wineprefix that doesn't see the changes -.-
"

# Capture args
protonifer_string="$*"
protonifer_expression="s#^${HOME//\//\\\/}\/\\.local\/share\/Steam\/steamapps\/common\/Proton[^\/]+\/proton\s{1}waitforexitandrun\s{1}([^\n]+)#wine start \"\1\"#gm"

# printf '%s\n' "${protonifer_string##--winefy }" | sed -E "s#^${HOME//\//\\\/}\/\\.local\/share\/Steam\/steamapps\/common\/Proton[^\/]+\/proton\s{1}waitforexitandrun\s{1}([^\n]+)#WINEPREFIX=\"$HOME/.steam/steam/steamapps/compatdata/242050/pfx\" wine \"\1\" \"-uplay_steam_mode\"#gm"

WINEPREFIX="/home/kreyren/.steam/steam/steamapps/compatdata/242050/pfx" wine "/home/kreyren/.local/share/Steam/steamapps/common/Assassin's Creed IV Black Flag/AC4BFSP.exe" "-uplay_steam_mode"

exit 0

# Process args
while [ $# -gt 1 ]; do case "$1" in
	--test)
		printf "expression: '%s'\\n" "$protonifer_expression"
		printf "test string: '%s'\\n" "$protonifer_string"
		shift 1 ;;
	--winefy)
		# Core - Replace proton with wine to be executed through Steam
		printf '%s\n' "${protonifer_string##--winefy }" | sed -E "$protonifer_expression"
		exit 0 ;; # We have to exit since this is last command following steam commands (FIXME: ugly solution)
	--hijack)
		printf 'FIXME: %s\n' "Hijacking of steam is currently not adapted"
		exit 1 ;;
	*)
		# FIXME: Add way to notify the end-user since output is not exported on steam launch cli (HOTFIX: protonifer %command% > "$HOME/protonifer")
		printf 'FATAL: %s\n' "Argument '$1' is not recognized"
		shift 1
esac; done

# Global unset - Put all variables defined in this script here to avoid them exporting in the host (this should be implemeted in die() )
unset protonifer_string protonifer_expression

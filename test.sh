#!/bin/bash
# Make sure you run build.sh beforehand !!!

########################################################################

TERM_EMULATOR=kitty       # Change this to your preferred terminal emulator
UT_PATH="../__UTDir"      # Must be a legitimate UT installation

########################################################################

BUILD_DIR=./Build
SYS="$UT_PATH/System"
FILES=("$BUILD_DIR"/*)

# Copy the built files do System
for F in "${FILES[@]}"; do
  cp -v "$F" "$SYS"
done

# todo: Prefer native version instead, WINE was just easier to set up at the time
# Run UnrealTournament
echo "Running Unreal Tournament in WINE"
wineserver -k

# The game doesn't have a console, spawn one that reads UnrealTournament.log live as it updates
$TERM_EMULATOR sh -c "watch -n 0.1 tac $(realpath $SYS)/UnrealTournament.log" &
wine "$SYS/UnrealTournament.exe"

# Once it's finished, delete the copied files
for F in "${FILES[@]}"; do
  rm -v "$SYS/$(basename "$F")"
done

# Stop the term emulator
echo "Killing $!"
kill $!

exit 0

#!/bin/bash

########################################################################

PKG=$(basename "$PWD")    # Package name, must contain a Classes subdirectory
UT_PATH="../__UTDir"      # Must be a legitimate UT installation

########################################################################

SYS="$UT_PATH/System"                     # UT's System directory
INS+=$(find ./Classes -name '*.uc')       # Source files
OUTS=("$SYS/$PKG.u" "$SYS/$PKG.ucl")      # Output files
CFG="./Make.ini"                          # Build configuration

# The package must be specified as an EditPackage after its dependencies
if ! grep -F "EditPackages=$PKG" "$CFG" &> /dev/null; then
  echo "EditPackages=$PKG not found in $CFG! Make sure the package is added after its dependencies."
  exit 1
fi

# Make the build dir if it doesn't exist yet
mkdir -p ./Build

# Delete previous build files
rm -vf "${OUTS[@]}"
rm -vf "$SYS/$PKG.int"
rm -vf ./Build/*

# Copy our project folder to UT's root folder
cp -vr "../$PKG" "$SYS"/..

# Build project
echo "Running UCC"
OUTPUT=$(cd "$SYS" || exit 1; ./UCC.exe make ini="../../$PKG/$CFG" "$INS")
STATUS=$?

echo "$OUTPUT"
if [ $STATUS -ne 0 ]; then
  echo "UCC exited with status $STATUS"
  exit $STATUS
fi

# Move the build files
mv -v "${OUTS[@]}" ./Build/
cp -v "Classes/$PKG.int" ./Build/

printf "\nBuild complete with status 0\n"
exit 0

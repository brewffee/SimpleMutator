#!/bin/bash

########################################################################

PKG=$(basename "$PWD")    # Package name, must contain a Classes subdirectory
UT_PATH="../__UTDirLinux"      # Must be a legitimate UT installation

########################################################################

SYS="$UT_PATH/System"                       # UT's System directory
INS+=$(find ./Classes -name '*.uc')         # Source files
OUTS=("$HOME/.utpg/System/$PKG.u" "$HOME/System/.utpg/$PKG.ucl")  # Output files
CFG="./Make.ini"                            # Build configuration

# The package must be specified as an EditPackage after its dependencies
if ! grep -F "EditPackages=$PKG" "$CFG" &> /dev/null; then
  echo "EditPackages=$PKG not found in $CFG! Make sure the package is added after its dependencies."
  exit 1
fi

# Make the build dir if it doesn't exist yet
mkdir -p ./Build

# Delete previous build files
rm -vf "$SYS/$PKG.int"
rm -vf ./Build/*

# Copy our project folder to UT's root folder
cp -vr "../$PKG" "$SYS"/..

# NOTE: UCC does not have a -nohomedir option, so we have to temporarily rename the
# user's UT data folder and copy the system files there
if [ -d ~/.utpg ]; then
  mv -v ~/.utpg ~/.utpg.user
  cp -v ~/.utpg.user ~/.utpg.bak # Just in case anything happens during the build
fi

mkdir -vp ~/.utpg
cp -vr "$SYS" ~/.utpg

# Build project
echo "Running UCC"
echo "./ucc-bin-x86 make ini=\"../../$PKG/$CFG\" \"$INS\""
OUTPUT=$(cd "$SYS" || exit 1; ./ucc-bin-x86 make ini="../../$PKG/$CFG" "$INS")
STATUS=$?

cleanup() {
  printf "\nCleaning up...\n"

  # Remove the project folder from UT's root folder
  rm -rvf "${UT_PATH:?}/${PKG:?}"

  # Restore the user's UT data folders
  if [ -d ~/.utpg.user ]; then
    rm -rvf ~/.utpg
    mv -v ~/.utpg.user ~/.utpg
  fi
}

# Check UCC's status before continuing
echo "$OUTPUT"
if [ $STATUS -ne 0 ]; then
  echo "UCC exited with status $STATUS"
  cleanup; exit $STATUS
else
  echo "UCC exited with status 0"

  # Move the built files
  mv -v "${OUTS[@]}" ./Build/
  cp -v "Classes/$PKG.int" ./Build/
fi

cleanup;

echo "Build complete!"
exit 0

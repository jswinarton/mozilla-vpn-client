#!/bin/bash

# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

. $(dirname $0)/commons.sh

REVISION=1
RELEASE=focal
BUILDTYPE=prod
SOURCEONLY=N
PPA_URL=
DPKG_SIGN="--no-sign"
RPM=N
DEB=N

if [ -f .env ]; then
  . .env
fi

helpFunction() {
  print G "Usage: $0 [OPTIONS]"
  print N ""
  print N "Build options:"
  print N "  -r, --release DIST     Build packages for distribution DIST"
  print N "  -v, --version REV      Set package revision to REV"
  print N "  -s, --stage            Build packages to use staging services"
  print N "      --source           Build source packages only (no binary)"
  print N "      --ppa URL          Upload source packages to PPA at URL (implies: --source)"
  print N ""
  print N "Signing options:"
  print N "      --sign             Enable package signing (default: disabled)"
  print N "  -k, --sign-key KEYID   Enable package using using GPG key of KEYID"
  print N "      --no-sign          Disable package signing" 
  print N ""
  print N "By default, the release is 'focal'"
  print N "The default version is 1, but you can recreate packages using the same code version changing the version id."
  print N ""
  exit 0
}

print N "This script compiles MozillaVPN and creates a debian/ubuntu package"
print N ""

while [[ $# -gt 0 ]]; do
  key="$1"

  case $key in
  -s | --stage)
    BUILDTYPE=stage
    shift
    ;;
  -r | --release)
    RELEASE="$2"
    shift
    shift
    ;;
  -v | --version)
    REVISION="$2"
    shift
    shift
    ;;
  --source)
    SOURCEONLY=Y
    shift
    ;;
  --ppa)
    SOURCEONLY=Y
    PPA_URL="$2"
    shift
    shift
    ;;
  --sign)
    DPKG_SIGN=""
    shift
    ;;
  -k | --sign-key)
    DPKG_SIGN="--sign-key=$2"
    shift
    shift
    ;;
  --no-sign)
    DPKG_SIGN="--no-sign"
    shift
    ;;
  *)
    helpFunction
    ;;
  esac
done

printn Y "Computing the version... "
SHORTVERSION=$(cat version.pri | grep VERSION | grep defined | cut -d= -f2 | tr -d \ )
WORKDIR=mozillavpn-$SHORTVERSION
print G "$SHORTVERSION"

rm -rf .tmp || die "Failed to remove the temporary directory"
mkdir .tmp || die "Failed to create the temporary directory"

print Y "Update the submodules..."
git submodule init || die "Failed"
git submodule update --remote --depth 1 i18n || die "Failed"
git submodule update --remote --depth 1 3rdparty/wireguard-tools || die "Failed"
print G "done."

print G "Creating the orig tarball"

printn N "Creating the working directory... "
cd .tmp
mkdir $WORKDIR || die "Failed"
rsync -a --exclude='.*' .. $WORKDIR || die "Failed"
print G "done."

print Y "Generating glean samples..."
(cd $WORKDIR && python3 scripts/generate_glean.py) || die "Failed to generate glean samples"

print Y "Downloading Go dependencies..."
(cd $WORKDIR/linux/netfilter && go mod vendor)
print G "done."

printn Y "Removing the packaging templates... "
rm -f $WORKDIR/linux/mozillavpn.spec || die "Failed"
rm -rf $WORKDIR/linux/debian || die "Failed"
print G "done."

printn Y "Archiving the source code... "
TAR_OPTIONS="--mtime=$(git log -1 --format=%cI) --owner=root:0 --group=root:0 --sort=name"
LC_ALL=C tar cfz mozillavpn_$SHORTVERSION.orig.tar.gz $TAR_OPTIONS $WORKDIR || die "Failed"
print G "done."

## Generate the spec file for building RPMs
build_rpm_spec() {
cat << EOF > mozillavpn.spec
Version: $SHORTVERSION
Release: $REVISION
Source0: mozillavpn_$SHORTVERSION.orig.tar.gz
$(grep -v -e "^Version:" -e "^Release" -e "^%define" ../linux/mozillavpn.spec)
EOF
}

## For a given distro, build the DSC and debian tarball.
build_deb_source() {
  local distro=$1
  local buildtype=$2
  local buildrev=${distro}${REVISION}

  print Y "Building sources for $distro ($buildtype)..."
  rm -rf $WORKDIR/debian || die "Failed"
  cp -r ../linux/debian $WORKDIR || die "Failed"

  mv $WORKDIR/debian/rules.$buildtype.$distro $WORKDIR/debian/rules
  mv $WORKDIR/debian/control.$buildtype.$distro $WORKDIR/debian/control
  rm $WORKDIR/debian/control.*
  rm $WORKDIR/debian/rules.*

  mv $WORKDIR/debian/changelog.template $WORKDIR/debian/changelog || die "Failed"
  sed -i -e "s/SHORTVERSION/$SHORTVERSION/g" $WORKDIR/debian/changelog || die "Failed"
  sed -i -e "s/VERSION/$buildrev/g" $WORKDIR/debian/changelog || die "Failed"
  sed -i -e "s/RELEASE/$distro/g" $WORKDIR/debian/changelog || die "Failed"
  sed -i -e "s/DATE/$(date -R)/g" $WORKDIR/debian/changelog || die "Failed"

  (cd $WORKDIR && dpkg-buildpackage --build=source $DPKG_SIGN --no-check-builddeps) || die "Failed"
}

## For source-only, build all the source bundles we can.
if [ "$SOURCEONLY" == "Y" ]; then
  print Y "Configuring the DEB sources..."
  for control in ../linux/debian/control.*; do
    filename=$(basename $control)
    buildtype=$(echo $filename | cut -d'.' -f2)
    distro=$(echo $filename | cut -d'.' -f3)

    build_deb_source $distro $buildtype

    mkdir $distro-$buildtype/
    mv mozillavpn_${SHORTVERSION}-*_source.buildinfo $distro-$buildtype/ || die "Failed"
    mv mozillavpn_${SHORTVERSION}-*_source.changes $distro-$buildtype/ || die "Failed"
    mv mozillavpn_${SHORTVERSION}-*.debian.tar.* $distro-$buildtype/ || die "Failed"
    mv mozillavpn_${SHORTVERSION}-*.dsc $distro-$buildtype/ || die "Failed"
  done

  print Y "Configuring the RPM spec..."
  build_rpm_spec
## Otherwise, build the desired release.
else
  case "$RELEASE" in
    bionic|focal|groovy|hirsute)
      build_deb_source $RELEASE $BUILDTYPE

      print Y "Building Debian packages for $RELEASE ($BUILDTYPE)"
      (cd $WORKDIR && dpkg-buildpackage --build=binary $DPKG_SIGN) || die "Failed"
      ;;
    
    fedora)
      build_rpm_spec

      print Y "Building RPM packages for $RELEASE ($BUILDTYPE)"
      rpmbuild --define "_topdir $(pwd)" --define "_sourcedir $(pwd)" -bs mozillavpn.spec
      RPM=Y
      ;;

    *)
      die "We support RELEASE focal, groovy, bionic, hirsute and fedora only"
      ;; 
  esac
fi

print Y "Cleaning up working directory..."
rm -rf $WORKDIR || die "Failed"

if [ ! -z "$PPA_URL" ]; then
  print Y "Uploading sources to $PPA_URL"
  for dist in $(find . -type d -name '*-prod'); do
    ln -s ../mozillavpn_${SHORTVERSION}.orig.tar.gz $dist/mozillavpn_${SHORTVERSION}.orig.tar.gz
    dput "$PPA_URL" $dist/mozillavpn_${SHORTVERSION}-*_source.changes
  done
fi

print G "All done."

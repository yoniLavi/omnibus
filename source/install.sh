#!/bin/bash

release_version="0.10.4-6"
use_shell=0

# Check whether a command exists - returns 0 if it does, 1 if it does not
exists() {
  if command -v $1 &>/dev/null
  then
    return 0
  else
    return 1
  fi
}

# Set the filename for a deb, based on version and machine
deb_filename() {
  filetype="deb"
  if [ $machine = "x86_64" ];
  then
    filename="chef-full_${version}_amd64.deb"
  else
    filename="chef-full_${version}_i386.deb"
  fi
}

# Set the filename for an rpm, based on version and machine
rpm_filename() {
  filetype="rpm"
  filename="chef-full-${version}.${machine}.rpm"
}

# Set the filename for the sh archive
shell_filename() {
  filetype="sh"
  filename="chef-full-${version}-${platform}-${platform_version}-${machine}.sh"
}

# Get command line arguments
while getopts sv: opt
do
  case "$opt" in
    v)  version="$OPTARG";;
    s)  use_shell=1;;
    \?)   # unknown flag
      echo >&2 \
      "usage: $0 [-s] [-v version]"
      exit 1;;
  esac
done
shift `expr $OPTIND - 1`

machine=$(echo -e `uname -m`)

# Retrieve Platform and Platform Version
if [ -f "/etc/lsb-release" ];
then
  platform=$(grep DISTRIB_ID /etc/lsb-release | cut -d "=" -f 2 | tr '[A-Z]' '[a-z]')
  platform_version=$(grep DISTRIB_RELEASE /etc/lsb-release | cut -d "=" -f 2)
elif [ -f "/etc/debian_version" ];
then
  platform="debian"
  platform_version=$(echo -e `cat /etc/debian_version`)
elif [ -f "/etc/redhat-release" ];
then
  platform=$(sed 's/^\(.\+\) release.*/\1/' /etc/redhat-release | tr '[A-Z]' '[a-z]')
  platform_version=$(sed 's/^.\+ release \([.0-9]\+\).*/\1/' /etc/redhat-release)
  if [ "$platform" = "redhat enterprise linux server" ];
  then
    platform="el"
  elif [ "$platform" = "centos" ];
  then
    platform="el"
  elif [ "$platform" = "centos linux" ];
  then
    platform="el"
  elif [ "$platform" = "scientific linux" ];
  then
    platform="el"
  elif [ "$platform" = "fedora" ];
  then
    platform="el"
    # Change platform version for use below.
    platform_version="6.0"
  fi
elif [ -f "/etc/system-release" ];
then
  platform=$(sed 's/^\(.\+\) release.\+/\1/' /etc/system-release | tr '[A-Z]' '[a-z]')
  platform_version=$(sed 's/^.\+ release \([.0-9]\+\).*/\1/' /etc/system-release | tr '[A-Z]' '[a-z]')
fi

# Mangle $platform_version to pull the correct build
# for various platforms
major_version=$(echo $platform_version | cut -d. -f1)
case $platform in
  "el")
    case $major_version in
      "5") platform_version="5.6" ;;
      "6") platform_version="6.0" ;;
    esac
    ;;
  "debian")
    case $major_version in
      "5") platform_version="6.0.1";;
      "6") platform_version="6.0.1";;
    esac
    ;;
  "ubuntu")
    case $platform_version in
      "10.10") platform_version="10.04";;
      "11.10") platform_version="11.04";;
    esac
    ;;
esac

if [ -z "$version" ];
then
    version=$release_version
fi

if [ $use_shell = 1 ];
then
  shell_filename
else
  case $platform in
    "ubuntu") deb_filename ;;
    "debian") deb_filename ;;
    "el") rpm_filename ;;
    "fedora") rpm_filename ;;
    *) shell_filename ;;
  esac
fi

echo "Downloading Chef $version for ${platform}..."

if exists wget;
then
  wget -O /tmp/$filename http://s3.amazonaws.com/opscode-full-stack/$platform-$platform_version-$machine/$filename
elif exists curl;
then
  curl http://s3.amazonaws.com/opscode-full-stack/$platform-$platform_version-$machine/$filename > /tmp/$filename
else
  echo "Cannot find wget or curl - cannot install Chef!"
  exit 5
fi

echo "Installing Chef $version"
case "$filetype" in
  "rpm") rpm -Uvh /tmp/$filename ;;
  "deb") dpkg -i /tmp/$filename ;;
  "sh" ) bash /tmp/$filename ;;
esac

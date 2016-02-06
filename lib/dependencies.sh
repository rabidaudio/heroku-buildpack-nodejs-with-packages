install_custom_packages() {
  local build_dir=${1:-}

  if [ -e $build_dir/.packages ]; then
    packages=`cat $build_dir/.packages | tr '\n' ' '`
    if [ `which apt-get` ]; then
      apt-get -y install $packages
    elif [ `which yum` ]; then
      yum -y install $packages
    elif [ `which pacman` ]; then
      pacman -Sy $packages
    else
      echo "No known package manager found!"
    fi
  else
    echo ".packages file not found"
  fi
}
install_node_modules() {
  local build_dir=${1:-}

  if [ -e $build_dir/package.json ]; then
    cd $build_dir
    echo "Pruning any extraneous modules"
    npm prune --unsafe-perm --userconfig $build_dir/.npmrc 2>&1
    if [ -e $build_dir/npm-shrinkwrap.json ]; then
      echo "Installing node modules (package.json + shrinkwrap)"
    else
      echo "Installing node modules (package.json)"
    fi
    npm install --unsafe-perm --userconfig $build_dir/.npmrc 2>&1
  else
    echo "Skipping (no package.json)"
  fi
}

rebuild_node_modules() {
  local build_dir=${1:-}

  if [ -e $build_dir/package.json ]; then
    cd $build_dir
    echo "Rebuilding any native modules"
    npm rebuild 2>&1
    if [ -e $build_dir/npm-shrinkwrap.json ]; then
      echo "Installing any new modules (package.json + shrinkwrap)"
    else
      echo "Installing any new modules (package.json)"
    fi
    npm install --unsafe-perm --userconfig $build_dir/.npmrc 2>&1
  else
    echo "Skipping (no package.json)"
  fi
}

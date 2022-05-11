#!/bin/sh
set -exu

apt update
apt install libjemalloc-dev

sudo -iu leihs-database bash << 'SCRIPT'
  cd "/home/leihs-database/.rubies/"
  rm -rf "ruby-2.6.6_stdmalloc" && cp -R "ruby-2.6.6" "ruby-2.6.6_stdmalloc"
  time ruby-install --no-install-deps --install-dir "/home/leihs-database/.rubies/ruby-2.6.6" ruby "2.6.6" -- --with-jemalloc
  ruby-2.6.6/bin/ruby -r rbconfig -e "puts RbConfig::CONFIG['MAINLIBS']"
  cd /leihs/database
  /home/leihs-database/.rubies/ruby-2.6.6/bin/bundle
SCRIPT

# sudo -iu leihs-database bash << 'SCRIPT'
#   cd "/home/leihs-database/.rubies/"
#   rm -rf "ruby-2.7.5_stdmalloc" && cp -R "ruby-2.7.5" "ruby-2.7.5_stdmalloc"
#   time ruby-install --no-install-deps --install-dir "/home/leihs-database/.rubies/ruby-2.7.5" ruby "2.7.5" -- --with-jemalloc
#   ruby-2.7.5/bin/ruby -r rbconfig -e "puts RbConfig::CONFIG['MAINLIBS']"
#   cd /leihs/database
#   /home/leihs-database/.rubies/ruby-2.7.5/bin/bundle
# SCRIPT

sudo -iu leihs-legacy bash << 'SCRIPT'
  cd "/home/leihs-legacy/.rubies/"
  rm -rf "ruby-2.6.6_stdmalloc" && cp -R "ruby-2.6.6" "ruby-2.6.6_stdmalloc"
  time ruby-install --no-install-deps --install-dir "/home/leihs-legacy/.rubies/ruby-2.6.6" ruby "2.6.6" -- --with-jemalloc
  ruby-2.6.6/bin/ruby -r rbconfig -e "puts RbConfig::CONFIG['MAINLIBS']"
  cd /leihs/legacy
  /home/leihs-legacy/.rubies/ruby-2.6.6/bin/bundle
SCRIPT

systemctl restart leihs-legacy


# BACK

sudo -iu leihs-database bash << 'SCRIPT'
  cd "/home/leihs-database/.rubies/"
  mv "ruby-2.6.c" "ruby-2.6.6_jemalloc"
  mv "ruby-2.6.6_stdmalloc" "ruby-2.6.6"
  ruby-2.6.6/bin/ruby -r rbconfig -e "puts RbConfig::CONFIG['MAINLIBS']"
SCRIPT

# sudo -iu leihs-database bash << 'SCRIPT'
#   cd "/home/leihs-database/.rubies/"
#   mv "ruby-2.7.5" "ruby-2.7.5_jemalloc"
#   mv "ruby-2.7.5_stdmalloc" "ruby-2.7.5"
#   ruby-2.7.5/bin/ruby -r rbconfig -e "puts RbConfig::CONFIG['MAINLIBS']"
# SCRIPT

sudo -iu leihs-legacy bash << 'SCRIPT'
  cd "/home/leihs-legacy/.rubies/"
  mv "ruby-2.6.6" "ruby-2.6.6_jemalloc"
  mv "ruby-2.6.6_stdmalloc" "ruby-2.6.6"
  ruby-2.6.6/bin/ruby -r rbconfig -e "puts RbConfig::CONFIG['MAINLIBS']"
SCRIPT

systemctl restart leihs-legacy

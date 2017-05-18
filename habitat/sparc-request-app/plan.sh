# This file is the heart of your application's habitat.
# See full docs at https://www.habitat.sh/docs/reference/plan-syntax/

pkg_name=sparc-request
pkg_origin=chrisortman
pkg_version="0.2.0"
pkg_source="https://github.com/ui-icts/sparc-request/archive/${pkg_name}-${pkg_version}.tar.bz2"
# Overwritten later because we compute it based on the repo
pkg_shasum="b663cefcbd5fabd7fabb00e6a114c24103391014cfe1c5710a668de30dd30371"
pkg_deps=(
  core/runit # Maybe not needed, thought i had to use it to get chpst
  core/cacerts
  core/glibc
  core/libffi
  core/libxml2
  core/libxslt
  core/libyaml
  core/node
  core/mysql-client

  # Used for passenger
  core/curl
  core/openssl
  core/zlib

  chrisortman/ruby
  chrisortman/passenger
  )
pkg_build_deps=(
  core/coreutils
  core/git
  core/rsync
  core/gcc
  core/make
  core/curl
  core/openssl
  core/zlib
  core/which
)
pkg_lib_dirs=(lib)
pkg_include_dirs=(include)
pkg_svc_user="hab"
pkg_svc_group="$pkg_svc_user"

# Callback Functions
#
do_begin() {
  return 0
}

do_download() {
  export GIT_SSL_CAINFO="$(pkg_path_for core/cacerts)/ssl/certs/cacert.pem"

  # This is a way of getting the git code that I found in the chef plan
  build_line "Fake download! Creating archive of latest repository commit from $PLAN_CONTEXT"
  cd $PLAN_CONTEXT/../..
  git archive --prefix=${pkg_name}-${pkg_version}/ --output=$HAB_CACHE_SRC_PATH/${pkg_filename} HEAD

  pkg_shasum=$(trim $(sha256sum $HAB_CACHE_SRC_PATH/${pkg_filename} | cut -d " " -f 1))
}

do_verify() {
  do_default_verify
  # return 0
}

# The default implementation removes the HAB_CACHE_SRC_PATH/$pkg_dirname folder
# in case there was a previously-built version of your package installed on
# disk. This ensures you start with a clean build environment.
do_clean() {
  do_default_clean
}

do_unpack() {
  do_default_unpack
  # return 0
}

do_prepare() {
  build_line "Setting link for /usr/bin/env to 'coreutils'"
  [[ ! -f /usr/bin/env ]] && ln -s "$(pkg_path_for coreutils)/bin/env" /usr/bin/env
  return 0
}

do_build() {

  export CPPFLAGS="${CPPFLAGS} ${CFLAGS}"
  local _libxml2_dir=$(pkg_path_for libxml2)
  local _libxslt_dir=$(pkg_path_for libxslt)
  local _zlib_dir=$(pkg_path_for zlib)
  local _openssl_include_dir=$(pkg_path_for openssl)

  #export GEM_HOME=${pkg_prefix}/vendor/bundle
  #export GEM_PATH=${GEM_HOME}

  # don't let bundler split up the nokogiri config string (it breaks
  # the build), so specify it as an env var instead
  export NOKOGIRI_CONFIG="--use-system-libraries --with-zlib-dir=${_zlib_dir} --with-xslt-dir=${_libxslt_dir} --with-xml2-include=${_libxml2_dir}/include/libxml2 --with-xml2-lib=${_libxml2_dir}/lib"

  # we control the variable above, and it will be all on one line, and
  # we need single quotes otherwise the extconf doesn't build the
  # extension.
  bundle config build.nokogiri '${NOKOGIRI_CONFIG}'

  # We need to add tzinfo-data to the Gemfile since we're not in an
  # environment that has this from the OS
   if ! grep -q 'gem .*tzinfo-data.*' Gemfile; then
     echo 'gem "tzinfo-data"' >> Gemfile
   fi

  # If you want rails console to work you need to
  # provide an implementation of readline
   if ! grep -q 'gem .*rb-readline.*' Gemfile; then
     echo 'gem "rb-readline"' >> Gemfile
   fi

  bundle install --without test development --jobs 2 --retry 5 --path vendor/bundle --binstubs

  # Some bundle files when they install have permissions that don't
  # allow the all user to read them, but because we are running as
  # root right now for building, but as 'hab' or someone else when the
  # package installs we need to make sure we can read the files
  chmod -R a+rx vendor/bundle

}

# The default implementation runs nothing during post-compile. An example of a
# command you might use in this callback is make test. To use this callback, two
# conditions must be true. A) do_check() function has been declared, B) DO_CHECK
# environment variable exists and set to true, env DO_CHECK=true.
do_check() {
  return 0
}

# The default implementation is to run make install on the source files and
# place the compiled binaries or libraries in HAB_CACHE_SRC_PATH/$pkg_dirname,
# which resolves to a path like /hab/cache/src/packagename-version/. It uses
# this location because of do_build() using the --prefix option when calling the
# configure script. You should override this behavior if you need to perform
# custom installation steps, such as copying files from HAB_CACHE_SRC_PATH to
# specific directories in your package, or installing pre-built binaries into
# your package.
do_install() {

  # At this point my current directory is something
  # like /hab/cache/src/sparc-request-0.1.0
  # this the HAB CACHE SRC PATH or some such 
  # and in this directory I have a copy of my
  # rails app because this is where do_unpack would have
  # extracted my archive to.
  # The job of this task then is to get the files out of there
  # and put them someplace _useful_
  # Now the rails sample where I copied all this from
  # copies the files to pkg_prefix/release which I think can be 
  # thought of in the same vein as capistrano's releases folder?
  # so in order to not have new files overwriting existing files you
  # need something similar which for habitat is the package path because
  # that is all versioned out.
  # EDIT: I changed the cp -r to cp -a cuz maybe that's better
  # since I'm setting my user to hab up above anyway?
  echo "Copying current files to ${pkg_prefix}"
  mkdir -p "${pkg_prefix}/static/release"
  cp -a . "${pkg_prefix}/static/release"


  # This seems to be some habitat stuff that you 
  # just need to do?
  for binstub in ${pkg_prefix}/static/release/bin/*; do
    build_line "Setting shebang for ${binstub} to 'ruby'"
    [[ -f $binstub ]] && sed -e "s#/usr/bin/env ruby#$(pkg_path_for ruby)/bin/ruby#" -i "$binstub"
  done

  if [[ $(readlink /usr/bin/env) = "$(pkg_path_for coreutils)/bin/env" ]]; then
    build_line "Removing the symlink we created for '/usr/bin/env'"
    rm /usr/bin/env
  fi
}

# The default implementation is to strip any binaries in $pkg_prefix of their
# debugging symbols. You should override this behavior if you want to change
# how the binaries are stripped, which additional binaries located in
# subdirectories might also need to be stripped, or whether you do not want the
# binaries stripped at all.
do_strip() {
  do_default_strip
}

# There is no default implementation of this callback. This is called after the
# package has been built and installed. You can use this callback to remove any
# temporary files or perform other post-install clean-up actions.
do_end() {
  return 0
}


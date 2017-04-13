# This file is the heart of your application's habitat.
# See full docs at https://www.habitat.sh/docs/reference/plan-syntax/

# Required.
# Sets the name of the package. This will be used in along with `pkg_origin`,
# and `pkg_version` to define the fully-qualified package name, which determines
# where the package is installed to on disk, how it is referred to in package
# metadata, and so on.
pkg_name=sparc-request

# Required unless overridden by the `HAB_ORIGIN` environment variable.
# The origin is used to denote a particular upstream of a package.
pkg_origin=chrisortman

# Required.
# Sets the version of the package.
pkg_version="0.1.0"

# Optional.
# The name and email address of the package maintainer.
# pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"

# Optional.
# An array of valid software licenses that relate to this package.
# Please choose a license from http://spdx.org/licenses/
# pkg_license=('Apache-2.0')

# Required.
# A URL that specifies where to download the source from. Any valid wget url
# will work. Typically, the relative path for the URL is partially constructed
# from the pkg_name and pkg_version values; however, this convention is not
# required.
pkg_source="https://github.com/ui-icts/sparc-request/archive/${pkg_name}-${pkg_version}.tar.bz2"

# Optional.
# The resulting filename for the download, typically constructed from the
# pkg_name and pkg_version values.
# pkg_filename="${pkg_name}-${pkg_version}.tar.gz"

# Required if a valid URL is provided for pkg_source or unless do_verify() is overridden.
# The value for pkg_shasum is a sha-256 sum of the downloaded pkg_source. If you
# do not have the checksum, you can easily generate it by downloading the source
# and using the sha256sum or gsha256sum tools. Also, if you do not have
# do_verify() overridden, and you do not have the correct sha-256 sum, then the
# expected value will be shown in the build output of your package.
pkg_shasum="b663cefcbd5fabd7fabb00e6a114c24103391014cfe1c5710a668de30dd30371"

# Optional.
# An array of package dependencies needed at runtime. You can refer to packages
# at three levels of specificity: `origin/package`, `origin/package/version`, or
# `origin/package/version/release`.
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
  chrisortman/ruby
  )

# Optional.
# An array of the package dependencies needed only at build time.
pkg_build_deps=(
  core/coreutils
  core/git
  core/rsync
  core/gcc
  core/make
  core/curl
  core/which
)

# Optional.
# An array of paths, relative to the final install of the software, where
# libraries can be found. Used to populate LD_FLAGS and LD_RUN_PATH for
# software that depends on your package.
pkg_lib_dirs=(lib)

# Optional.
# An array of paths, relative to the final install of the software, where
# headers can be found. Used to populate CFLAGS for software that depends on
# your package.
pkg_include_dirs=(include)

# Optional.
# An array of paths, relative to the final install of the software, where
# binaries can be found. Used to populate PATH for software that depends on
# your package.
# pkg_bin_dirs=(bin)

# Optional.
# An array of paths, relative to the final install of the software, where
# pkg-config metadata (.pc files) can be found. Used to populate
# PKG_CONFIG_PATH for software that depends on your package.
# pkg_pconfig_dirs=(lib/pconfig)

# Optional.
# The command for the supervisor to execute when starting a service. You can
# omit this setting if your package is not intended to be run directly by a
# supervisor of if your plan contains a run hook in hooks/run.
# pkg_svc_run="bin/haproxy -f $pkg_svc_config_path/haproxy.conf"

# Optional.
# An associative array representing configuration data which should be gossiped to peers. The keys
# in this array represent the name the value will be assigned and the values represent the toml path
# to read the value.
pkg_exports=(
  [port]=rails_port
)

# Optional.
# An array of `pkg_exports` keys containing default values for which ports that this package
# exposes. These values are used as sensible defaults for other tools. For example, when exporting
# a package to a container format.
pkg_exposes=(port)

# Optional.
# An associative array representing services which you depend on and the configuration keys that
# you expect the service to export (by their `pkg_exports`). These binds *must* be set for the
# supervisor to load the service. The loaded service will wait to run until it's bind becomes
# available. If the bind does not contain the expected keys, the service will not start
# successfully.
#pkg_binds=(
  # [database]="port"
# )

# Optional.
# Same as `pkg_binds` but these represent optional services to connect to.
pkg_binds_optional=(
  [database]="port"
)

# Optional.
# An array of interpreters used in shebang lines for scripts. Specify the
# subdirectory where the binary is relative to the package, for example,
# bin/bash or libexec/neverland, since binaries can be located in directories
# besides bin. This list of interpreters will be written to the metadata
# INTERPRETERS file, located inside a package, with their fully-qualified path.
# Then these can be used with the fix_interpreter function.
# pkg_interpreters=(bin/bash)

# Optional.
# The user to run the service as. The default is hab.
pkg_svc_user="hab"

# Optional.
# The group to run the service as. The default is hab.
pkg_svc_group="$pkg_svc_user"

# Required for core plans, optional otherwise.
# A short description of the package. It can be a simple string, or you can
# create a multi-line description using markdown to provide a rich description
# of your package.
# pkg_description="Some description."

# Required for core plans, optional otherwise.
# The project home page for the package.
# pkg_upstream_url="http://example.com/project-name"


# Callback Functions
#
# When defining your plan, you have the flexibility to override the default
# behavior of Habitat in each part of the package building stage through a
# series of callbacks. To define a callback, simply create a shell function
# of the same name in your plan.sh file and then write your script. If you do
# not want to use the default callback behavior, you must override the callback
# and return 0 in the function definition.
#
# Callbacks are defined here with either their "do_default_x", if they have a
# default implementation, or empty with "return 0" if they have no default
# implementation (Bash does not allow empty function bodies.) If callbacks do
# nothing or do the same as the default implementation, they can be removed from
# this template.
#
# The default implementations (the do_default_* functions) are defined in the
# plan build script:
# https://github.com/habitat-sh/habitat/tree/master/components/plan-build/bin/hab-plan-build.sh

# There is no default implementation of this callback. You can use it to execute
# any arbitrary commands before anything else happens.
do_begin() {
  return 0
}

# The default implementation is that the software specified in $pkg_source is
# downloaded, checksum-verified, and placed in $HAB_CACHE_SRC_PATH/$pkgfilename,
# which resolves to a path like /hab/cache/src/filename.tar.gz. You should
# override this behavior if you need to change how your binary source is
# downloaded, if you are not downloading any source code at all, or if your are
# cloning from git. If you do clone a repo from git, you must override
# do_verify() to return 0.
xdo_download() {
  # do_default_download
  return 0
}

do_download() {
  export GIT_SSL_CAINFO="$(pkg_path_for core/cacerts)/ssl/certs/cacert.pem"

  # This is a way of getting the git code that I found in the chef plan
  build_line "Fake download! Creating archive of latest repository commit"
  cd $PLAN_CONTEXT/../..
  git archive --prefix=${pkg_name}-${pkg_version}/ --output=$HAB_CACHE_SRC_PATH/${pkg_filename} HEAD

  # This is another way that I got from I don't know where
#  tar -cjvf $HAB_CACHE_SRC_PATH/${pkg_name}-${pkg_version}.tar.bz2 \
#      --transform "s,^\./sparc-request,sparc-request-${pkg_version}," ./sparc-request \
#      --exclude sparc-request/.git --exclude sparc-request/spec --exclude sparc-request/habitat

  
  pkg_shasum=$(trim $(sha256sum $HAB_CACHE_SRC_PATH/${pkg_filename} | cut -d " " -f 1))
}

# The default implementation tries to verify the checksum specified in the plan
# against the computed checksum after downloading the source tarball to disk.
# If the specified checksum doesn't match the computed checksum, then an error
# and a message specifying the mismatch will be printed to stderr. You should
# not need to override this behavior unless your package does not download
# any files.
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

# The default implementation extracts your tarball source file into
# HAB_CACHE_SRC_PATH. The supported archives are: .tar, .tar.bz2, .tar.gz,
# .tar.xz, .rar, .zip, .Z, .7z. If the file archive could not be found or was
# not supported, then a message will be printed to stderr with additional
# information.
do_unpack() {
  do_default_unpack
  # return 0
}

# There is no default implementation of this callback. At this point in the
# build process, the tarball source has been downloaded, unpacked, and the build
# environment variables have been set, so you can use this callback to perform
# any actions before the package starts building, such as exporting variables,
# adding symlinks, and so on.
do_prepare() {
  build_line "Setting link for /usr/bin/env to 'coreutils'"
  [[ ! -f /usr/bin/env ]] && ln -s "$(pkg_path_for coreutils)/bin/env" /usr/bin/env
  return 0
}

# The default implementation is to update the prefix path for the configure
# script to use $pkg_prefix and then run make to compile the downloaded source.
# This means the script in the default implementation does
# ./configure --prefix=$pkg_prefix && make. You should override this behavior
# if you have additional configuration changes to make or other software to
# build and install as part of building your package.
do_build() {

  # attach

  # rsync -av --exclude=.git --exclude=tmp --exclude=log --exclude=habitat $PLAN_CONTEXT/.. $HAB_CACHE_SRC_PATH/$pkg_dirname

   # shellcheck disable=SC2153
  export CPPFLAGS="${CPPFLAGS} ${CFLAGS}"

  # shellcheck disable=SC2155
  # shellcheck disable=SC2155
  local _libxml2_dir=$(pkg_path_for libxml2)
  # shellcheck disable=SC2155
  local _libxslt_dir=$(pkg_path_for libxslt)
  # shellcheck disable=SC2155
  # local _postgresql_dir=$(pkg_path_for postgresql)
  # shellcheck disable=SC2155
  # local _pgconfig=$_postgresql_dir/bin/pg_config
  # shellcheck disable=SC2155
  local _zlib_dir=$(pkg_path_for zlib)

  # shellcheck disable=SC2154
  #export GEM_HOME=${pkg_prefix}/vendor/bundle
  #export GEM_PATH=${GEM_HOME}

  # don't let bundler split up the nokogiri config string (it breaks
  # the build), so specify it as an env var instead
  export NOKOGIRI_CONFIG="--use-system-libraries --with-zlib-dir=${_zlib_dir} --with-xslt-dir=${_libxslt_dir} --with-xml2-include=${_libxml2_dir}/include/libxml2 --with-xml2-lib=${_libxml2_dir}/lib"

  # we control the variable above, and it will be all on one line, and
  # we need single quotes otherwise the extconf doesn't build the
  # extension.
  # shellcheck disable=SC2086,SC2016
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
  # Remove the specific ruby version, because our ruby is 2.3
  # sed -e 's/^ruby.*//' -i Gemfile


  bundle install --without test development --jobs 2 --retry 5 --path vendor/bundle --binstubs
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
  # copies the files to pkg_prefix/dist which I think can be 
  # thought of in the same vein as capistrano's releases folder?
  # so in order to not have new files overwriting existing files you
  # need something similar which for habitat is the package path because
  # that is all versioned out.
  # EDIT: I changed the cp -r to cp -a cuz maybe that's better
  # since I'm setting my user to hab up above anyway?
  echo "Copying current files to ${pkg_prefix}"
  cp -a . "${pkg_prefix}/dist"


  # This seems to be some habitat stuff that you 
  # just need to do?
  for binstub in ${pkg_prefix}/dist/bin/*; do
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


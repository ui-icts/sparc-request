# This file is the heart of your application's habitat.
# See full docs at https://www.habitat.sh/docs/reference/plan-syntax/

pkg_name=sparc-request-web
pkg_origin=chrisortman
pkg_version="2.0.0"
pkg_source="https://github.com/ui-icts/sparc-request/archive/${pkg_name}-${pkg_version}.tar.bz2"
# Overwritten later because we compute it based on the repo
pkg_shasum="b663cefcbd5fabd7fabb00e6a114c24103391014cfe1c5710a668de30dd30371"
pkg_deps=(
  chrisortman/passenger/5.1.2+ruby2.1.5
  chrisortman/sparc-request
)
pkg_build_deps=(
)
pkg_lib_dirs=(lib)
pkg_include_dirs=(include)
pkg_svc_user="hab"
pkg_svc_group="$pkg_svc_user"
pkg_binds=(
  [base]="rails-port"
)

# Callback Functions
#
do_begin() {
  return 0
}

do_download() {
  return 0
}

do_verify() {
  return 0
}

# The default implementation removes the HAB_CACHE_SRC_PATH/$pkg_dirname folder
# in case there was a previously-built version of your package installed on
# disk. This ensures you start with a clean build environment.
do_clean() {
  do_default_clean
}

do_unpack() {
  return 0
}
do_prepare() {
  return 0
}

do_build() {
  return 0
}
do_check() {
  return 0
}
do_install() {
  return 0
}
do_strip() {
  return 0
}
do_end() {
  return 0
}


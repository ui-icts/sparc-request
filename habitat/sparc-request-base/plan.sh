# This file is the heart of your application's habitat.
# See full docs at https://www.habitat.sh/docs/reference/plan-syntax/

pkg_name=sparc-request
pkg_origin=chrisortman
pkg_version="3.6.0"

ruby_pkg="core/ruby25"
ruby_major="2.5.0"

# If you don't have this, then do_build won't happen inside the cache
# directory and will happen in /src which could potentially change files you care about

# Have to do this because we are creating the package from our git repo
pkg_filename=${pkg_name}-${pkg_version}.tar.gz

app_sub_path="static/release"

pkg_deps=(
  core/libxml2
  core/libxslt
  core/libyaml
  core/gcc-libs
  core/mysql-client
  core/node
  core/curl
  core/rsync
  core/zlib
  core/gzip
  $ruby_pkg

  core/busybox-static
  )
pkg_build_deps=(
  core/coreutils
  core/git
  core/gcc
  core/make
  core/which
  core/cacerts
  core/tar
  core/yarn
)
pkg_bin_dirs=(bin)
pkg_lib_dirs=(lib)
pkg_include_dirs=(include)
pkg_svc_user="hab"
pkg_svc_group="$pkg_svc_user"

pkg_binds_optional=(
  [database]="port host"
)
pkg_exports=(
  [rails-port]=rails_port
)
pkg_exposes=(rails-port)

do_begin() {
  # Because we don't have pkg_source set
  # we need to explicitly set a source path
  # potentially it could all work without it
  # but then we'd be changing stuff in our
  # same directory as where we have our git
  # repository and I don't want to accidentally
  # rm -fr something
  # If you delete this you're going to wind
  # up in $PLAN_CONTEXT in the do_build func
  SRC_PATH=$CACHE_PATH
  return 0
}
do_download() {
  return 0
}

do_verify() {
  return 0
}

do_unpack() {
  build_line "Cloning source files"
  cd $PLAN_CONTEXT/../../
  { git ls-files; git ls-files --exclude-standard --others; } \
    | _tar_pipe_app_cp_to $HAB_CACHE_SRC_PATH/${pkg_dirname}
}

do_prepare() {

  build_line "Setting link for /usr/bin/env to 'coreutils'"
  [[ ! -f /usr/bin/env ]] && ln -s "$(pkg_path_for coreutils)/bin/env" /usr/bin/env

  return 0
}

do_setup_environment() {

  set_runtime_env TZ "America/Chicago"
  set_runtime_env time_zone "America/Chicago"
  push_runtime_env GEM_PATH "${pkg_prefix}/vendor/bundle/ruby/${ruby_major}"
  set_runtime_env LD_LIBRARY_PATH "$(pkg_path_for "core/gcc-libs")/lib:$(pkg_path_for "core/libevent")"
  set_runtime_env HOME ${pkg_svc_data_path}
  set_runtime_env LANG "en_US.UTF-8"
  set_runtime_env LC_ALL "en_US.UTF-8"
  set_runtime_env SENDMAIL_PATH "$(pkg_path_for busybox-static)/bin/sendmail"
  set_runtime_env RAILS_ENV "production"
  set_runtime_env RACK_ENV "production"
  set_runtime_env RAILS_ROOT "${pkg_prefix}/${app_sub_path}"
  set_runtime_env EYE_HOME "${pkg_svc_var_path}/eye"

  set_runtime_env SPARC_VERSION "v${pkg_version}"
  # Build specific

  set_buildtime_env HOME /root
  mkdir --parents '/hab/cache/artifacts/studio_cache/yarn'
  set_buildtime_env YARN_CACHE_FOLDER '/hab/cache/artifacts/studio_cache/yarn'

  set_buildtime_env BUNDLE_SILENCE_ROOT_WARNING 1

  set_buildtime_env MY_BUNDLE_CACHE_PATH $HAB_CACHE_SRC_PATH/bundle_cache
  set_buildtime_env MY_TMP_CACHE_PATH $HAB_CACHE_SRC_PATH/tmp_cache
  set_buildtime_env MY_NODE_CACHE_PATH $HAB_CACHE_SRC_PATH/node_cache

  local _libxml2_dir=$(pkg_path_for libxml2)
  local _libxslt_dir=$(pkg_path_for libxslt)
  local _zlib_dir=$(pkg_path_for zlib)
  local _mysql2_dir=$(pkg_path_for mysql-client)

  # don't let bundler split up the nokogiri config string (it breaks
  # the build), so specify it as an env var instead
  set_buildtime_env NOKOGIRI_CONFIG "--use-system-libraries --with-zlib-dir=${_zlib_dir} --with-xslt-dir=${_libxslt_dir} --with-xml2-include=${_libxml2_dir}/include/libxml2 --with-xml2-lib=${_libxml2_dir}/lib"

  set_buildtime_env MYSQL_CONFIG "--with-mysql-dir=${_mysql2_dir}"
}
do_build() {


  # we control the variable above, and it will be all on one line, and
  # we need single quotes otherwise the extconf doesn't build the
  # extension.
  bundle config build.nokogiri '${NOKOGIRI_CONFIG}'
  bundle config build.mysql2 '${MYSQL_CONFIG}'

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

  ####### ZOOM ######
  if [[ -e $MY_BUNDLE_CACHE_PATH ]]; then
    build_line "Restoring cached bundle gems"
    mkdir -p vendor
    cp -a $MY_BUNDLE_CACHE_PATH vendor/bundle
  fi

  if [[ -e $MY_NODE_CACHE_PATH ]]; then
    build_line "Restoring cached node modules"
    rm -fr node_modules
    cp -a $MY_NODE_CACHE_PATH node_modules
  fi

  if [[ -e $MY_TMP_CACHE_PATH ]]; then
    build_line "Restoring cached assets"
    mkdir -p tmp
    cp -a $MY_TMP_CACHE_PATH tmp/cache
  fi

   build_line "Bundle install gems"
   bundle install \
     --path vendor/bundle \
     --without test:development \
     --retry 5 \
     --binstubs \
     --quiet

  # cp -R vendor/bundle $HAB_CACHE_SRC_PATH/bundle_cache
  # Some bundle files when they install have permissions that don't
  # allow the all user to read them, but because we are running as
  # root right now for building, but as 'hab' or someone else when the
  # package installs we need to make sure we can read the files
  chmod -R a+rx vendor/bundle

  # Need to generate a database.yml if there isn't one
  if [[ ! -e config/database.yml ]]; then
    clean_up_db=true
    build_line "Creating stub database.yml"
    cat << NULLDB > config/database.yml
production:
  adapter: nulldb
  database: none
NULLDB

  fi

  if [[ ! -e config/epic.yml ]]; then
    build_line "Copying default epic.yml for asset compilation"
    cp config/epic.yml.example config/epic.yml
  fi

  if [[ ! -e config/ldap.yml ]]; then
    build_line "Copying default ldap.yml for asset compilation"
    cp config/ldap.yml.example config/ldap.yml
    sed -e "s#test#production#" -i "config/ldap.yml"
  fi

  build_line "Installing JS packages"
  yarn install

  build_line "Precompiling assets"
  RAILS_ENV=production bin/rake -s assets:precompile

  # need to clean up these yaml files
  rm config/epic.yml
  rm config/ldap.yml

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
  build_line "Copying current files to $RAILS_ROOT"
  mkdir -p "$RAILS_ROOT"
  cp -a . "$RAILS_ROOT"

  # This seems to be some habitat stuff that you 
  # just need to do?
  for binstub in $RAILS_ROOT/bin/*; do
    build_line "Setting shebang for ${binstub} to 'ruby'"
    [[ -f $binstub ]] && sed -e "s#/usr/bin/env ruby#$(pkg_path_for ${ruby_pkg})/bin/ruby#" -i "$binstub"
  done
  for binstub in $RAILS_ROOT/script/*; do
    build_line "Setting shebang for ${binstub} to 'ruby'"
    [[ -f $binstub ]] && sed -e "s#/usr/bin/env ruby#$(pkg_path_for ${ruby_pkg})/bin/ruby#" -i "$binstub"
  done

  if [[ $(readlink /usr/bin/env) = "$(pkg_path_for coreutils)/bin/env" ]]; then
    build_line "Removing the symlink we created for '/usr/bin/env'"
    rm /usr/bin/env
  fi

  chmod +x $RAILS_ROOT/script/upgrade/*.sh

  _create_symlinks
  _create_process_bin "${pkg_prefix}/bin/rake" rake
  _create_process_bin "${pkg_prefix}/bin/rails" rails
  _create_process_bin "${pkg_prefix}/bin/eye" eye
}

_create_symlinks() {

  rm -rf ${pkg_prefix}/static/release/log
  rm -rf ${pkg_prefix}/static/release/tmp
  rm -rf ${pkg_prefix}/static/release/backup
  rm -rf ${pkg_prefix}/static/release/public/system
  rm -rf ${pkg_prefix}/static/release/config/database.yml
  rm -rf ${pkg_prefix}/static/release/config/fulfillment_db.yml
  rm -rf ${pkg_prefix}/static/release/config/application.yml
  rm -rf ${pkg_prefix}/static/release/config/epic.yml
  rm -rf ${pkg_prefix}/static/release/config/ldap.yml

  ln -sf ${pkg_svc_var_path}/log ${pkg_prefix}/static/release/log
  ln -sf ${pkg_svc_var_path}/tmp ${pkg_prefix}/static/release/tmp
  ln -sf ${pkg_svc_var_path}/backup ${pkg_prefix}/static/release/backup
  ln -sf ${pkg_svc_data_path}/system ${pkg_prefix}/static/release/public/system

  ln -sf ${pkg_svc_config_path}/database.yml ${pkg_prefix}/static/release/config/database.yml
  ln -sf ${pkg_svc_config_path}/fulfillment_db.yml ${pkg_prefix}/static/release/config/fulfillment_db.yml
  ln -sf ${pkg_svc_config_path}/application.yml ${pkg_prefix}/static/release/config/application.yml
  ln -sf ${pkg_svc_config_path}/epic.yml ${pkg_prefix}/static/release/config/epic.yml
  ln -sf ${pkg_svc_config_path}/ldap.yml ${pkg_prefix}/static/release/config/ldap.yml
  ln -sf ${pkg_svc_config_path}/dotenv ${pkg_prefix}/static/release/.env
}

# The default implementation is to strip any binaries in $pkg_prefix of their
# debugging symbols. You should override this behavior if you want to change
# how the binaries are stripped, which additional binaries located in
# subdirectories might also need to be stripped, or whether you do not want the
# binaries stripped at all.
do_strip() {
  return 0
}

do_after() {
  if [[ $HAB_CREATE_PACKAGE == 'false' ]]; then
    build_line "WARN: Skipping artifact creation because 'HAB_CREATE_PACKAGE=false'"

    _generate_artifact() {
      return 0
    }

    _prepare_build_outputs() {
      return 0
    }
  fi
}
# There is no default implementation of this callback. This is called after the
# package has been built and installed. You can use this callback to remove any
# temporary files or perform other post-install clean-up actions.
do_end() {
  if [[ "$STORE_CACHES" == "true" ]]; then
    build_line "Caching expensive dependencies"
    
    # Remove first so that our cp command behaves consistently
    rm -frv $MY_BUNDLE_CACHE_PATH
    rm -frv $MY_NODE_CACHE_PATH
    rm -frv $MY_TMP_CACHE_PATH

    cp -a $HAB_CACHE_SRC_PATH/${pkg_dirname}/vendor/bundle $MY_BUNDLE_CACHE_PATH
    [[ -d $HAB_CACHE_SRC_PATH/${pkg_dirname}/node_modules ]] && cp -a $HAB_CACHE_SRC_PATH/${pkg_dirname}/node_modules $MY_NODE_CACHE_PATH
    cp -a $HAB_CACHE_SRC_PATH/${pkg_dirname}/tmp/cache $MY_TMP_CACHE_PATH
  fi

  return 0
}

# **Internal** Use a "tar pipe" to copy the app source into a destination
# directory. This function reads from `stdin` for its file/directory manifest
# where each entry is on its own line ending in a newline. Several filters and
# changes are made via this copy strategy:
#
# * All user and group ids are mapped to root/0
# * No extended attributes are copied
# * Some file editor backup files are skipped
# * Some version control-related directories are skipped
# * Any `./habitat/` directory is skipped
# * Any `./vendor/bundle` directory is skipped as it may have native gems
_tar_pipe_app_cp_to() {
  local dst_path tar
  dst_path="$1"
  tar="$(pkg_path_for tar)/bin/tar"

  mkdir -p $dst_path

  "$tar" -cp \
      --owner=root:0 \
      --group=root:0 \
      --no-xattrs \
      --exclude-backups \
      --exclude-vcs \
      --exclude='habitat' \
      --exclude='node_modules' \
      --exclude='vendor/bundle' \
      --exclude='results' \
      --files-from=- \
      -f - \
  | "$tar" -x \
      -C "$dst_path" \
      -f -
}

_create_process_bin() {
  local bin cmd env_sh
  bin="$1"
  cmd="$2"
  env_sh="$pkg_svc_config_path/dotenv"

  build_line "Creating ${bin} process bin"

  cat <<EOF > "$bin"
#!$(pkg_path_for busybox-static)/bin/sh
set -e
if test -n "\$DEBUG"; then set -x; fi
export HOME="$pkg_svc_data_path"
if [ -f "$env_sh" ]; then
  source "$env_sh"
else
  >&2 echo "No dotenv file found: '$env_sh'"
  >&2 echo "Have you not started this service ($pkg_origin/$pkg_name) before?"
  >&2 echo ""
  >&2 echo "Aborting..."
  exit 1
fi
cd $RAILS_ROOT
exec ./bin/$cmd \$@
EOF
  chmod -v 755 "$bin"
}

set -o nounset
set -e

echo "Running 2.0.5 data migrations"

bundle exec rake data:update_protocol_filters
bundle exec rake data:replace_arm_name_special_characters

echo "Running 2.0.5 data migrations"

bin/rake data:update_protocol_filters
bin/rake data:replace_arm_name_special_characters

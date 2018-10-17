echo "Running 3.3.0 rake tasks"

echo "migrate IDs to bigint"
bin/rake migrate_ids_to_bigint

echo "clean up past statuses"
bin/rake data:clean_up_past_statuses

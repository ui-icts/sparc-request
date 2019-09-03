echo "Running 3.5.0 rake tasks"

echo "fix past status data"
bin/rake "data:fix_past_status_data"

echo "Backbill original submissions"
bin/rake "data:backfill_original_submissions"



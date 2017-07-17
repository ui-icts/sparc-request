echo "Running 2.1.0 data migrations"

echo "Clean up services"
bin/rake data:clean_up_services
echo "Fix study type questions"
bin/rake study_type_question_3_fix
echo "Merge SRS"
bin/rake merge_srs
echo "Fix SSR IDs"
bin/rake fix_ssr_ids

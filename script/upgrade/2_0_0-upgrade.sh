#! /usr/bin/env sh

set -o nounset
set -e

echo "Running 2.0.0 data migrations"

echo "Remove duplicate status"
bundle exec rake remove_duplicate_past_status
# echo "Surveyor customer satisfaction survey"
# bundle exec rake surveyor FILE=surveys/SCTR_customer_satisfaction_survey.rb
# echo "Surveyor system satisfaction survey"
# bundle exec rake surveyor FILE=surveys/system_satisfaction_survey.rb
echo "fix OTF service associations"
bundle exec rake fix_otf_service_associations
echo "remove invalid identities"
bundle exec rake data:remove_invalid_identities
echo "Replace ARM name special characters"
bundle exec rake data:replace_arm_name_special_characters
echo "Professional organizations update"
bundle exec rake professional_organizations_update
echo "Add service request to dashboard protocols"
bundle exec rake add_service_request_to_dashboard_protocols
echo "Fix missing ssr_ids"
bundle exec rake data:fix_missing_ssr_ids


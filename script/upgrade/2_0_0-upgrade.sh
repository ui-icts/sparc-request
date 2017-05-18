#! /usr/bin/env sh

set -o nounset
set -e

bundle exec rake remove_duplicate_past_status
bundle exec rake surveyor FILE=surveys/SCTR_customer_satisfaction_survey.rb
bundle exec rake surveyor FILE=surveys/system_satisfaction_survey.rb
bundle exec rake fix_otf_service_associations
bundle exec rake data:remove_invalid_identities
bundle exec rake data:replace_arm_name_special_characters
bundle exec rake professional_organizations_update
bundle exec rake add_service_request_to_dashboard_protocols
bundle exec rake data:fix_missing_ssr_ids


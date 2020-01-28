update 'en' do

  change 'activerecord.attributes.human_subjects_info.pro_number', to: 'WIRB #:'
  change 'activerecord.attributes.protocol.udak_project_number', to: 'Financial Account (MFK#):'


  update 'mailer' do
    replace 'received', part: 'SPARC', with: 'I-CART'
    change 'issue_contact', to: "Please contact us at iCartHelp@healthcare.uiowa.edu for assistance with this process or with any questions you may have."
  end

  update 'notifier.status_change' do
    replace 'body1', part: 'SPARC', with: 'I-CART'
    replace 'body2', part: 'SPARC', with: 'I-CART'
    replace 'body5', part: 'SPARC', with: 'I-CART'
  end


#  change 'right_navigation.redcap_survey', to: "https://redcap.icts.uiowa.edu/redcap/surveys/?s=7LRHJ9NP3M"

  change 'subsidy_page.eligible_html', to: "The services selected below may be eligible for a <b><i>funding award</i></b> or subsidy to cover some or all of the costs of the services."
  change 'tags.ctrc_clinical_services', to: "Clinical Research Support services"


end

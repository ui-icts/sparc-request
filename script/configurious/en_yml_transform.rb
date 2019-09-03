update 'en' do
  update 'admin_identities' do
    change 'button_add_user', to: 'Add User to I-CART'
    change 'footer', to: "* Close this window or tab when you're done adding new users to I-CART."
    change 'grid_uid', to: 'HawkID'
    change 'search_help_block', to: "Full name searches do not work. Filter the results by searching within the column headers in the grid below. Edit User buttons are displayed for people already in I-CART and only usable by I-CART administrators."
    change 'search_placeholder', to: "Search one of the following: first name, last name, email, or HawkID"
  end

  update 'bottom_navigation' do
    change 'submit_to_start', to: "Submit to Start Services ⟶ "
  end

  change 'message.red_message', to: ''
  change 'calendar_page.headers.subjects', to: '# Subjects'

  update 'study_form' do

    change 'nct_number', to: "NCT # (clinicaltrials.gov number):"
    change 'pro_number', to: "WIRB #:"
    change 'udak_project_number', to: "Financial Account (MFK#):"
  end

  change 'protocols.studies.financial_information.udak_project_number', to: 'MFK #'

  update 'footer' do
    change 'mail_to', to: ""
    change 'mail_link', to: ""
    change 'mail_subject', to: ""
    change 'link_one_text', to: "I-CART Newsletter"
    change 'link_one_url', to: "https://list.uiowa.edu/scripts/wa.exe?SUBED1=ICTS-I-CART&A=1"
    change 'link_two_text', to: "SPARC Request Blog"
    change 'link_two_url', to: "http://sparcrequestosblog.com/"
    change 'link_three_text', to: "SPARC Request at MUSC"
  end

  update 'reports' do

    change 'intro', to: "Welcome to the I-CART Request Reporting Module. Please select a report type to proceed."
  end

  update 'indirect_cost_rates' do
    change 'industry', to: "25"
    change 'foundation_and_investigator', to: "15"
    change 'federal', to: "51"
  end

  update 'cart' do
    #change 'remove_request_confirm' to: "This action will delete this service request and you will be redirected to the dashboard. Click OK to proceed."
    replace 'remove_request_confirm', part: 'your user portal', with: 'the dashboard'
  end

  update 'mailer' do
    replace 'received', part: 'SPARC', with: 'I-CART'
    change 'issue_contact', to: "Please contact us at iCartHelp@healthcare.uiowa.edu for assistance with this process or with any questions you may have."
  end

  update 'signup' do
    replace 'message', part: 'SPARC', with: 'I-CART'
  end

  update 'notifier.notice' do
    replace 'body1', part: 'SPARC', with: 'I-CART'
    replace 'body2', part: 'SPARC', with: 'I-CART'
  end

  update 'notifier.status_change' do
    replace 'body1', part: 'SPARC', with: 'I-CART'
    replace 'body2', part: 'SPARC', with: 'I-CART'
    replace 'body5', part: 'SPARC', with: 'I-CART'
  end

  update 'portal_user_form' do
    change 'epic_access', to: "Epic EMR Access?:"
  end

  update 'protocol_information' do
    replace 'message1', part: 'SPARC', with: 'I-CART'
  end

  replace 'rails_root', with: {
    message1_html: "I-CART is an online one-stop-shopping experience that efficiently manages all of your ICTS-related research requests and services. Anyone requesting to use ICTS services must use I-CART. If you need help planning your project, please select the appropriate consulting service to meet with a service manager.",
    welcome_html: "Welcome to the UIowa SPARC Request Services Catalog",
    message4_html: "I-CART is powered by Medical University of South Carolina’s Services, Pricing, & Applications for Research Centers (SPARC) request management system.",
    message5_html: "Welcome to SPARC Request Version 4.0. We're happy to announce that Step 2 now includes the concept of clinical trial arms. You'll find other numerous enhancements and upgrades in Version 4.0. For more information and training documents, please visit our new website at",
    message6_html: "Please contact the PLACEHOLDER at xxx-xxxx with any questions or to set up a demonstration!",
    message7_html: "Check out our SPARC Request Blog (",
    message8_html: "). This feature allows you to follow our latest news and is a great way to ask questions of and leave feedback for the SPARC Request Team as well as communicate with both us and other SPARC Request Users.",
    message9_html: 'Search for services above or browse the catalog to your left. <strong>You may only select services applicable to ONE research study/project at a time</strong>. Please watch the following <a href="http://academicdepartments.musc.edu/sctr/sparc_request/training.html" target="_blank">training videos</a> to learn more.',
    message9link: '',
    message10_html: "",
    message10link: '',
    message11_html: "",
  }

  change 'right_navigation.redcap_survey', to: "https://redcap.icts.uiowa.edu/redcap/surveys/?s=7LRHJ9NP3M"

  update 'sr_confirmation' do
    change 'instructions', to: "Thank you for submitting your service request(s) through I-CART. An email has been sent to each of your service providers and they should be contacting you soon. If you have any questions or concerns, please don't hesitate to contact us at iCartHelp@healthcare.uiowa.edu"
    change 'portal_button', to: "Go to I-CART Dashboard"
  end

  update 'service_request_details' do
    replace 'one_time_fee_instructions', part: 'SPARC', with: 'I-CART'
  end

  update 'sr_review' do
    replace 'participate_in_survey', part: 'SPARC', with: 'I-CART'
    change 'study_project_info.title', to: "Study/Project Title:"
  end

  update 'signin' do
    replace 'button1', part: 'MUSC', with: 'UIowa'
    replace 'message1', part: 'MUSC', with: 'UIowa'
    replace 'message3', part: 'SPARC', with: 'I-CART'

  end

  replace 'initial_signin_dialog', part: 'SPARC', with: 'I-CART'
  replace 'proceed_to_database_login', part: 'SPARC', with: 'I-CART'
  replace 'proceed_to_shibboleth', part: 'MUSC', with: 'UIowa'

  change 'subsidy_page.eligible_html', to: "The services selected below may be eligible for a <b><i>funding award</i></b> or subsidy to cover some or all of the costs of the services."
  change 'tags.ctrc_clinical_services', to: "Clinical Research Support services"

  update 'cart_help.questions' do
    change 'question_text5', to: "How is I-CART Request calculating my indirect costs?"
    change 'answer_text5', to: "The original requester for your study/project defined both the funding source of the study/project and the indirect cost rate. I-CART Request uses this data to calculate your total overall indirect costs."
    change 'question_text6', to: "I'm stuck! Who can I contact for assistance with an I-CART Request?"
    change 'answer_text6', to: "We are happy to assist you! Please contact us at iCartHelp@healthcare.uiowa.edu"
  end

  change 'user_list.epic_access', to: "Epic EMR Access?:*"

  replace 'user_search.advanced_user_search_title', part: 'SPARC', with: 'I-CART'
end

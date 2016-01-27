require 'rails_helper'

RSpec.describe 'editing a studys epic box', js: true do
  let_there_be_lane
  let_there_be_j
  fake_login_for_each_test
  build_service_request_with_study

  let(:numerical_day) { Date.today.strftime('%d').gsub(/^0/, '') }


  context 'visiting a studys edit page and the study is not selected for epic' do

    before :each do
      add_visits
      edit_project_study_info
    end

    it 'should only display that it is not chosen for epic' do

      study.update_attributes(selected_for_epic: false)
      expect(page).to_not have_selector('#study_type_answer_certificate_of_conf')
      expect(find(".epic_selected")).to have_text("No")
    end
  end

  context 'visiting a ACTIVE studys edit page and the study IS selected for epic' do

    before :each do
      add_visits
      study.update_attributes(selected_for_epic: true)
      study.update_attributes(study_type_question_group_id: StudyTypeQuestionGroup.where(active:true).pluck(:id).first)
    end

    context 'epic box answers are YES, YES, NIL, NIL, NIL, NIL' do

      before :each do
        answer_questions(1, 1, nil, nil, nil, nil)
        edit_project_study_info
      end

      it 'should display YES, YES, NIL, NIL, NIL, NIL' do

        expect(page).to have_css('#study_type_answer_certificate_of_conf')
        expect(find("#study_type_answer_certificate_of_conf .display_epic_answers")).to have_text("Yes")
        expect(page).to have_css('#study_type_answer_higher_level_of_privacy')
        expect(find("#study_type_answer_higher_level_of_privacy .display_epic_answers")).to have_text("Yes")
        expect(page).to_not have_css('#study_type_answer_access_study_info')
        expect(page).to_not have_css('#study_type_answer_epic_inbasket')
        expect(page).to_not have_css('#study_type_answer_research_active')
        expect(page).to_not have_css('#study_type_answer_restrict_sending')


      end
    end

    context 'epic box answers are YES, YES, NIL, NIL, NIL, NIL' do

      before :each do
        answer_questions(0, 1, 0, 0, 0, 1)
        edit_project_study_info
      end

      it 'should display YES, YES, NIL, NIL, NIL, NIL' do

        expect(page).to have_css('#study_type_answer_certificate_of_conf')
        expect(find("#study_type_answer_certificate_of_conf .display_epic_answers")).to have_text("No")

        expect(page).to have_css('#study_type_answer_higher_level_of_privacy')
        expect(find("#study_type_answer_higher_level_of_privacy .display_epic_answers")).to have_text("Yes")

        expect(page).to have_css('#study_type_answer_access_study_info')
        expect(find("#study_type_answer_access_study_info .display_epic_answers")).to have_text("No")

        expect(page).to have_css('#study_type_answer_epic_inbasket')
        expect(find("#study_type_answer_epic_inbasket .display_epic_answers")).to have_text("No")

        expect(page).to have_css('#study_type_answer_research_active')
        expect(find("#study_type_answer_research_active .display_epic_answers")).to have_text("No")

        expect(page).to have_css('#study_type_answer_restrict_sending')
        expect(find("#study_type_answer_restrict_sending .display_epic_answers")).to have_text("Yes")

      end
    end

    context 'epic box answers are NO, NO, NIL, NO, NO, TRUE' do

      before :each do
        answer_questions(0, 0, nil, 0, 0, 1)
        edit_project_study_info
      end

      it 'should display NO, NO, NIL, NO, NO, TRUE' do

        expect(page).to have_css('#study_type_answer_certificate_of_conf')
        expect(find("#study_type_answer_certificate_of_conf .display_epic_answers")).to have_text("No")

        expect(page).to have_css('#study_type_answer_higher_level_of_privacy')
        expect(find("#study_type_answer_higher_level_of_privacy .display_epic_answers")).to have_text("No")

        expect(page).to_not have_css('#study_type_answer_access_study_info')

        expect(page).to have_css('#study_type_answer_epic_inbasket')
        expect(find("#study_type_answer_epic_inbasket .display_epic_answers")).to have_text("No")

        expect(page).to have_css('#study_type_answer_research_active')
        expect(find("#study_type_answer_research_active .display_epic_answers")).to have_text("No")

        expect(page).to have_css('#study_type_answer_restrict_sending')
        expect(find("#study_type_answer_restrict_sending .display_epic_answers")).to have_text("Yes")

      end
    end
    context 'epic box answers are NO, YES, NO, NO, NO, TRUE' do

      before :each do
        answer_questions(0, 1, 0, 0, 0, 1)
        edit_project_study_info
      end

      it 'should display ACTIVE questions' do

        expect(page).to have_css('#study_type_answer_certificate_of_conf')
        expect(find("#study_type_answer_certificate_of_conf")).to have_text("1. Does your study have a Certificate of Confidentiality?")

        expect(page).to have_css('#study_type_answer_higher_level_of_privacy')
        expect(find("#study_type_answer_higher_level_of_privacy")).to have_text("2. Does your study require a higher level of privacy for the participants?")

        expect(page).to have_css('#study_type_answer_access_study_info')
        expect(find('#study_type_answer_access_study_info')).to have_text("2b. Do participants enrolled in your study require a second DEIDENTIFIED Medical Record that is not connected to their primary record in Epic?")

        expect(page).to have_css('#study_type_answer_epic_inbasket')
        expect(find("#study_type_answer_epic_inbasket")).to have_text("3. Do you wish to receive a notification via Epic InBasket when your research participants are admitted to the hospital or ED?")

        expect(page).to have_css('#study_type_answer_research_active')
        expect(find("#study_type_answer_research_active")).to have_text("4. Do you wish to remove the 'Research: Active' indicator in the Patient Header for your study participants?")

        expect(page).to have_css('#study_type_answer_restrict_sending')
        expect(find("#study_type_answer_restrict_sending")).to have_text("5. Do you need to restrict the sending of study related results, such as laboratory and radiology results, to a participants MyChart?")
      end
    end
  end

  context 'visiting a INACTIVE studys edit page and the study is selected for epic' do
    before :each do
      add_visits
      study.update_attributes(selected_for_epic: true)
      study.update_attributes(study_type_question_group_id: StudyTypeQuestionGroup.where(active:false).pluck(:id).first)
    end

    context 'epic box answers are YES, NO, YES, NIL, NIL, NIL' do

      before :each do

        answer1.update_attributes(answer: 1)
        answer2.update_attributes(answer: 0)
        answer3.update_attributes(answer: 1)
        answer4.update_attributes(answer: nil)
        answer5.update_attributes(answer: nil)
        answer6.update_attributes(answer: nil)



        edit_project_study_info

      end

      it 'should display YES, NO, YES, NIL, NIL, NIL' do

        expect(page).to have_css('#study_type_answer_higher_level_of_privacy')
        expect(find("#study_type_answer_higher_level_of_privacy .display_epic_answers")).to have_text("Yes")

        expect(page).to have_css('#study_type_answer_certificate_of_conf')
        expect(find("#study_type_answer_certificate_of_conf .display_epic_answers")).to have_text("No")

        expect(page).to have_css('#study_type_answer_access_study_info')
        expect(find("#study_type_answer_access_study_info .display_epic_answers")).to have_text("Yes")

        expect(page).to_not have_css('#study_type_answer_epic_inbasket')
        expect(page).to_not have_css('#study_type_answer_research_active')
        expect(page).to_not have_css('#study_type_answer_restrict_sending')


      end
    end

    context 'epic box answers are YES, NO, NO, YES, YES, YES ' do

      before :each do


        answer1.update_attributes(answer: 1)
        answer2.update_attributes(answer: 0)
        answer3.update_attributes(answer: 0)
        answer4.update_attributes(answer: 1)
        answer5.update_attributes(answer: 1)
        answer6.update_attributes(answer: 1)



        edit_project_study_info

      end

      it 'should display YES, NO, NO, YES, YES, YES' do

        expect(page).to have_css('#study_type_answer_higher_level_of_privacy')
        expect(find("#study_type_answer_higher_level_of_privacy .display_epic_answers")).to have_text("Yes")

        expect(page).to have_css('#study_type_answer_certificate_of_conf')
        expect(find("#study_type_answer_certificate_of_conf .display_epic_answers")).to have_text("No")

        expect(page).to have_css('#study_type_answer_access_study_info')
        expect(find("#study_type_answer_access_study_info .display_epic_answers")).to have_text("No")

        expect(page).to have_css('#study_type_answer_epic_inbasket')
        expect(find("#study_type_answer_epic_inbasket .display_epic_answers")).to have_text("Yes")

        expect(page).to have_css('#study_type_answer_research_active')
        expect(find("#study_type_answer_research_active .display_epic_answers")).to have_text("Yes")

        expect(page).to have_css('#study_type_answer_restrict_sending')
        expect(find("#study_type_answer_restrict_sending .display_epic_answers")).to have_text("Yes")


      end
    end

    context 'epic box answers are NO, NIL, NIL, YES, YES, YES' do

      before :each do

        answer1.update_attributes(answer: 0)
        answer2.update_attributes(answer: nil)
        answer3.update_attributes(answer: nil)
        answer4.update_attributes(answer: 1)
        answer5.update_attributes(answer: 1)
        answer6.update_attributes(answer: 1)



        edit_project_study_info

      end

      it 'should display NO, NIL, NIL, YES, YES, YES' do

        expect(page).to have_css('#study_type_answer_higher_level_of_privacy')
        expect(find("#study_type_answer_higher_level_of_privacy .display_epic_answers")).to have_text("No")

        expect(page).to_not have_css('#study_type_answer_certificate_of_conf')
        expect(page).to_not have_css('#study_type_answer_access_study_info')


        expect(page).to have_css('#study_type_answer_epic_inbasket')
        expect(find("#study_type_answer_epic_inbasket .display_epic_answers")).to have_text("Yes")

        expect(page).to have_css('#study_type_answer_research_active')
        expect(find("#study_type_answer_research_active .display_epic_answers")).to have_text("Yes")

        expect(page).to have_css('#study_type_answer_restrict_sending')
        expect(find("#study_type_answer_restrict_sending .display_epic_answers")).to have_text("Yes")

      end
    end
    context 'epic box answers are NO, YES, NO, NO, NO, TRUE' do

      before :each do

        active_answer1.update_attributes(answer: 0)
        active_answer2.update_attributes(answer: 1)
        active_answer3.update_attributes(answer: 0)
        active_answer4.update_attributes(answer: 0)
        active_answer5.update_attributes(answer: 0)
        active_answer6.update_attributes(answer: 1)

        edit_project_study_info

      end

      it 'should display INACTIVE questions' do

        expect(page).to have_css('#study_type_answer_higher_level_of_privacy')
        expect(find("#study_type_answer_higher_level_of_privacy")).to have_text("1a. Does your study require a higher level of privacy for the participants?")

        expect(page).to have_css('#study_type_answer_certificate_of_conf')
        expect(find("#study_type_answer_certificate_of_conf")).to have_text("1b. Does your study have a Certificate of Confidentiality?")

        expect(page).to have_css('#study_type_answer_access_study_info')
        expect(find('#study_type_answer_access_study_info')).to have_text("1c. Do participants enrolled in your study require a second DEIDENTIFIED Medical Record that is not connected to their primary record in Epic?")

        expect(page).to have_css('#study_type_answer_epic_inbasket')
        expect(find("#study_type_answer_epic_inbasket")).to have_text("2. Do you wish to receive a notification via Epic InBasket when your research participants are admitted to the hospital or ED?")

        expect(page).to have_css('#study_type_answer_research_active')
        expect(find("#study_type_answer_research_active")).to have_text("3. Do you wish to remove the 'Research: Active' indicator in the Patient Header for your study participants?")

        expect(page).to have_css('#study_type_answer_restrict_sending')
        expect(find("#study_type_answer_restrict_sending")).to have_text("4. Do you need to restrict the sending of study related results, such as laboratory and radiology results, to a participants MyChart?")

      end
    end
  end

  def edit_project_study_info
    study.reload
    visit portal_admin_sub_service_request_path sub_service_request.id
    click_on('Project/Study Information')
    wait_for_javascript_to_finish
  end

  def answer_questions(*answers)
    active_answer1.update_attributes(answer: answers[0])
    active_answer2.update_attributes(answer: answers[1])
    active_answer3.update_attributes(answer: answers[2])
    active_answer4.update_attributes(answer: answers[3])
    active_answer5.update_attributes(answer: answers[4])
    active_answer6.update_attributes(answer: answers[5])
  end
end

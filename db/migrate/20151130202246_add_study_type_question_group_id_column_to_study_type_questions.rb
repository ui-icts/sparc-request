class AddStudyTypeQuestionGroupIdColumnToStudyTypeQuestions < ActiveRecord::Migration
  def up
  	add_column :study_type_questions, :study_type_question_group_id, :integer
  end

  def down
  	remove_column :study_type_questions, :study_type_question_group_id
  end
end

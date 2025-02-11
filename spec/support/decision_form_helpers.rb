module DecisionFormHelpers
  def complete_ioj_form(result = 'Passed')
    choose_answer('Interests of justice test result', result)
    fill_in('Reason for result', with: 'Test result reason details')
    fill_in('Caseworker name', with: 'Zoe Blogs')
    fill_date('Date of test', with: Date.new(2024, 2, 1))
    save_and_continue
  end

  def complete_overall_result_form(decision = 'Granted')
    choose_answer('What is the funding decision for this application?', decision)
    save_and_continue
  end

  def complete_comment_form
    fill_in('Comments for provider (optional)', with: 'Caseworker comment')
    save_and_continue
  end

  def add_a_non_means_decision
    click_button 'Start'
    complete_ioj_form
    complete_overall_result_form
    complete_comment_form
  end

  def add_a_failed_non_means_decision
    click_button 'Start'
    complete_ioj_form('Failed')
    complete_overall_result_form('Refused')
    complete_comment_form
  end

  def add_a_maat_decision
    click_button 'Start'
    complete_ioj_form
    complete_overall_result_form
    complete_comment_form
  end
end

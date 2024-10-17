module DecisionFormHelpers
  def complete_ioj_form
    choose_answer('What is the interests of justice test result?', 'Passed')
    fill_in('What is the reason for this?', with: 'Test result reason details')
    fill_in('What is the name of the caseworker who assessed this?', with: 'Zoe Blogs')
    fill_date('Enter the date of assessment', with: Date.new(2024, 2, 1))
    save_and_continue
  end

  def complete_overall_result_form
    choose_answer('What is the funding decision for this application?', 'Granted')
    save_and_continue
  end

  def complete_comment_form
    choose('Yes')
    fill_in('Additional comments for the provider', with: 'Caseworker comment')
    save_and_continue
  end

  def add_a_non_means_decision
    click_button 'Start'
    complete_ioj_form
    complete_overall_result_form
    complete_comment_form
  end
end

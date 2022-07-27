## Questions Structure ##
# [
#   {
#     text: 'What is the meaning of life?',
#     options: [{ text: '41' }, { text: '42' }]
#   }
# ]
## Answer Structure ##
# {q0: 1} -- Answer to q0 is the second option (0-indexed)

class CraqValidator
  POSSIBLE_ERRORS = [
    WAS_NOT_ANSWERED = 'was not answered',
    INVALID_SELECTION = 'has an answer that is not on the list of valid answers',
    PREVIOUS_QUESTION_ANSWERED = 'was answered even though a previous response indicated that the questions were complete'
  ]

  def initialize(questions, answers)
    @questions = questions
    @answers = answers
    @complete_if_selected = false
    @errors = {} 
  end

  attr_reader :errors

  def valid?    
    validate

    errors.empty?
  end

  private

  def validate
    @errors = @questions.each_with_index.reduce({}) do |errors, (element, index)|
      key = "q#{index}".to_sym

      if no_answer_given?(key)
        errors[key] = WAS_NOT_ANSWERED unless @complete_if_selected
      elsif invalid_answer?(element, key)
        errors[key] = INVALID_SELECTION
      elsif @complete_if_selected
        errors[key] = PREVIOUS_QUESTION_ANSWERED
      elsif element[:options][@answers[key]][:complete_if_selected]
        set_complete_if_selected
      end
      errors
    end
  end

  def set_complete_if_selected
    @complete_if_selected = true
  end
  
  def no_answer_given?(key)
    @answers.nil? || @answers.empty? || @answers[key].nil?
  end

  def invalid_answer?(question, key)
    question[:options][@answers[key]].nil?
  end
end
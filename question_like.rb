require 'singleton'
require 'sqlite3'


class QuestionLike

  attr_accessor :id, :user_id, :question_id

  def self.find_by_id(question_like_id)
    result = QuestionsDatabase.instance.execute(<<-SQL, question_like_id)
    SELECT
      id, user_id, question_id
    FROM
      question_likes
    WHERE
      id = ?
    SQL
    result.empty? ? nil : QuestionLike.new(result.first)
  end

  def initialize(options = {})
    @id = options['id']
    @user_id = options['user_id']
    @question_id = options['question_id']
  end

end

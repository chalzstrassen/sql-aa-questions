require 'singleton'
require 'sqlite3'


class Reply

  attr_accessor :id, :body, :user_id, :question_id, :parent_id

  def self.find_by_id(reply_id)
    result = QuestionsDatabase.instance.execute(<<-SQL, reply_id)
    SELECT
      id, body, user_id, question_id, parent_id
    FROM
      replies
    WHERE
      id = ?
    SQL

    result.empty? ? nil : Reply.new(result.first)
  end

  def initialize(options = {})
    @id = options['id']
    @body = options['body']
    @user_id = options['user_id']
    @question_id = options['question_id']
    @parent_id = options['parent_id']
  end

  def self.find_by_user_id(user_id)
    results = QuestionsDatabase.instance.execute(<<-SQL, user_id)
    SELECT
      id, body, user_id, question_id, parent_id
    FROM
      replies
    WHERE
      user_id = ?
    SQL

    results.map { |result| Reply.new(result) }
  end

  # returns an array of all replies to a question
  def self.find_by_question_id(question_id)
    results = QuestionsDatabase.instance.execute(<<-SQL, question_id)
    SELECT
      id, body, user_id, question_id, parent_id
    FROM
      replies
    WHERE
      question_id = ?
    SQL

    results.map { |result| Reply.new(result) }
  end

  def author
    User.find_by_id(self.user_id)
  end

  def question
    Question.find_by_id(self.question_id)
  end

  def parent_reply
    result = QuestionsDatabase.instance.execute(<<-SQL, self.parent_id)
    SELECT
      id, body, user_id, question_id, parent_id
    FROM
      replies
    WHERE
      id = ?
    SQL

    result.empty? ? nil : Reply.new(result.first)
  end

  def child_replies
    results = QuestionsDatabase.instance.execute(<<-SQL, self.id)
    SELECT
      id, body, user_id, question_id, parent_id
    FROM
      replies
    WHERE
      parent_id = ?
    SQL

    results.map { |result| Reply.new(result) }
  end

end

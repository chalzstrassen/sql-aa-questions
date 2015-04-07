require 'singleton'
require 'sqlite3'


class Question

  attr_accessor :id, :title, :body, :user_id

  def self.find_by_id(question_id)
    result = QuestionsDatabase.instance.execute(<<-SQL, question_id)
    SELECT
      id, title, body, user_id
    FROM
      questions
    WHERE
      id = ?
    SQL
    result.empty? ? nil : Question.new(result.first)
  end

  def initialize(options = {})
    @id = options['id']
    @title = options['title']
    @body = options['body']
    @user_id = options['user_id']
  end

  def self.find_by_author_id(author_id)
    result = QuestionsDatabase.instance.execute(<<-SQL, author_id)
    SELECT
      id, title, body, user_id
    FROM
      questions
    WHERE
      user_id = ?
    SQL

    result.empty? ? nil : Question.new(result.first)
  end

  def author
    User.find_by_id(self.user_id)
  end

  def replies
    Reply.find_by_question_id(self.id)
  end

  def followers
    QuestionFollow.followers_for_question_id(self.id)
  end
end

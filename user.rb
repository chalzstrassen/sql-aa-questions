require 'singleton'
require 'sqlite3'

class User

  attr_accessor :id, :fname, :lname

  def self.find_by_id(user_id)
    result = QuestionsDatabase.instance.execute(<<-SQL, user_id)
    SELECT
      id, fname, lname
    FROM
      users
    WHERE
      id = ?
    SQL

    result.empty? ? nil : User.new(result.first)
  end

  def initialize(options = {})
    @id = options['id']
    @fname = options['fname']
    @lname = options['lname']
  end

  def self.find_by_name(fname, lname)
    result = QuestionsDatabase.instance.execute(<<-SQL, fname, lname)
    SELECT
      id, fname, lname
    FROM
      users
    WHERE
      fname = ? AND lname = ?
    SQL

    result.empty? ? nil : User.new(result.first)
  end

  def authored_questions
    Question.find_by_author_id(self.id)
  end

  def authored_replies
    Reply.find_by_user_id(self.id)
  end

  def followed_questions
    QuestionFollow.followed_questions_for_user_id(self.id)
  end

end

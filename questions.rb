require 'singleton'
require 'sqlite3'
require 'byebug'

class QuestionsDatabase < SQLite3::Database

  include Singleton

  def initialize
    super('questions.db')

    self.results_as_hash = true
    self.type_translation = true
  end
end

# model class for each table represents an item from each table:

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


class QuestionFollow

  attr_accessor :id, :user_id, :question_id

  def self.find_by_id(question_follow_id)
    result = QuestionsDatabase.instance.execute(<<-SQL, question_follow_id)
    SELECT
      id, user_id, question_id
    FROM
      question_follows
    WHERE
      id = ?
    SQL
    result.empty? ? nil : QuestionFollow.new(result.first)
  end

  def initialize(options = {})
    @id = options['id']
    @user_id = options['user_id']
    @question_id = options['question_id']
  end


  def self.followers_for_question_id(question_id)
    results = QuestionsDatabase.instance.execute(<<-SQL, question_id)
    SELECT
      u.id, u.fname, u.lname
    FROM
      users AS u
    JOIN
      question_likes AS ql
    ON
      u.id = ql.user_id
    JOIN
      questions AS q
    ON
      ql.question_id = q.id
    WHERE
      q.id = ?
    SQL

    results.map { |result| User.new(result) }
  end

  def self.followed_questions_for_user_id(user_id)
    results = QuestionsDatabase.instance.execute(<<-SQL, user_id)
    SELECT
      q.id, q.title, q.body, q.user_id
    FROM
      questions AS q
    JOIN
      question_likes AS ql
    ON
      q.id = ql.question_id
    JOIN
      users AS u
    ON
      u.id = ql.user_id
    WHERE
      u.id = ?
    SQL

    results.map { |result| Question.new(result) }
  end

  def self.most_follow_questions()

end


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

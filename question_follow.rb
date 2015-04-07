require 'singleton'
require 'sqlite3'


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

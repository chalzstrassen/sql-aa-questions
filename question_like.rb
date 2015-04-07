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

  def self.likers_for_question_id(question_id)
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

  def self.num_likes_for_question_id(question_id)
    result = QuestionsDatabase.instance.execute(<<-SQL, question_id)
    SELECT
      COUNT(ql.user_id)
    FROM
      users AS u
    JOIN
      question_likes AS ql
    ON
      u.id = ql.user_id
    WHERE
      ql.question_id = ?
    SQL

    result.first.values.first
  end

  def self.most_liked_questions(n)
    results = QuestionsDatabase.instance.execute(<<-SQL, n)
    SELECT
      q.id, q.title, q.body, q.user_id
    FROM
      questions AS q
    JOIN
      question_likes AS ql
    ON
      q.id = ql.question_id
    ORDER BY
      COUNT(ql.id)
    LIMIT
      ?
    SQL

    results.map { |result| Question.new(result) }
  end

  def self.liked_questions_for_user_id(user_id)
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
      u.id = ?
    SQL

    results.map { |result| Question.new(result) }
  end

end

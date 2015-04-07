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
      question_follows AS qf
    ON
      u.id = qf.user_id
    JOIN
      questions AS q
    ON
      qf.question_id = q.id
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
      question_follows AS qf
    ON
      q.id = qf.question_id
    JOIN
      users AS u
    ON
      u.id = qf.user_id
    WHERE
      u.id = ?
    SQL

    results.map { |result| Question.new(result) }
  end

  def self.most_followed_questions(n)
    results = QuestionsDatabase.instance.execute(<<-SQL, n)
    SELECT
      q.id, q.title, q.body, q.user_id
    FROM
      questions AS q
    JOIN
      question_follows AS qf
    ON
      q.id = qf.question_id
    JOIN
      users AS u
    ON
      u.id = qf.user_id
    GROUP BY
      q.id
    ORDER BY
      COUNT(u.id)
    LIMIT
      ?
    SQL

    results.map { |result| Question.new(result) }
  end

  def likers
    QuestionLike.likers_for_question_id(self.id)
  end

  def num_likes
    QuestionLike.num_likes_for_question_id(self.id)
  end
end

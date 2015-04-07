CREATE TABLE users (
  id INTEGER PRIMARY KEY,
  fname VARCHAR(255) NOT NULL,
  lname VARCHAR(255) NOT NULL
);

CREATE TABLE questions (
  id INTEGER PRIMARY KEY,
  title VARCHAR (255) NOT NULL,
  body TEXT,
  user_id INTEGER NOT NULL,
  FOREIGN KEY (user_id) REFERENCES users(id)
);

CREATE TABLE question_follows (
  id INTEGER PRIMARY KEY,
  user_id INTEGER NOT NULL,
  question_id INTEGER NOT NULL,
  FOREIGN KEY (user_id) REFERENCES users(id),
  FOREIGN KEY (question_id) REFERENCES question(id)
);

CREATE TABLE replies (
  id INTEGER PRIMARY KEY,
  body TEXT,
  user_id INTEGER NOT NULL,
  question_id INTEGER NOT NULL,
  parent_id INTEGER,
  FOREIGN KEY (question_id) REFERENCES question(id),
  FOREIGN KEY (user_id) REFERENCES users(id),
  FOREIGN KEY (parent_id) REFERENCES replies(id)

);

CREATE TABLE question_likes (
  id INTEGER PRIMARY KEY,
  user_id INTEGER NOT NULL,
  question_id INTEGER NOT NULL,
  FOREIGN KEY (user_id) REFERENCES users(id),
  FOREIGN KEY (question_id) REFERENCES question(id)
);

INSERT INTO
  users (fname, lname)
VALUES
  ('John', 'Smith'), ('Foo', 'Bar'), ('Abigail', 'Adams');

INSERT INTO
  questions (title, body, user_id)
VALUES
  ('Car parts', 'How do I install turbo boost?',
    (SELECT id FROM users WHERE fname = 'Foo' AND lname = 'Bar')),
  ('Astrophysics', 'How many stars are there?',
    (SELECT id FROM users WHERE fname = 'John' AND lname = 'Smith'));

INSERT INTO
  question_follows (user_id, question_id)
VALUES
  ((SELECT id FROM users WHERE fname = 'Abigail' AND lname = 'Adams'),
    (SELECT questions.id FROM questions JOIN users ON questions.user_id = users.id
      WHERE users.fname = 'John' AND users.lname = 'Smith')),
  ((SELECT id FROM users WHERE fname = 'Foo' AND lname = 'Bar'),
    (SELECT questions.id FROM questions JOIN users ON questions.user_id = users.id
      WHERE users.fname = 'John' AND users.lname = 'Smith'));

INSERT INTO
  replies (body, question_id, user_id, parent_id)
VALUES
  ('There are 521 important stars.',
    (SELECT id FROM questions WHERE title = 'Astrophysics'),
    (SELECT id FROM users WHERE fname = 'Abigail' AND lname = 'Adams'),
    NULL),
  ('No, I scream! There are 1000!',
    (SELECT id FROM questions WHERE title = 'Astrophysics'),
    (SELECT id FROM users WHERE fname = 'Foo' AND lname = 'Bar'),
    (SELECT id FROM replies WHERE body = 'There are 521 important stars.')),
  ('RTFM.',
    (SELECT id FROM questions WHERE title = 'Car parts'),
    (SELECT id FROM users WHERE fname = 'Foo' AND lname = 'Bar'),
    NULL),
  ('Hire a mechanic.',
    (SELECT id FROM questions WHERE title = 'Car parts'),
    (SELECT id FROM users WHERE fname = 'Abigail' AND lname = 'Adams'),
    (SELECT id FROM replies WHERE body = 'RTFM.')),
  ('Thanks.',
    (SELECT id FROM questions WHERE title = 'Car parts'),
    (SELECT id FROM users WHERE fname = 'John' AND lname = 'Smith'),
    (SELECT id FROM replies WHERE body = 'Hire a mechanic.'));

INSERT INTO
  question_likes (user_id, question_id)
VALUES
  ((SELECT id FROM users WHERE fname = 'Foo' AND lname = 'Bar'),
    (SELECT id FROM questions WHERE title = 'Astrophysics'));

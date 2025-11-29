-- Добавление пяти новых пользователей
INSERT INTO users (name, email, gender, register_date, occupation_id)
VALUES 
('Андронов Никита', 'andronov.nikita@gmail.com', 'male', date('now'), 
    (SELECT id FROM occupations WHERE name = 'student')),
('Бабин Данила', 'babin.danila@gmail.com', 'male', date('now'), 
    (SELECT id FROM occupations WHERE name = 'student')),
('Буянкина Алина', 'buyankina.alina@gmail.com', 'female', date('now'), 
    (SELECT id FROM occupations WHERE name = 'student')),
('Голиков Павел', 'golikov.pavel@gmail.com', 'male', date('now'), 
    (SELECT id FROM occupations WHERE name = 'student')),
('Гончаров Константин', 'goncharov.konstantin@gmail.com', 'male', date('now'), 
    (SELECT id FROM occupations WHERE name = 'student'));

-- Добавление трех новых фильмов разных жанров
INSERT INTO movies (title, year)
VALUES 
('Интерстеллар', 2014),
('Криминальное чтиво', 1994),
('Властелин колец: Братство кольца', 2001);

-- Добавление жанров к фильмам
INSERT INTO movies_genres (movie_id, genre_id)
VALUES 
-- Интерстеллар: Sci-Fi, Drama, Adventure
((SELECT id FROM movies WHERE title = 'Интерстеллар'), 
 (SELECT id FROM genres WHERE name = 'Sci-Fi')),
((SELECT id FROM movies WHERE title = 'Интерстеллар'), 
 (SELECT id FROM genres WHERE name = 'Drama')),
((SELECT id FROM movies WHERE title = 'Интерстеллар'), 
 (SELECT id FROM genres WHERE name = 'Adventure')),

-- Криминальное чтиво: Crime, Thriller, Drama
((SELECT id FROM movies WHERE title = 'Криминальное чтиво'), 
 (SELECT id FROM genres WHERE name = 'Crime')),
((SELECT id FROM movies WHERE title = 'Криминальное чтиво'), 
 (SELECT id FROM genres WHERE name = 'Thriller')),
((SELECT id FROM movies WHERE title = 'Криминальное чтиво'), 
 (SELECT id FROM genres WHERE name = 'Drama')),

-- Властелин колец: Братство кольца: Adventure, Fantasy, Drama
((SELECT id FROM movies WHERE title = 'Властелин колец: Братство кольца'), 
 (SELECT id FROM genres WHERE name = 'Adventure')),
((SELECT id FROM movies WHERE title = 'Властелин колец: Братство кольца'), 
 (SELECT id FROM genres WHERE name = 'Fantasy')),
((SELECT id FROM movies WHERE title = 'Властелин колец: Братство кольца'), 
 (SELECT id FROM genres WHERE name = 'Drama'));

-- Добавление трех отзывов от Андронова Никиты
INSERT INTO ratings (user_id, movie_id, rating, timestamp)
VALUES 
((SELECT id FROM users WHERE email = 'andronov.nikita@gmail.com'), 
 (SELECT id FROM movies WHERE title = 'Интерстеллар'), 5.0, strftime('%s', 'now')),
((SELECT id FROM users WHERE email = 'andronov.nikita@gmail.com'), 
 (SELECT id FROM movies WHERE title = 'Криминальное чтиво'), 4.9, strftime('%s', 'now')),
((SELECT id FROM users WHERE email = 'andronov.nikita@gmail.com'), 
 (SELECT id FROM movies WHERE title = 'Властелин колец: Братство кольца'), 5.0, strftime('%s', 'now'));

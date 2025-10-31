#!/bin/bash
chcp 65001

sqlite3 movies_rating.db < db_init.sql

echo "1. Найти все пары пользователей, оценивших один и тот же фильм. Устранить дубликаты, исключить пары с самим собой. Для каждой пары вывести имена пользователей и название фильма. Оставить первые 100 записей."
echo --------------------------------------------------
sqlite3 movies_rating.db -box -echo "
SELECT u1.name AS user1, u2.name AS user2, m.title AS movie
FROM ratings r1
JOIN ratings r2 ON r1.movie_id = r2.movie_id AND r1.user_id < r2.user_id
JOIN users u1 ON u1.id = r1.user_id
JOIN users u2 ON u2.id = r2.user_id
JOIN movies m ON m.id = r1.movie_id
LIMIT 100;
"
echo " "

echo "2. Найти 10 самых свежих оценок от разных пользователей: название фильма, имя пользователя, оценка, дата отзыва в формате ГГГГ-ММ-ДД."
echo --------------------------------------------------
sqlite3 movies_rating.db -box -echo "
WITH latest_per_user AS (
  SELECT r.user_id, r.movie_id, r.rating, r.timestamp,
         ROW_NUMBER() OVER (PARTITION BY r.user_id ORDER BY r.timestamp DESC) AS rn
  FROM ratings r
)
SELECT m.title AS movie, u.name AS user, l.rating AS rating,
       date(datetime(l.timestamp,'unixepoch')) AS review_date
FROM latest_per_user l
JOIN users u ON u.id = l.user_id
JOIN movies m ON m.id = l.movie_id
WHERE l.rn = 1
ORDER BY l.timestamp DESC
LIMIT 10;
"
echo " "

echo "3. Вывести фильмы с максимальным и минимальным средним рейтингом в одном списке. Отсортировать общий список по году выпуска и названию. В колонке \"Рекомендуем\" указать \"Да\" для максимального рейтинга и \"Нет\" для минимального."
echo --------------------------------------------------
sqlite3 movies_rating.db -box -echo "
WITH avg_r AS (
  SELECT movie_id, AVG(rating) AS avg_rating
  FROM ratings
  GROUP BY movie_id
),
ext AS (
  SELECT MAX(avg_rating) AS max_avg, MIN(avg_rating) AS min_avg FROM avg_r
)
SELECT m.title, m.year, ROUND(a.avg_rating,3) AS avg_rating, 'Да' AS 'Рекомендуем'
FROM avg_r a, ext e
JOIN movies m ON m.id = a.movie_id
WHERE a.avg_rating = e.max_avg
UNION ALL
SELECT m.title, m.year, ROUND(a.avg_rating,3) AS avg_rating, 'Нет' AS 'Рекомендуем'
FROM avg_r a, ext e
JOIN movies m ON m.id = a.movie_id
WHERE a.avg_rating = e.min_avg
ORDER BY year, title;
"
echo " "

echo "4. Вычислить количество оценок и среднюю оценку, которые дали фильмам пользователи-женщины в период 2010-2012 гг."
echo --------------------------------------------------
sqlite3 movies_rating.db -box -echo "
SELECT COUNT(*) AS num_ratings,
       ROUND(AVG(r.rating),3) AS avg_rating
FROM ratings r
JOIN users u ON u.id = r.user_id
WHERE u.gender = 'F'
  AND date(datetime(r.timestamp,'unixepoch')) BETWEEN '2010-01-01' AND '2012-12-31';
"
echo " "

echo "5. Составить список фильмов со средней оценкой и местом в рейтинге по средней оценке. Отсортировать по году выпуска и названию. Оставить первые 20 записей."
echo --------------------------------------------------
sqlite3 movies_rating.db -box -echo "
WITH movie_avg AS (
  SELECT m.id, m.title, m.year, AVG(r.rating) AS avg_rating
  FROM movies m
  LEFT JOIN ratings r ON r.movie_id = m.id
  GROUP BY m.id, m.title, m.year
),
ranked AS (
  SELECT id, title, year, avg_rating,
         DENSE_RANK() OVER (ORDER BY avg_rating DESC) AS rank_by_avg
  FROM movie_avg
)
SELECT title, year, ROUND(avg_rating,3) AS avg_rating, rank_by_avg
FROM ranked
ORDER BY year, title
LIMIT 20;
"
echo " "

echo "6. Вывести 10 последних зарегистрированных пользователей в формате \"Фамилия Имя|Дата регистрации\"."
echo --------------------------------------------------
sqlite3 movies_rating.db -box -echo "
SELECT
  TRIM(
    CASE
      WHEN instr(name,' ') > 0
      THEN substr(name, instr(name,' ') + 1) || ' ' || substr(name, 1, instr(name,' ') - 1)
      ELSE name
    END
  ) || '|' || register_date AS 'Фамилия Имя|Дата регистрации'
FROM users
ORDER BY register_date DESC
LIMIT 10;
"
echo " "

echo "7. Рекурсивный CTE: таблица умножения для чисел 1..10 (один столбец AxB=C)."
echo --------------------------------------------------
sqlite3 movies_rating.db -box -echo "
WITH RECURSIVE a(n) AS (
  SELECT 1 UNION ALL SELECT n + 1 FROM a WHERE n < 10
),
b(n) AS (
  SELECT 1 UNION ALL SELECT n + 1 FROM b WHERE n < 10
)
SELECT printf('%dx%d=%d', a.n, b.n, a.n * b.n) AS mul
FROM a CROSS JOIN b
ORDER BY a.n, b.n;
"
echo " "

echo "8. Рекурсивный CTE: выделить все жанры фильмов из таблицы movies (каждый жанр отдельной строкой)."
echo --------------------------------------------------
sqlite3 movies_rating.db -box -echo "
WITH RECURSIVE
  split(id, rest, genre) AS (
    SELECT id, genres || '|', '' FROM movies
    UNION ALL
    SELECT id,
           substr(rest, instr(rest,'|') + 1),
           substr(rest, 1, instr(rest,'|') - 1)
    FROM split
    WHERE rest <> ''
  )
SELECT DISTINCT TRIM(genre) AS genre
FROM split
WHERE genre <> ''
ORDER BY genre;
"

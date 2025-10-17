#!/bin/bash
chcp 65001

# init database
sqlite3 movies_rating.db < db_init.sql

echo "1. Составить список фильмов, имеющих хотя бы одну оценку. Список фильмов отсортировать по году выпуска и по названиям. В списке оставить первые 10 фильмов."
echo --------------------------------------------------
sqlite3 movies_rating.db -box -echo "\
SELECT m.title, m.year\
FROM movies m\
WHERE EXISTS (SELECT 1 FROM ratings r WHERE r.movie_id = m.id)\
ORDER BY m.year, m.title\
LIMIT 10;"
echo " "

echo "2. Вывести список всех пользователей, фамилии (не имена!) которых начинаются на букву 'A'. Полученный список отсортировать по дате регистрации. В списке оставить первых 5 пользователей."
echo --------------------------------------------------
# users.name is stored as 'First Last'; take last word as surname
sqlite3 movies_rating.db -box -echo "\
SELECT name AS full_name, register_date\
FROM users\
WHERE UPPER(SUBSTR(name, INSTR(name, ' ') + 1)) LIKE 'A%'\
ORDER BY register_date\
LIMIT 5;"
echo " "

echo "3. Написать запрос, возвращающий информацию о рейтингах: имя и фамилия эксперта, название фильма, год выпуска, оценка и дата оценки в формате ГГГГ-ММ-ДД. Отсортировать по имени эксперта, затем названию фильма и оценке. В списке оставить первые 50 записей."
echo --------------------------------------------------
sqlite3 movies_rating.db -box -echo "\
SELECT u.name AS expert_name, m.title, m.year, r.rating, DATE(r.timestamp, 'unixepoch') AS rating_date\
FROM ratings r\
JOIN users u ON u.id = r.user_id\
JOIN movies m ON m.id = r.movie_id\
ORDER BY u.name, m.title, r.rating\
LIMIT 50;"
echo " "

echo "4. Вывести список фильмов с указанием тегов, присвоенных пользователями. Сортировать по году выпуска, названию фильма, тегу. В списке оставить первые 40 записей."
echo --------------------------------------------------
sqlite3 movies_rating.db -box -echo "\
SELECT m.title, m.year, t.tag\
FROM tags t\
JOIN movies m ON m.id = t.movie_id\
ORDER BY m.year, m.title, t.tag\
LIMIT 40;"
echo " "

echo "5. Вывести список самых свежих фильмов: все фильмы последнего года выпуска (год вычислять в запросе)."
echo --------------------------------------------------
sqlite3 movies_rating.db -box -echo "\
WITH max_year AS (SELECT MAX(year) AS y FROM movies)\
SELECT title, year\
FROM movies, max_year\
WHERE year = max_year.y\
ORDER BY title;"
echo " "

echo "6. Найти комедии после 2000 года, понравившиеся мужчинам (оценка ≥ 4.5). Вывести название, год и количество таких оценок. Отсортировать по году и названию."
echo --------------------------------------------------
sqlite3 movies_rating.db -box -echo "\
SELECT m.title, m.year, COUNT(*) AS num_high_male_ratings\
FROM ratings r\
JOIN users u ON u.id = r.user_id AND u.gender = 'male'\
JOIN movies m ON m.id = r.movie_id AND m.year > 2000 AND m.genres LIKE '%Comedy%'\
WHERE r.rating >= 4.5\
GROUP BY m.id, m.title, m.year\
ORDER BY m.year, m.title;"
echo " "

echo "7. Анализ профессий пользователей: количество пользователей по каждому роду занятий; показать самую распространённую и самую редкую."
echo --------------------------------------------------
# Полный список по всем профессиям
sqlite3 movies_rating.db -box -echo "\
SELECT occupation, COUNT(*) AS num_users\
FROM users\
GROUP BY occupation\
ORDER BY num_users DESC, occupation;"
echo " "
# Самая распространённая профессия
sqlite3 movies_rating.db -box -echo "\
SELECT occupation, COUNT(*) AS num_users\
FROM users\
GROUP BY occupation\
ORDER BY num_users DESC, occupation\
LIMIT 1;"
echo " "
# Самая редкая профессия
sqlite3 movies_rating.db -box -echo "\
SELECT occupation, COUNT(*) AS num_users\
FROM users\
GROUP BY occupation\
ORDER BY num_users ASC, occupation\
LIMIT 1;"

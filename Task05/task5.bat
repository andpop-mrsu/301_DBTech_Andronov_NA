#!/bin/bash
chcp 65001

sqlite3 movies_rating.db < db_init.sql

echo "1. Для каждого фильма выведите его название, год выпуска и средний рейтинг с рангом по убыванию среднего рейтинга"
echo --------------------------------------------------
sqlite3 movies_rating.db -box -echo "SELECT title, year, ROUND(AVG(rating), 2) as avg_rating, DENSE_RANK() OVER (ORDER BY AVG(rating) DESC) as rank_by_avg_rating FROM movies m LEFT JOIN ratings r ON m.id = r.movie_id GROUP BY m.id, m.title, m.year ORDER BY rank_by_avg_rating ASC LIMIT 10"
echo " "

echo "2. С помощью рекурсивного CTE выделить все жанры фильмов с расчетом среднего рейтинга и ранга жанра"
echo --------------------------------------------------
sqlite3 movies_rating.db -box -echo "WITH RECURSIVE genre_split AS (SELECT m.id, TRIM(SUBSTR(m.genres, 1, INSTR(m.genres || '|', '|') - 1)) as genre, SUBSTR(m.genres, INSTR(m.genres || '|', '|') + 1) as remaining FROM movies m UNION ALL SELECT id, TRIM(SUBSTR(remaining, 1, INSTR(remaining || '|', '|') - 1)), SUBSTR(remaining, INSTR(remaining || '|', '|') + 1) FROM genre_split WHERE remaining != '') SELECT genre, ROUND(AVG(r.rating), 2) as avg_rating, RANK() OVER (ORDER BY AVG(r.rating) DESC) as genre_rank FROM genre_split g LEFT JOIN ratings r ON g.id = r.movie_id WHERE genre != '' GROUP BY genre ORDER BY genre_rank ASC"
echo " "

echo "3. Посчитайте количество фильмов в каждом жанре"
echo --------------------------------------------------
sqlite3 movies_rating.db -box -echo "WITH RECURSIVE genre_split AS (SELECT m.id, TRIM(SUBSTR(m.genres, 1, INSTR(m.genres || '|', '|') - 1)) as genre, SUBSTR(m.genres, INSTR(m.genres || '|', '|') + 1) as remaining FROM movies m UNION ALL SELECT id, TRIM(SUBSTR(remaining, 1, INSTR(remaining || '|', '|') - 1)), SUBSTR(remaining, INSTR(remaining || '|', '|') + 1) FROM genre_split WHERE remaining != '') SELECT genre, COUNT(DISTINCT id) as movie_count FROM genre_split WHERE genre != '' GROUP BY genre ORDER BY movie_count DESC"
echo " "

echo "4. Найдите жанры, в которых чаще всего оставляют теги"
echo --------------------------------------------------
sqlite3 movies_rating.db -box -echo "WITH RECURSIVE genre_split AS (SELECT m.id, TRIM(SUBSTR(m.genres, 1, INSTR(m.genres || '|', '|') - 1)) as genre, SUBSTR(m.genres, INSTR(m.genres || '|', '|') + 1) as remaining FROM movies m UNION ALL SELECT id, TRIM(SUBSTR(remaining, 1, INSTR(remaining || '|', '|') - 1)), SUBSTR(remaining, INSTR(remaining || '|', '|') + 1) FROM genre_split WHERE remaining != ''), genre_tags AS (SELECT genre, COUNT(t.id) as tag_count FROM genre_split g LEFT JOIN tags t ON g.id = t.movie_id WHERE genre != '' GROUP BY genre) SELECT genre, tag_count, ROUND(tag_count * 100.0 / (SELECT SUM(tag_count) FROM genre_tags), 2) as tag_share FROM genre_tags ORDER BY tag_count DESC"
echo " "

echo "5. Для каждого пользователя рассчитайте общее количество оценок, средний рейтинг, дату первой и последней оценки"
echo --------------------------------------------------
sqlite3 movies_rating.db -box -echo "SELECT u.id as user_id, COUNT(r.id) as rating_count, ROUND(AVG(r.rating), 2) as avg_rating, datetime(MIN(r.timestamp), 'unixepoch') as first_rating_date, datetime(MAX(r.timestamp), 'unixepoch') as last_rating_date FROM users u LEFT JOIN ratings r ON u.id = r.user_id GROUP BY u.id ORDER BY rating_count DESC LIMIT 10"
echo " "


echo "6. Сегментируйте пользователей по типу поведения"
echo --------------------------------------------------
sqlite3 movies_rating.db -box -echo "SELECT u.id as user_id, COALESCE(rc.rating_count, 0) as rating_count, COALESCE(tc.tag_count, 0) as tag_count, CASE WHEN COALESCE(tc.tag_count, 0) > COALESCE(rc.rating_count, 0) THEN 'Комментаторы' WHEN COALESCE(rc.rating_count, 0) > COALESCE(tc.tag_count, 0) THEN 'Оценщики' WHEN COALESCE(rc.rating_count, 0) >= 10 AND COALESCE(tc.tag_count, 0) >= 10 THEN 'Активные' WHEN COALESCE(rc.rating_count, 0) < 5 AND COALESCE(tc.tag_count, 0) < 5 THEN 'Пассивные' ELSE 'Другие' END as user_type FROM users u LEFT JOIN (SELECT user_id, COUNT(*) as rating_count FROM ratings GROUP BY user_id) rc ON u.id = rc.user_id LEFT JOIN (SELECT user_id, COUNT(*) as tag_count FROM tags GROUP BY user_id) tc ON u.id = tc.user_id ORDER BY u.id"
echo " "

echo "7. Для каждого пользователя выведите его имя и последний оцененный фильм"
echo --------------------------------------------------
sqlite3 movies_rating.db -box -echo "SELECT u.id as user_id, u.name, m.title as last_rated_movie_title, datetime(r.timestamp, 'unixepoch') as last_rating_timestamp FROM users u LEFT JOIN (SELECT user_id, movie_id, timestamp, ROW_NUMBER() OVER (PARTITION BY user_id ORDER BY timestamp DESC) as rn FROM ratings) r ON u.id = r.user_id AND r.rn = 1 LEFT JOIN movies m ON r.movie_id = m.id ORDER BY u.id"
echo " "

import csv
import os
import re
from datetime import datetime


WORKDIR = os.path.dirname(os.path.abspath(__file__))
ROOTDIR = os.path.abspath(os.path.join(WORKDIR, os.pardir))
DATASET_DIR = os.path.join(ROOTDIR, "dataset")
OUTPUT_SQL = os.path.join(WORKDIR, "db_init.sql")
DB_NAME = "movies_rating.db"


def sql_quote(value: str) -> str:
    if value is None:
        return "NULL"
    return "'" + value.replace("'", "''") + "'"


def parse_movie_title(title: str):
    year_match = re.search(r"\((\d{4})\)\s*$", title)
    year = None
    if year_match:
        year = int(year_match.group(1))
        title = title[: year_match.start()].strip()
    return title, year


def infer_types_for_users():
    return {
        "id": "INTEGER PRIMARY KEY",
        "name": "TEXT",
        "email": "TEXT",
        "gender": "TEXT",
        "register_date": "TEXT",
        "occupation": "TEXT",
    }


def write_schema(out):
    out.write("PRAGMA foreign_keys = OFF;\n")
    out.write("BEGIN TRANSACTION;\n\n")
    out.write("DROP TABLE IF EXISTS movies;\n")
    out.write("DROP TABLE IF EXISTS ratings;\n")
    out.write("DROP TABLE IF EXISTS tags;\n")
    out.write("DROP TABLE IF EXISTS users;\n\n")

    out.write(
        """
CREATE TABLE movies (
    id INTEGER PRIMARY KEY,
    title TEXT,
    year INTEGER,
    genres TEXT
);
""".lstrip()
    )

    out.write(
        """
CREATE TABLE ratings (
    id INTEGER PRIMARY KEY,
    user_id INTEGER,
    movie_id INTEGER,
    rating REAL,
    timestamp INTEGER
);
""".lstrip()
    )

    out.write(
        """
CREATE TABLE tags (
    id INTEGER PRIMARY KEY,
    user_id INTEGER,
    movie_id INTEGER,
    tag TEXT,
    timestamp INTEGER
);
""".lstrip()
    )

    out.write(
        """
CREATE TABLE users (
    id INTEGER PRIMARY KEY,
    name TEXT,
    email TEXT,
    gender TEXT,
    register_date TEXT,
    occupation TEXT
);
""".lstrip()
    )


def load_movies(out):
    path = os.path.join(DATASET_DIR, "movies.csv")
    with open(path, "r", encoding="utf-8") as f:
        reader = csv.DictReader(f)
        next_id = 1
        for row in reader:
            movie_id = int(row["movieId"]) if row["movieId"] else None
            title_raw = row["title"] or ""
            title, year = parse_movie_title(title_raw)
            genres = row["genres"] or ""
            out.write(
                f"INSERT INTO movies (id, title, year, genres) VALUES ({movie_id if movie_id is not None else 'NULL'}, {sql_quote(title)}, {year if year is not None else 'NULL'}, {sql_quote(genres)});\n"
            )
            next_id += 1


def load_ratings(out):
    path = os.path.join(DATASET_DIR, "ratings.csv")
    with open(path, "r", encoding="utf-8") as f:
        reader = csv.DictReader(f)
        next_id = 1
        for row in reader:
            user_id = int(row["userId"]) if row["userId"] else None
            movie_id = int(row["movieId"]) if row["movieId"] else None
            rating = float(row["rating"]) if row["rating"] else None
            ts = int(row["timestamp"]) if row["timestamp"] else None
            out.write(
                f"INSERT INTO ratings (id, user_id, movie_id, rating, timestamp) VALUES ({next_id}, {user_id if user_id is not None else 'NULL'}, {movie_id if movie_id is not None else 'NULL'}, {rating if rating is not None else 'NULL'}, {ts if ts is not None else 'NULL'});\n"
            )
            next_id += 1


def load_tags(out):
    path = os.path.join(DATASET_DIR, "tags.csv")
    with open(path, "r", encoding="utf-8") as f:
        reader = csv.DictReader(f)
        next_id = 1
        for row in reader:
            user_id = int(row["userId"]) if row["userId"] else None
            movie_id = int(row["movieId"]) if row["movieId"] else None
            tag = row["tag"] or ""
            ts = int(row["timestamp"]) if row["timestamp"] else None
            out.write(
                f"INSERT INTO tags (id, user_id, movie_id, tag, timestamp) VALUES ({next_id}, {user_id if user_id is not None else 'NULL'}, {movie_id if movie_id is not None else 'NULL'}, {sql_quote(tag)}, {ts if ts is not None else 'NULL'});\n"
            )
            next_id += 1


def load_users(out):
    path = os.path.join(DATASET_DIR, "users.txt")
    with open(path, "r", encoding="utf-8") as f:
        next_id = 1
        for line in f:
            line = line.rstrip("\n")
            if not line:
                continue
            parts = line.split("|")
            if len(parts) != 6:
                continue
            user_id = int(parts[0]) if parts[0] else None
            name = parts[1]
            email = parts[2]
            gender = parts[3]
            register_date = parts[4]
            occupation = parts[5]
            out.write(
                f"INSERT INTO users (id, name, email, gender, register_date, occupation) VALUES ({user_id if user_id is not None else 'NULL'}, {sql_quote(name)}, {sql_quote(email)}, {sql_quote(gender)}, {sql_quote(register_date)}, {sql_quote(occupation)});\n"
            )
            next_id += 1


def finalize(out):
    out.write("\nCOMMIT;\n")


def main():
    os.makedirs(WORKDIR, exist_ok=True)
    with open(OUTPUT_SQL, "w", encoding="utf-8") as out:
        write_schema(out)
        load_movies(out)
        load_ratings(out)
        load_tags(out)
        load_users(out)
        finalize(out)
    print(f"Generated SQL at {OUTPUT_SQL}")


if __name__ == "__main__":
    main()
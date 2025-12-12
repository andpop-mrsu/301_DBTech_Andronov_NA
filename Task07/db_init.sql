-- База данных для учета успеваемости студентов ФМиИТ

-- Удаление таблиц (если существуют)
DROP TABLE IF EXISTS assessments;
DROP TABLE IF EXISTS student_groups;
DROP TABLE IF EXISTS curriculum;
DROP TABLE IF EXISTS groups;
DROP TABLE IF EXISTS students;
DROP TABLE IF EXISTS disciplines;
DROP TABLE IF EXISTS directions;

-- Таблица направлений подготовки
CREATE TABLE directions (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL UNIQUE,
    code TEXT NOT NULL UNIQUE
);

-- Таблица дисциплин
CREATE TABLE disciplines (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL UNIQUE
);

-- Таблица учебных планов (связь направления и дисциплины)
CREATE TABLE curriculum (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    direction_id INTEGER NOT NULL,
    discipline_id INTEGER NOT NULL,
    lecture_hours INTEGER NOT NULL DEFAULT 0 CHECK(lecture_hours >= 0),
    practice_hours INTEGER NOT NULL DEFAULT 0 CHECK(practice_hours >= 0),
    total_hours INTEGER NOT NULL DEFAULT 0 CHECK(total_hours >= 0),
    assessment_type TEXT NOT NULL CHECK(assessment_type IN ('зачет', 'экзамен')),
    FOREIGN KEY (direction_id) REFERENCES directions(id) ON DELETE CASCADE,
    FOREIGN KEY (discipline_id) REFERENCES disciplines(id) ON DELETE CASCADE,
    UNIQUE(direction_id, discipline_id)
);

-- Таблица групп
CREATE TABLE groups (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    direction_id INTEGER NOT NULL,
    academic_year TEXT NOT NULL,
    semester INTEGER NOT NULL CHECK(semester IN (1, 2)),
    FOREIGN KEY (direction_id) REFERENCES directions(id) ON DELETE RESTRICT,
    UNIQUE(name, academic_year, semester)
);

-- Таблица студентов
CREATE TABLE students (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    last_name TEXT NOT NULL,
    first_name TEXT NOT NULL,
    middle_name TEXT,
    birth_date DATE NOT NULL,
    gender TEXT NOT NULL CHECK(gender IN ('M', 'F'))
);

-- Таблица связи студентов и групп (с фиксацией академического года и семестра)
CREATE TABLE student_groups (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    student_id INTEGER NOT NULL,
    group_id INTEGER NOT NULL,
    academic_year TEXT NOT NULL,
    semester INTEGER NOT NULL CHECK(semester IN (1, 2)),
    FOREIGN KEY (student_id) REFERENCES students(id) ON DELETE CASCADE,
    FOREIGN KEY (group_id) REFERENCES groups(id) ON DELETE RESTRICT,
    UNIQUE(student_id, group_id, academic_year, semester)
);

-- Таблица аттестаций (оценки по экзаменам и зачетам)
CREATE TABLE assessments (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    student_id INTEGER NOT NULL,
    curriculum_id INTEGER NOT NULL,
    group_id INTEGER NOT NULL,
    academic_year TEXT NOT NULL,
    semester INTEGER NOT NULL CHECK(semester IN (1, 2)),
    assessment_type TEXT NOT NULL CHECK(assessment_type IN ('зачет', 'экзамен')),
    grade INTEGER CHECK(
        (assessment_type = 'экзамен' AND grade IN (2, 3, 4, 5)) OR
        (assessment_type = 'зачет' AND grade IN (0, 1))
    ),
    assessment_date DATE NOT NULL DEFAULT (date('now')),
    FOREIGN KEY (student_id) REFERENCES students(id) ON DELETE CASCADE,
    FOREIGN KEY (curriculum_id) REFERENCES curriculum(id) ON DELETE RESTRICT,
    FOREIGN KEY (group_id) REFERENCES groups(id) ON DELETE RESTRICT,
    UNIQUE(student_id, curriculum_id, academic_year, semester)
);

-- Индексы для ускорения запросов
CREATE INDEX idx_students_last_name ON students(last_name);
CREATE INDEX idx_assessments_student_id ON assessments(student_id);
CREATE INDEX idx_assessments_curriculum_id ON assessments(curriculum_id);
CREATE INDEX idx_assessments_group_id ON assessments(group_id);
CREATE INDEX idx_student_groups_student_id ON student_groups(student_id);
CREATE INDEX idx_student_groups_group_id ON student_groups(group_id);

-- Заполнение тестовыми данными
BEGIN TRANSACTION;

-- Направления подготовки
INSERT INTO directions (name, code) VALUES ('Фундаментальная информатика и информационные технологии', 'ФИиИТ');
INSERT INTO directions (name, code) VALUES ('Прикладная информатика', 'ПИ');
INSERT INTO directions (name, code) VALUES ('Прикладная математика и информатика', 'ПМиИ');

-- Дисциплины
INSERT INTO disciplines (name) VALUES ('Базы данных');
INSERT INTO disciplines (name) VALUES ('Программирование');
INSERT INTO disciplines (name) VALUES ('Математический анализ');
INSERT INTO disciplines (name) VALUES ('Линейная алгебра');
INSERT INTO disciplines (name) VALUES ('Дискретная математика');
INSERT INTO disciplines (name) VALUES ('Алгоритмы и структуры данных');
INSERT INTO disciplines (name) VALUES ('Операционные системы');
INSERT INTO disciplines (name) VALUES ('Веб-программирование');

-- Учебные планы для направления ФИиИТ
INSERT INTO curriculum (direction_id, discipline_id, lecture_hours, practice_hours, total_hours, assessment_type)
VALUES (1, 1, 36, 36, 72, 'экзамен');
INSERT INTO curriculum (direction_id, discipline_id, lecture_hours, practice_hours, total_hours, assessment_type)
VALUES (1, 2, 54, 54, 108, 'экзамен');
INSERT INTO curriculum (direction_id, discipline_id, lecture_hours, practice_hours, total_hours, assessment_type)
VALUES (1, 3, 72, 72, 144, 'экзамен');
INSERT INTO curriculum (direction_id, discipline_id, lecture_hours, practice_hours, total_hours, assessment_type)
VALUES (1, 4, 36, 36, 72, 'зачет');
INSERT INTO curriculum (direction_id, discipline_id, lecture_hours, practice_hours, total_hours, assessment_type)
VALUES (1, 5, 54, 36, 90, 'экзамен');
INSERT INTO curriculum (direction_id, discipline_id, lecture_hours, practice_hours, total_hours, assessment_type)
VALUES (1, 6, 36, 54, 90, 'экзамен');

-- Учебные планы для направления ПИ
INSERT INTO curriculum (direction_id, discipline_id, lecture_hours, practice_hours, total_hours, assessment_type)
VALUES (2, 2, 54, 54, 108, 'экзамен');
INSERT INTO curriculum (direction_id, discipline_id, lecture_hours, practice_hours, total_hours, assessment_type)
VALUES (2, 3, 72, 72, 144, 'экзамен');
INSERT INTO curriculum (direction_id, discipline_id, lecture_hours, practice_hours, total_hours, assessment_type)
VALUES (2, 4, 36, 36, 72, 'экзамен');
INSERT INTO curriculum (direction_id, discipline_id, lecture_hours, practice_hours, total_hours, assessment_type)
VALUES (2, 5, 54, 36, 90, 'экзамен');
INSERT INTO curriculum (direction_id, discipline_id, lecture_hours, practice_hours, total_hours, assessment_type)
VALUES (2, 7, 36, 36, 72, 'зачет');

-- Учебные планы для направления ПМиИ
INSERT INTO curriculum (direction_id, discipline_id, lecture_hours, practice_hours, total_hours, assessment_type)
VALUES (3, 1, 36, 36, 72, 'экзамен');
INSERT INTO curriculum (direction_id, discipline_id, lecture_hours, practice_hours, total_hours, assessment_type)
VALUES (3, 2, 54, 54, 108, 'экзамен');
INSERT INTO curriculum (direction_id, discipline_id, lecture_hours, practice_hours, total_hours, assessment_type)
VALUES (3, 3, 72, 72, 144, 'экзамен');
INSERT INTO curriculum (direction_id, discipline_id, lecture_hours, practice_hours, total_hours, assessment_type)
VALUES (3, 4, 36, 36, 72, 'экзамен');
INSERT INTO curriculum (direction_id, discipline_id, lecture_hours, practice_hours, total_hours, assessment_type)
VALUES (3, 5, 54, 36, 90, 'экзамен');
INSERT INTO curriculum (direction_id, discipline_id, lecture_hours, practice_hours, total_hours, assessment_type)
VALUES (3, 6, 36, 54, 90, 'экзамен');

-- Группы
-- ФИиИТ (direction_id=1): группы 301, 302
INSERT INTO groups (name, direction_id, academic_year, semester) VALUES ('301', 1, '2020/2021', 1);
INSERT INTO groups (name, direction_id, academic_year, semester) VALUES ('301', 1, '2020/2021', 2);
INSERT INTO groups (name, direction_id, academic_year, semester) VALUES ('401', 1, '2021/2022', 1);
INSERT INTO groups (name, direction_id, academic_year, semester) VALUES ('401', 1, '2021/2022', 2);
INSERT INTO groups (name, direction_id, academic_year, semester) VALUES ('302', 1, '2020/2021', 1);
INSERT INTO groups (name, direction_id, academic_year, semester) VALUES ('302', 1, '2020/2021', 2);
INSERT INTO groups (name, direction_id, academic_year, semester) VALUES ('402', 1, '2021/2022', 1);
INSERT INTO groups (name, direction_id, academic_year, semester) VALUES ('402', 1, '2021/2022', 2);
-- ПМиИ (direction_id=3): группа 303
INSERT INTO groups (name, direction_id, academic_year, semester) VALUES ('303', 3, '2020/2021', 1);
INSERT INTO groups (name, direction_id, academic_year, semester) VALUES ('303', 3, '2020/2021', 2);
INSERT INTO groups (name, direction_id, academic_year, semester) VALUES ('403', 3, '2021/2022', 1);
INSERT INTO groups (name, direction_id, academic_year, semester) VALUES ('403', 3, '2021/2022', 2);
-- ПИ (direction_id=2): группы 304, 305
INSERT INTO groups (name, direction_id, academic_year, semester) VALUES ('304', 2, '2020/2021', 1);
INSERT INTO groups (name, direction_id, academic_year, semester) VALUES ('304', 2, '2020/2021', 2);
INSERT INTO groups (name, direction_id, academic_year, semester) VALUES ('404', 2, '2021/2022', 1);
INSERT INTO groups (name, direction_id, academic_year, semester) VALUES ('404', 2, '2021/2022', 2);
INSERT INTO groups (name, direction_id, academic_year, semester) VALUES ('305', 2, '2020/2021', 1);
INSERT INTO groups (name, direction_id, academic_year, semester) VALUES ('305', 2, '2020/2021', 2);
INSERT INTO groups (name, direction_id, academic_year, semester) VALUES ('405', 2, '2021/2022', 1);
INSERT INTO groups (name, direction_id, academic_year, semester) VALUES ('405', 2, '2021/2022', 2);

-- Студенты
INSERT INTO students (last_name, first_name, middle_name, birth_date, gender) 
VALUES ('Иванов', 'Иван', 'Иванович', '2002-05-15', 'M');
INSERT INTO students (last_name, first_name, middle_name, birth_date, gender) 
VALUES ('Петрова', 'Мария', 'Сергеевна', '2002-08-22', 'F');
INSERT INTO students (last_name, first_name, middle_name, birth_date, gender) 
VALUES ('Сидоров', 'Петр', 'Александрович', '2002-03-10', 'M');
INSERT INTO students (last_name, first_name, middle_name, birth_date, gender) 
VALUES ('Козлова', 'Анна', 'Дмитриевна', '2002-11-30', 'F');
INSERT INTO students (last_name, first_name, middle_name, birth_date, gender) 
VALUES ('Морозов', 'Дмитрий', 'Викторович', '2002-01-20', 'M');
INSERT INTO students (last_name, first_name, middle_name, birth_date, gender) 
VALUES ('Волкова', 'Елена', 'Николаевна', '2002-07-05', 'F');
INSERT INTO students (last_name, first_name, middle_name, birth_date, gender) 
VALUES ('Новиков', 'Алексей', 'Петрович', '2002-09-12', 'M');
INSERT INTO students (last_name, first_name, middle_name, birth_date, gender) 
VALUES ('Смирнова', 'Ольга', 'Ивановна', '2002-04-25', 'F');

-- Связь студентов и групп
-- Студенты ФИиИТ: группа 301 (id=1,2,3,4)
INSERT INTO student_groups (student_id, group_id, academic_year, semester) 
VALUES (1, 1, '2020/2021', 1);
INSERT INTO student_groups (student_id, group_id, academic_year, semester) 
VALUES (1, 2, '2020/2021', 2);
INSERT INTO student_groups (student_id, group_id, academic_year, semester) 
VALUES (1, 3, '2021/2022', 1);
INSERT INTO student_groups (student_id, group_id, academic_year, semester) 
VALUES (1, 4, '2021/2022', 2);
INSERT INTO student_groups (student_id, group_id, academic_year, semester) 
VALUES (2, 1, '2020/2021', 1);
INSERT INTO student_groups (student_id, group_id, academic_year, semester) 
VALUES (2, 2, '2020/2021', 2);
INSERT INTO student_groups (student_id, group_id, academic_year, semester) 
VALUES (2, 3, '2021/2022', 1);
INSERT INTO student_groups (student_id, group_id, academic_year, semester) 
VALUES (2, 4, '2021/2022', 2);
-- Студенты ФИиИТ: группа 302 (id=5,6,7,8)
INSERT INTO student_groups (student_id, group_id, academic_year, semester) 
VALUES (3, 5, '2020/2021', 1);
INSERT INTO student_groups (student_id, group_id, academic_year, semester) 
VALUES (3, 6, '2020/2021', 2);
INSERT INTO student_groups (student_id, group_id, academic_year, semester) 
VALUES (4, 5, '2020/2021', 1);
INSERT INTO student_groups (student_id, group_id, academic_year, semester) 
VALUES (4, 6, '2020/2021', 2);
-- Студенты ПМиИ: группа 303 (id=9,10,11,12)
INSERT INTO student_groups (student_id, group_id, academic_year, semester) 
VALUES (7, 9, '2020/2021', 1);
INSERT INTO student_groups (student_id, group_id, academic_year, semester) 
VALUES (7, 10, '2020/2021', 2);
INSERT INTO student_groups (student_id, group_id, academic_year, semester) 
VALUES (7, 11, '2021/2022', 1);
INSERT INTO student_groups (student_id, group_id, academic_year, semester) 
VALUES (8, 9, '2020/2021', 1);
INSERT INTO student_groups (student_id, group_id, academic_year, semester) 
VALUES (8, 10, '2020/2021', 2);
-- Студенты ПИ: группа 304 (id=13,14,15,16)
INSERT INTO student_groups (student_id, group_id, academic_year, semester) 
VALUES (5, 13, '2020/2021', 1);
INSERT INTO student_groups (student_id, group_id, academic_year, semester) 
VALUES (5, 14, '2020/2021', 2);
INSERT INTO student_groups (student_id, group_id, academic_year, semester) 
VALUES (5, 15, '2021/2022', 1);
-- Студенты ПИ: группа 305 (id=17,18,19,20)
INSERT INTO student_groups (student_id, group_id, academic_year, semester) 
VALUES (6, 17, '2020/2021', 1);
INSERT INTO student_groups (student_id, group_id, academic_year, semester) 
VALUES (6, 18, '2020/2021', 2);

-- Аттестации (оценки)
-- ФИиИТ: группа 301 (студенты 1, 2)
INSERT INTO assessments (student_id, curriculum_id, group_id, academic_year, semester, assessment_type, grade, assessment_date)
VALUES (1, 1, 3, '2021/2022', 1, 'экзамен', 5, '2022-01-15');
INSERT INTO assessments (student_id, curriculum_id, group_id, academic_year, semester, assessment_type, grade, assessment_date)
VALUES (2, 1, 3, '2021/2022', 1, 'экзамен', 4, '2022-01-15');
INSERT INTO assessments (student_id, curriculum_id, group_id, academic_year, semester, assessment_type, grade, assessment_date)
VALUES (1, 4, 3, '2021/2022', 1, 'зачет', 1, '2022-01-10');
INSERT INTO assessments (student_id, curriculum_id, group_id, academic_year, semester, assessment_type, grade, assessment_date)
VALUES (2, 4, 3, '2021/2022', 1, 'зачет', 1, '2022-01-10');
INSERT INTO assessments (student_id, curriculum_id, group_id, academic_year, semester, assessment_type, grade, assessment_date)
VALUES (1, 2, 2, '2020/2021', 2, 'экзамен', 5, '2021-06-20');
INSERT INTO assessments (student_id, curriculum_id, group_id, academic_year, semester, assessment_type, grade, assessment_date)
VALUES (2, 2, 2, '2020/2021', 2, 'экзамен', 4, '2021-06-20');
INSERT INTO assessments (student_id, curriculum_id, group_id, academic_year, semester, assessment_type, grade, assessment_date)
VALUES (1, 3, 2, '2020/2021', 2, 'экзамен', 4, '2021-06-25');
INSERT INTO assessments (student_id, curriculum_id, group_id, academic_year, semester, assessment_type, grade, assessment_date)
VALUES (2, 3, 2, '2020/2021', 2, 'экзамен', 5, '2021-06-25');

-- ФИиИТ: группа 302 (студенты 3, 4)
INSERT INTO assessments (student_id, curriculum_id, group_id, academic_year, semester, assessment_type, grade, assessment_date)
VALUES (3, 1, 5, '2020/2021', 1, 'экзамен', 3, '2021-01-20');
INSERT INTO assessments (student_id, curriculum_id, group_id, academic_year, semester, assessment_type, grade, assessment_date)
VALUES (4, 1, 5, '2020/2021', 1, 'экзамен', 5, '2021-01-20');
INSERT INTO assessments (student_id, curriculum_id, group_id, academic_year, semester, assessment_type, grade, assessment_date)
VALUES (3, 4, 5, '2020/2021', 1, 'зачет', 0, '2021-01-12');
INSERT INTO assessments (student_id, curriculum_id, group_id, academic_year, semester, assessment_type, grade, assessment_date)
VALUES (4, 3, 6, '2020/2021', 2, 'экзамен', 4, '2021-06-25');

-- ПМиИ: группа 303 (студенты 7, 8)
INSERT INTO assessments (student_id, curriculum_id, group_id, academic_year, semester, assessment_type, grade, assessment_date)
VALUES (7, 12, 9, '2020/2021', 1, 'экзамен', 4, '2021-01-19');
INSERT INTO assessments (student_id, curriculum_id, group_id, academic_year, semester, assessment_type, grade, assessment_date)
VALUES (8, 12, 9, '2020/2021', 1, 'экзамен', 5, '2021-01-19');
INSERT INTO assessments (student_id, curriculum_id, group_id, academic_year, semester, assessment_type, grade, assessment_date)
VALUES (7, 13, 10, '2020/2021', 2, 'экзамен', 5, '2021-06-21');
INSERT INTO assessments (student_id, curriculum_id, group_id, academic_year, semester, assessment_type, grade, assessment_date)
VALUES (8, 15, 9, '2020/2021', 1, 'экзамен', 4, '2021-01-23');

-- ПИ: группа 304 (студент 5)
INSERT INTO assessments (student_id, curriculum_id, group_id, academic_year, semester, assessment_type, grade, assessment_date)
VALUES (5, 7, 13, '2020/2021', 1, 'экзамен', 5, '2021-01-18');
INSERT INTO assessments (student_id, curriculum_id, group_id, academic_year, semester, assessment_type, grade, assessment_date)
VALUES (5, 8, 13, '2020/2021', 1, 'экзамен', 4, '2021-01-20');
INSERT INTO assessments (student_id, curriculum_id, group_id, academic_year, semester, assessment_type, grade, assessment_date)
VALUES (5, 9, 14, '2020/2021', 2, 'экзамен', 5, '2021-06-22');

-- ПИ: группа 305 (студент 6)
INSERT INTO assessments (student_id, curriculum_id, group_id, academic_year, semester, assessment_type, grade, assessment_date)
VALUES (6, 7, 17, '2020/2021', 1, 'экзамен', 4, '2021-01-18');
INSERT INTO assessments (student_id, curriculum_id, group_id, academic_year, semester, assessment_type, grade, assessment_date)
VALUES (6, 8, 17, '2020/2021', 1, 'экзамен', 5, '2021-01-20');

COMMIT;


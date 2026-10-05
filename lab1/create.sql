CREATE TABLE transport_type (
    type_id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE,
    description TEXT
);

CREATE TABLE transport (
    transport_id SERIAL PRIMARY KEY,
    type_id INT NOT NULL REFERENCES transport_type(type_id) ON DELETE RESTRICT,
    name VARCHAR(100) UNIQUE,
    capacity INT CHECK (capacity > 0)
);

CREATE TABLE place (
    place_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    kind VARCHAR(30) NOT NULL CHECK (kind IN (
        'стол','набережная','шлюпка','борт','палуба','каюта','койка','трап'
    )),
    description TEXT,
    transport_type_id INT NOT NULL REFERENCES transport_type(type_id)
        ON DELETE RESTRICT
);

CREATE TABLE person (
    person_id SERIAL PRIMARY KEY,
    last_name VARCHAR(50) NOT NULL,
    first_name VARCHAR(50) NOT NULL,
    middle_name VARCHAR(50),
    role VARCHAR(30) NOT NULL CHECK (role IN (
        'капитан','пассажир','извозчик','помощник','гребец','прохожий'
    ))
);

CREATE TABLE worker (
    worker_id SERIAL PRIMARY KEY,
    person_id INT NOT NULL REFERENCES person(person_id) ON DELETE CASCADE,
    transport_id INT NOT NULL REFERENCES transport(transport_id) ON DELETE CASCADE,
    position VARCHAR(50) NOT NULL,
    hire_date DATE DEFAULT CURRENT_DATE,
    CONSTRAINT uq_worker UNIQUE (person_id, transport_id, position)
);

CREATE TABLE movement (
    movement_id SERIAL PRIMARY KEY,
    person_id INT NOT NULL REFERENCES person(person_id) ON DELETE CASCADE,
    worker_id INT REFERENCES worker(worker_id) ON DELETE SET NULL,
    origin_place_id INT REFERENCES place(place_id) ON DELETE SET NULL,
    destination_place_id INT REFERENCES place(place_id) ON DELETE SET NULL
);



INSERT INTO transport_type (name, description) VALUES
('экипаж', 'Конный экипаж для передвижения по городу'),
('шлюпка', 'Небольшая лодка для перевозки людей'),
('яхта', 'Крупное судно для морских прогулок'),
('пеший', 'Передвижение без транспортного средства');

INSERT INTO transport (type_id, name, capacity)
SELECT type_id, 'Извозчик', 2 FROM transport_type WHERE name = 'экипаж'
UNION ALL
SELECT type_id, 'Шлюпка', 6 FROM transport_type WHERE name = 'шлюпка'
UNION ALL
SELECT type_id, 'Яхта', 20 FROM transport_type WHERE name = 'яхта';

INSERT INTO place (name, kind, description, transport_type_id)
SELECT 'Стол в комнате', 'стол', 'Стол, с которого Янсен взял фуражку',
       type_id FROM transport_type WHERE name = 'пеший'
UNION ALL
SELECT 'Набережная', 'набережная', 'Место, куда Янсен приказал ехать',
       type_id FROM transport_type WHERE name = 'экипаж'
UNION ALL
SELECT 'Шлюпка', 'шлюпка', 'Шлюпка у набережной',
       type_id FROM transport_type WHERE name = 'шлюпка'
UNION ALL
SELECT 'Борт яхты', 'борт', 'Борт яхты, куда поднялся Янсен',
       type_id FROM transport_type WHERE name = 'шлюпка'
UNION ALL
SELECT 'Палуба яхты', 'палуба', 'Палуба, где Янсен кричал на помощника',
       type_id FROM transport_type WHERE name = 'яхта'
UNION ALL
SELECT 'Каюта Янсена', 'каюта', 'Каюта, где Янсен заперся',
       type_id FROM transport_type WHERE name = 'яхта'
UNION ALL
SELECT 'Койка в каюте', 'койка', 'Койка, на которую упал Янсен',
       type_id FROM transport_type WHERE name = 'яхта';

INSERT INTO person (last_name, first_name, middle_name, role) VALUES
('Янсен', 'Ян', 'Янович', 'капитан'),
('Извозчик', 'Пётр', 'Петрович', 'извозчик'),
('Помощник', 'Иван', 'Иванович', 'помощник'),
('Прохожий', 'Семён', 'Семёнович', 'прохожий');

INSERT INTO worker (person_id, transport_id, position, hire_date)
SELECT p.person_id, t.transport_id, 'извозчик', DATE '2025-01-01'
FROM person p, transport t
WHERE p.last_name = 'Извозчик' AND t.name = 'Извозчик';

INSERT INTO worker (person_id, transport_id, position, hire_date)
SELECT p.person_id, t.transport_id, 'помощник', DATE '2025-01-01'
FROM person p, transport t
WHERE p.last_name = 'Помощник' AND t.name = 'Яхта';

INSERT INTO movement (
    person_id, worker_id,
    origin_place_id, destination_place_id
)
SELECT p.person_id, w.worker_id, m1.place_id, m2.place_id
FROM (VALUES
    ('Стол в комнате', 'Набережная', 'извозчик'),
    ('Набережная', 'Шлюпка', 'помощник'),
    ('Шлюпка', 'Борт яхты', 'помощник'),
    ('Борт яхты', 'Палуба яхты', 'помощник'),
    ('Палуба яхты', 'Каюта Янсена', NULL),
    ('Каюта Янсена', 'Койка в каюте', NULL)
) AS v(origin, destination, worker_position)
JOIN person p ON p.last_name = 'Янсен'
LEFT JOIN worker w ON w.position = v.worker_position
JOIN place m1 ON m1.name = v.origin
JOIN place m2 ON m2.name = v.destination;
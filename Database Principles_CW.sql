/*===============   
CREATE STATEMENTS 
=================*/
-- CREATE TABLE countries
CREATE TABLE countries (
    country_id SERIAL PRIMARY KEY,
    country_name VARCHAR(50)
);

--CREATE TABLE Cities
CREATE TABLE cities (
    city_id SERIAL PRIMARY KEY,
    country_id INT NOT NULL,
    city_name VARCHAR(50) NOT NULL,
    FOREIGN KEY (country_id) REFERENCES countries (country_id)
);

-- CREATE TABLE addresses
CREATE TABLE addresses (
    address_id SERIAL PRIMARY KEY,
    city_id INT NOT NULL,
    address_first_line VARCHAR(50),
    address_second_line VARCHAR(50),
    address_postcode VARCHAR(10),
    FOREIGN KEY (city_id) REFERENCES cities (city_id)
);

-- CREATE INDEX postcode
CREATE INDEX idx_postcode ON addresses (address_postcode);

-- CREATE TABLE branches
CREATE TABLE branches (
    branch_id SERIAL PRIMARY KEY,
    city_id INT NOT NULL,
    FOREIGN KEY (city_id) REFERENCES cities (city_id),
    branch_name VARCHAR(50) NOT NULL,
    branch_capacity INT
);

--CREATE TABLE buildings
CREATE TABLE buildings (
    building_id SERIAL PRIMARY KEY,
    branch_id INT,
    FOREIGN KEY (branch_id) REFERENCES branches (branch_id),
    building_name VARCHAR(50),
    building_room_count INT
);

---CREATE ROOM_TYPE ENUM 
CREATE TYPE room_types AS ENUM(
    'COMP-LAB',
    'SCI-LAB',
    'LECTURE',
    'TOILET',
    'KITCHEN',
    'STORAGE',
    'OTHER'
);

--CREATE TABLE rooms
CREATE TABLE rooms (
    room_id SERIAL PRIMARY KEY,
    building_id INT,
    FOREIGN KEY (building_id) REFERENCES buildings (building_id),
    room_number DECIMAL(4, 2),
    room_capacity INT,
    room_type ROOM_TYPES NOT NULL
);

--CREATE TABLE facilities
CREATE TABLE facilities (
    facility_id SERIAL PRIMARY KEY,
    facility_name VARCHAR(50) NOT NULL
);

--CREATE TABLE rooms_facilities
CREATE TABLE rooms_facilities (
    room_id INT NOT NULL,
    facility_id INT NOT NULL,
    PRIMARY KEY (room_id, facility_id),
    FOREIGN KEY (room_id) REFERENCES rooms (room_id),
    FOREIGN KEY (facility_id) REFERENCES facilities (facility_id)
);

-- CREATE TABLE accomodations
CREATE TABLE accomodations (
    accomodation_id SERIAL PRIMARY KEY,
    address_id INT NOT NULL,
    FOREIGN KEY (address_id) REFERENCES addresses (address_id),
    accomodation_name VARCHAR(50)
);

-- CREATE TABLE departments
CREATE TYPE department_types AS ENUM('Academic', 'Non-academic');

CREATE TABLE departments (
    department_id SERIAL PRIMARY KEY,
    department_type DEPARTMENT_TYPES NOT NULL,
    department_name VARCHAR(50) NOT NULL
);

-- CREATE TABLE staff_members
CREATE TABLE staff_members (
    staff_id SERIAL PRIMARY KEY,
    address_id INT NOT NULL,
    branch_id INT NOT NULL,
    department_id INT NOT NULL,
    FOREIGN KEY (address_id) REFERENCES addresses (address_id),
    FOREIGN KEY (branch_id) REFERENCES branches (branch_id),
    FOREIGN KEY (department_id) REFERENCES departments (department_id),
    staff_first_name VARCHAR(50) NOT NULL,
    staff_middle_name VARCHAR(50),
    staff_surname VARCHAR(50) NOT NULL,
    staff_phone_number VARCHAR(15) NOT NULL UNIQUE,
    staff_org_email VARCHAR(50) NOT NULL UNIQUE,
    CHECK (LENGTH(staff_phone_number) > 1)
);

-- CREATE academic_level ENUM 
CREATE TYPE academic_levels AS ENUM('L4', 'L5', 'L6', 'L7');

-- CREATE TABLE courses
CREATE TABLE courses (
    course_id SERIAL PRIMARY KEY,
    department_id INT NOT NULL,
    FOREIGN KEY (department_id) REFERENCES departments (department_id),
    course_name VARCHAR(50) UNIQUE NOT NULL,
    course_description TEXT
);

CREATE INDEX idx_course_name ON courses (course_name);

-- CREATE TABLE students
CREATE TABLE students (
    student_id SERIAL PRIMARY KEY,
    course_id INT NOT NULL,
    branch_id INT NOT NULL,
    accomodation_id INT,
    tutor_id INT NOT NULL,
    course_rep BOOLEAN NOT NULL,
    address_id INT NOT NULL,
    FOREIGN KEY (course_id) REFERENCES courses (course_id),
    FOREIGN KEY (branch_id) REFERENCES branches (branch_id),
    FOREIGN KEY (accomodation_id) REFERENCES accomodations (accomodation_id),
    FOREIGN KEY (tutor_id) REFERENCES staff_members (staff_id),
    FOREIGN KEY (address_id) REFERENCES addresses (address_id),
    student_first_name VARCHAR(50) NOT NULL,
    student_middle_name VARCHAR(50),
    student_last_name VARCHAR(50) NOT NULL,
    student_org_email VARCHAR(50) NOT NULL UNIQUE,
    student_phone_number VARCHAR(15) NOT NULL UNIQUE,
    student_personal_email VARCHAR(50) NOT NULL UNIQUE,
    student_academic_level ACADEMIC_LEVELS NOT NULL,
    CHECK (LENGTH(student_phone_number) > 1)
);

-- CREATE TABLE emergency_contacts
CREATE TABLE emergency_contacts (
    emergency_contact_id SERIAL PRIMARY KEY,
    address_id INT NOT NULL,
    FOREIGN KEY (address_id) REFERENCES addresses (address_id),
    emergency_contact_first_name VARCHAR(50),
    emergency_contact_middle_name VARCHAR(50),
    emergency_contact_last_name VARCHAR(50),
    emergency_contact_phone_number VARCHAR(15) NOT NULL UNIQUE,
    emergency_contact_email VARCHAR(50) NOT NULL UNIQUE
);

-- CREATE TABLE students_emergency_contacts
CREATE TABLE students_emergency_contacts (
    emergency_contact_id INT NOT NULL,
    student_id INT NOT NULL,
    FOREIGN KEY (emergency_contact_id) REFERENCES emergency_contacts (emergency_contact_id),
    FOREIGN KEY (student_id) REFERENCES students (student_id)
);

-- CREATE TABLE special_requests
CREATE TABLE special_requests (
    special_request_id SERIAL PRIMARY KEY,
    special_request_name VARCHAR(50) NOT NULL UNIQUE
);

-- CREATE TABLE students_special_requests
CREATE TABLE students_special_requests (
    special_request_id INT NOT NULL,
    student_id INT NOT NULL,
    FOREIGN KEY (special_request_id) REFERENCES special_requests (special_request_id),
    FOREIGN KEY (student_id) REFERENCES students (student_id)
);

--  CREATE TABLE modules
CREATE TABLE modules (
    module_id SERIAL PRIMARY KEY,
    module_name VARCHAR(50) NOT NULL UNIQUE,
    module_description VARCHAR(200) NOT NULL,
    module_level ACADEMIC_LEVELS NOT NULL
);

--CREATE STAFF_MODULES 
CREATE TABLE staff_module (
    staff_id INT,
    module_id INT,
    PRIMARY KEY (staff_id, module_id),
    FOREIGN KEY (staff_id) REFERENCES staff_members (staff_id),
    FOREIGN KEY (module_id) REFERENCES modules (module_id)
);

--CREATE TABLE module_course
CREATE TABLE module_course (
    module_id INT NOT NULL,
    course_id INT NOT NULL,
    PRIMARY KEY (module_id, course_id),
    FOREIGN KEY (module_id) REFERENCES modules (module_id),
    FOREIGN KEY (course_id) REFERENCES courses (course_id)
);

CREATE TYPE assessment_types AS ENUM('COURSEWORK', 'EXAM');

CREATE TABLE assessments (
    assessment_id INT,
    module_id INT NOT NULL,
    student_id INT NOT NULL,
    PRIMARY KEY (assessment_id, module_id, student_id),
    FOREIGN KEY (module_id) REFERENCES modules (module_id),
    FOREIGN KEY (student_id) REFERENCES students (student_id),
    assessment_type ASSESSMENT_TYPES NOT NULL,
    assessment_date DATE NOT NULL,
    CHECK (assessment_date > CURRENT_DATE),
    assessment_time TIME NOT NULL,
    CHECK (assessment_time BETWEEN '09:00:00' AND '18:00:00'),
    assessment_late_date DATE NOT NULL,
    CHECK (assessment_late_date >= assessment_date),
    assessment_late_time TIME NOT NULL,
    CHECK (
        assessment_late_time BETWEEN '09:00:00' AND '18:00:00'
    ),
    assessment_mark DECIMAL(5, 2),
    assessment_weight DECIMAL(5, 2) NOT NULL,
    assessment_ontime BOOLEAN NOT NULL,
    assessment_feedback TEXT CHECK (assessment_date > CURRENT_DATE),
    CHECK (assessment_time BETWEEN '09:00:00' AND '18:00:00'),
    CHECK (assessment_mark BETWEEN 0 AND 100),
    CHECK (assessment_late_date > CURRENT_DATE),
    CHECK (
        assessment_late_time BETWEEN '09:00:00' AND '18:00:00'
    )
);

CREATE INDEX idx_assessment_mark ON assessments (assessment_mark);

CREATE TABLE events (
    event_id SERIAL PRIMARY KEY,
    course_id INT NOT NULL,
    FOREIGN KEY (course_id) REFERENCES courses (course_id),
    event_name VARCHAR(50) NOT NULL,
    event_date DATE NOT NULL,
    event_time TIME NOT NULL,
    CHECK (event_date > CURRENT_DATE),
    CHECK (event_time BETWEEN '09:00:00' AND '18:00:00')
);

-- CREATE appointment type ENUM 
CREATE TYPE appointment_types AS ENUM(
    'Academic Tutor',
    'Well-being support',
    'Career support',
    'On-line career support',
    'Placement support'
);

-- CREATE TABLE appointments
CREATE TABLE appointments (
    appointment_id SERIAL PRIMARY KEY,
    staff_id INT NOT NULL,
    student_id INT NOT NULL,
    FOREIGN KEY (staff_id) REFERENCES staff_members (staff_id),
    FOREIGN KEY (student_id) REFERENCES students (student_id),
    appointment_time TIME NOT NULL,
    appointment_date DATE NOT NULL,
    appointment_type APPOINTMENT_TYPES NOT NULL,
    CHECK (appointment_date > CURRENT_DATE),
    CHECK (
        appointment_time BETWEEN '09:00:00' AND '18:00:00'
    )
);

-- CREATE TABLE staff_roles
CREATE TABLE staff_roles (
    staff_role_id SERIAL PRIMARY KEY,
    staff_role_name VARCHAR(50) NOT NULL UNIQUE,
    staff_role_support BOOLEAN
);

-- CREATE TABLE staff_members_staff_roles
CREATE TABLE staff_members_staff_roles (
    staff_id INT NOT NULL,
    staff_role_id INT NOT NULL,
    FOREIGN KEY (staff_id) REFERENCES staff_members (staff_id),
    FOREIGN KEY (staff_role_id) REFERENCES staff_roles (staff_role_id),
    PRIMARY KEY (staff_id, staff_role_id)
);

-- CREATE TABLE teams
CREATE TABLE teams (
    team_id SERIAL PRIMARY KEY,
    team_name VARCHAR(50) NOT NULL
);

-- CREATE TABLE staff_teams
CREATE TABLE staff_teams (
    team_id INT NOT NULL,
    staff_id INT NOT NULL,
    FOREIGN KEY (team_id) REFERENCES teams (team_id),
    FOREIGN KEY (staff_id) REFERENCES staff_members (staff_id),
    PRIMARY KEY (team_id, staff_id)
);

-- CREATE TABLE session_type_names
CREATE TYPE session_type_names AS ENUM(
    'Practical',
    'Lecture',
    'On-line',
    'drop-in',
    'Tutorial'
);

-- CREATE TABLE teaching_sessions
CREATE TABLE teaching_sessions (
    session_id SERIAL PRIMARY KEY,
    module_id INT NOT NULL,
    room_id INT,
    FOREIGN KEY (module_id) REFERENCES modules (module_id),
    FOREIGN KEY (room_id) REFERENCES rooms (room_id),
    session_type_name SESSION_TYPE_NAMES NOT NULL,
    session_date DATE NOT NULL,
    session_start_time TIME NOT NULL,
    session_end_time TIME NOT NULL,
    CHECK (session_date > CURRENT_DATE),
    CHECK (
        session_start_time BETWEEN '09:00:00' AND '18:00:00'
    ),
    CHECK (
        session_end_time BETWEEN '09:00:00' AND '18:00:00'
    )
);

-- CREATE TABLE student_teaching_sessions
CREATE TABLE student_teaching_sessions (
    student_id INT NOT NULL,
    session_id INT NOT NULL,
    student_attended BOOLEAN NOT NULL,
    last_updated TIMESTAMP,
    PRIMARY KEY (student_id, session_id),
    FOREIGN KEY (student_id) REFERENCES students (student_id),
    FOREIGN KEY (session_id) REFERENCES teaching_sessions (session_id)
);

CREATE INDEX idx_student_attended ON student_teaching_sessions (student_attended);

-- Trigger before inserts 
CREATE
OR REPLACE FUNCTION UPDATE_LAST_UPDATED () RETURNS TRIGGER AS $$
BEGIN
    -- Update the last_updated column to the current timestamp
    NEW.last_updated := CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_last_updated BEFORE INSERT
OR
UPDATE ON student_teaching_sessions FOR EACH ROW
EXECUTE FUNCTION UPDATE_LAST_UPDATED ();

-- CREATE TABLE staff_teaching_sessions
CREATE TABLE staff_teaching_sessions (
    staff_id INT NOT NULL,
    session_id INT NOT NULL,
    PRIMARY KEY (staff_id, session_id),
    FOREIGN KEY (staff_id) REFERENCES staff_members (staff_id),
    FOREIGN KEY (session_id) REFERENCES teaching_sessions (session_id)
);

-- CREATE TABLE extenuating_circumstances
CREATE TABLE extenuating_circumstances (
    ec_id SERIAL PRIMARY KEY,
    student_id INT NOT NULL,
    ec_date DATE NOT NULL,
    reason TEXT NOT NULL,
    module_ids INT[],
    CONSTRAINT unique_student_date UNIQUE (student_id, ec_date),
    FOREIGN KEY (student_id) REFERENCES students (student_id)
);

-- Create a check function if module exists
CREATE
OR REPLACE FUNCTION CHECK_MODULE_IDS () RETURNS TRIGGER AS $$
DECLARE mod_id INT;
BEGIN FOREACH mod_id IN ARRAY NEW.module_ids LOOP IF NOT EXISTS (
    SELECT 1
    FROM modules
    WHERE module_id = mod_id
) THEN RAISE EXCEPTION 'Module ID % not found',
mod_id;
END IF;
END LOOP;
RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- The trigger for the function
CREATE TRIGGER trigger_check_module_ids BEFORE INSERT
OR
UPDATE ON extenuating_circumstances FOR EACH ROW
EXECUTE FUNCTION CHECK_MODULE_IDS ();

/*===============   
INSERT STATEMENTS
=================*/
-- INSERT INTO countries 
INSERT INTO
    countries (country_name)
VALUES
    ('United Kingdom'),
    ('Germany'),
    ('France'),
    ('Iceland'),
    ('Sweden'),
    ('USA'),
    ('Norway');

--INSERT INTO cities 
--CITY 25
INSERT INTO
    cities (country_id, city_name)
VALUES
    (3, 'Campbellton'),
    (5, 'Xumai'),
    (5, 'Georgīevka'),
    (1, 'Surin'),
    (5, 'Camabatela'),
    (5, 'Nizhnyaya Salda'),
    (3, 'Vitoria-Gasteiz'),
    (6, 'Tankhoy'),
    (7, 'Kibiti'),
    (6, 'Huanggang'),
    (6, 'Kertapura'),
    (7, 'Indianapolis'),
    (3, 'Troitskiy'),
    (5, 'Baiyushan'),
    (4, 'Vrbice'),
    (3, 'Hinlayagan Ilaud'),
    (7, 'Lâm Thao'),
    (7, 'Huanggang'),
    (4, 'Tembongraja'),
    (3, 'Jeju-si'),
    (2, 'Karamat'),
    (1, 'Mompach'),
    (6, 'Chantepie'),
    (1, 'Charenton-le-Pont'),
    (3, 'Sungaibengkal');

--INSERT INTO addresses 400 
INSERT INTO
    addresses (
        city_id,
        address_first_line,
        address_second_line,
        address_postcode
    )
VALUES
    (2, '6971', 'Corben', 'AAZAZZ'),
    (4, '80567', 'Weeping Birch', '00A'),
    (5, '4581', 'Homewood', NULL),
    (1, '03888', 'Monica', 'A0Z'),
    (2, '682', 'Vidon', 'ZA0AAZZ'),
    (3, '634', 'Esch', 'Z'),
    (4, '24', 'Forest Run', '9A0Z9'),
    (1, '14', 'Sutherland', 'AA9ZZA'),
    (1, '71', 'Lien', 'Z'),
    (2, '55', 'Eagle Crest', 'A0AA'),
    (5, '707', 'Randy', '099'),
    (5, '1', 'Sheridan', 'Z9AZZ'),
    (5, '78323', 'Twin Pines', 'Z0A'),
    (4, '09', 'Butterfield', '009ZZZ'),
    (1, '8245', 'Delaware', 'A0Z0'),
    (2, '0', 'Holy Cross', '9ZZ9A'),
    (5, '600', 'Russell', '0A9ZZ'),
    (1, '31', 'Roxbury', 'ZZ'),
    (2, '754', 'Spaight', 'ZAA9Z'),
    (2, '87357', 'Raven', 'ZZ0ZZA0'),
    (3, '2', 'Division', '0A00'),
    (1, '59031', 'Novick', 'AZ'),
    (1, '67', 'Memorial', '9090ZA0'),
    (5, '05921', 'Fuller', '0'),
    (5, '5', 'Hollow Ridge', 'Z90090'),
    (4, '536', 'Bunker Hill', '0A9'),
    (1, '16810', 'Elgar', 'ZA9'),
    (1, '97', 'Independence', '9900Z0'),
    (3, '99801', 'Stuart', 'A0AA00'),
    (2, '31', 'Clove', 'ZZ00A0'),
    (1, '4', 'Blue Bill Park', 'ZZ9ZA'),
    (2, '85', 'Express', 'A9AA9'),
    (3, '41101', 'Lotheville', 'A99ZZ00'),
    (2, '2281', 'Gulseth', 'A'),
    (2, '75601', 'Hudson', '99009'),
    (2, '11', 'Tomscot', 'ZAA0AA0'),
    (1, '8045', 'Shelley', '9990ZAZ'),
    (3, '228', 'Schlimgen', '9ZZA0'),
    (1, '611', 'Gulseth', 'Z'),
    (5, '783', 'Carioca', 'Z0A'),
    (1, '4', 'Menomonie', '00Z999'),
    (5, '9505', 'Messerschmidt', 'Z9ZZ9A'),
    (2, '4', 'Sunbrook', '09000A'),
    (2, '1627', '3rd', '0Z0'),
    (1, '435', 'Starling', '0AZ'),
    (2, '837', 'Northwestern', '9009AZ9'),
    (5, '7766', 'Emmet', '0Z990ZA'),
    (1, '10', 'Ruskin', '999Z99Z'),
    (4, '27756', 'Alpine', '0A0'),
    (5, '4', 'Southridge', 'ZZ99A0Z'),
    (1, '0', 'Eagle Crest', NULL),
    (5, '194', 'Holmberg', 'Z9'),
    (2, '17', 'Summerview', '0Z9A'),
    (3, '07', 'Nobel', '9Z0A0'),
    (1, '749', 'Melby', 'ZZAZ'),
    (3, '76', 'Melby', '9AZ'),
    (3, '88', 'Vera', 'A9A9Z'),
    (3, '2', 'Leroy', '90A09'),
    (3, '21637', 'Lien', NULL),
    (5, '9', 'Sunnyside', '9Z00099'),
    (2, '85586', 'Bobwhite', 'Z'),
    (3, '598', 'Cordelia', 'A90099'),
    (5, '5633', 'Canary', '99'),
    (5, '16850', 'Moland', 'A'),
    (3, '900', 'Carberry', '99Z'),
    (4, '16587', 'Monterey', 'A0Z9Z'),
    (2, '3', 'Sloan', '99ZA'),
    (4, '496', 'Nobel', 'AZ0099'),
    (3, '22067', 'Sugar', 'A00Z'),
    (1, '3922', 'Kinsman', '9'),
    (1, '99', 'Chinook', NULL),
    (3, '74896', 'Reinke', 'ZA'),
    (1, '20', 'Oak Valley', 'A9A90'),
    (5, '979', 'Lakeland', '9AZZZA0'),
    (2, '4', 'Meadow Ridge', 'AA'),
    (1, '99', 'Fuller', 'A09Z9AZ'),
    (5, '00', 'Buhler', NULL),
    (5, '7155', 'Sunbrook', '00ZZAZ'),
    (1, '28062', 'Transport', 'A09A00'),
    (3, '86985', 'Rieder', '99AAZ'),
    (2, '5', 'Westend', '0000'),
    (4, '6784', 'Oak', '9AAA90A'),
    (4, '40412', 'Chinook', '0ZAZ0A'),
    (5, '42396', 'Holmberg', 'A9A'),
    (1, '82', 'Bay', 'AZ9'),
    (2, '984', 'High Crossing', '9Z'),
    (3, '82', 'Shopko', '9ZAZ0AZ'),
    (2, '5', 'Mesta', '0A9'),
    (1, '532', 'Declaration', '99'),
    (4, '364', 'Thompson', 'AZ'),
    (5, '181', '1st', 'Z09A90A'),
    (5, '3792', 'Maple Wood', 'AAA9A9'),
    (1, '947', 'Caliangt', '9090A'),
    (5, '93669', 'Old Shore', 'Z'),
    (5, '99', 'Bobwhite', '90ZAZ'),
    (3, '8639', 'Mccormick', '09'),
    (1, '85085', 'Nova', '909'),
    (5, '83525', 'Crowley', 'ZZZAAA'),
    (4, '8389', 'Rockefeller', '99900AA'),
    (4, '6', 'Sutherland', 'Z'),
    (4, '1', 'Kropf', 'Z00AA'),
    (3, '68', 'Hazelcrest', '00ZA0'),
    (3, '3528', 'Bowman', '9090'),
    (4, '7', 'Forster', 'ZA'),
    (2, '32', 'Harper', '0A'),
    (5, '01163', 'Reinke', '99AA'),
    (4, '3', 'Veith', '9AZAZ0A'),
    (1, '4', 'Sunnyside', NULL),
    (3, '2075', 'Graceland', 'A9Z09A0'),
    (5, '69', '5th', 'AAZ'),
    (2, '911', 'Reinke', 'ZZ00A99'),
    (1, '7396', 'Dorton', '9ZZ09Z'),
    (5, '56750', 'Nelson', 'AAAZ'),
    (4, '682', 'Bluejay', '099ZAA9'),
    (2, '61', '2nd', '90Z0AZ'),
    (2, '261', 'Fulton', '0990A9'),
    (3, '95', 'Pepper Wood', 'ZZZZ'),
    (1, '1286', 'Mifflin', '9Z9Z'),
    (3, '700', 'Victoria', 'A9A'),
    (2, '7657', 'Straubel', '0A9A'),
    (1, '03', 'Susan', '9AZ'),
    (1, '4', 'Vermont', NULL),
    (3, '9847', 'Bonner', '909'),
    (3, '10264', 'Hansons', 'ZA'),
    (5, '2143', 'Sutherland', '90'),
    (1, '611', 'Melody', 'ZA9Z'),
    (3, '229', 'Graceland', NULL),
    (3, '140', 'Nancy', 'Z'),
    (5, '920', 'Redwing', '0ZA0'),
    (1, '38119', 'Hudson', '09Z0'),
    (2, '6', 'Dennis', '900A'),
    (3, '1050', 'Merchant', 'A'),
    (4, '12787', 'Drewry', 'ZZ'),
    (1, '3', 'Melody', 'AAAA0AA'),
    (3, '6', 'Fallview', '0Z00'),
    (1, '367', 'Huxley', 'Z9AZ900'),
    (3, '45', 'La Follette', 'AZ'),
    (2, '78', 'Manufacturers', '9999ZA'),
    (3, '73', 'Huxley', 'AA0Z990'),
    (5, '790', 'Hansons', 'ZA0ZAZ'),
    (3, '059', 'Mcbride', 'ZZ'),
    (1, '5548', 'Dakota', 'Z09Z99A'),
    (4, '27', 'Dwight', 'Z9ZZZ'),
    (4, '3', 'Donald', 'A'),
    (5, '0212', 'Saint Paul', 'Z'),
    (1, '4132', 'Homewood', 'A0AA90'),
    (1, '921', 'New Castle', '0AA'),
    (2, '25', 'Bunker Hill', '999A'),
    (1, '895', 'Boyd', '9AA'),
    (2, '9', 'Lakewood', 'ZZ'),
    (2, '111', 'Esker', 'A9'),
    (1, '4800', 'Hauk', NULL),
    (5, '086', 'Bluestem', 'AAA0ZA9'),
    (1, '2', 'Parkside', NULL),
    (1, '025', 'Oneill', 'Z'),
    (3, '5333', 'Jenifer', 'Z9'),
    (2, '9928', 'Redwing', '0A9AAZ'),
    (3, '71170', 'Bluestem', 'Z9Z9Z0A'),
    (2, '3', 'Carberry', NULL),
    (3, '1626', 'Hagan', '9'),
    (5, '376', 'Lerdahl', 'A09ZA09'),
    (1, '44901', 'Petterle', 'A90AA'),
    (1, '154', 'Caliangt', 'Z00Z'),
    (2, '2939', 'Magdeline', 'A'),
    (4, '82314', 'Texas', '09000A0'),
    (4, '34738', 'Roth', NULL),
    (1, '1184', 'Dovetail', 'Z'),
    (1, '7170', 'Summit', '9ZAZ0A'),
    (5, '891', 'Badeau', '0'),
    (5, '97439', 'Columbus', 'A00Z99A'),
    (5, '8', 'Upham', 'Z9A'),
    (4, '77260', 'Mendota', 'A90Z099'),
    (2, '62', 'Stuart', '9A'),
    (1, '9', 'Moland', '000A9'),
    (3, '3', 'Chive', '99AAAZ'),
    (2, '0044', 'Marcy', '00AZAA'),
    (3, '24', 'Heath', NULL),
    (3, '41', 'Havey', 'AZZ0Z'),
    (3, '2497', 'Hansons', '9Z0AAA'),
    (4, '784', 'Heffernan', NULL),
    (1, '693', 'Scofield', 'Z9A990A'),
    (2, '20501', 'Crownhardt', 'AZAZA'),
    (4, '9', 'Oakridge', '09Z00Z9'),
    (1, '0927', 'Pierstorff', 'Z009A'),
    (1, '3', 'Pine View', 'AZA0A0Z'),
    (2, '00', 'Acker', '9A0AAZ'),
    (4, '57', 'Heffernan', 'ZZ9'),
    (3, '758', 'Crownhardt', 'ZZ0'),
    (4, '70640', 'Northfield', 'AAA9'),
    (3, '79586', 'Mallory', '0A'),
    (5, '93', 'Red Cloud', 'AA'),
    (4, '63', 'Fisk', 'ZA9'),
    (5, '4', 'Del Sol', 'A9A'),
    (2, '9033', 'Declaration', 'Z09'),
    (3, '687', 'Mariners Cove', 'A'),
    (3, '439', 'Dorton', '909Z0A'),
    (4, '70', 'Columbus', 'A099A'),
    (1, '3368', 'Spaight', 'ZAZ0'),
    (4, '25', 'Cardinal', '99A9A'),
    (2, '48', 'Maryland', 'AZA9'),
    (4, '222', 'Moulton', 'A0'),
    (1, '07961', 'Stuart', '0Z0'),
    (3, '62548', 'Mccormick', 'A090'),
    (2, '81', 'Bartillon', '000'),
    (5, '90515', 'Northwestern', 'A'),
    (4, '37', 'Nova', '9A0Z9A'),
    (5, '30', 'Delaware', 'Z9Z0'),
    (3, '08485', 'Acker', NULL),
    (1, '2775', 'Carey', NULL),
    (3, '8524', 'Ridgeview', 'Z9A9'),
    (5, '8', 'Iowa', 'A909'),
    (2, '62257', 'Judy', '9ZA'),
    (2, '2', 'Sage', 'Z'),
    (2, '142', 'Eastwood', '0AZA'),
    (2, '096', 'Southridge', 'A9A9Z0Z'),
    (5, '18063', 'Northridge', 'AZ990A'),
    (3, '81588', 'Cambridge', '9'),
    (3, '2219', 'Meadow Vale', '00A09A'),
    (5, '01', 'Sundown', '0ZZAAZ'),
    (3, '059', 'Delladonna', 'Z99A0'),
    (3, '9', 'Mallory', NULL),
    (3, '64', 'Old Gate', '09AA9Z0'),
    (3, '76', 'Havey', 'Z9A'),
    (2, '29', 'Toban', 'ZAZ0'),
    (5, '87093', 'Golf Course', 'Z0AAA'),
    (2, '44847', 'Roxbury', '00'),
    (3, '89', 'Towne', 'A9'),
    (2, '15', 'Stuart', 'AA'),
    (1, '542', 'Hansons', 'AZZ0A'),
    (1, '0', 'Holy Cross', 'AA0ZA09'),
    (4, '93', 'Nobel', 'A99'),
    (1, '38', 'Banding', 'AAZ0'),
    (2, '286', 'Lawn', 'Z0Z'),
    (2, '45562', 'Fordem', '0ZZ09A9'),
    (1, '8', 'Jana', 'Z0'),
    (4, '18260', 'Buhler', '0A9'),
    (2, '1', 'Eastlawn', 'Z0A'),
    (1, '9', 'Gina', '9AZ9Z'),
    (4, '923', 'Nevada', '90AA'),
    (4, '79900', 'Loeprich', '90ZZ0Z9'),
    (4, '46418', 'Mayfield', '09A0090'),
    (5, '3', 'Karstens', '0AAZ9'),
    (4, '95277', 'Bonner', '9'),
    (4, '1233', 'Cascade', '0'),
    (4, '574', 'Pankratz', 'Z9'),
    (5, '0804', 'Forest Dale', NULL),
    (1, '75981', 'Hazelcrest', 'AA9AZ'),
    (3, '0357', 'Dapin', '0AZZ'),
    (1, '78', 'Autumn Leaf', 'Z0A90A0'),
    (1, '45', 'Hudson', NULL),
    (1, '57', 'Schiller', '0A90'),
    (1, '1845', 'Nevada', NULL),
    (3, '706', 'Leroy', 'ZA9A99'),
    (1, '650', 'Lawn', 'A9'),
    (1, '05547', 'Meadow Valley', '0009A'),
    (5, '1', 'Bultman', '09'),
    (3, '75472', 'Havey', '09'),
    (5, '7', 'Onsgard', '9AZA'),
    (4, '021', 'Birchwood', '009'),
    (3, '48560', 'Crescent Oaks', 'A9'),
    (1, '508', 'Myrtle', '0A009'),
    (4, '414', 'Eagan', 'A90ZAZZ'),
    (4, '3', 'Red Cloud', '9'),
    (4, '32073', 'Lunder', 'ZZZ9ZZ'),
    (3, '01', 'Pennsylvania', '9AAAA99'),
    (2, '13991', 'Loomis', '0A'),
    (1, '776', 'Hoffman', 'A0'),
    (4, '84965', 'Caliangt', 'Z'),
    (1, '0', 'Dovetail', '909'),
    (3, '6', 'Arizona', 'Z'),
    (1, '17310', 'Hanson', '9909'),
    (5, '390', 'Lyons', 'AZ09A9Z'),
    (4, '694', 'Summerview', '90Z'),
    (3, '920', 'Leroy', 'A'),
    (5, '12', 'Susan', 'ZZA9A9Z'),
    (1, '705', 'Clyde Gallagher', '9A0AAA'),
    (3, '6970', 'Nelson', '9Z9Z'),
    (4, '8', 'Hollow Ridge', NULL),
    (5, '19', 'Lunder', '90'),
    (1, '28521', 'Norway Maple', '0A00'),
    (3, '3125', 'Arrowood', '0Z0A'),
    (5, '51', 'Schiller', 'Z0'),
    (5, '08089', 'Division', 'ZAAZ'),
    (2, '0', 'Delaware', '9999A9Z'),
    (5, '242', 'Kensington', 'Z09Z'),
    (5, '85', 'Fordem', NULL),
    (1, '5', 'Welch', '9A99Z0'),
    (5, '06', 'Farwell', 'Z909A00'),
    (4, '982', 'Hudson', 'AZ9'),
    (3, '06547', 'School', 'ZZ9Z9'),
    (5, '1', 'Valley Edge', '0'),
    (2, '56', 'Bunting', '0'),
    (2, '25975', 'Montana', '0Z09909'),
    (5, '12', 'Graedel', '0'),
    (3, '0', 'Harbort', 'AZA'),
    (1, '85889', 'Bellgrove', 'AAA9'),
    (4, '05432', 'Barnett', '090'),
    (3, '2', 'Grasskamp', 'AA'),
    (2, '1832', 'Meadow Ridge', '9A009A9'),
    (2, '8482', 'Michigan', 'Z9'),
    (4, '76865', 'International', 'A9A'),
    (5, '1', 'Esch', 'AA'),
    (2, '57', 'Quincy', 'AA00'),
    (2, '9261', 'Utah', 'A'),
    (1, '5467', 'Monterey', '9999AAZ'),
    (1, '43004', 'Ronald Regan', '0A'),
    (4, '0', '2nd', 'AZ9A'),
    (4, '45', 'Emmet', 'A09Z0Z0'),
    (2, '703', 'Darwin', '0AZ9A'),
    (1, '64', 'Superior', '9A900A9'),
    (5, '1060', 'Summerview', '9A0A09Z'),
    (2, '0', 'Southridge', 'A0A9A'),
    (5, '45', 'Blackbird', '99Z'),
    (1, '13', 'American', NULL),
    (3, '9', 'Kedzie', '00Z'),
    (4, '8018', 'Miller', 'Z9A0'),
    (5, '333', 'Comanche', 'A'),
    (4, '1474', 'Schmedeman', '9AA9'),
    (4, '8', 'Packers', 'Z'),
    (5, '17', 'Sunbrook', 'A'),
    (3, '6', 'Northfield', '0A'),
    (5, '02705', 'Springview', '0'),
    (1, '1', 'Continental', NULL),
    (2, '4', 'Alpine', '99A'),
    (2, '3', 'Blackbird', 'A'),
    (2, '81', 'Farmco', 'Z00A'),
    (1, '24945', 'Sullivan', 'ZAA0'),
    (3, '8048', 'Spohn', 'ZZZ0Z9'),
    (1, '2347', 'Dapin', 'A099Z'),
    (5, '5', 'Drewry', 'A0A0'),
    (1, '48', 'Maple Wood', 'AAZ9AA0'),
    (3, '620', 'Anniversary', 'AAZZZ'),
    (3, '3699', 'Heath', '90ZZ00'),
    (1, '3401', 'Lighthouse Bay', '9Z9'),
    (3, '0', 'Nelson', '00AZ'),
    (2, '667', 'Ridgeview', 'AA0A090'),
    (4, '772', 'Prairie Rose', 'A009'),
    (1, '87644', 'Darwin', '0900Z'),
    (5, '3', 'Nevada', 'A9AZ0A'),
    (2, '19804', 'Vermont', 'Z'),
    (5, '7', 'Little Fleur', 'ZAA0Z9A'),
    (4, '921', 'Loeprich', 'AZ09'),
    (2, '6', 'Fulton', NULL),
    (4, '285', 'Oak Valley', 'Z'),
    (5, '517', 'Claremont', '09'),
    (1, '0', 'Bobwhite', 'A0ZZAZ'),
    (3, '92', 'Paget', '09'),
    (1, '1892', 'Hudson', 'Z999A9'),
    (1, '4', '2nd', '00Z90A0'),
    (3, '5997', '3rd', 'A0'),
    (5, '64977', 'Pepper Wood', 'A'),
    (2, '795', 'Pankratz', '90Z'),
    (2, '62', 'Roth', '9A9ZZAZ'),
    (5, '0', 'Service', 'Z'),
    (4, '27', 'Nancy', 'AA0A00'),
    (3, '01545', 'David', '9ZZZ9A'),
    (3, '4745', 'Troy', 'Z9'),
    (4, '5032', 'Del Sol', NULL),
    (3, '1', 'Elmside', 'ZZ909ZA'),
    (2, '77', 'Bonner', 'AZZ'),
    (2, '9349', 'American Ash', '0'),
    (1, '80307', 'Michigan', '0'),
    (2, '51528', 'Trailsway', '9ZZZ'),
    (4, '06536', 'Annamark', '09Z0A'),
    (1, '3', 'Prentice', 'ZZ09A'),
    (4, '98', 'Fair Oaks', '9A'),
    (3, '714', 'Ramsey', 'A00Z'),
    (2, '5', 'Sutteridge', '9999A9A'),
    (2, '9264', 'Shopko', 'ZAZ09'),
    (2, '9800', 'Dawn', '90'),
    (1, '569', 'Havey', '9AZ9'),
    (1, '61', 'Crownhardt', 'Z'),
    (3, '3685', 'Mariners Cove', 'ZZ'),
    (4, '54', 'Springview', '00'),
    (4, '0540', 'Moulton', 'A9ZA'),
    (1, '5610', 'Pennsylvania', '9'),
    (2, '194', 'Hudson', '000'),
    (3, '24', 'Sage', '9Z'),
    (1, '4', 'Brickson Park', '9Z900A'),
    (2, '0', 'Moose', 'Z'),
    (4, '3191', 'Lillian', '0'),
    (4, '2022', 'Russell', '0A0'),
    (1, '9', 'Raven', '0ZZ'),
    (4, '2434', 'Farmco', 'Z9Z9Z'),
    (1, '45080', 'Manufacturers', 'Z99ZA0'),
    (3, '73314', 'Londonderry', 'A'),
    (1, '7059', 'Vernon', 'Z0AZ0'),
    (1, '4408', 'Cordelia', 'AA0A0ZZ'),
    (4, '2446', 'Harbort', '9ZA0Z99'),
    (2, '0', 'Dovetail', 'AAZ9Z'),
    (4, '38016', 'Doe Crossing', '9'),
    (5, '8', 'Morrow', 'ZZ0A999'),
    (3, '0841', 'Becker', 'Z'),
    (4, '71', 'Dawn', '0A'),
    (4, '007', 'Bashford', '990'),
    (4, '1', 'Cardinal', NULL),
    (4, '8867', 'Victoria', 'A'),
    (2, '663', 'Corscot', NULL),
    (2, '3974', 'Lake View', 'Z0Z0AA9'),
    (5, '74', 'Glendale', '999ZAA0');

--INSERT INTO branches 
INSERT INTO
    branches (city_id, branch_name, branch_capacity)
VALUES
    (1, 'Branch 1', 1000),
    (2, 'Branch 2', 2000);

-- INSERT INTO buildings (10) 
INSERT INTO
    buildings (branch_id, building_name, building_room_count)
VALUES
    (2, 'Crest Complete Multi-Benefit', 53),
    (
        2,
        'Hand Wash Nettoyant Pour Les Mains Orange Pekoe',
        58
    ),
    (2, 'Xylocaine', 32),
    (1, 'Midodrine Hydrochloride', 42),
    (2, 'iBlanc Restora-Bright', 50),
    (
        1,
        'Animal Allergens, Dog Hair and Dander Canis spp.',
        51
    ),
    (1, 'hydroxyzine pamoate', 54),
    (2, 'Bioelements', 28),
    (
        1,
        'Covergirl Outlast Stay Fabulous 3in1 Foundation',
        62
    ),
    (2, 'Double Antibiotic', 50);

--INSERT INTO rooms  (40)
INSERT INTO
    rooms (
        building_id,
        room_number,
        room_capacity,
        room_type
    )
VALUES
    (5, 2.09, 170, 'OTHER'),
    (10, 4.82, 21, 'STORAGE'),
    (1, 1.04, 30, 'KITCHEN'),
    (5, 8.67, 90, 'KITCHEN'),
    (5, 3.29, 258, 'COMP-LAB'),
    (8, 8.83, 24, 'KITCHEN'),
    (7, 1.35, 349, 'SCI-LAB'),
    (6, 4.5, 108, 'OTHER'),
    (4, 5.93, 93, 'TOILET'),
    (4, 4.68, 185, 'OTHER'),
    (8, 1.56, 242, 'STORAGE'),
    (9, 1.19, 4, 'COMP-LAB'),
    (5, 6.99, 150, 'TOILET'),
    (6, 4.26, 125, 'SCI-LAB'),
    (5, 2.84, 135, 'SCI-LAB'),
    (9, 7.32, 96, 'OTHER'),
    (5, 1.26, 322, 'OTHER'),
    (8, 8.8, 277, 'STORAGE'),
    (2, 7.37, 100, 'TOILET'),
    (7, 5.56, 319, 'LECTURE'),
    (4, 1.99, 165, 'LECTURE'),
    (10, 8.96, 309, 'TOILET'),
    (7, 8.64, 190, 'KITCHEN'),
    (10, 3.01, 375, 'LECTURE'),
    (8, 3.87, 14, 'STORAGE'),
    (9, 4.34, 220, 'TOILET'),
    (3, 3.88, 213, 'KITCHEN'),
    (7, 6.23, 138, 'SCI-LAB'),
    (10, 2.14, 104, 'TOILET'),
    (4, 1.97, 365, 'STORAGE'),
    (4, 4.6, 189, 'OTHER'),
    (9, 1.58, 361, 'KITCHEN'),
    (9, 6.84, 33, 'KITCHEN'),
    (8, 4.65, 243, 'OTHER'),
    (7, 6.54, 225, 'KITCHEN'),
    (2, 3.09, 247, 'SCI-LAB'),
    (10, 6.75, 330, 'SCI-LAB'),
    (8, 2.32, 300, 'SCI-LAB'),
    (7, 6.29, 74, 'OTHER'),
    (9, 5.97, 218, 'KITCHEN');

---INSERT INTO facilities (10) 
INSERT INTO
    facilities (facility_name)
VALUES
    ('Projector'),
    ('Whiteboard'),
    ('Scanner'),
    ('Printer'),
    ('Computer'),
    ('Wi-Fi Access'),
    ('Sound System'),
    ('Air Conditioning'),
    ('Security Camera'),
    ('Fire Alarm');

--INSERT INTO room_facilities 
INSERT INTO
    rooms_facilities (room_id, facility_id)
VALUES
    (13, 5),
    (30, 7),
    (20, 3),
    (32, 3),
    (32, 4),
    (32, 6),
    (30, 5),
    (32, 10),
    (32, 1),
    (32, 2),
    (32, 7),
    (1, 7),
    (32, 5),
    (25, 10),
    (22, 9),
    (20, 10),
    (8, 4),
    (5, 4),
    (35, 8),
    (25, 2),
    (22, 10),
    (7, 4),
    (22, 2),
    (9, 9),
    (20, 1),
    (19, 3),
    (3, 4),
    (34, 3),
    (21, 5),
    (6, 4),
    (17, 2),
    (8, 1),
    (11, 7),
    (38, 3),
    (37, 7),
    (20, 2),
    (7, 7),
    (13, 6),
    (25, 9),
    (8, 6),
    (12, 9),
    (31, 10),
    (40, 10),
    (22, 4),
    (16, 7),
    (25, 6),
    (18, 3),
    (18, 6),
    (24, 2),
    (19, 8),
    (5, 6),
    (8, 8),
    (13, 4),
    (15, 3),
    (9, 5),
    (28, 10),
    (33, 4);

--INSERT INTO  accomodations (50) 
INSERT INTO
    accomodations (address_id, accomodation_name)
VALUES
    (140, 'velit vivamus'),
    (191, 'nisl venenatis'),
    (185, 'pharetra magna'),
    (180, 'magna'),
    (27, 'dolor'),
    (115, 'ultrices'),
    (197, 'odio'),
    (126, 'tristique'),
    (120, 'primis'),
    (130, 'nunc viverra'),
    (263, 'tempor turpis'),
    (273, 'suscipit'),
    (261, 'sapien non'),
    (172, 'justo sollicitudin'),
    (324, 'mollis'),
    (398, 'scelerisque mauris'),
    (272, 'enim'),
    (274, 'ipsum'),
    (280, 'rutrum'),
    (68, 'duis ac'),
    (320, 'tempus'),
    (31, 'vehicula'),
    (135, 'est risus'),
    (36, 'pede justo'),
    (358, 'ipsum'),
    (93, 'est'),
    (170, 'volutpat eleifend'),
    (99, 'nunc'),
    (21, 'et'),
    (313, 'non'),
    (367, 'enim lorem'),
    (326, 'tincidunt'),
    (201, 'tempus sit'),
    (324, 'amet consectetuer'),
    (24, 'ultrices libero'),
    (4, 'platea dictumst'),
    (39, 'facilisi cras'),
    (105, 'nibh quisque'),
    (80, 'adipiscing molestie'),
    (260, 'bibendum felis'),
    (181, 'tincidunt lacus'),
    (384, 'lectus'),
    (303, 'tellus nulla'),
    (109, 'mauris'),
    (248, 'ut'),
    (348, 'gravida sem'),
    (375, 'turpis'),
    (344, 'dolor sit'),
    (72, 'hac habitasse'),
    (164, 'augue');

-- INSERT INTO departments 
INSERT INTO
    departments (department_type, department_name)
VALUES
    ('Academic', 'Mathematics'),
    ('Academic', 'Computing'),
    ('Academic', 'Humanities'),
    ('Academic', 'Art'),
    ('Non-academic', 'Human Resources'),
    ('Non-academic', 'Finance');

-- INSERT INTO staff_members (30) 
INSERT INTO
    staff_members (
        address_id,
        branch_id,
        department_id,
        staff_first_name,
        staff_middle_name,
        staff_surname,
        staff_phone_number,
        staff_org_email
    )
VALUES
    --,br_1,dep_1 
    (
        90,
        1,
        1,
        'Maëlle',
        'Caesar',
        'Robley',
        '357-876-4553',
        'Maëlle@myport.ac.uk'
    ),
    (
        64,
        1,
        1,
        'Eléonore',
        'Verdie',
        'Lowis',
        '548-714-8363',
        'Eléonore@myport.ac.uk'
    ),
    (
        59,
        1,
        1,
        'Åslög',
        'Renvoys',
        'Hourahan',
        '170-571-0939',
        'Åslög@myport.ac.uk'
    ),
    (
        7,
        1,
        1,
        'Léone',
        'Di Nisco',
        'Ouver',
        '515-117-9962',
        'Léone@myport.ac.uk'
    ),
    (
        56,
        1,
        1,
        'Styrbjörn',
        'Moring',
        'Shewry',
        '412-434-6675',
        'Styrbjörn5@myport.ac.uk'
    ),
    (
        81,
        1,
        1,
        'Åsa',
        'Downer',
        'Slaney',
        '219-917-6718',
        'Åsa@myport.ac.uk'
    ),
    --dep2
    (
        13,
        1,
        2,
        'Almérinda',
        'Oakly',
        'Pantecost',
        '118-872-1550',
        'Almérinda@myport.ac.uk'
    ),
    (
        12,
        1,
        2,
        'Maëlla',
        'Boyland',
        'Cluer',
        '973-209-7588',
        'Maëlla@myport.ac.uk'
    ),
    (
        20,
        1,
        2,
        'Camélia',
        'Espine',
        'Le Hucquet',
        '802-938-1613',
        'Camélia@myport.ac.uk'
    ),
    (
        9,
        1,
        2,
        'Maïlys',
        'Gostage',
        'Beachem',
        '863-530-7610',
        'Maïlys@myport.ac.uk'
    ),
    (
        47,
        1,
        2,
        'Yú',
        'Billham',
        'Ducket',
        '856-432-6032',
        'Yú8@myport.ac.uk'
    ),
    (
        24,
        1,
        2,
        'Clémentine',
        'Vardy',
        'Perone',
        '545-131-7374',
        'Clémentine@myport.ac.uk'
    ),
    --dep3
    (
        63,
        1,
        3,
        'Cloé',
        'Thomann',
        'Crossan',
        '366-950-2143',
        'Cloé@myport.ac.uk'
    ),
    (
        85,
        1,
        3,
        'Magdalène',
        'Ricoald',
        'Sanchis',
        '235-722-5303',
        'Magdalène@myport.ac.uk'
    ),
    (
        75,
        1,
        3,
        'Aimée',
        'Shackesby',
        'Arends',
        '394-804-0043',
        'Aimée@myport.ac.uk'
    ),
    (
        80,
        1,
        3,
        'Anaëlle',
        'Patrickson',
        'Bastow',
        '412-252-8244',
        'Anaëlle@myport.ac.uk'
    ),
    (
        35,
        1,
        3,
        'Gaétane',
        'Goodhand',
        'Sisland',
        '940-760-5008',
        'Gaétane@myport.ac.uk'
    ),
    (
        51,
        1,
        3,
        'Styrbjörn',
        'Pountney',
        'Reames',
        '321-713-2667',
        'Styrbjörn@myport.ac.uk'
    ),
    --dep4
    (
        12,
        1,
        4,
        'Dà',
        'Warsap',
        'Nellies',
        '895-454-9552',
        'Dà@myport.ac.uk'
    ),
    (
        58,
        1,
        4,
        'Estève',
        'Tiuit',
        'Garbett',
        '769-927-9447',
        'Estève@myport.ac.uk'
    ),
    (
        64,
        1,
        4,
        'Andréa',
        'Tomasek',
        'Sapshed',
        '957-729-3841',
        'Andréa@myport.ac.uk'
    ),
    (
        39,
        1,
        4,
        'Edmée',
        'Linnit',
        'Tibalt',
        '744-517-8346',
        'Edmée@myport.ac.uk'
    ),
    (
        16,
        1,
        4,
        'Solène',
        'Calcraft',
        'Oughton',
        '141-955-2069',
        'Solène@myport.ac.uk'
    ),
    (
        19,
        1,
        4,
        'Cécilia',
        'Berndt',
        'Portress',
        '371-939-9366',
        'Cécilia@myport.ac.uk'
    ),
    --branch_2, dep_1
    (
        85,
        2,
        1,
        'Méghane',
        'Dabnor',
        'Pavolini',
        '711-197-3240',
        'Méghane5@myport.ac.uk'
    ),
    (
        44,
        2,
        1,
        'Eléna',
        'Cuthbert',
        'Fahey',
        '647-230-1587',
        'Eléna@myport.ac.uk'
    ),
    (
        28,
        2,
        1,
        'Théo',
        'Ramos',
        'Kinney',
        '852-349-9271',
        'Théo@myport.ac.uk'
    ),
    (
        76,
        2,
        1,
        'Zoé',
        'Kane',
        'Mulvey',
        '324-564-2816',
        'Zoé@myport.ac.uk'
    ),
    (
        37,
        2,
        1,
        'Jean-Baptiste',
        'Mercier',
        'Lebon',
        '485-194-8329',
        'Jean-Baptiste@myport.ac.uk'
    ),
    (
        49,
        2,
        1,
        'Sébastien',
        'Dufour',
        'Larue',
        '914-839-4837',
        'Sébastien@myport.ac.uk'
    ),
    --dep2
    (
        397,
        2,
        2,
        'Maëline',
        'Salomé',
        'Kinsley',
        '603-220-9721',
        'Maëline@myport.ac.uk'
    ),
    (
        338,
        2,
        2,
        'Alizée',
        'Mégane',
        'Labat',
        '260-683-8051',
        'Alizée@myport.ac.uk'
    ),
    (
        356,
        2,
        2,
        'Méthode',
        'Audréanne',
        'MacGille',
        '421-108-9264',
        'Méthode@myport.ac.uk'
    ),
    (
        308,
        2,
        2,
        'Frédérique',
        'Frédérique',
        'Oliva',
        '715-804-4888',
        'Frédérique@myport.ac.uk'
    ),
    (
        362,
        2,
        2,
        'Estée',
        'Styrbjörn',
        'Fairrie',
        '428-456-7358',
        'Estée@myport.ac.uk'
    ),
    (
        396,
        2,
        2,
        'Léane',
        'Lorène',
        'Ausiello',
        '202-248-7283',
        'Léane@myport.ac.uk'
    ),
    --dep3
    (
        335,
        2,
        3,
        'Pénélope',
        'Hélèna',
        'Uzelli',
        '978-151-2507',
        'Pénélope@myport.ac.uk'
    ),
    (
        300,
        2,
        3,
        'Liè',
        'Liè',
        'Greschke',
        '824-473-9420',
        'Liè@myport.ac.uk'
    ),
    (
        343,
        2,
        3,
        'Yénora',
        'Styrbjörn',
        'Gwinn',
        '349-546-6157',
        'Yénora@myport.ac.uk'
    ),
    (
        388,
        2,
        3,
        'Véronique',
        'Méryl',
        'Stambridge',
        '684-819-8573',
        'Véronique@myport.ac.uk'
    ),
    (
        375,
        2,
        3,
        'Mélanie',
        'Léana',
        'Birney',
        '680-385-8986',
        'Mélanie@myport.ac.uk'
    ),
    (
        384,
        2,
        3,
        'Chloé',
        'Méghane',
        'Strelitz',
        '196-664-4387',
        'Chloé@myport.ac.uk'
    ),
    --dep4
    (
        335,
        2,
        4,
        'Naéva',
        'Irène',
        'Hollow',
        '196-295-1828',
        'Naéva@myport.ac.uk'
    ),
    (
        355,
        2,
        4,
        'Miléna',
        'Eugénie',
        'Cock',
        '396-837-2713',
        'Miléna@myport.ac.uk'
    ),
    (
        358,
        2,
        4,
        'Méghane',
        'Garçon',
        'Lavens',
        '372-301-0746',
        'Méghane7@myport.ac.uk'
    ),
    (
        345,
        2,
        4,
        'Zhì',
        'Mégane',
        'Spoerl',
        '589-940-8732',
        'Zhì@myport.ac.uk'
    ),
    (
        369,
        2,
        4,
        'Yú',
        'André',
        'Filchagin',
        '190-312-7051',
        'Yú10@myport.ac.uk'
    ),
    (
        326,
        2,
        4,
        'Léana',
        'Maëline',
        'Patifield',
        '870-136-2187',
        'Léana@myport.ac.uk'
    );

-- INSERT INTO courses 
INSERT INTO
    courses (department_id, course_name, course_description)
VALUES
    (
        1,
        'Electrical Engineering',
        'But I must explain to you how all this mistaken'
    ),
    (
        1,
        'Mathematics with statistics',
        'idea of denouncing pleasure and praising'
    ),
    (
        2,
        'Software engineering',
        'At vero eos et accusamus et iusto odio dignissimos ducimus '
    ),
    (
        2,
        'Computing',
        'pain was born and I will give you a complete'
    ),
    (
        3,
        'Criminology and Criminal Justice',
        'the actual teachings of the great explorer of the'
    ),
    (
        3,
        'Social Science',
        'the actual teachings of the great explorer of the'
    ),
    (
        4,
        'Graphic Design',
        'the actual teachings of the great explorer of the'
    ),
    (
        4,
        'Art and desing',
        'the actual teachings of the great explorer of the'
    );

-- INSERT INTO students 
INSERT INTO
    students (
        course_id,
        branch_id,
        accomodation_id,
        tutor_id,
        course_rep,
        address_id,
        student_first_name,
        student_middle_name,
        student_last_name,
        student_org_email,
        student_phone_number,
        student_personal_email,
        student_academic_level
    )
VALUES
    -- course_1,branch_1
    (
        1,
        1,
        4,
        15,
        TRUE,
        32,
        'Lén',
        'Mén',
        'Pusill',
        'Lén@myport.ac.uk',
        '402-343-1418',
        'Pusill@gmail.com',
        'L4'
    ),
    (
        1,
        1,
        2,
        19,
        FALSE,
        5,
        'Östen',
        'Léandre',
        'Doxey',
        'Östen@myport.ac.uk',
        '733-820-7439',
        'Doxey@gmail.com',
        'L5'
    ),
    (
        1,
        1,
        4,
        13,
        FALSE,
        10,
        'Maëlyss',
        'Bénédicte',
        'Groves',
        'Maëlyss@myport.ac.uk',
        '175-622-8448',
        'Groves@gmail.com',
        'L6'
    ),
    (
        1,
        1,
        2,
        17,
        FALSE,
        19,
        'Gérald',
        'Magdalène',
        'Coning',
        'Gérald@myport.ac.uk',
        '830-353-8654',
        'Coning@gmail.com',
        'L7'
    ),
    (
        1,
        1,
        4,
        21,
        FALSE,
        47,
        'Cloé',
        'Renée',
        'Farfolomeev',
        'Cloé@myport.ac.uk',
        '768-910-1992',
        'Farfolomeev@gmail.com',
        'L4'
    ),
    (
        1,
        1,
        6,
        7,
        FALSE,
        70,
        'Östen',
        'Mélinda',
        'Glasheen',
        'Östen2@myport.ac.uk',
        '889-778-8158',
        'Glasheen@gmail.com',
        'L5'
    ),
    (
        1,
        1,
        5,
        9,
        FALSE,
        58,
        'Néhémie',
        'Naéva',
        'Dorber',
        'Néhémie@myport.ac.uk',
        '295-941-0653',
        'Dorber@gmail.com',
        'L6'
    ),
    (
        1,
        1,
        6,
        23,
        FALSE,
        40,
        'Anaïs',
        'Gisèle',
        'Gofforth',
        'Anaïs@myport.ac.uk',
        '713-390-4965',
        'Gofforth@gmail.com',
        'L7'
    ),
    --course_2,branch_1
    (
        2,
        1,
        2,
        8,
        FALSE,
        30,
        'Mélys',
        'Miléna',
        'Teffrey',
        'Mélysfff@myport.ac.uk',
        '366-958-4274',
        'Teffrey@gmail.com',
        'L4'
    ),
    (
        2,
        1,
        3,
        18,
        TRUE,
        5,
        'Eléa',
        'Östen',
        'Challiner',
        'Eléa@myport.ac.uk',
        '282-496-8228',
        'Challiner@gmail.com',
        'L5'
    ),
    (
        2,
        1,
        5,
        3,
        FALSE,
        90,
        'Zhì',
        'Marie-noël',
        'Kubicek',
        'Zhì@myport.ac.uk',
        '590-540-5714',
        'Kubicek@gmail.com',
        'L6'
    ),
    (
        2,
        1,
        1,
        21,
        FALSE,
        95,
        'Dà',
        'Desirée',
        'Webberley',
        'Dà@myport.ac.uk',
        '991-839-5468',
        'Webberley@gmail.com',
        'L7'
    ),
    (
        2,
        1,
        4,
        3,
        FALSE,
        20,
        'Maïly',
        'Véronique',
        'Kenwell',
        'Maïlydd@myport.ac.uk',
        '429-649-4046',
        'Kenwell@gmail.com',
        'L4'
    ),
    (
        2,
        1,
        2,
        2,
        FALSE,
        20,
        'Noëlla',
        'Maëlys',
        'Dykins',
        'Noëlla@myport.ac.uk',
        '369-779-0421',
        'Dykins@gmail.com',
        'L5'
    ),
    (
        2,
        1,
        2,
        22,
        FALSE,
        46,
        'Maëlle',
        'Véronique',
        'Coleiro',
        'Maëlle@myport.ac.uk',
        '441-537-6412',
        'Coleiro@gmail.com',
        'L6'
    ),
    (
        2,
        1,
        1,
        14,
        FALSE,
        81,
        'Mégane',
        'Maïlis',
        'Duker',
        'Mégane@myport.ac.uk',
        '491-737-0579',
        'Duker@gmail.com',
        'L7'
    ),
    --course_3,branch_1
    (
        3,
        1,
        2,
        19,
        FALSE,
        11,
        'Léa',
        'Ráo',
        'Paddison',
        'Léa@myport.ac.uk',
        '285-772-6158',
        'Paddison@gmail.com',
        'L4'
    ),
    (
        3,
        1,
        3,
        12,
        FALSE,
        49,
        'Nuó',
        'Ráo',
        'Hyndes',
        'Nuó@myport.ac.uk',
        '805-247-9846',
        'Hyndes@gmail.com',
        'L5'
    ),
    (
        3,
        1,
        4,
        18,
        FALSE,
        80,
        'Mårten',
        'Lucrèce',
        'Dumphreys',
        'Mårten@myport.ac.uk',
        '647-813-3970',
        'Dumphreys@gmail.com',
        'L6'
    ),
    (
        3,
        1,
        2,
        14,
        FALSE,
        100,
        'Océane',
        'Laurélie',
        'Napper',
        'Océane@myport.ac.uk',
        '930-985-7085',
        'Napperff@gmail.com',
        'L7'
    ),
    (
        3,
        1,
        1,
        8,
        FALSE,
        48,
        'Garçon',
        'Estée',
        'Risbridge',
        'Garçon@myport.ac.uk',
        '495-757-2688',
        'Risbridge@gmail.com',
        'L4'
    ),
    (
        3,
        1,
        5,
        18,
        TRUE,
        2,
        'Uò',
        'Gaïa',
        'Duplain',
        'Uò2@myport.ac.uk',
        '886-737-0817',
        'Duplain@gmail.com',
        'L5'
    ),
    (
        3,
        1,
        2,
        2,
        FALSE,
        9,
        'Anaïs',
        'Valérie',
        'Sharpless',
        'Anaïs5@myport.ac.uk',
        '323-453-9463',
        'Sharpless@gmail.com',
        'L6'
    ),
    (
        3,
        1,
        2,
        10,
        FALSE,
        9,
        'Aí',
        'Anaé',
        'Errichelli',
        'Aíggg@myport.ac.uk',
        '522-516-6950',
        'Errichelli@gmail.com',
        'L7'
    ),
    --course_4,branch_1
    (
        4,
        1,
        5,
        18,
        FALSE,
        49,
        'Tú',
        'Laurène',
        'Tickle',
        'Tú@myport.ac.uk',
        '520-828-2506',
        'Tickle@gmail.com',
        'L4'
    ),
    (
        4,
        1,
        3,
        18,
        FALSE,
        20,
        'Aurélie',
        'Marie-thérèse',
        'Scarre',
        'Aurélie@myport.ac.uk',
        '719-772-2199',
        'Scarre@gmail.com',
        'L5'
    ),
    (
        4,
        1,
        3,
        23,
        TRUE,
        43,
        'Eloïse',
        'Aí',
        'Beagles',
        'Eloïse2@myport.ac.uk',
        '324-475-5537',
        'Beagles@gmail.com',
        'L6'
    ),
    (
        4,
        1,
        4,
        12,
        FALSE,
        24,
        'Eugénie',
        'Publicité',
        'Labroue',
        'Eugénierre@myport.ac.uk',
        '784-446-0829',
        'Labroue@gmail.com',
        'L7'
    ),
    (
        4,
        1,
        4,
        8,
        FALSE,
        10,
        'Naëlle',
        'Håkan',
        'Tixall',
        'Naëlle@myport.ac.uk',
        '134-480-5077',
        'Tixall@gmail.com',
        'L4'
    ),
    (
        4,
        1,
        3,
        4,
        FALSE,
        2,
        'Séréna',
        'Séverine',
        'Bunton',
        'Séréna10@myport.ac.uk',
        '881-390-2676',
        'Bunton@gmail.com',
        'L5'
    ),
    (
        4,
        1,
        6,
        23,
        FALSE,
        12,
        'Aimée',
        'Vérane',
        'Ridgeway',
        'Aiméefff@myport.ac.uk',
        '265-287-9435',
        'Ridgeway@gmail.com',
        'L6'
    ),
    (
        4,
        1,
        1,
        18,
        FALSE,
        53,
        'Maëlys',
        'Håkan',
        'O''Fallone',
        'Maëlysff@myport.ac.uk',
        '460-617-8837',
        'O''Fallone@gmail.com',
        'L7'
    ),
    --COURSE_5, branch_1
    (
        5,
        1,
        4,
        24,
        FALSE,
        54,
        'Bérengère',
        'Yú',
        'Manchett',
        'BérengèreE@myport.ac.uk',
        '612-259-3392',
        'Manchett@gmail.com',
        'L4'
    ),
    (
        5,
        1,
        1,
        21,
        FALSE,
        76,
        'Marie-noël',
        'Naëlle',
        'Girardetti',
        'Marie-noël@myport.ac.uk',
        '153-411-6725',
        'Girardetti@gmail.com',
        'L5'
    ),
    (
        5,
        1,
        3,
        24,
        TRUE,
        34,
        'Cinéma',
        'Kuí',
        'Skate',
        'Cinémaggg@myport.ac.uk',
        '642-820-6867',
        'Skate@gmail.com',
        'L6'
    ),
    (
        5,
        1,
        1,
        20,
        FALSE,
        65,
        'Léonie',
        'Nélie',
        'Kliche',
        'Léonie@myport.ac.uk',
        '452-188-2797',
        'Kliche@gmail.com',
        'L7'
    ),
    (
        5,
        1,
        3,
        23,
        FALSE,
        8,
        'Håkan',
        'Adélaïde',
        'Bosquet',
        'Håkan@myport.ac.uk',
        '653-533-3787',
        'Bosquet@gmail.com',
        'L4'
    ),
    (
        5,
        1,
        5,
        22,
        FALSE,
        52,
        'Lóng',
        'Aurélie',
        'Rannie',
        'Lóng@myport.ac.uk',
        '809-727-7535',
        'Rannie@gmail.com',
        'L5'
    ),
    (
        5,
        1,
        5,
        8,
        FALSE,
        92,
        'Léonore',
        'Danièle',
        'Paybody',
        'Léonore@myport.ac.uk',
        '814-844-1508',
        'Paybody@gmail.com',
        'L6'
    ),
    (
        5,
        1,
        5,
        7,
        FALSE,
        1,
        'Clémentine',
        'Maëlys',
        'Realy',
        'Clémentine@myport.ac.uk',
        '222-206-7677',
        'Realy@gmail.com',
        'L7'
    ),
    --course_6, branch _1
    (
        6,
        1,
        5,
        9,
        FALSE,
        34,
        'Märta',
        'Nadège',
        'Assante',
        'Märtadd@myport.ac.uk',
        '555-811-4258',
        'Assante@gmail.com',
        'L4'
    ),
    (
        6,
        1,
        3,
        20,
        FALSE,
        86,
        'Cléopatre',
        'Régine',
        'Normanton',
        'Cléopatre@myport.ac.uk',
        '121-728-0477',
        'Normanton@gmail.com',
        'L5'
    ),
    (
        6,
        1,
        5,
        2,
        FALSE,
        2,
        'Séréna',
        'Géraldine',
        'Pattie',
        'Séréna@myport.ac.uk',
        '474-479-1164',
        'Pattie@gmail.com',
        'L6'
    ),
    (
        6,
        1,
        2,
        10,
        FALSE,
        37,
        'Josée',
        'Réservés',
        'Joppich',
        'Josée@myport.ac.uk',
        '713-232-5044',
        'Joppich@gmail.com',
        'L7'
    ),
    (
        6,
        1,
        5,
        12,
        TRUE,
        5,
        'Annotés',
        'Néhémie',
        'Isaq',
        'Annotés@myport.ac.uk',
        '755-560-3010',
        'Isaq@gmail.com',
        'L4'
    ),
    (
        6,
        1,
        3,
        14,
        FALSE,
        8,
        'Cécile',
        'Solène',
        'Simonard',
        'Cécile@myport.ac.uk',
        '580-434-7227',
        'Simonard@gmail.com',
        'L5'
    ),
    (
        6,
        1,
        1,
        21,
        FALSE,
        36,
        'Mélia',
        'Loïs',
        'Buller',
        'Mélia@myport.ac.uk',
        '380-768-5017',
        'Buller@gmail.com',
        'L6'
    ),
    (
        6,
        1,
        5,
        12,
        FALSE,
        75,
        'Rébecca',
        'Kù',
        'Wansbury',
        'Rébecca@myport.ac.uk',
        '161-734-2850',
        'Wansbury@gmail.com',
        'L7'
    ),
    --course_7,branch_1
    (
        7,
        1,
        1,
        8,
        FALSE,
        47,
        'Görel',
        'Publicité',
        'Foran',
        'Görel@myport.ac.uk',
        '497-457-7373',
        'Foran@gmail.com',
        'L4'
    ),
    (
        7,
        1,
        5,
        2,
        FALSE,
        46,
        'Eléa',
        'Göran',
        'Deere',
        'Eléa9@myport.ac.uk',
        '297-470-9023',
        'Deere@gmail.com',
        'L5'
    ),
    (
        7,
        1,
        6,
        4,
        FALSE,
        29,
        'Clémence',
        'Célestine',
        'Budding',
        'Clémence@myport.ac.uk',
        '298-277-7306',
        'Budding@gmail.com',
        'L6'
    ),
    (
        7,
        1,
        2,
        9,
        FALSE,
        20,
        'Alizée',
        'Märta',
        'Wiggins',
        'Alizée@myport.ac.uk',
        '987-683-9941',
        'Wiggins@gmail.com',
        'L7'
    ),
    (
        7,
        1,
        3,
        19,
        FALSE,
        31,
        'Garçon',
        'Loïca',
        'Christophers',
        'Garçon9@myport.ac.uk',
        '748-539-0345',
        'Christophers@gmail.com',
        'L4'
    ),
    (
        7,
        1,
        3,
        23,
        TRUE,
        18,
        'Marie-ève',
        'Loïs',
        'Morilla',
        'Marie-ève@myport.ac.uk',
        '264-324-1351',
        'Morilla@gmail.com',
        'L5'
    ),
    (
        7,
        1,
        2,
        24,
        FALSE,
        6,
        'Eugénie',
        'Mélanie',
        'Shapero',
        'Eugénie@myport.ac.uk',
        '170-599-6528',
        'Shapero@gmail.com',
        'L6'
    ),
    (
        7,
        1,
        2,
        5,
        FALSE,
        27,
        'Laïla',
        'Maëlla',
        'Tongue',
        'Laïla@myport.ac.uk',
        '808-191-4079',
        'Tongue@gmail.com',
        'L7'
    ),
    -- course_8,branch_1
    (
        8,
        1,
        4,
        2,
        FALSE,
        89,
        'Inès',
        'Solène',
        'Pritchett',
        'Inès@myport.ac.uk',
        '951-925-2162',
        'Pritchett@gmail.com',
        'L4'
    ),
    (
        8,
        1,
        6,
        9,
        FALSE,
        92,
        'Gwenaëlle',
        'Simplifiés',
        'Corwin',
        'Gwenaëlle@myport.ac.uk',
        '714-625-1064',
        'Corwin@gmail.com',
        'L5'
    ),
    (
        8,
        1,
        2,
        23,
        FALSE,
        88,
        'Marie-thérèse',
        'Noémie',
        'Wink',
        'Marie-thérèse@myport.ac.uk',
        '133-536-6546',
        'Wink@gmail.com',
        'L6'
    ),
    (
        8,
        1,
        6,
        20,
        FALSE,
        6,
        'Angèle',
        'Kù',
        'Rome',
        'Angèle@myport.ac.uk',
        '684-477-5353',
        'Rome@gmail.com',
        'L7'
    ),
    (
        8,
        1,
        3,
        1,
        FALSE,
        81,
        'Fèi',
        'Mélinda',
        'Etheredge',
        'Fèi@myport.ac.uk',
        '567-607-6082',
        'Etheredge@gmail.com',
        'L4'
    ),
    (
        8,
        1,
        1,
        10,
        FALSE,
        43,
        'Uò',
        'Östen',
        'Pittaway',
        'Uò@myport.ac.uk',
        '966-122-0576',
        'Pittaway@gmail.com',
        'L5'
    ),
    (
        8,
        1,
        4,
        13,
        TRUE,
        80,
        'Anaël',
        'Andrée',
        'Dymoke',
        'Anaël@myport.ac.uk',
        '325-437-2947',
        'Dymoke@gmail.com',
        'L6'
    ),
    (
        8,
        1,
        2,
        2,
        FALSE,
        76,
        'Dà',
        'Vénus',
        'Larchiere',
        'Dàf@myport.ac.uk',
        '125-678-7488',
        'Larchiere@gmail.com',
        'L7'
    ),
    --course_1,branch_2
    (
        1,
        2,
        2,
        28,
        FALSE,
        144,
        'Méryl',
        'Stévina',
        'Crossfield',
        'Méryl@myport.ac.uk',
        '354-812-8755',
        'Crossfield@gmail.com',
        'L4'
    ),
    (
        1,
        2,
        1,
        31,
        FALSE,
        149,
        'Danièle',
        'Publicité',
        'Antushev',
        'Danièle@myport.ac.uk',
        '272-132-9863',
        'Antushev@gmail.com',
        'L5'
    ),
    (
        1,
        2,
        2,
        30,
        FALSE,
        190,
        'Naéva',
        'Françoise',
        'Burnyate',
        'Naéva@myport.ac.uk',
        '247-398-0976',
        'Burnyate@gmail.com',
        'L6'
    ),
    (
        1,
        2,
        5,
        36,
        FALSE,
        185,
        'Irène',
        'Maïly',
        'Goslin',
        'Irène@myport.ac.uk',
        '525-561-3814',
        'Goslin@gmail.com',
        'L7'
    ),
    (
        1,
        2,
        4,
        26,
        TRUE,
        170,
        'Agnès',
        'Mà',
        'Bolles',
        'Agnèsee@myport.ac.uk',
        '877-167-4863',
        'Bolles@gmail.com',
        'L4'
    ),
    (
        1,
        2,
        2,
        34,
        FALSE,
        145,
        'Noémie',
        'Frédérique',
        'Inggall',
        'Noémie@myport.ac.uk',
        '964-401-4707',
        'Inggall@gmail.com',
        'L5'
    ),
    (
        1,
        2,
        2,
        47,
        FALSE,
        184,
        'Maëlle',
        'Inès',
        'Tebbut',
        'Maëllee@myport.ac.uk',
        '566-664-8200',
        'Tebbut@gmail.com',
        'L6'
    ),
    (
        1,
        2,
        4,
        32,
        FALSE,
        182,
        'Léonore',
        'Yè',
        'Connal',
        'Léonorer@myport.ac.uk',
        '141-565-1528',
        'Connal@gmail.com',
        'L7'
    ),
    --course_2.branch_2
    (
        2,
        2,
        7,
        27,
        FALSE,
        106,
        'Eloïse',
        'Eléa',
        'Corey',
        'Eloïse@myport.ac.uk',
        '270-842-4784',
        'Corey@gmail.com',
        'L4'
    ),
    (
        2,
        2,
        14,
        35,
        FALSE,
        119,
        'Bérengère',
        'Salomé',
        'Cosslett',
        'Bérengère@myport.ac.uk',
        '938-224-9810',
        'Cosslett@gmail.com',
        'L5'
    ),
    (
        2,
        2,
        40,
        34,
        TRUE,
        131,
        'Lén',
        'Kévina',
        'Pykett',
        'LénR@myport.ac.uk',
        '129-384-7083',
        'Pykett@gmail.com',
        'L6'
    ),
    (
        2,
        2,
        39,
        40,
        FALSE,
        130,
        'Adèle',
        'Lorène',
        'Olifard',
        'Adèle@myport.ac.uk',
        '361-872-4997',
        'Olifard@gmail.com',
        'L7'
    ),
    (
        2,
        2,
        22,
        37,
        FALSE,
        159,
        'Maëlla',
        'Maëline',
        'Philliphs',
        'Maëlla@myport.ac.uk',
        '936-999-8977',
        'Philliphs@gmail.com',
        'L4'
    ),
    (
        2,
        2,
        26,
        28,
        FALSE,
        191,
        'Gwenaëlle',
        'Françoise',
        'Burnell',
        'GwenaëlleE@myport.ac.uk',
        '723-619-5469',
        'Burnell@gmail.com',
        'L5'
    ),
    (
        2,
        2,
        21,
        26,
        FALSE,
        152,
        'Pò',
        'André',
        'Wackly',
        'Pò@myport.ac.uk',
        '459-931-3801',
        'Wackly@gmail.com',
        'L6'
    ),
    (
        2,
        2,
        20,
        48,
        FALSE,
        198,
        'Nadège',
        'Réjane',
        'Switsur',
        'Nadège@myport.ac.uk',
        '235-517-5096',
        'Switsur@gmail.com',
        'L7'
    ),
    --course_3/branch_2
    (
        3,
        2,
        24,
        39,
        FALSE,
        140,
        'Maïly',
        'Irène',
        'Grinvalds',
        'MaïlyR@myport.ac.uk',
        '160-111-9335',
        'Grinvalds@gmail.com',
        'L4'
    ),
    (
        3,
        2,
        23,
        30,
        FALSE,
        176,
        'Maëline',
        'Frédérique',
        'Seilmann',
        'Maëline@myport.ac.uk',
        '391-463-8415',
        'Seilmann@gmail.com',
        'L5'
    ),
    (
        3,
        2,
        22,
        40,
        FALSE,
        188,
        'Maéna',
        'Yóu',
        'Anneslie',
        'Maéna@myport.ac.uk',
        '525-631-8766',
        'Anneslie@gmail.com',
        'L6'
    ),
    (
        3,
        2,
        29,
        28,
        TRUE,
        192,
        'Loïs',
        'Léana',
        'Alcorn',
        'Loïs@myport.ac.uk',
        '586-664-5152',
        'Alcorn@gmail.com',
        'L7'
    ),
    (
        3,
        2,
        40,
        47,
        FALSE,
        119,
        'Estève',
        'Cléopatre',
        'Earl',
        'Estève@myport.ac.uk',
        '565-881-5700',
        'Earl@gmail.com',
        'L4'
    ),
    (
        3,
        2,
        23,
        30,
        FALSE,
        202,
        'Illustrée',
        'Marie-ève',
        'Skypp',
        'Illustrée@myport.ac.uk',
        '994-926-0614',
        'Skypp@gmail.com',
        'L5'
    ),
    (
        3,
        2,
        24,
        40,
        FALSE,
        135,
        'Mårten',
        'Laurène',
        'MattiCCI',
        'MårtenRR@myport.ac.uk',
        '498-597-8665',
        'MattiCCI@gmail.com',
        'L6'
    ),
    (
        3,
        2,
        21,
        43,
        FALSE,
        147,
        'Garçon',
        'Jú',
        'Wankling',
        'Garçon44@myport.ac.uk',
        '816-411-7888',
        'Wankling@gmail.com',
        'L7'
    ),
    --COURSE_4/BRANCH_2
    (
        4,
        2,
        27,
        38,
        FALSE,
        163,
        'Gérald',
        'Mårten',
        'Wortt',
        'Gérald2@myport.ac.uk',
        '749-430-4439',
        'Wortt@gmail.com',
        'L4'
    ),
    (
        4,
        2,
        29,
        32,
        FALSE,
        122,
        'Jú',
        'Andréa',
        'Jaxon',
        'Jú@myport.ac.uk',
        '661-769-7232',
        'Jaxon@gmail.com',
        'L5'
    ),
    (
        4,
        2,
        21,
        33,
        FALSE,
        132,
        'Mylène',
        'Mélia',
        'Porte',
        'Mylène@myport.ac.uk',
        '265-106-8611',
        'Porte@gmail.com',
        'L6'
    ),
    (
        4,
        2,
        28,
        34,
        FALSE,
        125,
        'Maïwenn',
        'Tán',
        'Ochterlony',
        'Maïwenn@myport.ac.uk',
        '500-764-1258',
        'Ochterlony@gmail.com',
        'L7'
    ),
    (
        4,
        2,
        28,
        36,
        TRUE,
        125,
        'Maïly',
        'Dafnée',
        'MacLachlan',
        'Maïlyww@myport.ac.uk',
        '777-711-7319',
        'MacLachlan@gmail.com',
        'L4'
    ),
    (
        4,
        2,
        27,
        32,
        FALSE,
        183,
        'Styrbjörn',
        'Hélène',
        'Silcock',
        'Styrbjörn@myport.ac.uk',
        '253-456-8467',
        'Silcock@gmail.com',
        'L5'
    ),
    (
        4,
        2,
        26,
        42,
        FALSE,
        198,
        'Laurélie',
        'Clélia',
        'Pilley',
        'Laurélie@myport.ac.uk',
        '741-984-4308',
        'Pilley@gmail.com',
        'L6'
    ),
    (
        4,
        2,
        21,
        46,
        FALSE,
        198,
        'Maïly',
        'Mélissandre',
        'Sowersby',
        'Maïly@myport.ac.uk',
        '612-462-5465',
        'Sowersby@gmail.com',
        'L7'
    ),
    --COURSE_5/BRANCH _2
    (
        5,
        2,
        3,
        44,
        FALSE,
        133,
        'Stéphanie',
        'Estée',
        'Napper',
        'Stéphanie@myport.ac.uk',
        '338-794-4180',
        'Napper@gmail.com',
        'L4'
    ),
    (
        5,
        2,
        22,
        48,
        FALSE,
        173,
        'Marie-josée',
        'Tán',
        'Edridge',
        'Marie-josée@myport.ac.uk',
        '669-468-0605',
        'Edridge@gmail.com',
        'L5'
    ),
    (
        5,
        2,
        2,
        44,
        FALSE,
        123,
        'Pénélope',
        'Cinéma',
        'Ugo',
        'Pénélope@myport.ac.uk',
        '525-801-8760',
        'Ugo@gmail.com',
        'L6'
    ),
    (
        5,
        2,
        9,
        45,
        FALSE,
        111,
        'Gösta',
        'Clélia',
        'Faithfull',
        'Gösta@myport.ac.uk',
        '303-473-9806',
        'Faithfull@gmail.com',
        'L7'
    ),
    (
        5,
        2,
        4,
        31,
        FALSE,
        189,
        'Märta',
        'André',
        'Hebburn',
        'Märta@myport.ac.uk',
        '588-584-5631',
        'Hebburn@gmail.com',
        'L4'
    ),
    (
        5,
        2,
        7,
        31,
        TRUE,
        112,
        'Aí',
        'Maëlle',
        'Eykelhof',
        'Aí@myport.ac.uk',
        '647-960-6754',
        'Eykelhof@gmail.com',
        'L5'
    ),
    (
        5,
        2,
        3,
        44,
        FALSE,
        115,
        'Intéressant',
        'Styrbjörn',
        'Legrave',
        'Intéressant@myport.ac.uk',
        '358-781-5684',
        'Legrave@gmail.com',
        'L6'
    ),
    (
        5,
        2,
        3,
        32,
        FALSE,
        174,
        'Cinéma',
        'Annotés',
        'Webburn',
        'Cinéma@myport.ac.uk',
        '906-171-5850',
        'Webburn@gmail.com',
        'L7'
    ),
    --course_6/branch2
    (
        6,
        2,
        25,
        36,
        FALSE,
        151,
        'Wá',
        'Hélène',
        'Fullylove',
        'Wáffff@myport.ac.uk',
        '474-776-4425',
        'Fullylove@gmail.com',
        'L4'
    ),
    (
        6,
        2,
        25,
        44,
        FALSE,
        185,
        'Camélia',
        'Miléna',
        'Orritt',
        'Camélia@myport.ac.uk',
        '990-172-8679',
        'Orritt@gmail.com',
        'L5'
    ),
    (
        6,
        2,
        33,
        32,
        FALSE,
        112,
        'Méghane',
        'Marie-françoise',
        'Chasmar',
        'Méghane@myport.ac.uk',
        '779-961-9247',
        'Chasmar@gmail.com',
        'L6'
    ),
    (
        6,
        2,
        31,
        45,
        TRUE,
        196,
        'Mélys',
        'Clémentine',
        'McArte',
        'Mélys@myport.ac.uk',
        '249-897-0075',
        'McArte@gmail.com',
        'L7'
    ),
    (
        6,
        2,
        26,
        40,
        FALSE,
        137,
        'Léandre',
        'Estée',
        'Dufaur',
        'Léandre@myport.ac.uk',
        '519-859-7360',
        'Dufaur@gmail.com',
        'L4'
    ),
    (
        6,
        2,
        30,
        36,
        FALSE,
        159,
        'Geneviève',
        'Cléa',
        'Scherer',
        'Geneviève@myport.ac.uk',
        '979-123-8699',
        'Scherer@gmail.com',
        'L5'
    ),
    (
        6,
        2,
        18,
        41,
        FALSE,
        157,
        'Cunégonde',
        'Eléa',
        'Hewlings',
        'Cunégonde@myport.ac.uk',
        '704-857-1580',
        'Hewlings@gmail.com',
        'L6'
    ),
    (
        6,
        2,
        46,
        41,
        FALSE,
        107,
        'Valérie',
        'Marie-hélène',
        'Lowndes',
        'Valérie@myport.ac.uk',
        '632-929-8733',
        'Lowndes@gmail.com',
        'L7'
    ),
    ---COURSE_7/BRANCH2
    (
        7,
        2,
        44,
        41,
        FALSE,
        146,
        'Maëlys',
        'Crééz',
        'Pettingall',
        'Maëlys@myport.ac.uk',
        '210-193-7446',
        'Pettingall@gmail.com',
        'L4'
    ),
    (
        7,
        2,
        14,
        37,
        FALSE,
        133,
        'Loïca',
        'Néhémie',
        'Capp',
        'Loïca@myport.ac.uk',
        '390-706-9666',
        'Capp@gmail.com',
        'L5'
    ),
    (
        7,
        2,
        11,
        40,
        FALSE,
        136,
        'Aimée',
        'Dafnée',
        'Scotson',
        'Aimée@myport.ac.uk',
        '444-369-4091',
        'Scotson@gmail.com',
        'L6'
    ),
    (
        7,
        2,
        11,
        25,
        TRUE,
        164,
        'Lén',
        'Mégane',
        'MattiCCI',
        'LénFFF@myport.ac.uk',
        '829-261-8605',
        'MattiCCI44@gmail.com',
        'L7'
    ),
    (
        7,
        2,
        48,
        36,
        FALSE,
        157,
        'Wá',
        'Åke',
        'Embury',
        'Wá@myport.ac.uk',
        '212-197-9066',
        'Embury@gmail.com',
        'L4'
    ),
    (
        7,
        2,
        09,
        40,
        FALSE,
        131,
        'Yáo',
        'Eléa',
        'Owtram',
        'Yáo@myport.ac.uk',
        '698-509-1347',
        'Owtram@gmail.com',
        'L5'
    ),
    (
        7,
        2,
        20,
        28,
        FALSE,
        197,
        'Léonie',
        'Néhémie',
        'Nealey',
        'LéonieDDD@myport.ac.uk',
        '558-276-0594',
        'Nealey@gmail.com',
        'L6'
    ),
    (
        7,
        2,
        10,
        45,
        FALSE,
        131,
        'Agnès',
        'Camélia',
        'Chiese',
        'Agnès@myport.ac.uk',
        '377-870-5264',
        'Chiese@gmail.com',
        'L7'
    ),
    -- COURSE_8/BRANCH2
    (
        8,
        2,
        17,
        34,
        FALSE,
        131,
        'Andréanne',
        'Yóu',
        'Paur',
        'Andréanne@myport.ac.uk',
        '651-978-0259',
        'Paur@gmail.com',
        'L4'
    ),
    (
        8,
        2,
        27,
        37,
        FALSE,
        197,
        'Maïwenn',
        'Naëlle',
        'Zoppo',
        'MaïwennFG@myport.ac.uk',
        '471-213-4306',
        'Zoppo@gmail.com',
        'L5'
    ),
    (
        8,
        2,
        46,
        41,
        FALSE,
        113,
        'Danièle',
        'Cloé',
        'Oloshkin',
        'DanièleDDD@myport.ac.uk',
        '641-906-9113',
        'Oloshkin@gmail.com',
        'L6'
    ),
    (
        8,
        2,
        45,
        40,
        TRUE,
        190,
        'Zoé',
        'Adèle',
        'Haywood',
        'Zoé@myport.ac.uk',
        '961-873-1693',
        'Haywood@gmail.com',
        'L7'
    ),
    (
        8,
        2,
        08,
        33,
        FALSE,
        139,
        'Joséphine',
        'Gaétane',
        'Cassells',
        'Joséphine@myport.ac.uk',
        '406-512-8632',
        'Cassells@gmail.com',
        'L4'
    ),
    (
        8,
        2,
        16,
        40,
        FALSE,
        148,
        'Håkan',
        'Bérengère',
        'Taffrey',
        'HåkanFF@myport.ac.uk',
        '536-920-2101',
        'Taffrey@gmail.com',
        'L5'
    ),
    (
        8,
        2,
        39,
        48,
        FALSE,
        188,
        'Torbjörn',
        'Mén',
        'Hussy',
        'Torbjörn@myport.ac.uk',
        '247-321-2972',
        'Hussy@gmail.com',
        'L6'
    ),
    (
        8,
        2,
        9,
        39,
        FALSE,
        200,
        'Méghane',
        'Célestine',
        'Andre',
        'MéghaneFF@myport.ac.uk',
        '842-243-8553',
        'Andre@gmail.com',
        'L7'
    );

-- INSERT INTO emergency_contacts  (260)
INSERT INTO
    emergency_contacts (
        address_id,
        emergency_contact_first_name,
        emergency_contact_middle_name,
        emergency_contact_last_name,
        emergency_contact_email,
        emergency_contact_phone_number
    )
VALUES
    (
        1,
        'Wade',
        'Jerratsch',
        'Brownfield',
        'wbrownfield0@netscape.com',
        '7571270998'
    ),
    (
        2,
        'Danie',
        'Sleit',
        'Boog',
        'dboog1@prweb.com',
        '7961299195'
    ),
    (
        3,
        'Charmian',
        'Mead',
        'Cluff',
        'ccluff2@uol.com.br',
        '2676857471'
    ),
    (
        4,
        'Raff',
        'Marryatt',
        'Growcock',
        'rgrowcock3@deviantart.com',
        '3487038016'
    ),
    (
        5,
        'Breanne',
        'Dearl',
        'Geill',
        'bgeill4@apple.com',
        '7446883530'
    ),
    (
        6,
        'Torry',
        'Bohea',
        'O'' Culligan',
        'toculligan5@bandcamp.com',
        '2476395531'
    ),
    (
        7,
        'Ruddy',
        'Waulker',
        'Yurtsev',
        'ryurtsev6@fema.gov',
        '7636841038'
    ),
    (
        8,
        'Delbert',
        'Goose',
        'Lotze',
        'dlotze7@zimbio.com',
        '9804795102'
    ),
    (
        9,
        'Berenice',
        'Jockle',
        'Clardge',
        'bclardge8@indiegogo.com',
        '3112643080'
    ),
    (
        10,
        'Ferne',
        'Dewicke',
        'Cocking',
        'fcocking9@latimes.com',
        '4788484913'
    ),
    (
        11,
        'Clark',
        'Jenk',
        'Ousley',
        'cousleya@creativecommons.org',
        '8581973026'
    ),
    (
        12,
        'Dulcinea',
        'Cryer',
        'O'' Scallan',
        'doscallanb@icio.us',
        '9562128882'
    ),
    (
        13,
        'Lawrence',
        'Cunnington',
        'Lexa',
        'llexac@google.pl',
        '9833566862'
    ),
    (
        14,
        'Neille',
        'Wagon',
        'Paradine',
        'nparadined@naver.com',
        '2889484189'
    ),
    (
        15,
        'Christian',
        'Traill',
        'Durning',
        'cdurninge@merriam-webster.com',
        '5217911892'
    ),
    (
        16,
        'Emylee',
        'Skews',
        'Kastel',
        'ekastelf@google.es',
        '3921134669'
    ),
    (
        17,
        'Florette',
        'Kopf',
        'Bradden',
        'fbraddeng@163.com',
        '7972974810'
    ),
    (
        18,
        'Irwin',
        'Carlisi',
        'Wooddisse',
        'iwooddisseh@irs.gov',
        '6273291031'
    ),
    (
        19,
        'Drew',
        'Holmyard',
        'Aslie',
        'dasliei@opera.com',
        '4858883876'
    ),
    (
        20,
        'Lotte',
        'Fucher',
        'Ellsom',
        'lellsomj@un.org',
        '2964571818'
    ),
    (
        21,
        'Gannon',
        'Bricklebank',
        'O'' Hanvey',
        'gohanveyk@ebay.com',
        '4277622221'
    ),
    (
        22,
        'Chrysler',
        'Titterrell',
        'Stannion',
        'cstannionl@comcast.net',
        '3724584250'
    ),
    (
        23,
        'Yorgos',
        'Ladson',
        'Rentoll',
        'yrentollm@seesaa.net',
        '5714810265'
    ),
    (
        24,
        'Kev',
        'Founds',
        'Blasio',
        'kblasion@godaddy.com',
        '7195670209'
    ),
    (
        25,
        'Annamarie',
        'Solan',
        'Whitehead',
        'awhiteheado@foxnews.com',
        '8311638498'
    ),
    (
        26,
        'Jaclin',
        'Senussi',
        'Vasile',
        'jvasilep@technorati.com',
        '4101881362'
    ),
    (
        27,
        'Laney',
        'MacAlester',
        'Davidge',
        'ldavidgeq@last.fm',
        '6693503343'
    ),
    (
        28,
        'Meriel',
        'Greensall',
        'Florio',
        'mflorior@opera.com',
        '9909572377'
    ),
    (
        29,
        'Dotti',
        'Chesworth',
        'Cush',
        'dcushs@japanpost.jp',
        '1318226199'
    ),
    (
        30,
        'Stormi',
        'Haliday',
        'Frankcombe',
        'sfrankcombet@twitpic.com',
        '3887338575'
    ),
    (
        31,
        'Flore',
        'Delgua',
        'Kissick',
        'fkissicku@nbcnews.com',
        '3903036491'
    ),
    (
        32,
        'Miltie',
        'Ockenden',
        'Shewen',
        'mshewenv@amazonaws.com',
        '2408613068'
    ),
    (
        33,
        'Raeann',
        'Peagrim',
        'Lacasa',
        'rlacasaw@networkadvertising.org',
        '6146220919'
    ),
    (
        34,
        'Zorina',
        'Cordier',
        'Blacklidge',
        'zblacklidgex@skype.com',
        '8853304268'
    ),
    (
        35,
        'Aloysius',
        'Widmore',
        'Worstall',
        'aworstally@typepad.com',
        '7404889460'
    ),
    (
        36,
        'Willem',
        'Undrell',
        'Twyning',
        'wtwyningz@icq.com',
        '5387669645'
    ),
    (
        37,
        'Deloria',
        'Gallihawk',
        'Balding',
        'dbalding10@yale.edu',
        '4928216327'
    ),
    (
        38,
        'Ddene',
        'Gouldbourn',
        'Bebbington',
        'dbebbington11@facebook.com',
        '3767522551'
    ),
    (
        39,
        'Nero',
        'Bannerman',
        'Canwell',
        'ncanwell12@last.fm',
        '9467756472'
    ),
    (
        40,
        'Marquita',
        'Kennard',
        'Blackaller',
        'mblackaller13@deliciousdays.com',
        '5819396797'
    ),
    (
        41,
        'Cassaundra',
        'Colnet',
        'Louthe',
        'clouthe14@bloomberg.com',
        '7305031752'
    ),
    (
        42,
        'Baily',
        'Oliva',
        'Sellman',
        'bsellman15@storify.com',
        '4104859044'
    ),
    (
        43,
        'Donia',
        'Norquoy',
        'Beran',
        'dberan16@unblog.fr',
        '5296288380'
    ),
    (
        44,
        'Sile',
        'Bleue',
        'Over',
        'sover17@flavors.me',
        '1456941597'
    ),
    (
        45,
        'Bill',
        'Bettenay',
        'Bartkiewicz',
        'bbartkiewicz18@chicagotribune.com',
        '5314369359'
    ),
    (
        46,
        'Ev',
        'Notman',
        'Tomini',
        'etomini19@dyndns.org',
        '2293124243'
    ),
    (
        47,
        'Alli',
        'Guess',
        'Fuzzard',
        'afuzzard1a@vinaora.com',
        '6297454445'
    ),
    (
        48,
        'Jerri',
        'Parrott',
        'Breckin',
        'jbreckin1b@walmart.com',
        '6607651891'
    ),
    (
        49,
        'Nanci',
        'Dacey',
        'Spear',
        'nspear1c@altervista.org',
        '3508496736'
    ),
    (
        50,
        'Alvis',
        'Jessett',
        'Menezes',
        'amenezes1d@surveymonkey.com',
        '2004210128'
    ),
    (
        51,
        'Meggie',
        'Trigg',
        'Lackmann',
        'mlackmann1e@xrea.com',
        '3734032748'
    ),
    (
        52,
        'Katerine',
        'Verdie',
        'Paynton',
        'kpaynton1f@usgs.gov',
        '8389506727'
    ),
    (
        53,
        'Roarke',
        'Measor',
        'Ridehalgh',
        'rridehalgh1g@canalblog.com',
        '7762816929'
    ),
    (
        54,
        'Clem',
        'Darington',
        'Budd',
        'cbudd1h@privacy.gov.au',
        '9276757184'
    ),
    (
        55,
        'Rubie',
        'Ashley',
        'Kirkham',
        'rkirkham1i@moonfruit.com',
        '1552655312'
    ),
    (
        56,
        'Marlow',
        'Dalinder',
        'Burndred',
        'mburndred1j@webs.com',
        '8224359295'
    ),
    (
        57,
        'Belicia',
        'Gotthard.sf',
        'Bertwistle',
        'bbertwistle1k@vinaora.com',
        '5574875475'
    ),
    (
        58,
        'Tory',
        'Maypole',
        'Blaasch',
        'tblaasch1l@tinypic.com',
        '4206679723'
    ),
    (
        59,
        'Kat',
        'Quogan',
        'Gutcher',
        'kgutcher1m@amazonaws.com',
        '8585539865'
    ),
    (
        60,
        'Alex',
        'Clayhill',
        'Hawket',
        'ahawket1n@ehow.com',
        '5667753590'
    ),
    (
        61,
        'Verine',
        'Hamflett',
        'Popland',
        'vpopland1o@ibm.com',
        '3437411571'
    ),
    (
        62,
        'Mirelle',
        'Goede',
        'Meir',
        'mmeir1p@europa.eu',
        '8805441111'
    ),
    (
        63,
        'Misty',
        'Savage',
        'Tudhope',
        'mtudhope1q@huffingtonpost.com',
        '1403090957'
    ),
    (
        64,
        'Homerus',
        'Cow',
        'Rodwell',
        'hrodwell1r@about.com',
        '4041609863'
    ),
    (
        65,
        'Bonnie',
        'Bridgestock',
        'Beddingham',
        'bbeddingham1s@reference.com',
        '8327895601'
    ),
    (
        66,
        'Joellyn',
        'Losano',
        'McClounan',
        'jmcclounan1t@statcounter.com',
        '4541175663'
    ),
    (
        67,
        'Dasha',
        'Sprosson',
        'Cardenas',
        'dcardenas1u@google.ru',
        '3176743958'
    ),
    (
        68,
        'Josiah',
        'Leyfield',
        'Guihen',
        'jguihen1v@auda.org.au',
        '4943547146'
    ),
    (
        69,
        'Kellyann',
        'Allinson',
        'Easterby',
        'keasterby1w@rediff.com',
        '9928682243'
    ),
    (
        70,
        'Tomasina',
        'Jelkes',
        'Meek',
        'tmeek1x@dmoz.org',
        '5023308928'
    ),
    (
        71,
        'Ruthi',
        'Cianelli',
        'Rate',
        'rrate1y@liveinternet.ru',
        '5663231823'
    ),
    (
        72,
        'Luce',
        'Locock',
        'MacPeice',
        'lmacpeice1z@wikipedia.org',
        '7596017963'
    ),
    (
        73,
        'Jeddy',
        'Grisard',
        'Ivic',
        'jivic20@scientificamerican.com',
        '8882679430'
    ),
    (
        74,
        'Maynard',
        'Georger',
        'Tingle',
        'mtingle21@histats.com',
        '2402250035'
    ),
    (
        75,
        'Ilyse',
        'Rounsefull',
        'Maceur',
        'imaceur22@examiner.com',
        '3034995895'
    ),
    (
        76,
        'Mayer',
        'Snowball',
        'Kuhndel',
        'mkuhndel23@soup.io',
        '6897046481'
    ),
    (
        77,
        'Bobbette',
        'Kither',
        'Leeson',
        'bleeson24@smugmug.com',
        '1949910708'
    ),
    (
        78,
        'Gerrie',
        'Winkell',
        'Askin',
        'gaskin25@blogger.com',
        '4302597359'
    ),
    (
        79,
        'Aubrey',
        'Jeanneau',
        'Bridal',
        'abridal26@nydailynews.com',
        '1497270208'
    ),
    (
        80,
        'Germayne',
        'Rowthorn',
        'Loton',
        'gloton27@xrea.com',
        '8241631909'
    ),
    (
        81,
        'Vida',
        'Maskell',
        'McIlory',
        'vmcilory28@chronoengine.com',
        '3746739520'
    ),
    (
        82,
        'Laird',
        'Folker',
        'Ferrick',
        'lferrick29@google.co.jp',
        '5227751858'
    ),
    (
        83,
        'Linoel',
        'Cratere',
        'Thain',
        'lthain2a@liveinternet.ru',
        '1481862689'
    ),
    (
        84,
        'Merrielle',
        'MacEllen',
        'Sange',
        'msange2b@clickbank.net',
        '7867872197'
    ),
    (
        85,
        'Odilia',
        'Claris',
        'Paff',
        'opaff2c@independent.co.uk',
        '9719537122'
    ),
    (
        86,
        'Madelyn',
        'Whithalgh',
        'Brundall',
        'mbrundall2d@nhs.uk',
        '7081350249'
    ),
    (
        87,
        'Esme',
        'Steart',
        'Cromie',
        'ecromie2e@over-blog.com',
        '9862352776'
    ),
    (
        88,
        'Hedy',
        'Kindon',
        'Lomasna',
        'hlomasna2f@cnn.com',
        '8626949388'
    ),
    (
        89,
        'Leodora',
        'Dominetti',
        'Gwinn',
        'lgwinn2g@marriott.com',
        '5596012545'
    ),
    (
        90,
        'Nevile',
        'Melloy',
        'Krop',
        'nkrop2h@miitbeian.gov.cn',
        '7373690468'
    ),
    (
        91,
        'Nara',
        'Quinnet',
        'Velasquez',
        'nvelasquez2i@icio.us',
        '6686465832'
    ),
    (
        92,
        'Davina',
        'Punshon',
        'Cosans',
        'dcosans2j@bloglines.com',
        '5899396266'
    ),
    (
        93,
        'Hughie',
        'Rathke',
        'Hustings',
        'hhustings2k@ucoz.ru',
        '5988223946'
    ),
    (
        94,
        'Aigneis',
        'Mustarde',
        'Bestwick',
        'abestwick2l@ovh.net',
        '5778717843'
    ),
    (
        95,
        'Frederick',
        'Reding',
        'Southerill',
        'fsoutherill2m@gov.uk',
        '2177113841'
    ),
    (
        96,
        'Lloyd',
        'Gasperi',
        'Adenot',
        'ladenot2n@xinhuanet.com',
        '1286744012'
    ),
    (
        97,
        'Dur',
        'Twells',
        'Deners',
        'ddeners2o@friendfeed.com',
        '4519010581'
    ),
    (
        98,
        'Dorothea',
        'Batch',
        'Daskiewicz',
        'ddaskiewicz2p@phpbb.com',
        '1554534185'
    ),
    (
        99,
        'Muffin',
        'Marchetti',
        'Stubbe',
        'mstubbe2q@instagram.com',
        '4987615264'
    ),
    (
        100,
        'Wally',
        'Stodit',
        'Wetherby',
        'wwetherby2r@wufoo.com',
        '3017962363'
    ),
    (
        101,
        'Noah',
        'Battrick',
        'Beaford',
        'nbeaford2s@canalblog.com',
        '1119653612'
    ),
    (
        102,
        'Axe',
        'Orrocks',
        'Gullyes',
        'agullyes2t@ifeng.com',
        '6174574147'
    ),
    (
        103,
        'Conn',
        'Parham',
        'Sumpter',
        'csumpter2u@example.com',
        '3376622856'
    ),
    (
        104,
        'Munroe',
        'Rawstron',
        'Vittel',
        'mvittel2v@disqus.com',
        '9141624972'
    ),
    (
        105,
        'Dino',
        'Tollady',
        'Keysel',
        'dkeysel2w@psu.edu',
        '9072857986'
    ),
    (
        106,
        'Issy',
        'Leathard',
        'Coulsen',
        'icoulsen2x@devhub.com',
        '2764681536'
    ),
    (
        107,
        'Frederich',
        'Challenger',
        'Patterfield',
        'fpatterfield2y@imgur.com',
        '1377457403'
    ),
    (
        108,
        'Magdaia',
        'Kobierra',
        'Goward',
        'mgoward2z@topsy.com',
        '7703372436'
    ),
    (
        109,
        'Dorthy',
        'Lorraine',
        'Minghella',
        'dminghella30@pinterest.com',
        '7449508225'
    ),
    (
        110,
        'Leonerd',
        'Wisniewski',
        'Bellsham',
        'lbellsham31@reuters.com',
        '4671388854'
    ),
    (
        111,
        'Reinwald',
        'Maleney',
        'Hanbury',
        'rhanbury32@uol.com.br',
        '7052852596'
    ),
    (
        112,
        'Bidget',
        'Danzig',
        'Burgoin',
        'bburgoin33@nature.com',
        '1589825585'
    ),
    (
        113,
        'Muire',
        'Onyon',
        'Channer',
        'mchanner34@xing.com',
        '8684746734'
    ),
    (
        114,
        'Clint',
        'McAlpine',
        'Toone',
        'ctoone35@myspace.com',
        '3351568420'
    ),
    (
        115,
        'Ashil',
        'Lancett',
        'Kinner',
        'akinner36@squarespace.com',
        '2995168805'
    ),
    (
        116,
        'Rafferty',
        'Lemerle',
        'Serraillier',
        'rserraillier37@globo.com',
        '4699872550'
    ),
    (
        117,
        'Valeda',
        'Fishenden',
        'Gercke',
        'vgercke38@omniture.com',
        '7803179777'
    ),
    (
        118,
        'Olva',
        'Boch',
        'Handford',
        'ohandford39@skype.com',
        '4749100534'
    ),
    (
        119,
        'Nickolaus',
        'Challen',
        'Shasnan',
        'nshasnan3a@biblegateway.com',
        '1499139496'
    ),
    (
        120,
        'Corbie',
        'Hun',
        'Dymott',
        'cdymott3b@independent.co.uk',
        '6377457094'
    ),
    (
        121,
        'Edgard',
        'Lennarde',
        'MacDunleavy',
        'emacdunleavy3c@eventbrite.com',
        '5885685793'
    ),
    (
        122,
        'Aurore',
        'Januszewski',
        'Duesberry',
        'aduesberry3d@blogtalkradio.com',
        '9503462709'
    ),
    (
        123,
        'Francis',
        'Bellin',
        'Hubeaux',
        'fhubeaux3e@ucsd.edu',
        '4342233107'
    ),
    (
        124,
        'Matilda',
        'Shillington',
        'Fabbri',
        'mfabbri3f@t.co',
        '6475035025'
    ),
    (
        125,
        'Electra',
        'Pizzey',
        'Witnall',
        'ewitnall3g@yandex.ru',
        '6187282357'
    ),
    (
        126,
        'Monty',
        'Brim',
        'Wormell',
        'mwormell3h@opera.com',
        '3845686894'
    ),
    (
        127,
        'Angus',
        'Collumbell',
        'Hindshaw',
        'ahindshaw3i@umn.edu',
        '9619213049'
    ),
    (
        128,
        'Jonathon',
        'Roger',
        'Oman',
        'joman3j@nsw.gov.au',
        '3628364165'
    ),
    (
        129,
        'Lucinda',
        'Scourfield',
        'Gooda',
        'lgooda3k@gnu.org',
        '3658240544'
    ),
    (
        130,
        'Donella',
        'McGunley',
        'Bleazard',
        'dbleazard3l@gravatar.com',
        '8187122678'
    ),
    (
        131,
        'Andee',
        'Pitkin',
        'Sidnell',
        'asidnell3m@ehow.com',
        '5711708257'
    ),
    (
        132,
        'Berkeley',
        'Redmille',
        'Boyce',
        'bboyce3n@mlb.com',
        '6036537342'
    ),
    (
        133,
        'Angil',
        'Agirre',
        'Lennon',
        'alennon3o@bandcamp.com',
        '2657180493'
    ),
    (
        134,
        'Wang',
        'McOwan',
        'Durnall',
        'wdurnall3p@mapquest.com',
        '5968566913'
    ),
    (
        135,
        'Elmira',
        'McPeck',
        'Robbs',
        'erobbs3q@deliciousdays.com',
        '7521442548'
    ),
    (
        136,
        'Shawn',
        'Horry',
        'McIlwraith',
        'smcilwraith3r@goodreads.com',
        '5509104175'
    ),
    (
        137,
        'Jasmina',
        'Itzhaiek',
        'Badsey',
        'jbadsey3s@howstuffworks.com',
        '4536669536'
    ),
    (
        138,
        'Jim',
        'Godilington',
        'Veltman',
        'jveltman3t@nps.gov',
        '2057169902'
    ),
    (
        139,
        'Bellanca',
        'Ellaway',
        'Hainey`',
        'bhainey3u@booking.com',
        '5662181387'
    ),
    (
        140,
        'Denyse',
        'Tesche',
        'Shapiro',
        'dshapiro3v@nps.gov',
        '8436289756'
    ),
    (
        141,
        'Graig',
        'Yude',
        'Banner',
        'gbanner3w@bizjournals.com',
        '7511848652'
    ),
    (
        142,
        'Griz',
        'Grills',
        'Coupland',
        'gcoupland3x@plala.or.jp',
        '6036151388'
    ),
    (
        143,
        'Tallia',
        'Klemmt',
        'Dowbekin',
        'tdowbekin3y@cbsnews.com',
        '5027320116'
    ),
    (
        144,
        'Nataline',
        'Guierre',
        'Nelthrop',
        'nnelthrop3z@g.co',
        '1582378767'
    ),
    (
        145,
        'Dee',
        'Knowling',
        'Mandy',
        'dmandy40@moonfruit.com',
        '8118193220'
    ),
    (
        146,
        'Emylee',
        'Van der Spohr',
        'Sherrington',
        'esherrington41@virginia.edu',
        '6067126458'
    ),
    (
        147,
        'Lauree',
        'O''Deoran',
        'Hastie',
        'lhastie42@europa.eu',
        '4185738197'
    ),
    (
        148,
        'Harrison',
        'Scatchar',
        'D''Ambrogi',
        'hdambrogi43@flavors.me',
        '5993722873'
    ),
    (
        149,
        'Ebba',
        'Tampen',
        'Ragbourne',
        'eragbourne44@youku.com',
        '2731176353'
    ),
    (
        150,
        'Arlana',
        'Meads',
        'Jentin',
        'ajentin45@dailymail.co.uk',
        '2138881432'
    ),
    (
        151,
        'Gwendolen',
        'Rickardes',
        'Carwithan',
        'gcarwithan46@php.net',
        '8504484931'
    ),
    (
        152,
        'Richy',
        'Edward',
        'Batkin',
        'rbatkin47@prlog.org',
        '1018518348'
    ),
    (
        153,
        'Karlik',
        'Jurca',
        'Angliss',
        'kangliss48@phpbb.com',
        '6467773479'
    ),
    (
        154,
        'Lorelei',
        'Fairleigh',
        'Blackett',
        'lblackett49@yellowpages.com',
        '9045404204'
    ),
    (
        155,
        'Aluin',
        'Andreazzi',
        'Giurio',
        'agiurio4a@themeforest.net',
        '8675531543'
    ),
    (
        156,
        'Thaxter',
        'Normandale',
        'Fausset',
        'tfausset4b@hc360.com',
        '3129621136'
    ),
    (
        157,
        'Kelvin',
        'Glasard',
        'Guiver',
        'kguiver4c@vk.com',
        '1436310727'
    ),
    (
        158,
        'Joice',
        'Toppes',
        'Pinnick',
        'jpinnick4d@newsvine.com',
        '9776054256'
    ),
    (
        159,
        'Nancie',
        'Portwain',
        'Ridoutt',
        'nridoutt4e@joomla.org',
        '9452320111'
    ),
    (
        160,
        'Reuben',
        'Jekel',
        'Cordeau]',
        'rcordeau4f@latimes.com',
        '1536971041'
    ),
    (
        161,
        'Etty',
        'Antic',
        'Benard',
        'ebenard4g@addthis.com',
        '2503690163'
    ),
    (
        162,
        'Roxy',
        'Dargie',
        'Bygrove',
        'rbygrove4h@exblog.jp',
        '2181261088'
    ),
    (
        163,
        'Hermann',
        'Westgarth',
        'Stowers',
        'hstowers4i@posterous.com',
        '3341975558'
    ),
    (
        164,
        'Sofia',
        'Overstall',
        'Crayk',
        'scrayk4j@skype.com',
        '5756375733'
    ),
    (
        165,
        'Jackqueline',
        'McGlaughn',
        'Kubat',
        'jkubat4k@photobucket.com',
        '3094373821'
    ),
    (
        166,
        'Zonnya',
        'Toffler',
        'McShirie',
        'zmcshirie4l@amazon.co.uk',
        '8609161875'
    ),
    (
        167,
        'Michele',
        'Philipot',
        'Ivakin',
        'mivakin4m@wikimedia.org',
        '5747160050'
    ),
    (
        168,
        'Tedie',
        'Tiller',
        'Empson',
        'tempson4n@nationalgeographic.com',
        '9862139069'
    ),
    (
        169,
        'Joana',
        'Caldroni',
        'Rablin',
        'jrablin4o@harvard.edu',
        '4657942978'
    ),
    (
        170,
        'Gerda',
        'Paslow',
        'Elegood',
        'gelegood4p@drupal.org',
        '5848773539'
    ),
    (
        171,
        'Trescha',
        'Dealy',
        'MacAvaddy',
        'tmacavaddy4q@upenn.edu',
        '2376636688'
    ),
    (
        172,
        'Ryun',
        'Skarman',
        'Maty',
        'rmaty4r@alexa.com',
        '1392041561'
    ),
    (
        173,
        'Wes',
        'Roddan',
        'Dewdeny',
        'wdewdeny4s@taobao.com',
        '4128249994'
    ),
    (
        174,
        'Baxy',
        'Shulem',
        'Whyborn',
        'bwhyborn4t@rambler.ru',
        '2448023713'
    ),
    (
        175,
        'Natalie',
        'Floweth',
        'Cobson',
        'ncobson4u@google.cn',
        '4267794253'
    ),
    (
        176,
        'Benoite',
        'Bergstrand',
        'Molan',
        'bmolan4v@furl.net',
        '4544610430'
    ),
    (
        177,
        'Carin',
        'Wayland',
        'Pearse',
        'cpearse4w@chron.com',
        '8728763285'
    ),
    (
        178,
        'Sela',
        'Dalmon',
        'Yardley',
        'syardley4x@gmpg.org',
        '6938768552'
    ),
    (
        179,
        'Lissy',
        'Twiddy',
        'Ikringill',
        'likringill4y@sourceforge.net',
        '5403670433'
    ),
    (
        180,
        'Archie',
        'Elnaugh',
        'Thorsby',
        'athorsby4z@kickstarter.com',
        '4183171797'
    ),
    (
        181,
        'Rory',
        'Binham',
        'Toal',
        'rtoal50@earthlink.net',
        '5207201405'
    ),
    (
        182,
        'Farley',
        'Hasloch',
        'Percifull',
        'fpercifull51@senate.gov',
        '3061316168'
    ),
    (
        183,
        'Binni',
        'Boldra',
        'Kaplin',
        'bkaplin52@github.com',
        '3038452896'
    ),
    (
        184,
        'Gertrude',
        'Scamp',
        'Cuddihy',
        'gcuddihy53@tripod.com',
        '7082046350'
    ),
    (
        185,
        'Verina',
        'Pighills',
        'Attenbrough',
        'vattenbrough54@amazonaws.com',
        '3166942997'
    ),
    (
        186,
        'Doy',
        'Carmel',
        'Merrikin',
        'dmerrikin55@wp.com',
        '8024995145'
    ),
    (
        187,
        'Roxanna',
        'Coxhell',
        'Hadfield',
        'rhadfield56@ucoz.com',
        '8105428682'
    ),
    (
        188,
        'Scotti',
        'Pendlenton',
        'Astman',
        'sastman57@hexun.com',
        '4386337646'
    ),
    (
        189,
        'Layton',
        'Monteaux',
        'Hindge',
        'lhindge58@ovh.net',
        '6706995158'
    ),
    (
        190,
        'Sadie',
        'Coales',
        'Dowzell',
        'sdowzell59@constantcontact.com',
        '3797488219'
    ),
    (
        191,
        'Flem',
        'Fleury',
        'Turri',
        'fturri5a@paginegialle.it',
        '4112823782'
    ),
    (
        192,
        'Felice',
        'Cutforth',
        'Brigstock',
        'fbrigstock5b@arizona.edu',
        '7572295589'
    ),
    (
        193,
        'Gerta',
        'Petrenko',
        'Ygoe',
        'gygoe5c@shinystat.com',
        '2961753126'
    ),
    (
        194,
        'Caprice',
        'Burtt',
        'Hornung',
        'chornung5d@vinaora.com',
        '1858601750'
    ),
    (
        195,
        'Boycey',
        'Syde',
        'Posselwhite',
        'bposselwhite5e@goo.ne.jp',
        '1125610264'
    ),
    (
        196,
        'Lyndy',
        'Bance',
        'Merton',
        'lmerton5f@ucoz.ru',
        '7674574757'
    ),
    (
        197,
        'Kerwin',
        'Tilte',
        'Sprake',
        'ksprake5g@sohu.com',
        '1686526772'
    ),
    (
        198,
        'Burty',
        'Tamsett',
        'Glewe',
        'bglewe5h@hatena.ne.jp',
        '4112543617'
    ),
    (
        199,
        'Silvester',
        'Purdie',
        'Arbuckle',
        'sarbuckle5i@163.com',
        '9837870788'
    ),
    (
        200,
        'Arvy',
        'Whiteland',
        'Woodworth',
        'awoodworth5j@webeden.co.uk',
        '7489238661'
    ),
    (
        201,
        'Wiatt',
        'Son',
        'Fullerton',
        'wfullerton5k@icio.us',
        '8268122423'
    ),
    (
        202,
        'Iris',
        'Caffrey',
        'Smittoune',
        'ismittoune5l@ask.com',
        '3301984351'
    ),
    (
        203,
        'Andriana',
        'Begwell',
        'Fetters',
        'afetters5m@smh.com.au',
        '3627285298'
    ),
    (
        204,
        'Rice',
        'Poyzer',
        'Dermot',
        'rdermot5n@engadget.com',
        '3806646265'
    ),
    (
        205,
        'Drucy',
        'Hudleston',
        'Flewin',
        'dflewin5o@unicef.org',
        '9995533512'
    ),
    (
        206,
        'Reg',
        'Budcock',
        'MacNair',
        'rmacnair5p@sina.com.cn',
        '9924780184'
    ),
    (
        207,
        'Opaline',
        'O''Sesnane',
        'Goodboddy',
        'ogoodboddy5q@ucoz.ru',
        '5469885690'
    ),
    (
        208,
        'Trixie',
        'Heymann',
        'Gunderson',
        'tgunderson5r@miitbeian.gov.cn',
        '8124076220'
    ),
    (
        209,
        'Martynne',
        'Cuckson',
        'Bernardon',
        'mbernardon5s@timesonline.co.uk',
        '8717880758'
    ),
    (
        210,
        'Major',
        'Moresby',
        'Krolman',
        'mkrolman5t@ifeng.com',
        '6554849934'
    ),
    (
        211,
        'Ole',
        'Hindrich',
        'Churly',
        'ochurly5u@ox.ac.uk',
        '2669795787'
    ),
    (
        212,
        'Brandyn',
        'D''Elia',
        'Ballinghall',
        'bballinghall5v@soundcloud.com',
        '4703036796'
    ),
    (
        213,
        'Pru',
        'Kilsby',
        'McPaike',
        'pmcpaike5w@oakley.com',
        '4249515154'
    ),
    (
        214,
        'Jolene',
        'Cosby',
        'Giff',
        'jgiff5x@mashable.com',
        '1768334696'
    ),
    (
        215,
        'Charlot',
        'Gilley',
        'Huncoot',
        'chuncoot5y@example.com',
        '3157217795'
    ),
    (
        216,
        'Caitrin',
        'Claeskens',
        'Cosbey',
        'ccosbey5z@youtube.com',
        '6338527315'
    ),
    (
        217,
        'Ondrea',
        'Meth',
        'Carrabott',
        'ocarrabott60@youtube.com',
        '5413431035'
    ),
    (
        218,
        'Lainey',
        'ffrench Beytagh',
        'Bartolini',
        'lbartolini61@ezinearticles.com',
        '6755230488'
    ),
    (
        219,
        'Georgianna',
        'Wonfar',
        'Mizen',
        'gmizen62@china.com.cn',
        '6528467302'
    ),
    (
        220,
        'Amalee',
        'Simunek',
        'Twaits',
        'atwaits63@usnews.com',
        '8991266835'
    ),
    (
        221,
        'Anne',
        'Kellie',
        'Haster',
        'ahaster64@networksolutions.com',
        '2088342328'
    ),
    (
        222,
        'Elsie',
        'Lifsey',
        'Shatliff',
        'eshatliff65@baidu.com',
        '2566928927'
    ),
    (
        223,
        'Pearce',
        'Hillborne',
        'Clell',
        'pclell66@sfgate.com',
        '4677669868'
    ),
    (
        224,
        'Filmore',
        'Gert',
        'Tuther',
        'ftuther67@trellian.com',
        '7308918659'
    ),
    (
        225,
        'Lucian',
        'Camplen',
        'Bruck',
        'lbruck68@networkadvertising.org',
        '3866009989'
    ),
    (
        226,
        'Mame',
        'Brend',
        'Dugue',
        'mdugue69@163.com',
        '6754466803'
    ),
    (
        227,
        'Howie',
        'Raynor',
        'Andre',
        'handre6a@redcross.org',
        '6827728004'
    ),
    (
        228,
        'Delmor',
        'Mantripp',
        'd''Arcy',
        'ddarcy6b@about.me',
        '4259705496'
    ),
    (
        229,
        'Alicea',
        'MacAndrew',
        'Maskew',
        'amaskew6c@wordpress.org',
        '2538475293'
    ),
    (
        230,
        'Tandie',
        'Lyles',
        'Brocklesby',
        'tbrocklesby6d@tiny.cc',
        '3251922316'
    ),
    (
        231,
        'Wanda',
        'Brozek',
        'Headings',
        'wheadings6e@google.co.jp',
        '4118140347'
    ),
    (
        232,
        'Meaghan',
        'Yerson',
        'Kimbley',
        'mkimbley6f@omniture.com',
        '3334495094'
    ),
    (
        233,
        'Kacie',
        'Momford',
        'Issit',
        'kissit6g@pagesperso-orange.fr',
        '2798439889'
    ),
    (
        234,
        'Beulah',
        'Hankey',
        'Mayo',
        'bmayo6h@prlog.org',
        '7503775791'
    ),
    (
        235,
        'Alla',
        'Gregol',
        'Leuren',
        'aleuren6i@army.mil',
        '9514136187'
    ),
    (
        236,
        'Corella',
        'Dee',
        'Clampin',
        'cclampin6j@ebay.co.uk',
        '1498431821'
    ),
    (
        237,
        'Zebadiah',
        'Tithecote',
        'Blenkhorn',
        'zblenkhorn6k@ucla.edu',
        '3943976602'
    ),
    (
        238,
        'Solomon',
        'Burgett',
        'Coogan',
        'scoogan6l@npr.org',
        '2546489583'
    ),
    (
        239,
        'Gussy',
        'Peegrem',
        'Kitchener',
        'gkitchener6m@ox.ac.uk',
        '1478190824'
    ),
    (
        240,
        'Rozamond',
        'Rickhuss',
        'Thouless',
        'rthouless6n@hexun.com',
        '9824798281'
    ),
    (
        241,
        'Cordie',
        'Manklow',
        'Kinder',
        'ckinder6o@ucla.edu',
        '3169907580'
    ),
    (
        242,
        'Madeleine',
        'Hassall',
        'Verrills',
        'mverrills6p@prlog.org',
        '5729602231'
    ),
    (
        243,
        'Don',
        'Dickon',
        'Tearney',
        'dtearney6q@shop-pro.jp',
        '8859151426'
    ),
    (
        244,
        'Araldo',
        'Dukes',
        'Netley',
        'anetley6r@hibu.com',
        '5632971873'
    ),
    (
        245,
        'Vi',
        'Cattonnet',
        'Densun',
        'vdensun6s@pinterest.com',
        '7031529991'
    ),
    (
        246,
        'Abrahan',
        'Demchen',
        'Lishman',
        'alishman6t@surveymonkey.com',
        '7885112705'
    ),
    (
        247,
        'Marlo',
        'Balshaw',
        'Lavell',
        'mlavell6u@arstechnica.com',
        '9925730171'
    ),
    (
        248,
        'Mathilda',
        'Medmore',
        'Trundle',
        'mtrundle6v@devhub.com',
        '1153730392'
    ),
    (
        249,
        'Val',
        'Willmore',
        'Fearnyough',
        'vfearnyough6w@statcounter.com',
        '4196498734'
    ),
    (
        250,
        'Sherrie',
        'Docherty',
        'Durgan',
        'sdurgan6x@eepurl.com',
        '4679640196'
    ),
    (
        251,
        'Mead',
        'Baudoux',
        'Wash',
        'mwash6y@digg.com',
        '5717993814'
    ),
    (
        252,
        'Loren',
        'Pimmocke',
        'Sreenan',
        'lsreenan6z@admin.ch',
        '3603068100'
    ),
    (
        253,
        'Claretta',
        'Wynter',
        'Machent',
        'cmachent70@bloglovin.com',
        '6499368830'
    ),
    (
        254,
        'Nanine',
        'Passo',
        'Dalton',
        'ndalton71@apache.org',
        '8084099971'
    ),
    (
        255,
        'Rochell',
        'Gyer',
        'Commins',
        'rcommins72@ehow.com',
        '5044815947'
    ),
    (
        256,
        'Horatia',
        'Crippes',
        'Halt',
        'hhalt73@ucoz.com',
        '2533968208'
    ),
    (
        257,
        'Jenna',
        'Crudge',
        'Berryann',
        'jberryann74@example.com',
        '7095967379'
    ),
    (
        258,
        'Alf',
        'Tanman',
        'Rodenburgh',
        'arodenburgh75@photobucket.com',
        '3815496587'
    ),
    (
        259,
        'Hyacinthia',
        'Glascott',
        'Vakhrushin',
        'hvakhrushin76@yellowpages.com',
        '2958476805'
    ),
    (
        260,
        'Kizzee',
        'Reihill',
        'Eade',
        'keade77@people.com.cn',
        '1138953041'
    );

--INSERT INTO students_emergency_contacts (256)
INSERT INTO
    students_emergency_contacts (emergency_contact_id, student_id)
VALUES
    (1, 1),
    (2, 1),
    (3, 2),
    (4, 2),
    (5, 3),
    (6, 3),
    (7, 4),
    (8, 4),
    (9, 5),
    (10, 5),
    (11, 6),
    (12, 6),
    (13, 7),
    (14, 7),
    (15, 8),
    (16, 8),
    (17, 9),
    (18, 9),
    (19, 10),
    (20, 10),
    (21, 11),
    (22, 11),
    (23, 12),
    (24, 12),
    (25, 13),
    (26, 13),
    (27, 14),
    (28, 14),
    (29, 15),
    (30, 15),
    (31, 16),
    (32, 16),
    (33, 17),
    (34, 17),
    (35, 18),
    (36, 18),
    (37, 19),
    (38, 19),
    (39, 20),
    (40, 20),
    (41, 21),
    (42, 21),
    (43, 22),
    (44, 22),
    (45, 23),
    (46, 23),
    (47, 24),
    (48, 24),
    (49, 25),
    (50, 25),
    (51, 26),
    (52, 26),
    (53, 27),
    (54, 27),
    (55, 28),
    (56, 28),
    (57, 29),
    (58, 29),
    (59, 30),
    (60, 30),
    (61, 31),
    (62, 31),
    (63, 32),
    (64, 32),
    (65, 33),
    (66, 33),
    (67, 34),
    (68, 34),
    (69, 35),
    (70, 35),
    (71, 36),
    (72, 36),
    (73, 37),
    (74, 37),
    (75, 38),
    (76, 38),
    (77, 39),
    (78, 39),
    (79, 40),
    (80, 40),
    (81, 41),
    (82, 41),
    (83, 42),
    (84, 42),
    (85, 43),
    (86, 43),
    (87, 44),
    (88, 44),
    (89, 45),
    (90, 45),
    (91, 46),
    (92, 46),
    (93, 47),
    (94, 47),
    (95, 48),
    (96, 48),
    (97, 49),
    (98, 49),
    (99, 50),
    (100, 50),
    (101, 51),
    (102, 51),
    (103, 52),
    (104, 52),
    (105, 53),
    (106, 53),
    (107, 54),
    (108, 54),
    (109, 55),
    (110, 55),
    (111, 56),
    (112, 56),
    (113, 57),
    (114, 57),
    (115, 58),
    (116, 58),
    (117, 59),
    (118, 59),
    (119, 60),
    (120, 60),
    (121, 61),
    (122, 61),
    (123, 62),
    (124, 62),
    (125, 63),
    (126, 63),
    (127, 64),
    (128, 64),
    (129, 65),
    (130, 65),
    (131, 66),
    (132, 66),
    (133, 67),
    (134, 67),
    (135, 68),
    (136, 68),
    (137, 69),
    (138, 69),
    (139, 70),
    (140, 70),
    (141, 71),
    (142, 71),
    (143, 72),
    (144, 72),
    (145, 73),
    (146, 73),
    (147, 74),
    (148, 74),
    (149, 75),
    (150, 75),
    (151, 76),
    (152, 76),
    (153, 77),
    (154, 77),
    (155, 78),
    (156, 78),
    (157, 79),
    (158, 79),
    (159, 80),
    (160, 80),
    (161, 81),
    (162, 81),
    (163, 82),
    (164, 82),
    (165, 83),
    (166, 83),
    (167, 84),
    (168, 84),
    (169, 85),
    (170, 85),
    (171, 86),
    (172, 86),
    (173, 87),
    (174, 87),
    (175, 88),
    (176, 88),
    (177, 89),
    (178, 89),
    (179, 90),
    (180, 90),
    (181, 91),
    (182, 91),
    (183, 92),
    (184, 92),
    (185, 93),
    (186, 93),
    (187, 94),
    (188, 94),
    (189, 95),
    (190, 95),
    (191, 96),
    (192, 96),
    (193, 97),
    (194, 97),
    (195, 98),
    (196, 98),
    (197, 99),
    (198, 99),
    (199, 100),
    (200, 100),
    (201, 101),
    (202, 101),
    (203, 102),
    (204, 102),
    (205, 103),
    (206, 103),
    (207, 104),
    (208, 104),
    (209, 105),
    (210, 105),
    (211, 106),
    (212, 106),
    (213, 107),
    (214, 107),
    (215, 108),
    (216, 108),
    (217, 109),
    (218, 109),
    (219, 110),
    (220, 110),
    (221, 111),
    (222, 111),
    (223, 112),
    (224, 112),
    (225, 113),
    (226, 113),
    (227, 114),
    (228, 114),
    (229, 115),
    (230, 115),
    (231, 116),
    (232, 116),
    (233, 117),
    (234, 117),
    (235, 118),
    (236, 118),
    (237, 119),
    (238, 119),
    (239, 120),
    (240, 120),
    (241, 121),
    (242, 121),
    (243, 122),
    (244, 122),
    (245, 123),
    (246, 123),
    (247, 124),
    (248, 124),
    (249, 125),
    (250, 125),
    (251, 126),
    (252, 126),
    (253, 127),
    (254, 127),
    (255, 128),
    (256, 128);

-- INSERT INTO special_requests (5) 
INSERT INTO
    special_requests (special_request_name)
VALUES
    ('Visual Impairment'),
    ('Deaf or hard of hearing'),
    ('Mental health conditions'),
    ('Physical disability'),
    ('Autism spectrum disorder');

-- INSERT INTO students_special_requests 
INSERT INTO
    students_special_requests (special_request_id, student_id)
VALUES
    (1, 10),
    (1, 2),
    (2, 13),
    (2, 6),
    (3, 7),
    (3, 27),
    (4, 21),
    (4, 25),
    (5, 4),
    (5, 3),
    (5, 10);

-- INSERT INTO modules (65) 
INSERT INTO
    modules (module_name, module_description, module_level)
VALUES
    --id_1'electrical engineering' l4-3 modules,l5- 2 modules , l6 2 modules ,l7 2 modules
    (
        'Mathematical principles',
        'this module provides the foundation to algebra',
        'L4'
    ),
    (
        'Introduction to programming 2 ',
        'this module introduces fundamental computer programming',
        'L4'
    ), ---use this one 
    (
        'introduction to analogue circuits',
        'knowledge of analogue electronics of digital systems',
        'L4'
    ),
    (
        'circuit analysis',
        'introduction to electrical circuits, including ohm\`s law, kirchhoff\`s laws, and circuit theorems.',
        'L5'
    ),
    (
        'electromagnetics',
        'fundamental concepts of electromagnetics, focusing on electric and magnetic fields and maxwell\`s equations.',
        'L5'
    ),
    (
        'power systems',
        'study of power generation, transmission, and distribution with a focus on energy efficiency and grid stability.',
        'L6'
    ),
    (
        'control systems',
        'an in-depth look at control theory, covering feedback systems, stability analysis, and system response.',
        'L6'
    ),
    (
        'advanced signal processing',
        'advanced techniques in signal processing including filtering, fourier transforms, and signal analysis.',
        'L7'
    ),
    (
        'renewable energy systems',
        'design and analysis of renewable energy systems, focusing on solar, wind, and other sustainable sources.',
        'L7'
    ),
    --id_2 'mathematics with statistics L4-2 modules, L5-2 modules, L6-2 modules, L7-2 modules
    (
        'calculus i',
        'introduction to differential and integral calculus, covering limits, derivatives, and basic integrals.',
        'L4'
    ),
    (
        'introduction to statistics',
        'fundamentals of statistics, including data collection, descriptive statistics, and probability theory.',
        'L4'
    ),
    (
        'linear algebra',
        'exploration of vector spaces, matrices, determinants, and linear transformations.',
        'L5'
    ),
    (
        'probability theory',
        'comprehensive study of probability models, random variables, and probability distributions.',
        'L5'
    ),
    (
        'statistical inference',
        'advanced concepts in statistical inference, hypothesis testing, and estimation methods.',
        'L6'
    ),
    (
        'real analysis',
        'in-depth study of real-valued functions, including sequences, series, and continuity.',
        'L6'
    ),
    (
        'multivariate statistics',
        'examination of multivariate data, including techniques such as factor analysis and principal component analysis.',
        'L7'
    ),
    (
        'advanced calculus',
        'advanced topics in calculus, including vector calculus, multiple integrals, and surface integrals.',
        'L7'
    ),
    --id_3 software engineering L4-2 modules, L5-2 modules, L6-2 modules, L7-2 modules
    (
        'programming',
        'theory and practice of developing computer programs',
        'L4'
    ),
    (
        'architecture and operating systems',
        'iintroduction to the logical structure of computer systems',
        'L4'
    ),
    (
        'core computing concepts',
        'broad understanding of the discipline of computing science',
        'L5'
    ),
    (
        'object-oriented programming',
        'principles and practices of object-oriented focus and reusable code',
        'L5'
    ),
    (
        'database management systems',
        'design and management of databases, including relational database theory and sql',
        'L6'
    ),
    (
        'software project management',
        'principles of project management in software engineering, risk management',
        'L6'
    ),
    (
        'advanced software engineering',
        'advanced concepts in software engineering, including design patterns',
        'L7'
    ),
    (
        'machine learning and artificial intelligence',
        'introduction to machine learning and ai techniques',
        'L7'
    ),
    --id_4 'computing' L4-2 modules, L5-2 modules, L6-2 modules, L7-2 modules
    (
        'introduction to computing',
        'fundamental concepts of computing, including hardware, software, and basic algorithms.',
        'L4'
    ),
    (
        'introduction to programming',
        'basics of programming, focusing on problem-solving, algorithms, and basic coding skills.',
        'L4'
    ),
    (
        'data structures and algorithms',
        'study of data structures such as arrays, lists, stacks, and algorithms for efficient processing.',
        'L5'
    ),
    (
        'computer networks',
        'introduction to computer networking principles, including protocols, models, and network security basics.',
        'L5'
    ),
    (
        'operating systems',
        'in-depth study of operating system concepts, including processes, memory management, and file systems.',
        'L6'
    ),
    (
        'database systems',
        'principles of database design, management, and sql, with a focus on relational databases.',
        'L6'
    ),
    (
        'advanced computing concepts',
        'exploration of advanced topics in computing, such as distributed systems and parallel computing.',
        'L7'
    ),
    (
        'research methods in computing',
        'methods and practices for conducting research in computing, including data collection and analysis.',
        'L7'
    ),
    --id_5 'criminology and criminal justice' L4-2 modules, L5-2 modules, L6-2 modules, L7-2 modules
    (
        'introduction to criminology',
        'foundational concepts in criminology, exploring crime, justice, and criminal behavior.',
        'L4'
    ),
    (
        'the criminal justice system',
        'overview of the criminal justice system, including law enforcement, courts, and corrections.',
        'L4'
    ),
    (
        'criminal law and policy',
        'study of criminal laws and policies, focusing on legal definitions and criminal liability.',
        'L5'
    ),
    (
        'crime and society',
        'examination of how social factors influence crime and the role of society in criminal justice.',
        'L5'
    ),
    (
        'criminological theories',
        'in-depth analysis of criminological theories explaining the causes and prevention of crime.',
        'L6'
    ),
    (
        'policing and crime prevention',
        'study of policing strategies, crime prevention techniques, and their effectiveness.',
        'L6'
    ),
    (
        'comparative criminal justice',
        'comparative study of criminal justice systems across different countries and legal systems.',
        'L7'
    ),
    (
        'research methods in criminology',
        'methods and techniques for conducting research in criminology and criminal justice.',
        'L7'
    ),
    ----id_6 'social science' L4-2 modules, L5-2 modules, L6-2 modules, L7-2 modules
    (
        'introduction to social sciences',
        'explores the foundations of social sciences, including sociology, psychology, and anthropology.',
        'L4'
    ),
    (
        'contemporary social issues',
        'study of current social issues, such as inequality, poverty, and social justice.',
        'L4'
    ),
    (
        'social research methods',
        'introduction to qualitative and quantitative research methods in social sciences.',
        'L5'
    ),
    (
        'society and culture',
        'examines the role of culture in shaping social norms, values, and human behavior.',
        'L5'
    ),
    (
        'social policy and welfare',
        'study of social policies and welfare systems, focusing on their impact on society.',
        'L6'
    ),
    (
        'gender and society',
        'explores how gender shapes social experiences, roles, and identities.',
        'L6'
    ),
    (
        'advanced social theory',
        'in-depth analysis of advanced theories in social sciences, such as critical and postmodern perspectives.',
        'L7'
    ),
    (
        'globalization and social change',
        'examines the impact of globalization on social structures, communities, and cultural identities.',
        'L7'
    ),
    --id_7 graphic design L4-2 modules, L5-2 modules, L6-2 modules, L7-2 modules
    (
        'introduction to graphic design',
        'fundamental concepts of graphic design, including design principles, color theory, and typography.',
        'L4'
    ),
    (
        'digital illustration',
        'basic techniques in digital illustration, covering vector and raster graphics software.',
        'L4'
    ),
    (
        'typography and layout',
        'explores the use of typography and layout in visual communication, including font selection and grid systems.',
        'L5'
    ),
    (
        'photography for designers',
        'introduction to photography techniques and their applications in design projects.',
        'L5'
    ),
    (
        'brand identity and logo design',
        'development of brand identities, focusing on logo design, branding, and visual storytelling.',
        'L6'
    ),
    (
        'user interface (ui) design',
        'principles of user interface design, including usability, interaction design, and prototyping.',
        'L6'
    ),
    (
        'advanced motion graphics',
        'advanced techniques in motion graphics, including animation, transitions, and dynamic storytelling.',
        'L7'
    ),
    (
        'design research and development',
        'methods for conducting design research, ideation, and development of innovative visual solutions.',
        'L7'
    ),
    --id_8 'art and desing' L4-2 modules, L5-2 modules, L6-2 modules, L7-2 modules
    (
        'introduction to fine art',
        'explores fundamental principles and techniques of fine art, including drawing, painting, and sculpture.',
        'L4'
    ),
    (
        'history of art and design',
        'study of key movements, styles, and influences in art and design history.',
        'L4'
    ),
    (
        'creative processes',
        'exploration of creative thinking techniques and their application in art and design projects.',
        'L5'
    ),
    (
        'visual communication',
        'principles of visual storytelling and communication through different mediums.',
        'L5'
    ),
    (
        'contemporary art practice',
        'focuses on modern art practices, encouraging experimentation and critical reflection.',
        'L6'
    ),
    (
        'exhibition design',
        'design and planning of exhibitions, including layout, audience engagement, and curation.',
        'L6'
    ),
    (
        'advanced studio practice',
        'independent and advanced practice in studio art, developing a personal style and portfolio.',
        'L7'
    ),
    (
        'art and design research methods',
        'research techniques and methodologies for art and design projects.',
        'L7'
    );

--INSERT INTO staff_module
INSERT INTO
    staff_module (staff_id, module_id)
VALUES
    -- dep 1
    (5, 11),
    (6, 9),
    (6, 1),
    (5, 3),
    (2, 14),
    (2, 6),
    (3, 6),
    (4, 14),
    (5, 8),
    (2, 5),
    (2, 1),
    (6, 8),
    (3, 16),
    (6, 7),
    (2, 17),
    -- dep 2
    (12, 25),
    (9, 29),
    (11, 25),
    (11, 31),
    (11, 28),
    (7, 22),
    (10, 31),
    (9, 30),
    (12, 18),
    (11, 29),
    (11, 23),
    (7, 25),
    (7, 30),
    (12, 28),
    (8, 20),
    (10, 30),
    -- dep 3
    (14, 49),
    (17, 41),
    (14, 47),
    (14, 35),
    (16, 45),
    (17, 40),
    (14, 36),
    (15, 47),
    (15, 38),
    (17, 36),
    (16, 42),
    (14, 42),
    (16, 46),
    (17, 38),
    (17, 46),
    (15, 36),
    --dep 4
    (20, 55),
    (22, 62),
    (21, 62),
    (23, 53),
    (21, 61),
    (23, 55),
    (19, 57),
    (23, 64),
    (22, 64),
    (20, 62),
    (24, 62),
    (23, 51),
    (22, 58),
    (24, 50),
    (19, 62),
    (21, 55),
    ---branch 2
    --dep 1
    (30, 1),
    (27, 1),
    (26, 4),
    (29, 13),
    (25, 6),
    (26, 13),
    (28, 11),
    (28, 17),
    (25, 12),
    (30, 7),
    (25, 2),
    (26, 6),
    (29, 1),
    (27, 10),
    (25, 5),
    (30, 16),
    --dep 2
    (36, 18),
    (35, 25),
    (34, 26),
    (34, 18),
    (33, 20),
    (33, 28),
    (35, 31),
    (31, 24),
    (34, 20),
    (34, 32),
    (33, 19),
    (33, 23),
    (35, 24),
    (32, 24),
    (34, 27),
    (35, 33),
    --dep3
    (37, 35),
    (40, 41),
    (38, 49),
    (40, 42),
    (38, 36),
    (37, 37),
    (37, 39),
    (42, 45),
    (41, 43),
    (39, 46),
    (40, 37),
    (38, 37),
    (38, 46),
    (42, 49),
    (40, 34),
    --dep 4
    (46, 58),
    (43, 61),
    (47, 56),
    (45, 61),
    (46, 61),
    (48, 64),
    (43, 51),
    (47, 61),
    (46, 65),
    (43, 65),
    (47, 52),
    (43, 56),
    (45, 51),
    (48, 59),
    (43, 59),
    (44, 63);

---INSERT INTO course_module 
INSERT INTO
    module_course (module_id, course_id)
VALUES
    (1, 1),
    (2, 1),
    (3, 1),
    (4, 1),
    (5, 1),
    (6, 1),
    (7, 1),
    (8, 1),
    (9, 1),
    (1, 2),
    (10, 2),
    (11, 2),
    (12, 2),
    (13, 2),
    (14, 2),
    (15, 2),
    (16, 2),
    (17, 2),
    (18, 3),
    (19, 3),
    (20, 3),
    (21, 3),
    (22, 3),
    (23, 3),
    (24, 3),
    (25, 3),
    (18, 4),
    (26, 4),
    (27, 4),
    (28, 4),
    (29, 4),
    (30, 4),
    (31, 4),
    (32, 4),
    (33, 4),
    (34, 5),
    (35, 5),
    (36, 5),
    (37, 5),
    (38, 5),
    (39, 5),
    (40, 5),
    (41, 5),
    (34, 6),
    (42, 6),
    (43, 6),
    (44, 6),
    (45, 7),
    (46, 6),
    (47, 6),
    (48, 6),
    (49, 6),
    (50, 7),
    (51, 7),
    (52, 7),
    (53, 7),
    (54, 7),
    (55, 7),
    (56, 7),
    (57, 7),
    (50, 8),
    (58, 8),
    (59, 8),
    (60, 8),
    (61, 8),
    (62, 8),
    (63, 8),
    (64, 8),
    (65, 8);

-- assessements 
---function automatic submissions match student level with module level and try with 2 assessment+ data for the previus year
CREATE
OR REPLACE FUNCTION INSERT_ASSESSMENTS () RETURNS VOID AS $$
DECLARE
    lorem_words TEXT[] := '{Lorem, ipsum, dolor, sit, amet, consectetur, adipiscing, elit, sed, do, eiusmod, tempor, incididunt, ut, labore, et, dolore, magna, aliqua, Ut, enim, ad, minim, veniam, quis, nostrud, exercitation, ullamco, laboris, nisi, ut, aliquip, ex, ea, commodo, consequat, Duis, aute, irure, dolor, in, reprehenderit, in, voluptate, velit, esse, cillum, dolore, eu, fugiat, nulla, pariatur}';
    var_module RECORD;
    num_assessments INT;
    student_record RECORD;
    base_date DATE;
    increment_day INT;
    total_weight INT := 100;
    remaining_weight INT;
    weight INT;
    weights INT[] := ARRAY[]::INT[];
    assessment_ontime BOOLEAN;
    feedback TEXT;
    num_words INT;
    word_idx INT;
    assessment_type assessment_types;
BEGIN
    -- Loop through all modules
    FOR var_module IN SELECT DISTINCT module_id, module_level FROM modules
    LOOP
        -- Determine the number of assessments for the module
        num_assessments := TRUNC(RANDOM() * 2) + 1;
        remaining_weight := total_weight;
        weights := ARRAY[]::INT[];

        -- Calculate weights for assessments
        FOR i IN 1..(num_assessments - 1)
        LOOP
            weight := (TRUNC(RANDOM() * (remaining_weight / 20)) * 10) + 10;
            weights := array_append(weights, weight);
            remaining_weight := remaining_weight - weight;
        END LOOP;
        weights := array_append(weights, remaining_weight); -- Last assessment gets the remaining weight

        -- Fetch students for the current module whose academic level matches the module's level
        FOR student_record IN 
            SELECT s.student_id, s.student_academic_level 
            FROM students s
            JOIN module_course cm ON s.course_id = cm.course_id
            WHERE cm.module_id = var_module.module_id
              AND var_module.module_level <=  s.student_academic_level
          
     -- Restrict modules to the student's level or below
        LOOP
            -- Generate base date for assessments
            base_date := CURRENT_DATE + (TRUNC(RANDOM() * 10) + 1)::int;
            increment_day := 0;

            -- Insert assessments for the student
            FOR assessment_id IN 1..num_assessments
            LOOP
                assessment_ontime := RANDOM() > 0.05;

                -- Generate random feedback
                num_words := TRUNC(RANDOM() * 21) + 30;
                feedback := INITCAP(lorem_words[TRUNC(RANDOM() * array_length(lorem_words, 1)) + 1]);
                FOR word_idx IN 2..num_words
                LOOP
                    feedback := feedback || ' ' || lorem_words[TRUNC(RANDOM() * array_length(lorem_words, 1)) + 1];
                END LOOP;
                assessment_type := (ARRAY['COURSEWORK', 'EXAM'])[TRUNC(RANDOM() * 2) + 1];

                -- Insert into assessments table
                INSERT INTO assessments (
                     assessment_id, 
                    module_id, 
                    student_id, 
                    assessment_type, 
                    assessment_date, 
                    assessment_time, 
                    assessment_late_date,                    
                    assessment_late_time, 
                    assessment_mark, 
                    assessment_weight, 
                    assessment_ontime, 
                    assessment_feedback
                )
                VALUES (
                    assessment_id, 
                    var_module.module_id, 
                    student_record.student_id, 
					assessment_type,
                    base_date + increment_day, 
                    TIME '09:00:00' + (RANDOM() * INTERVAL '9 hours'),
                    base_date + increment_day + 10,                    
                    TIME '09:00:00' + (RANDOM() * INTERVAL '9 hours'),
                    ROUND((RANDOM() * 100)::numeric, 2), 
                    weights[assessment_id], 
                    assessment_ontime, 
                    feedback
                );

                increment_day := increment_day + 3; -- Increment days for the next assessment
            END LOOP;
        END LOOP;
    END LOOP;
END;
$$ LANGUAGE plpgsql;

SELECT
    INSERT_ASSESSMENTS ();

-- INSERT INTO events 
INSERT INTO
    events (course_id, event_name, event_date, event_time)
VALUES
    (3, 'Criminal Talk', '2025-02-02', '10:55'),
    (1, 'Electrical Talk', '2025-10-15', '17:33'),
    (3, 'Justice Talk', '2025-01-09', '17:42'),
    (3, 'Criminal Talk 2', '2025-04-28', '14:03'),
    (2, 'Software Talk', '2025-10-05', '13:35'),
    (3, 'Criminal Talk 3', '2025-09-15', '15:22'),
    (2, 'Software Talk 2', '2025-10-06', '9:13'),
    (2, 'Software Talk 3', '2025-12-04', '12:00'),
    (3, 'Criminal Talk 4', '2025-09-09', '12:05'),
    (4, 'Graphics Talk', '2025-03-08', '9:27'),
    (1, 'Electrical Talk 2', '2025-07-01', '10:49'),
    (4, 'Graphics Talk 2', '2025-07-11', '16:52');

-- INSERT INTO TABLE appointments 
INSERT INTO
    appointments (
        staff_id,
        student_id,
        appointment_time,
        appointment_date,
        appointment_type
    )
VALUES
    (
        19,
        23,
        '14:07',
        '2025-03-11',
        'Well-being support'
    ),
    (8, 27, '17:04', '2025-10-01', 'Academic Tutor'),
    (19, 4, '15:15', '2025-02-18', 'Academic Tutor'),
    (
        23,
        17,
        '13:57',
        '2025-07-14',
        'On-line career support'
    ),
    (5, 6, '13:39', '2025-10-29', 'Placement support'),
    (22, 24, '16:06', '2025-06-16', 'Academic Tutor'),
    (
        22,
        12,
        '17:40',
        '2025-10-21',
        'Placement support'
    ),
    (4, 22, '10:38', '2025-08-18', 'Career support'),
    (4, 22, '15:05', '2025-11-06', 'Career support'),
    (2, 11, '11:11', '2025-10-26', 'Academic Tutor'),
    (
        14,
        25,
        '11:18',
        '2025-07-19',
        'On-line career support'
    ),
    (27, 5, '14:53', '2025-12-13', 'Placement support');

--INSERT INTO staff_roles 
INSERT INTO
    staff_roles (staff_role_name, staff_role_support)
VALUES
    ('Head of Department', FALSE),
    ('Lecturer', FALSE),
    ('Module Coordinator', FALSE),
    ('Assistant Lecturer', FALSE),
    ('Placement Advisor', TRUE), --5
    ('Career Services Officer', TRUE), --6
    ('IT Support', TRUE), --7
    ('Therapist', TRUE);

--8
INSERT INTO
    staff_members_staff_roles (staff_id, staff_role_id)
VALUES
    --head of hepartments branch 1 
    --id 1 to 24
    (1, 1),
    (7, 1),
    (13, 1),
    (19, 1),
    ---Leructurer dep1
    (1, 2),
    (2, 2),
    (3, 2),
    (4, 2),
    (5, 2),
    (6, 2),
    --Module Coordinator dep1 
    (4, 3),
    (2, 3),
    (4, 5),
    --assistance
    (2, 4),
    (3, 4),
    (5, 4),
    (6, 4),
    ---Leructurer dep2 from 7 to 12 
    (7, 2),
    (8, 2),
    (9, 2),
    (10, 2),
    (11, 2),
    (12, 2),
    (12, 6),
    --Module Coordinator dep2
    (9, 3),
    (11, 3),
    --assistance
    (8, 4),
    (10, 4),
    (11, 4),
    (12, 4),
    ---Leructurer dep3 from 13 to 18
    (13, 2),
    (14, 2),
    (15, 2),
    (16, 2),
    (17, 2),
    (18, 2),
    (18, 7),
    --Module Coordinator dep3
    (16, 3),
    (14, 3),
    --assistance
    (16, 4),
    (14, 4),
    (15, 4),
    (17, 4),
    (17, 8),
    ---Leructurer dep4 from 19 to 24
    (19, 2),
    (20, 2),
    (21, 2),
    (22, 2),
    (23, 2),
    (24, 2),
    --Module Coordinator dep4
    (19, 3),
    (23, 3),
    --assistance
    (21, 4),
    (20, 4),
    (24, 4),
    (19, 4),
    --dep 2 start 
    --head of hepartments branch 2
    --id 1 to 24
    (25, 1),
    (31, 1),
    (37, 1),
    (43, 1),
    ---Leructurer dep1
    (25, 2),
    (26, 2),
    (27, 2),
    (28, 2),
    (29, 2),
    (30, 2),
    (30, 5),
    --Module Coordinator dep1 
    (26, 3),
    (28, 3),
    --assistance
    (27, 4),
    (30, 4),
    (29, 4),
    (29, 6),
    ---Leructurer dep2 from 31-36
    (31, 2),
    (32, 2),
    (33, 2),
    (34, 2),
    (35, 2),
    (36, 2),
    (36, 7),
    --Module Coordinator dep2
    (32, 3),
    (36, 3),
    --assistance
    (32, 4),
    (33, 4),
    (34, 4),
    ---Leructurer dep3 from 37 tgo 42
    (37, 2),
    (38, 2),
    (39, 2),
    (40, 2),
    (41, 2),
    (42, 2),
    (42, 7),
    --Module Coordinator dep3
    (38, 3),
    (41, 3),
    --assistance
    (38, 4),
    (39, 4),
    (40, 4),
    ---Leructurer dep4 from 43 to 48
    (43, 2),
    (44, 2),
    (45, 2),
    (46, 2),
    (47, 2),
    (48, 2),
    --Module Coordinator dep4
    (44, 3),
    (48, 3),
    --assistance
    (44, 4),
    (46, 4),
    (48, 4),
    (48, 8);

-- INSERT INTO teams 
INSERT INTO
    teams (team_name)
VALUES
    ('Red Warriors'),
    ('Blue Titans'),
    ('Green Giants'),
    ('Golden Hawks'),
    ('Black Panthers');

-- INSERT INTO staff_teams 
INSERT INTO
    staff_teams (team_id, staff_id)
VALUES
    (3, 5),
    (3, 17),
    (2, 27),
    (4, 14),
    (5, 4),
    (5, 8),
    (4, 28),
    (2, 1),
    (5, 11),
    (1, 2),
    (3, 27),
    (4, 30),
    (4, 18),
    (4, 17),
    (1, 16),
    (5, 25),
    (4, 24),
    (3, 4),
    (1, 12),
    (5, 9),
    (5, 27),
    (5, 23),
    (3, 6),
    (3, 7),
    (4, 21),
    (4, 5),
    (5, 5),
    (4, 26);

--INSERT INTO teaching_sessions (256) 
INSERT INTO
    teaching_sessions (
        module_id,
        room_id,
        session_type_name,
        session_date,
        session_start_time,
        session_end_time
    )
VALUES
    (
        62,
        14,
        'Practical',
        '2025-11-12',
        '12:50',
        '17:48'
    ),
    (23, 24, 'drop-in', '2025-06-04', '13:22', '17:15'),
    (
        41,
        NULL,
        'On-line',
        '2025-02-26',
        '10:13',
        '17:06'
    ),
    (
        54,
        NULL,
        'On-line',
        '2025-03-09',
        '10:48',
        '16:45'
    ),
    (
        42,
        19,
        'Practical',
        '2025-05-21',
        '17:47',
        '16:35'
    ),
    (4, 12, 'Tutorial', '2025-06-01', '15:40', '16:34'),
    (7, 20, 'Tutorial', '2025-02-13', '9:27', '12:13'),
    (
        28,
        NULL,
        'On-line',
        '2025-06-20',
        '17:11',
        '9:52'
    ),
    (
        16,
        NULL,
        'On-line',
        '2025-04-18',
        '16:01',
        '9:57'
    ),
    (23, 30, 'drop-in', '2025-08-08', '17:57', '16:44'),
    (45, 18, 'drop-in', '2025-03-20', '12:55', '14:33'),
    (21, NULL, 'On-line', '2025-02-12', '9:48', '9:17'),
    (
        57,
        15,
        'Tutorial',
        '2025-02-28',
        '10:17',
        '15:11'
    ),
    (
        52,
        NULL,
        'On-line',
        '2025-10-30',
        '14:34',
        '13:52'
    ),
    (
        36,
        34,
        'Practical',
        '2025-03-30',
        '13:59',
        '11:22'
    ),
    (18, 3, 'Lecture', '2025-03-05', '17:38', '14:57'),
    (
        4,
        NULL,
        'On-line',
        '2025-10-12',
        '15:34',
        '10:08'
    ),
    (
        31,
        18,
        'Practical',
        '2025-12-25',
        '12:54',
        '17:18'
    ),
    (
        18,
        30,
        'Tutorial',
        '2025-06-14',
        '16:01',
        '16:40'
    ),
    (
        45,
        22,
        'Tutorial',
        '2025-04-01',
        '14:21',
        '12:20'
    ),
    (35, 7, 'drop-in', '2025-03-26', '14:16', '13:56'),
    (47, 8, 'Lecture', '2025-03-06', '14:19', '13:20'),
    (40, 10, 'drop-in', '2025-01-23', '14:08', '15:57'),
    (57, 29, 'Lecture', '2025-09-22', '16:13', '9:28'),
    (
        27,
        21,
        'Practical',
        '2025-06-30',
        '10:47',
        '15:07'
    ),
    (26, 8, 'Tutorial', '2025-04-03', '11:02', '15:17'),
    (51, 32, 'drop-in', '2025-01-19', '15:30', '12:11'),
    (
        65,
        15,
        'Practical',
        '2025-03-01',
        '16:44',
        '17:05'
    ),
    (
        61,
        23,
        'Tutorial',
        '2025-03-25',
        '12:44',
        '15:28'
    ),
    (
        14,
        27,
        'Tutorial',
        '2025-11-04',
        '17:11',
        '14:59'
    ),
    (4, 19, 'Tutorial', '2025-04-01', '17:48', '9:12'),
    (
        24,
        30,
        'Practical',
        '2025-01-04',
        '15:33',
        '12:05'
    ),
    (
        35,
        NULL,
        'On-line',
        '2025-11-14',
        '10:30',
        '15:18'
    ),
    (
        28,
        NULL,
        'On-line',
        '2025-11-03',
        '13:35',
        '10:14'
    ),
    (34, 23, 'drop-in', '2025-05-21', '9:03', '11:34'),
    (24, 35, 'drop-in', '2025-04-17', '15:58', '12:51'),
    (
        44,
        NULL,
        'On-line',
        '2025-08-23',
        '10:18',
        '12:42'
    ),
    (
        43,
        32,
        'Practical',
        '2025-12-03',
        '15:36',
        '9:43'
    ),
    (28, 33, 'drop-in', '2025-04-10', '16:24', '10:32'),
    (
        41,
        36,
        'Practical',
        '2025-02-27',
        '10:35',
        '15:52'
    ),
    (
        23,
        30,
        'Practical',
        '2025-04-26',
        '12:23',
        '12:44'
    ),
    (26, 34, 'Tutorial', '2025-01-31', '10:55', '9:10'),
    (
        16,
        27,
        'Practical',
        '2025-04-18',
        '17:28',
        '11:12'
    ),
    (33, 6, 'Lecture', '2025-04-28', '12:12', '11:36'),
    (
        40,
        NULL,
        'On-line',
        '2025-12-06',
        '10:40',
        '10:02'
    ),
    (63, 24, 'drop-in', '2025-10-17', '16:24', '15:33'),
    (5, 22, 'drop-in', '2025-01-07', '11:15', '15:51'),
    (59, 20, 'Tutorial', '2025-01-27', '13:38', '9:17'),
    (52, 25, 'Lecture', '2025-04-29', '17:00', '15:28'),
    (
        59,
        38,
        'Tutorial',
        '2025-12-04',
        '10:41',
        '16:09'
    ),
    (54, 11, 'drop-in', '2025-03-09', '13:21', '10:14'),
    (35, 6, 'Tutorial', '2025-08-26', '16:38', '11:29'),
    (
        57,
        20,
        'Tutorial',
        '2025-05-02',
        '13:58',
        '17:10'
    ),
    (58, 31, 'Lecture', '2025-01-15', '15:40', '9:39'),
    (50, 2, 'Tutorial', '2025-04-13', '10:25', '12:39'),
    (60, 27, 'Lecture', '2025-07-05', '16:01', '10:44'),
    (42, 36, 'drop-in', '2025-04-24', '16:05', '13:12'),
    (
        45,
        NULL,
        'On-line',
        '2025-11-15',
        '11:29',
        '14:01'
    ),
    (62, 19, 'Lecture', '2025-10-09', '12:36', '13:54'),
    (56, 14, 'drop-in', '2025-03-14', '15:42', '14:36'),
    (12, 23, 'Lecture', '2025-11-03', '9:54', '14:00'),
    (
        49,
        38,
        'Tutorial',
        '2025-07-25',
        '13:31',
        '13:04'
    ),
    (32, 21, 'Lecture', '2025-03-01', '9:11', '16:38'),
    (32, 29, 'Lecture', '2025-02-01', '11:57', '14:44'),
    (55, 10, 'Lecture', '2025-02-02', '17:28', '17:51'),
    (57, 32, 'Lecture', '2025-08-07', '16:48', '9:52'),
    (
        44,
        19,
        'Tutorial',
        '2025-04-10',
        '14:32',
        '14:37'
    ),
    (
        64,
        NULL,
        'On-line',
        '2025-08-07',
        '9:55',
        '16:43'
    ),
    (22, 5, 'Lecture', '2025-01-08', '11:03', '9:25'),
    (
        17,
        NULL,
        'On-line',
        '2025-07-04',
        '16:33',
        '10:46'
    ),
    (4, 18, 'drop-in', '2025-12-09', '13:43', '12:22'),
    (23, 37, 'drop-in', '2025-03-20', '10:56', '14:16'),
    (
        6,
        NULL,
        'On-line',
        '2025-11-06',
        '11:48',
        '16:40'
    ),
    (36, 28, 'Lecture', '2025-06-03', '17:17', '9:57'),
    (45, 25, 'drop-in', '2025-04-19', '13:37', '14:12'),
    (
        10,
        NULL,
        'On-line',
        '2025-03-14',
        '14:50',
        '15:28'
    ),
    (
        41,
        NULL,
        'On-line',
        '2025-09-06',
        '9:27',
        '11:52'
    ),
    (
        51,
        NULL,
        'On-line',
        '2025-04-03',
        '14:28',
        '17:44'
    ),
    (4, 6, 'drop-in', '2025-08-01', '15:55', '16:23'),
    (
        27,
        6,
        'Practical',
        '2025-01-03',
        '10:06',
        '12:35'
    ),
    (
        32,
        NULL,
        'On-line',
        '2025-09-01',
        '11:25',
        '16:43'
    ),
    (
        62,
        36,
        'Practical',
        '2025-08-12',
        '14:21',
        '15:24'
    ),
    (
        59,
        27,
        'Practical',
        '2025-09-28',
        '15:39',
        '13:52'
    ),
    (
        35,
        NULL,
        'On-line',
        '2025-12-15',
        '9:49',
        '16:40'
    ),
    (
        29,
        26,
        'Practical',
        '2025-10-13',
        '15:20',
        '13:39'
    ),
    (55, 28, 'Lecture', '2025-04-08', '16:49', '14:51'),
    (3, 2, 'Practical', '2025-02-13', '12:54', '17:27'),
    (54, 6, 'Tutorial', '2025-06-02', '12:14', '12:43'),
    (31, 8, 'Lecture', '2025-06-02', '14:00', '13:50'),
    (
        58,
        NULL,
        'On-line',
        '2025-02-10',
        '10:04',
        '13:45'
    ),
    (
        20,
        37,
        'Tutorial',
        '2025-07-01',
        '11:29',
        '15:26'
    ),
    (7, 18, 'Tutorial', '2025-11-28', '11:01', '12:23'),
    (8, 34, 'Lecture', '2025-03-19', '14:38', '12:27'),
    (
        32,
        21,
        'Tutorial',
        '2025-07-09',
        '16:01',
        '10:12'
    ),
    (
        46,
        25,
        'Practical',
        '2025-09-14',
        '10:30',
        '12:57'
    ),
    (
        39,
        NULL,
        'On-line',
        '2025-05-13',
        '11:15',
        '9:14'
    ),
    (41, 6, 'drop-in', '2025-05-19', '9:40', '12:44'),
    (
        13,
        28,
        'Practical',
        '2025-07-22',
        '10:14',
        '11:28'
    ),
    (
        54,
        25,
        'Practical',
        '2025-06-23',
        '9:26',
        '13:25'
    ),
    (3, 15, 'drop-in', '2025-05-23', '17:31', '14:09'),
    (60, 32, 'drop-in', '2025-08-22', '14:39', '15:43'),
    (35, 19, 'Lecture', '2025-05-30', '10:25', '15:22'),
    (43, 4, 'drop-in', '2025-11-21', '9:13', '11:40'),
    (
        2,
        29,
        'Practical',
        '2025-01-30',
        '13:30',
        '17:46'
    ),
    (
        16,
        25,
        'Tutorial',
        '2025-07-29',
        '14:38',
        '15:44'
    ),
    (21, 36, 'drop-in', '2025-08-19', '15:14', '9:33'),
    (
        33,
        9,
        'Practical',
        '2025-07-30',
        '15:19',
        '12:43'
    ),
    (43, 36, 'Lecture', '2025-05-27', '9:13', '13:44'),
    (
        33,
        16,
        'Tutorial',
        '2025-03-18',
        '16:34',
        '17:27'
    ),
    (
        10,
        23,
        'Practical',
        '2025-10-31',
        '10:58',
        '17:37'
    ),
    (59, 2, 'Lecture', '2025-08-19', '9:20', '11:55'),
    (
        22,
        37,
        'Tutorial',
        '2025-04-09',
        '15:09',
        '14:47'
    ),
    (
        23,
        15,
        'Practical',
        '2025-01-19',
        '9:51',
        '14:51'
    ),
    (
        23,
        NULL,
        'On-line',
        '2025-03-08',
        '9:12',
        '17:52'
    ),
    (3, 6, 'Tutorial', '2025-08-03', '14:11', '11:49'),
    (
        63,
        11,
        'Practical',
        '2025-04-30',
        '13:02',
        '16:14'
    ),
    (
        14,
        NULL,
        'On-line',
        '2025-06-11',
        '9:27',
        '14:42'
    ),
    (
        14,
        NULL,
        'On-line',
        '2025-04-18',
        '9:53',
        '11:30'
    ),
    (48, 3, 'drop-in', '2025-04-18', '16:02', '10:49'),
    (
        55,
        NULL,
        'On-line',
        '2025-01-26',
        '12:29',
        '15:06'
    ),
    (
        19,
        30,
        'Tutorial',
        '2025-03-14',
        '12:05',
        '12:40'
    ),
    (58, 7, 'Tutorial', '2025-04-22', '16:55', '12:04'),
    (45, 2, 'drop-in', '2025-12-11', '17:15', '9:34'),
    (1, 13, 'Tutorial', '2025-05-27', '13:21', '11:44'),
    (
        30,
        NULL,
        'On-line',
        '2025-05-16',
        '16:16',
        '10:37'
    ),
    (18, 6, 'Tutorial', '2025-11-22', '14:18', '11:15'),
    (26, 30, 'drop-in', '2025-09-02', '15:51', '17:13'),
    (
        14,
        27,
        'Practical',
        '2025-04-22',
        '12:17',
        '16:03'
    ),
    (34, 10, 'Lecture', '2025-02-28', '12:04', '9:18'),
    (29, 15, 'Lecture', '2025-07-25', '11:12', '11:22'),
    (24, 9, 'Lecture', '2025-03-24', '14:47', '14:17'),
    (
        13,
        25,
        'Tutorial',
        '2025-11-22',
        '16:36',
        '14:54'
    ),
    (12, NULL, 'On-line', '2025-03-16', '9:52', '9:07'),
    (
        56,
        11,
        'Tutorial',
        '2025-05-11',
        '11:46',
        '10:23'
    ),
    (30, 1, 'drop-in', '2025-11-07', '13:04', '13:19'),
    (43, 39, 'drop-in', '2025-06-09', '15:30', '16:01'),
    (62, 12, 'drop-in', '2025-10-04', '13:22', '12:50'),
    (35, 7, 'Tutorial', '2025-02-24', '15:16', '10:46'),
    (6, 15, 'Practical', '2025-01-12', '9:21', '11:00'),
    (
        51,
        28,
        'Practical',
        '2025-03-14',
        '17:32',
        '9:29'
    ),
    (
        53,
        16,
        'Practical',
        '2025-05-11',
        '11:41',
        '15:49'
    ),
    (49, 14, 'drop-in', '2025-03-08', '13:20', '17:55'),
    (55, 40, 'Lecture', '2025-08-05', '9:38', '10:02'),
    (60, 9, 'Lecture', '2025-04-11', '9:02', '12:07'),
    (44, 8, 'drop-in', '2025-01-23', '16:07', '9:39'),
    (55, 39, 'drop-in', '2025-11-13', '9:06', '17:19'),
    (
        63,
        30,
        'Tutorial',
        '2025-11-11',
        '12:54',
        '13:11'
    ),
    (51, 7, 'Lecture', '2025-02-10', '17:23', '15:09'),
    (29, 39, 'Lecture', '2025-01-30', '9:27', '12:36'),
    (55, 38, 'drop-in', '2025-02-09', '13:06', '11:08'),
    (
        41,
        NULL,
        'On-line',
        '2025-02-25',
        '11:14',
        '10:28'
    ),
    (7, 26, 'Tutorial', '2025-09-12', '9:52', '12:51'),
    (52, 35, 'Tutorial', '2025-10-04', '17:15', '9:04'),
    (
        62,
        7,
        'Practical',
        '2025-01-03',
        '14:58',
        '10:06'
    ),
    (6, 40, 'Tutorial', '2025-01-15', '15:38', '15:15'),
    (6, 29, 'drop-in', '2025-06-20', '12:07', '14:15'),
    (58, 39, 'Lecture', '2025-01-29', '12:36', '14:14'),
    (14, 2, 'drop-in', '2025-01-04', '12:43', '16:41'),
    (
        23,
        2,
        'Practical',
        '2025-05-24',
        '16:35',
        '17:38'
    ),
    (1, 26, 'drop-in', '2025-09-19', '16:53', '14:09'),
    (37, 37, 'Lecture', '2025-01-02', '10:22', '16:43'),
    (50, 8, 'Lecture', '2025-12-10', '12:21', '9:33'),
    (1, 37, 'Lecture', '2025-12-22', '10:33', '16:10'),
    (
        55,
        21,
        'Practical',
        '2025-09-16',
        '13:47',
        '17:04'
    ),
    (13, 29, 'drop-in', '2025-11-18', '10:55', '12:20'),
    (1, 33, 'drop-in', '2025-08-17', '12:15', '14:29'),
    (64, 30, 'Lecture', '2025-03-12', '17:04', '17:01'),
    (
        26,
        NULL,
        'On-line',
        '2025-07-04',
        '9:46',
        '12:13'
    ),
    (
        45,
        NULL,
        'On-line',
        '2025-08-13',
        '16:33',
        '16:25'
    ),
    (39, 40, 'Tutorial', '2025-02-15', '9:38', '18:00'),
    (
        37,
        17,
        'Tutorial',
        '2025-03-30',
        '17:40',
        '10:33'
    ),
    (63, 22, 'drop-in', '2025-04-21', '10:16', '17:39'),
    (11, 4, 'Lecture', '2025-05-29', '14:21', '13:31'),
    (8, 10, 'Lecture', '2025-05-26', '12:42', '12:48'),
    (8, 8, 'drop-in', '2025-04-13', '9:57', '12:47'),
    (7, 5, 'Lecture', '2025-04-05', '10:18', '14:38'),
    (
        2,
        NULL,
        'On-line',
        '2025-09-08',
        '14:40',
        '12:51'
    ),
    (
        47,
        NULL,
        'On-line',
        '2025-03-14',
        '16:26',
        '11:28'
    ),
    (58, 11, 'Lecture', '2025-02-10', '13:14', '14:09'),
    (39, 37, 'Lecture', '2025-03-26', '10:44', '9:48'),
    (30, 19, 'drop-in', '2025-07-05', '13:23', '12:18'),
    (
        36,
        33,
        'Practical',
        '2025-05-08',
        '16:03',
        '11:10'
    ),
    (49, 12, 'drop-in', '2025-03-08', '11:30', '14:30'),
    (
        47,
        20,
        'Practical',
        '2025-07-14',
        '17:34',
        '9:55'
    ),
    (
        22,
        35,
        'Practical',
        '2025-01-01',
        '9:46',
        '15:47'
    ),
    (
        42,
        NULL,
        'On-line',
        '2025-03-08',
        '13:09',
        '14:58'
    ),
    (46, 24, 'drop-in', '2025-08-26', '16:56', '16:19'),
    (18, 18, 'Practical', '2025-08-24', '9:16', '9:17'),
    (17, 25, 'Tutorial', '2025-09-30', '9:54', '13:14'),
    (
        41,
        1,
        'Practical',
        '2025-01-17',
        '13:39',
        '17:08'
    ),
    (29, 31, 'Lecture', '2025-06-13', '13:45', '14:52'),
    (11, 20, 'drop-in', '2025-06-26', '14:16', '11:49'),
    (35, 5, 'Tutorial', '2025-05-01', '9:36', '17:09'),
    (43, 4, 'Tutorial', '2025-01-18', '9:51', '13:47'),
    (46, 3, 'drop-in', '2025-07-29', '9:50', '10:37'),
    (
        23,
        36,
        'Tutorial',
        '2025-03-14',
        '11:22',
        '12:29'
    ),
    (28, 27, 'Lecture', '2025-05-26', '11:12', '15:01'),
    (
        28,
        37,
        'Tutorial',
        '2025-01-26',
        '16:07',
        '11:50'
    ),
    (30, 22, 'Lecture', '2025-03-22', '10:50', '17:21'),
    (
        49,
        NULL,
        'On-line',
        '2025-12-26',
        '11:30',
        '16:58'
    ),
    (
        20,
        37,
        'Practical',
        '2025-04-05',
        '13:06',
        '11:47'
    ),
    (58, 22, 'drop-in', '2025-11-08', '9:21', '15:12'),
    (
        50,
        NULL,
        'On-line',
        '2025-07-21',
        '14:30',
        '11:56'
    ),
    (12, 8, 'Lecture', '2025-01-16', '17:41', '17:56'),
    (
        6,
        26,
        'Practical',
        '2025-07-08',
        '15:09',
        '16:38'
    ),
    (
        57,
        NULL,
        'On-line',
        '2025-03-30',
        '11:03',
        '17:00'
    ),
    (6, 36, 'Tutorial', '2025-02-22', '13:44', '9:28'),
    (
        24,
        NULL,
        'On-line',
        '2025-07-12',
        '9:57',
        '17:04'
    ),
    (
        64,
        2,
        'Practical',
        '2025-02-03',
        '10:05',
        '16:46'
    ),
    (
        44,
        12,
        'Practical',
        '2025-01-27',
        '12:31',
        '10:06'
    ),
    (30, 17, 'drop-in', '2025-04-26', '15:47', '17:29'),
    (
        44,
        15,
        'Tutorial',
        '2025-07-05',
        '10:51',
        '16:14'
    ),
    (50, 9, 'Tutorial', '2025-05-18', '13:09', '10:09'),
    (
        5,
        38,
        'Practical',
        '2025-03-18',
        '12:51',
        '12:14'
    ),
    (51, 32, 'Lecture', '2025-08-05', '17:08', '14:44'),
    (
        13,
        NULL,
        'On-line',
        '2025-01-05',
        '14:17',
        '12:24'
    ),
    (9, 2, 'Tutorial', '2025-09-19', '15:29', '16:42'),
    (9, 6, 'Lecture', '2025-03-18', '16:19', '15:54'),
    (
        31,
        36,
        'Practical',
        '2025-10-14',
        '11:35',
        '16:04'
    ),
    (
        11,
        15,
        'Tutorial',
        '2025-03-10',
        '10:49',
        '10:32'
    ),
    (
        4,
        25,
        'Practical',
        '2025-05-10',
        '14:03',
        '11:41'
    ),
    (
        29,
        17,
        'Practical',
        '2025-06-19',
        '17:36',
        '14:58'
    ),
    (23, 19, 'Lecture', '2025-05-05', '10:26', '17:24'),
    (5, 2, 'Tutorial', '2025-01-23', '9:24', '9:07'),
    (
        64,
        NULL,
        'On-line',
        '2025-04-04',
        '9:52',
        '12:25'
    ),
    (
        25,
        NULL,
        'On-line',
        '2025-01-24',
        '9:44',
        '11:10'
    ),
    (
        60,
        NULL,
        'On-line',
        '2025-02-22',
        '16:42',
        '17:00'
    ),
    (
        24,
        NULL,
        'On-line',
        '2025-10-04',
        '12:26',
        '14:37'
    ),
    (
        39,
        NULL,
        'On-line',
        '2025-04-23',
        '17:27',
        '17:56'
    ),
    (18, 22, 'Tutorial', '2025-11-06', '11:53', '9:37'),
    (
        12,
        3,
        'Practical',
        '2025-03-18',
        '12:07',
        '11:55'
    ),
    (54, 32, 'drop-in', '2025-01-16', '11:26', '9:48'),
    (
        15,
        NULL,
        'On-line',
        '2025-01-19',
        '13:33',
        '13:36'
    ),
    (45, 7, 'drop-in', '2025-04-17', '11:06', '9:45'),
    (
        8,
        NULL,
        'On-line',
        '2025-07-30',
        '13:14',
        '14:24'
    ),
    (
        15,
        15,
        'Practical',
        '2025-01-11',
        '15:10',
        '10:54'
    ),
    (42, 30, 'drop-in', '2025-04-10', '16:44', '16:13'),
    (2, 1, 'Practical', '2025-01-08', '11:20', '16:14'),
    (
        54,
        11,
        'Practical',
        '2025-06-06',
        '15:55',
        '11:46'
    ),
    (
        3,
        NULL,
        'On-line',
        '2025-03-09',
        '15:23',
        '10:26'
    ),
    (18, 23, 'drop-in', '2025-05-09', '15:23', '15:08'),
    (
        28,
        16,
        'Practical',
        '2025-03-09',
        '16:41',
        '10:53'
    ),
    (26, 3, 'drop-in', '2025-01-30', '15:02', '11:23'),
    (
        19,
        NULL,
        'On-line',
        '2025-09-30',
        '16:16',
        '10:29'
    ),
    (
        10,
        5,
        'Practical',
        '2025-03-11',
        '14:03',
        '16:49'
    ),
    (35, 24, 'drop-in', '2025-12-31', '10:56', '11:01'),
    (
        29,
        NULL,
        'On-line',
        '2025-03-11',
        '16:05',
        '9:47'
    ),
    (23, 39, 'drop-in', '2025-06-13', '17:18', '10:29'),
    (46, 18, 'drop-in', '2025-10-29', '17:36', '9:54'),
    (
        51,
        12,
        'Tutorial',
        '2025-03-10',
        '16:10',
        '14:06'
    ),
    (1, 2, 'Tutorial', '2025-05-31', '9:05', '15:21'),
    (35, 7, 'Practical', '2025-09-14', '16:35', '9:02'),
    (
        42,
        NULL,
        'On-line',
        '2025-02-20',
        '16:46',
        '10:40'
    ),
    (64, 29, 'drop-in', '2025-03-15', '13:06', '9:32'),
    (47, 18, 'drop-in', '2025-01-09', '9:09', '17:03'),
    (59, 38, 'Lecture', '2025-01-10', '12:41', '15:46');

-- Automatic INSERT for STUDENTS_TEACHING (SESSIONS) 
-- INSERT INTO student_teaching_sessions (student_id, session_id, student_attended)
CREATE
OR REPLACE FUNCTION INSERT_STUDENT_ATTENDANCE () RETURNS VOID AS $$
DECLARE
    attendance_record RECORD;
BEGIN
    -- Iterate through the result of the SELECT query
    FOR attendance_record IN
        SELECT 
            s.student_id, 
            ts.session_id, 
            CASE 
                WHEN RANDOM() <= 0.05 THEN FALSE -- Approximately 5% not attended
                ELSE TRUE -- Rest attended
            END AS attended
        FROM 
            students s
        JOIN 
            module_course cm ON s.course_id = cm.course_id
        JOIN 
            teaching_sessions ts ON cm.module_id = ts.module_id
        JOIN 
            modules m ON ts.module_id = m.module_id AND s.student_academic_level = m.module_level
        WHERE 
            s.course_id IN (
                SELECT 
                    c.course_id 
                FROM 
                    courses c
                JOIN 
                    module_course cm ON c.course_id = cm.course_id
                WHERE 
                    cm.module_id = ts.module_id
            )
    LOOP
        -- Insert the record into the target table
        INSERT INTO student_teaching_sessions (student_id, session_id, student_attended)
        VALUES (attendance_record.student_id, attendance_record.session_id, attendance_record.attended);
    END LOOP;
END;
$$ LANGUAGE plpgsql;

SELECT
    INSERT_STUDENT_ATTENDANCE ();

-- Function for automatics insert in staff_teaching sessions 
--INSERT INTO staff_teaching_sessions
CREATE
OR REPLACE FUNCTION INSERT_STAFF_TEACHING_SESSIONS () RETURNS VOID AS $$ 
BEGIN
INSERT INTO
  staff_teaching_sessions (staff_id, session_id)
SELECT
  sm.staff_id,
  ts.session_id
FROM
  staff_module AS sm
  JOIN teaching_sessions AS ts ON sm.module_id = ts.module_id
WHERE EXISTS (
    SELECT
      1
    FROM
      modules AS m
    WHERE
      m.module_id = sm.module_id
      AND m.module_id IN (
        SELECT
          module_id
        FROM
          teaching_sessions
      )
  );
END;
$$ LANGUAGE plpgsql;

SELECT
    INSERT_STAFF_TEACHING_SESSIONS ();

-- INSERT INTO extenuating_circumstances (5)
INSERT INTO
    extenuating_circumstances (student_id, ec_date, reason, module_ids)
VALUES
    (
        108,
        '2025-10-16',
        'Medical emergency',
        ARRAY[46, 42, 47, 49]
    ),
    (
        109,
        '2025-10-17',
        'Family bereavement',
        ARRAY[42]
    ),
    (110, '2025-10-18', 'Car accident', ARRAY[42, 65]),
    (
        111,
        '2025-10-18',
        'Family bereavement',
        ARRAY[42, 65]
    ),
    (
        112,
        '2025-10-18',
        'Medical emergency',
        ARRAY[42, 65]
    );

/*===============
QUERIES 
=================*/
/*===== Query 1 
This query shows the students module performance
=======*/
CREATE OR REPLACE VIEW module_performance AS
SELECT
    b.branch_name AS "Branch",
    a.student_id AS "Student ID",
    CONCAT_WS(' ', s.student_first_name, s.student_last_name) AS "Student name",
    s.student_academic_level AS "Student level",
    c.course_name AS "Course",
    m.module_name AS "Module",
    m.module_level AS "Module level",
    ROUND(
        SUM(a.assessment_mark * (a.assessment_weight / 100)),
        2
    ) AS "Module final mark"
FROM
    assessments AS a
    INNER JOIN students AS s ON a.student_id = s.student_id
    INNER JOIN courses AS c ON s.course_id = c.course_id
    INNER JOIN modules AS m ON a.module_id = m.module_id
    INNER JOIN branches AS b ON s.branch_id = b.branch_id
WHERE
    s.student_academic_level = m.module_level
GROUP BY
    s.student_first_name,
    b.branch_name,
    s.student_last_name,
    s.student_academic_level,
    c.course_name,
    m.module_name,
    m.module_level,
    a.student_id
ORDER BY
    b.branch_name,
    s.student_academic_level;

SELECT
    *
FROM
    module_performance;

/*======Q2 
This query show the teachers schedule for the specific period of time,
as this query can be run frequently 
========*/
SELECT
    CONCAT_WS(' ', sm.staff_first_name, sm.staff_surname) AS "Teacher Name",
    ts.session_date AS "Session Date",
    ts.session_start_time AS "Start Time",
    ts.session_end_time AS "End Time",
    ts.session_type_name AS "Session Type",
    m.module_name AS "Module Name",
    r.room_number AS "Room Number",
    r.room_type AS "Room Type",
    b.branch_name AS "Branch"
FROM
    staff_teaching_sessions sts
    INNER JOIN staff_members sm ON sts.staff_id = sm.staff_id
    INNER JOIN teaching_sessions ts ON sts.session_id = ts.session_id
    INNER JOIN modules m ON ts.module_id = m.module_id
    INNER JOIN rooms r ON ts.room_id = r.room_id
    INNER JOIN buildings bld ON r.building_id = bld.building_id
    INNER JOIN branches b ON bld.branch_id = b.branch_id
WHERE
    ts.session_date BETWEEN '2025-01-01' AND '2025-01-07'
ORDER BY
    "Teacher Name",
    "Session Date",
    "Start Time";

/*=======Q3
This query shows the average,
minimum and maximum module marks, retrieving data for both branches 
to monitor performance, as it's important to track module efficiency, and 
to compare the branches performance to catch the early problems.
========*/
SELECT
    "Branch",
    "Module",
    "Module level",
    ROUND(AVG("Module final mark"), 2) AS "Average Module Mark",
    MIN("Module final mark") AS "Lowest Module Mark",
    MAX("Module final mark") AS "Highest Module Mark"
FROM
    module_performance
WHERE
    "Branch" IN ('Branch 1', 'Branch 2')
GROUP BY
    "Branch",
    "Module",
    "Module level"
ORDER BY
    "Module";

/*========= Q4
Monitoring the attendence 
============*/
SELECT
    s.student_id AS "Student ID",
    s.student_first_name AS "Student",
    c.course_name AS "Course",
    s.student_academic_level AS "Level",
    subquery.total_sessions AS "Total Sessions",
    subquery.attended_sessions AS "Attended Sessions",
    ROUND(subquery."Attendance (%)", 2) AS "Attendance (%)"
FROM
    students s
    INNER JOIN (
        SELECT
            sts.student_id,
            COUNT(sts.session_id) AS total_sessions,
            SUM(
                CASE
                    WHEN sts.student_attended THEN 1
                    ELSE 0
                END
            ) AS attended_sessions,
            AVG(
                CASE
                    WHEN sts.student_attended THEN 1.0
                    ELSE 0.0
                END
            ) * 100 AS "Attendance (%)"
        FROM
            student_teaching_sessions sts
        GROUP BY
            sts.student_id
    ) subquery ON s.student_id = subquery.student_id
    INNER JOIN courses c ON s.course_id = c.course_id
ORDER BY
    s.student_id,
    "Attendance (%)" DESC;

/*========= Q5 
CREATE a query to view rooms with a small number of students but a large capacity
============*/
SELECT
    rooms.room_number AS "Room Number",
    rooms.room_capacity AS "Room Capacity",
    teaching_sessions.session_date AS "Session Date",
    teaching_sessions.session_type_name AS "Session Type Name",
    COUNT(student_teaching_sessions.student_id) AS "Count of Students",
    (
        (
            COUNT(student_teaching_sessions.student_id) * 1.0 / rooms.room_capacity
        ) * 100
    ) AS "Percentage Capacity Used"
FROM
    student_teaching_sessions
    INNER JOIN teaching_sessions ON student_teaching_sessions.session_id = teaching_sessions.session_id
    INNER JOIN rooms ON teaching_sessions.room_id = rooms.room_id
GROUP BY
    rooms.room_id,
    rooms.room_number,
    rooms.room_capacity,
    teaching_sessions.session_date,
    teaching_sessions.session_type_name
ORDER BY
    "Percentage Capacity Used" ASC;

/*
SECURITY ASPECTS

CREATE ROLE admin
WITH
CREATEROLE LOGIN PASSWORD 'Hlxe6jSjhMZ9zYzG';

CREATE ROLE head_of_department
WITH
LOGIN PASSWORD 'wHiG6XtV5vbK55KV';

CREATE ROLE lecturer
WITH
LOGIN PASSWORD 'qN2nrLN6Z9Yr2fAT';

CREATE ROLE module_coordinator
WITH
LOGIN PASSWORD '9C4LFWFdoqJcrp2f';

CREATE ROLE assisstant_lecturer
WITH
LOGIN PASSWORD 'yzVRVl22HAFtFjBZ';

CREATE ROLE placement_advisor
WITH
LOGIN PASSWORD 'DEL6dgpfn9eoRD7N';

CREATE ROLE careers_services_officer
WITH
LOGIN PASSWORD 'GbfQm3QW5wDXj2Hp';

CREATE ROLE it_support
WITH
LOGIN PASSWORD 'n7ZATnvh5DQWe3vf';

CREATE ROLE therapist
WITH
LOGIN PASSWORD '3LmEjFYCx5Bd3gVZ';

CREATE ROLE student
WITH
LOGIN PASSWORD '8PspeGqY8ogo9AxY';

-- To reset student passwords
GRANT
SELECT, UPDATE ON students TO it_support;

-- Allow student to see their module performance
GRANT
SELECT ON module_performance TO student; 

-- Allow student to see their module marks 
GRANT
SELECT ON average_min_max_module_marks TO student; 

-- Allow head_of_department, lecturer, module_coordinator, assisstant_lecturer to view teacher schedules
GRANT
SELECT ON teachers_schedule TO lecturer, module_coordinator, assisstant_lecturer; 

-- Allow student, head_of_department, lecturer, module_coordinator, assisstant_lecturer to view student attendance
GRANT
SELECT ON student_attendance TO student, lecturer, module_coordinator, assisstant_lecturer; 

-- Allow head_of_department, lecturer, module_coordinator, assisstant_lecturer to view rooms
-- with a small number of students but a large capacity
GRANT
SELECT ON rooms_large_capacity_small_number_students TO student, lecturer, module_coordinator, assisstant_lecturer; 
*/

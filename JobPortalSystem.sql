-- ## Job Portal System ##

-- 1. Jobs Table

CREATE TABLE Jobs (
    JobID NUMBER PRIMARY KEY,
    JobTitle VARCHAR2(100),
    CompanyName VARCHAR2(100),
    Location VARCHAR2(50),
    Salary NUMBER,
    RequiredSkills VARCHAR2(200),
    JobDescription VARCHAR2(500)
);

-- 2. Candidates Table

CREATE TABLE Candidates (
    CandidateID NUMBER PRIMARY KEY,
    Name VARCHAR2(100),
    Email VARCHAR2(100) UNIQUE,
    PhoneNumber VARCHAR2(15),
    Skills VARCHAR2(200),
    Experience NUMBER
);

-- 3. Applications Table

CREATE TABLE Applications (
    ApplicationID NUMBER PRIMARY KEY,
    JobID NUMBER REFERENCES Jobs(JobID),
    CandidateID NUMBER REFERENCES Candidates(CandidateID),
    ApplicationDate DATE DEFAULT SYSDATE,
    Status VARCHAR2(50) DEFAULT 'Pending'
);

-- 4. Notifications Table

CREATE TABLE Notifications (
    NotificationID NUMBER PRIMARY KEY,
    CandidateID NUMBER REFERENCES Candidates(CandidateID),
    Message VARCHAR2(200),
    NotificationDate DATE DEFAULT SYSDATE
);

-- 5. CandidateSkills Table

CREATE TABLE CandidateSkills (
    CandidateSkillID NUMBER PRIMARY KEY,
    CandidateID NUMBER REFERENCES Candidates(CandidateID),
    SkillID NUMBER
);

-- 6. JobSkills Table
CREATE TABLE JobSkills (
    JobSkillID NUMBER PRIMARY KEY,
    JobID NUMBER,
    SkillID NUMBER
);

-- ##Inserting values into Jobs table
INSERT INTO Jobs VALUES (1, 'Software Engineer', 'TechCorp', 'San Francisco', 120000, 'Java, SQL, Python', 'Develop and maintain software.');
INSERT INTO Jobs VALUES (2, 'Data Analyst', 'DataWorks', 'New York', 90000, 'SQL, Excel, Python', 'Analyze and visualize data.');
INSERT INTO Jobs VALUES (3, 'Network Administrator', 'NetSecure Inc.', 'Austin', 85000, 'Networking, Firewall, Linux', 'Maintain and secure network infrastructure.');
INSERT INTO Jobs VALUES (4, 'Web Developer', 'CreativeWeb', 'Los Angeles', 75000, 'HTML, CSS, JavaScript', 'Design and develop responsive websites.');
INSERT INTO Jobs VALUES (5, 'Machine Learning Engineer', 'AI Labs', 'Seattle', 130000, 'Python, TensorFlow, Machine Learning', 'Develop and deploy ML models.');
INSERT INTO Jobs VALUES (6, 'Cybersecurity Analyst', 'CyberGuard', 'Chicago', 95000, 'Security, Penetration Testing, Python', 'Analyze and protect systems from threats.');
INSERT INTO Jobs VALUES (7, 'Project Manager', 'BuildRight', 'Denver', 110000, 'Agile, MS Project, Leadership', 'Manage project timelines and deliverables.');
INSERT INTO Jobs VALUES (8, 'Database Administrator', 'DataSecure', 'Boston', 100000, 'SQL, Oracle, Backup', 'Maintain and optimize database systems.');
INSERT INTO Jobs VALUES (9, 'Cloud Architect', 'Cloudify', 'San Jose', 140000, 'AWS, Azure, Kubernetes', 'Design scalable cloud solutions.');
INSERT INTO Jobs VALUES (10, 'Mobile App Developer', 'AppVision', 'Atlanta', 80000, 'Kotlin, Swift, React Native', 'Develop cross-platform mobile apps.');


-- ##Inserting values into Candidates table
INSERT INTO Candidates VALUES (1, 'Alice Johnson', 'alice@example.com', '1234567890', 'Python, SQL', 3);
INSERT INTO Candidates VALUES (2, 'Bob Smith', 'bob@example.com', '0987654321', 'Java, SQL', 5);
INSERT INTO Candidates VALUES (3, 'Charlie Brown', 'charlie@example.com', '5678901234', 'Networking, Firewall', 4);
INSERT INTO Candidates VALUES (4, 'Diana Prince', 'diana@example.com', '6789012345', 'HTML, CSS, JavaScript', 2);
INSERT INTO Candidates VALUES (5, 'Ethan Hunt', 'ethan@example.com', '7890123456', 'Python, TensorFlow, Machine Learning', 6);
INSERT INTO Candidates VALUES (6, 'Fiona Gallagher', 'fiona@example.com', '8901234567', 'Security, Penetration Testing', 5);
INSERT INTO Candidates VALUES (7, 'George Harrison', 'george@example.com', '9012345678', 'Agile, Leadership', 8);
INSERT INTO Candidates VALUES (8, 'Hannah Montana', 'hannah@example.com', '2345678901', 'SQL, Oracle, Backup', 3);
INSERT INTO Candidates VALUES (9, 'Ian Malcolm', 'ian@example.com', '3456789012', 'AWS, Kubernetes', 7);
INSERT INTO Candidates VALUES (10, 'Julia Roberts', 'julia@example.com', '4567890123', 'Kotlin, Swift', 4);


-- ##Inserting values into Applications table
INSERT INTO Applications VALUES (1, 1, 1, SYSDATE, 'Pending');
INSERT INTO Applications VALUES (2, 2, 2, SYSDATE, 'Pending');
INSERT INTO Applications VALUES (3, 3, 3, SYSDATE, 'Pending');
INSERT INTO Applications VALUES (4, 4, 4, SYSDATE, 'Pending');
INSERT INTO Applications VALUES (5, 5, 5, SYSDATE, 'Pending');
INSERT INTO Applications VALUES (6, 6, 6, SYSDATE, 'Pending');
INSERT INTO Applications VALUES (7, 7, 7, SYSDATE, 'Pending');
INSERT INTO Applications VALUES (8, 8, 8, SYSDATE, 'Pending');
INSERT INTO Applications VALUES (9, 9, 9, SYSDATE, 'Pending');
INSERT INTO Applications VALUES (10, 10, 10, SYSDATE, 'Pending');


-- ##Chacking the tables created
SELECT TABLE_NAME 
FROM USER_TABLES
WHERE TABLE_NAME IN ('CANDIDATES', 'CANDIDATESKILLS', 'JOBSKILLS');

-- ##Creating function to Match candidate
CREATE OR REPLACE FUNCTION MatchCandidate(JobID IN NUMBER)
RETURN VARCHAR2
IS
    MatchedCandidates VARCHAR2(4000);
BEGIN
    SELECT LISTAGG(Name, ', ') WITHIN GROUP (ORDER BY Name)
    INTO MatchedCandidates
    FROM Candidates
    WHERE CandidateID IN (
        SELECT CandidateID
        FROM CandidateSkills cs
        JOIN JobSkills js ON cs.SkillID = js.SkillID
        WHERE js.JobID = JobID
    );

    RETURN NVL(MatchedCandidates, 'No matches found');
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN 'No matches found';
END;
/


-- ##Creating procedure for updating the application status of candidate
CREATE OR REPLACE PROCEDURE UpdateApplicationStatus (
    ApplicationID IN NUMBER,
    NewStatus IN VARCHAR2
) IS
BEGIN
    UPDATE Applications
    SET Status = NewStatus
    WHERE ApplicationID = ApplicationID;

    COMMIT;
END;
/


-- ##Create sequence
CREATE SEQUENCE Notifications_SEQ
START WITH 1
INCREMENT BY 1
NOCACHE;

-- ##Check sequence creted
SELECT SEQUENCE_NAME
FROM USER_SEQUENCES
WHERE SEQUENCE_NAME = 'NOTIFICATIONS_SEQ';

-- ##Create Trigger
CREATE OR REPLACE TRIGGER NotifyCandidate
AFTER UPDATE OF Status ON Applications
FOR EACH ROW
BEGIN
    INSERT INTO Notifications (NotificationID, CandidateID, Message, NotificationDate)
    VALUES (
        Notifications_SEQ.NEXTVAL, 
        :NEW.CandidateID, 
        'Your application status has been updated to ' || :NEW.Status,
        SYSDATE
    );
END;
/


UPDATE Applications
SET Status = 'Accepted'
WHERE ApplicationID = 1;

UPDATE Applications
SET Status = 'Accepted'
WHERE ApplicationID IN (4, 5, 7, 9);


SELECT * FROM Notifications;


SELECT J.JobTitle, COUNT(A.ApplicationID) AS ApplicationCount
FROM Jobs J
LEFT JOIN Applications A ON J.JobID = A.JobID
GROUP BY J.JobTitle;

-- ##Test the function
SELECT MatchCandidate(1) AS MatchedCandidates FROM DUAL;

select * from jobs;
select * from candidates;
select * from applications;
select * from notifications;


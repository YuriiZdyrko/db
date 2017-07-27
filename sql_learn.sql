-- Create team

CREATE TABLE Team (
TeamID INT PRIMARY KEY,
PracticeNight CHAR(20)
);

INSERT INTO Team VALUES (1, 'Sunday');
INSERT INTO Team VALUES (2, 'Monday');

-- Create member
CREATE TABLE Member(
MemberID INT PRIMARY KEY,
LastName CHAR(20),
FirstName CHAR(20),
Phone CHAR(20),
Handicap INT,
JoinDate DATE,
Gender CHAR(1),
Team INT REFERENCES Team);

INSERT INTO Member Values(2, 'Pelyush', 'Roman', 09676, 1,
'10/10/2000', 'M', 2)

-- Simple Select
SELECT lastname, firstname FROM Member WHERE firstname = 'Yura'

-- Select with aliases
SELECT m.lastname, m.firstname FROM Member m WHERE m.firstname = 'Yura'

-- View
CREATE VIEW PhoneList AS
SELECT m.LastName, m.FirstName, m.Phone
FROM Member m;

SELECT * FROM PhoneList;

-- CONDITIONAL
SELECT * FROM PhoneList p WHERE NOT(NOT(NOT(p.Firstname IS NULL)));
SELECT * FROM PhoneList p WHERE NOT(LENGTH(p.FirstName)) > 4;


----CONSTRAINTS
CREATE TABLE Member (
MemberID INT PRIMARY KEY,
.....
Gender CHAR(1) NOT NULL,
....)

-- Tools
SELECT DISTINCT p.FirstName FROM PhoneList p;

-- Ordering
SELECT DISTINCT p.FirstName, p.LastName FROM PhoneList p ORDER BY p.LastName;
SELECT DISTINCT p.FirstName, p.LastName FROM PhoneList p ORDER BY p.LastName DESC;

SELECT m.LastName, m.FirstName, m.Handicap
FROM Member m
ORDER BY (CASE
	WHEN (m.Handicap = 1) THEN 1
	ELSE 0
END), m.Handicap


-- Statistics

SELECT AVG(Handicap) FROM Member
SELECT COUNT(*) FROM Member -- Counts all
SELECT COUNT(Handicap) FROM Member -- Counts only where Handicap IS NOT NULL
SELECT COUNT(DISTINCT MemberType) FROM Member

CREATE TABLE Tour (
  TourID INT PRIMARY KEY,
  TourName VARCHAR
);

CREATE TABLE Entry (
  MemberID INT REFERENCES Member,
  TourID INT REFERENCES Tour,
  Year INT
);

ALTER TABLE Member ADD COLUMN MemberType VARCHAR REFERENCES Type;


----JOINS
-- Cross-join (Cartesian produlct)
1. SELECT * FROM Member CROSS JOIN Type t;
2. SELECT * FROM Member m, Type t;
-- Inner JOIN
1. SELECT * FROM Member m LEFT JOIN Type t ON m.membertype = t.type;
2. SELECT * FROM Member m, Type t WHERE m.MemberType = t.Type;

-- Nested inner JOIN (WHAT APPROACH)
SELECT lastname, year FROM (Member m INNER JOIN Entry e ON m.memberid = e.memberid)
INNER JOIN Tour t ON t.TourID = e.TourID
WHERE t.tourid = 23;

SELECT lastname, year FROM (Member m INNER JOIN Entry e ON m.memberid = e.memberid)
INNER JOIN (SELECT * FROM Tour tt WHERE tt.tourid = 23) t ON t.TourID = e.TourID;

-- Manual join (HOW APPROACH)
SELECT lastname, year
FROM Member m, Entry e, Tour t
WHERE m.MemberID = e.MemberID
AND e.TourID = t.TourID
AND t.TourID = 23;


----SUBQUERIES

-- Subquery can return:
- single value (use with '=', 'AVG'...),
- rows with single column (use with 'IN')
- rows with any number of columns (use with 'EXISTS')

-- IN (set)
SELECT e.year FROM Entry e
WHERE e.TourID IN (36, 38, 40);

SELECT e.year FROM Entry e
-- Subquery returns IDs of Open tournaments
WHERE e.TourID IN (SELECT t.TourID FROM Tour t WHERE t.tourname='RockTour')

SELECT e.year FROM Entry e
-- Good old fashioned
INNER JOIN Tournament t ON e.TourID = t.TourID WHERE t.TourType = 'Open';

-- EXISTS
SELECT lastname, firstname
FROM Member m WHERE
{NOT} EXISTS (SELECT * FROM Entry e WHERE e.MemberID = m.MemberID);


SELECT m.Lastname
FROM Member m
WHERE EXISTS
(SELECT * FROM Entry e
WHERE e.MemberID = m.MemberID);
=
SELECT DISTINCT m.LastName
FROM Member m INNER JOIN Entry e ON
e.MemberID = m.MemberID;


----SELF-JOIN (answers to questions involving word "both")
ALTER TABLE Member
ADD Coach INT REFERENCES Member;

SELECT * FROM Member m
INNER JOIN Member c ON m.MemberID = c.Coach AND m.FirstName = 'Yura';
=
SELECT c.FirstName
FROM Member m, Member c
WHERE c.MemberID = m.Coach AND m.FirstName = 'Yura';

-- Member ID who toured both 24 and 36 tours
SELECT e1.MemberID
FROM Entry e1, Entry e2
WHERE e1.MemberID = e2.MemberID
AND e1.TourID = 24 AND e2.TourID = 36;
=
SELECT DISTINCT e.memberID FROM Entry e
INNER JOIN Entry e2
ON e.memberID = e2.memberID
WHERE e1.TourID = 24 AND e2.TourID = 36;


---- SET OPERATIONS
-- UNION - take all, drop duplicates
-- INTERSECTION - exist in both
-- EXCEPT - unique for right set
SELECT LastName, FirstName
FROM Member
WHERE MemberID IN
	(SELECT MemberID FROM Entry WHERE TourID = 36
	INTERSECT
	SELECT MemberID FROM Entry WHERE TourID = 38);
=
-- No INTERSECT keyword
SELECT DISTINCT e1.MemberID
FROM Entry e1, Entry e2
WHERE e1.MemberID = e2.MemberID
AND e1.TourID = 36 AND e2.TourID = 38;

-- WEIRD (members what participate in all tours)
SELECT m.LastName, m.FirstName FROM Member m
WHERE NOT EXISTS
	(
		SELECT * FROM Tournament t
		WHERE NOT EXISTS
		(
			SELECT * FROM Entry e
			WHERE e.MemberID = m.MemberID AND e.TourID = t.TourID
		)
);


---- AGGREGATES (COUNT, SUM, AVG, MAX, ROUND)
SELECT COUNT(*) AS NumberWomen
FROM Member
WHERE Gender = 'F';

-- number of rows
SELECT COUNT(*)
FROM Member;
!=
-- number of rows having not null Coach
SELECT COUNT(Coach)
FROM Member;

SELECT COUNT(DISTINCT Coach)
FROM Member;

-- Weird
SELECT SUM(TestMark)/COUNT(*)
FROM Student;

SELECT MAX(Handicap) AS maximum, MIN(Handicap) AS minimum,
ROUND(AVG(Handicap * 1.0),2) AS average
FROM Member;

-- GROUP BY
SELECT MemberID, COUNT(*) AS NumEntries
FROM Entry
GROUP BY MemberID;

-- GROUPING BY MULTIPLE THINGS (For example if MemberID is not unique)
SELECT m.MemberID, m.LastName, m.FirstName, COUNT(*) AS NumEntries
FROM Entry e INNER JOIN Member m ON m.MemberID = e.MemberID
GROUP BY m.MemberID, m.LastName, m.FirstName;

SELECT Gender, MIN(Handicap) as Minimum, Max(Handicap) as Maximum,
ROUND(AVG(Handicap),1) AS Average
FROM Member
GROUP BY Gender;

-- CPU4 103 NHS Database Assignment SQL File
-- Database: nhs_assignment

DROP DATABASE IF EXISTS nhs_assignment;
CREATE DATABASE nhs_assignment;
USE nhs_assignment;

-- 1. Original Unnormalised Table
CREATE TABLE unnormalized_nhs_data (
PatientID VARCHAR(10),
PatientName VARCHAR(100),
Address VARCHAR(255),
DoctorName VARCHAR(100),
DoctorSpecialty VARCHAR(100),
ClinicName VARCHAR(100),
ClinicAddress VARCHAR(255),
MedicationList VARCHAR(255),
AppointmentDate DATE,
AppointmentTime VARCHAR(20),
Notes VARCHAR(255)
);

INSERT INTO unnormalized_nhs_data (PatientID, PatientName, Address, DoctorName, DoctorSpecialty, ClinicName, ClinicAddress, MedicationList, AppointmentDate, AppointmentTime, Notes)
VALUES
('P001', 'John Smith', '123 Hill Rd', 'Dr. Adams', 'Cardiology', 'Clinic A', '10 Main St', 'Aspirin, Beta Blocker', '2024-05-01', '10:00 AM', 'Follow-up in 2 weeks'),
('P002', 'Mary Jones', '456 Lake Ave', 'Dr. Brown', 'General Practice', 'Clinic B', '22 River Rd', 'Paracetamol', '2024-05-03', '09:00 AM', 'First visit'),
('P001', 'John Smith', '123 Hill Rd', 'Dr. Adams', 'Cardiology', 'Clinic A', '10 Main St', 'Aspirin', '2024-05-10', '11:30 AM', 'Blood pressure check');

SELECT * FROM unnormalized_nhs_data;

-- 2. First Normal Form
CREATE TABLE nhs_1nf (
PatientID VARCHAR(10),
PatientName VARCHAR(100),
Address VARCHAR(255),
DoctorName VARCHAR(100),
DoctorSpecialty VARCHAR(100),
ClinicName VARCHAR(100),
ClinicAddress VARCHAR(255),
MedicationName VARCHAR(100),
AppointmentDate DATE,
AppointmentTime VARCHAR(20),
Notes VARCHAR(255)
);

INSERT INTO nhs_1nf (PatientID, PatientName, Address, DoctorName, DoctorSpecialty, ClinicName, ClinicAddress, MedicationName, AppointmentDate, AppointmentTime, Notes)
VALUES
('P001', 'John Smith', '123 Hill Rd', 'Dr. Adams', 'Cardiology', 'Clinic A', '10 Main St', 'Aspirin', '2024-05-01', '10:00 AM', 'Follow-up in 2 weeks'),
('P001', 'John Smith', '123 Hill Rd', 'Dr. Adams', 'Cardiology', 'Clinic A', '10 Main St', 'Beta Blocker', '2024-05-01', '10:00 AM', 'Follow-up in 2 weeks'),
('P002', 'Mary Jones', '456 Lake Ave', 'Dr. Brown', 'General Practice', 'Clinic B', '22 River Rd', 'Paracetamol', '2024-05-03', '09:00 AM', 'First visit'),
('P001', 'John Smith', '123 Hill Rd', 'Dr. Adams', 'Cardiology', 'Clinic A', '10 Main St', 'Aspirin', '2024-05-10', '11:30 AM', 'Blood pressure check');

SELECT * FROM nhs_1nf;
SELECT COUNT(*) AS total_1nf_rows FROM nhs_1nf;

-- 3. Second Normal Form
CREATE TABLE patients_2nf (PatientID VARCHAR(10) PRIMARY KEY, PatientName VARCHAR(100), Address VARCHAR(255));
CREATE TABLE doctors_2nf (DoctorID INT AUTO_INCREMENT PRIMARY KEY, DoctorName VARCHAR(100), DoctorSpecialty VARCHAR(100));
CREATE TABLE clinics_2nf (ClinicID INT AUTO_INCREMENT PRIMARY KEY, ClinicName VARCHAR(100), ClinicAddress VARCHAR(255));
CREATE TABLE medications_2nf (MedicationID INT AUTO_INCREMENT PRIMARY KEY, MedicationName VARCHAR(100));
CREATE TABLE appointments_2nf (AppointmentID INT AUTO_INCREMENT PRIMARY KEY, PatientID VARCHAR(10), DoctorID INT, ClinicID INT, AppointmentDate DATE, AppointmentTime VARCHAR(20), Notes VARCHAR(255));
CREATE TABLE appointment_medications_2nf (AppointmentID INT, MedicationID INT);

INSERT INTO patients_2nf (PatientID, PatientName, Address)
SELECT DISTINCT PatientID, PatientName, Address FROM nhs_1nf;

INSERT INTO doctors_2nf (DoctorName, DoctorSpecialty)
SELECT DISTINCT DoctorName, DoctorSpecialty FROM nhs_1nf;

INSERT INTO clinics_2nf (ClinicName, ClinicAddress)
SELECT DISTINCT ClinicName, ClinicAddress FROM nhs_1nf;

INSERT INTO medications_2nf (MedicationName)
SELECT DISTINCT MedicationName FROM nhs_1nf;

INSERT INTO appointments_2nf (PatientID, DoctorID, ClinicID, AppointmentDate, AppointmentTime, Notes)
SELECT DISTINCT n.PatientID, d.DoctorID, c.ClinicID, n.AppointmentDate, n.AppointmentTime, n.Notes
FROM nhs_1nf n
JOIN doctors_2nf d ON n.DoctorName = d.DoctorName AND n.DoctorSpecialty = d.DoctorSpecialty
JOIN clinics_2nf c ON n.ClinicName = c.ClinicName AND n.ClinicAddress = c.ClinicAddress;

INSERT INTO appointment_medications_2nf (AppointmentID, MedicationID)
SELECT DISTINCT a.AppointmentID, m.MedicationID
FROM nhs_1nf n
JOIN doctors_2nf d ON n.DoctorName = d.DoctorName AND n.DoctorSpecialty = d.DoctorSpecialty
JOIN clinics_2nf c ON n.ClinicName = c.ClinicName AND n.ClinicAddress = c.ClinicAddress
JOIN appointments_2nf a ON n.PatientID = a.PatientID AND d.DoctorID = a.DoctorID AND c.ClinicID = a.ClinicID AND n.AppointmentDate = a.AppointmentDate AND n.AppointmentTime = a.AppointmentTime
JOIN medications_2nf m ON n.MedicationName = m.MedicationName;

-- 4. Third Normal Form
CREATE TABLE patients_3nf (PatientID VARCHAR(10) PRIMARY KEY, PatientName VARCHAR(100) NOT NULL, Address VARCHAR(255) NOT NULL);

CREATE TABLE doctors_3nf (
DoctorID INT AUTO_INCREMENT PRIMARY KEY,
DoctorName VARCHAR(100) NOT NULL,
DoctorSpecialty VARCHAR(100) NOT NULL,
UNIQUE (DoctorName, DoctorSpecialty)
);

CREATE TABLE clinics_3nf (
ClinicID INT AUTO_INCREMENT PRIMARY KEY,
ClinicName VARCHAR(100) NOT NULL,
ClinicAddress VARCHAR(255) NOT NULL,
UNIQUE (ClinicName, ClinicAddress)
);

CREATE TABLE medications_3nf (
MedicationID INT AUTO_INCREMENT PRIMARY KEY,
MedicationName VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE appointments_3nf (
AppointmentID INT AUTO_INCREMENT PRIMARY KEY,
PatientID VARCHAR(10) NOT NULL,
DoctorID INT NOT NULL,
ClinicID INT NOT NULL,
AppointmentDate DATE NOT NULL,
AppointmentTime VARCHAR(20) NOT NULL,
Notes VARCHAR(255),
FOREIGN KEY (PatientID) REFERENCES patients_3nf(PatientID),
FOREIGN KEY (DoctorID) REFERENCES doctors_3nf(DoctorID),
FOREIGN KEY (ClinicID) REFERENCES clinics_3nf(ClinicID),
UNIQUE (PatientID, DoctorID, ClinicID, AppointmentDate, AppointmentTime)
);

CREATE TABLE appointment_medications_3nf (
AppointmentID INT NOT NULL,
MedicationID INT NOT NULL,
PRIMARY KEY (AppointmentID, MedicationID),
FOREIGN KEY (AppointmentID) REFERENCES appointments_3nf(AppointmentID),
FOREIGN KEY (MedicationID) REFERENCES medications_3nf(MedicationID)
);

INSERT INTO patients_3nf (PatientID, PatientName, Address)
SELECT PatientID, PatientName, Address FROM patients_2nf;

INSERT INTO doctors_3nf (DoctorID, DoctorName, DoctorSpecialty)
SELECT DoctorID, DoctorName, DoctorSpecialty FROM doctors_2nf;

INSERT INTO clinics_3nf (ClinicID, ClinicName, ClinicAddress)
SELECT ClinicID, ClinicName, ClinicAddress FROM clinics_2nf;

INSERT INTO medications_3nf (MedicationID, MedicationName)
SELECT MedicationID, MedicationName FROM medications_2nf;

INSERT INTO appointments_3nf (AppointmentID, PatientID, DoctorID, ClinicID, AppointmentDate, AppointmentTime, Notes)
SELECT AppointmentID, PatientID, DoctorID, ClinicID, AppointmentDate, AppointmentTime, Notes FROM appointments_2nf;

INSERT INTO appointment_medications_3nf (AppointmentID, MedicationID)
SELECT AppointmentID, MedicationID FROM appointment_medications_2nf;

-- 5. Add 10 Records
INSERT INTO patients_3nf (PatientID, PatientName, Address)
VALUES
('P003', 'Ahmed Khan', '77 King Street'),
('P004', 'Sarah Taylor', '88 Queen Road'),
('P005', 'David Wilson', '91 Green Lane'),
('P006', 'Fatima Ali', '12 Park Avenue'),
('P007', 'Robert Brown', '45 Station Road'),
('P008', 'Emma Davis', '19 Church Street'),
('P009', 'Michael Green', '33 Market Road'),
('P010', 'Aisha Hussain', '25 Rose Street');

INSERT INTO doctors_3nf (DoctorID, DoctorName, DoctorSpecialty)
VALUES
(3, 'Dr. Clark', 'Neurology'),
(4, 'Dr. Evans', 'Dermatology'),
(5, 'Dr. Patel', 'Paediatrics'),
(6, 'Dr. White', 'Orthopaedics'),
(7, 'Dr. Green', 'Psychiatry'),
(8, 'Dr. Wilson', 'Endocrinology'),
(9, 'Dr. Ahmed', 'ENT'),
(10, 'Dr. Morris', 'Gastroenterology');

INSERT INTO clinics_3nf (ClinicID, ClinicName, ClinicAddress)
VALUES
(3, 'Clinic C', '35 North Road'),
(4, 'Clinic D', '47 South Avenue'),
(5, 'Clinic E', '59 West Lane'),
(6, 'Clinic F', '61 East Street'),
(7, 'Clinic G', '72 High Road'),
(8, 'Clinic H', '84 Central Road'),
(9, 'Clinic I', '96 Bridge Street'),
(10, 'Clinic J', '108 Hospital Road');

INSERT INTO medications_3nf (MedicationID, MedicationName)
VALUES
(4, 'Ibuprofen'),
(5, 'Amoxicillin'),
(6, 'Metformin'),
(7, 'Loratadine'),
(8, 'Omeprazole'),
(9, 'Atorvastatin'),
(10, 'Salbutamol');

INSERT INTO appointments_3nf (AppointmentID, PatientID, DoctorID, ClinicID, AppointmentDate, AppointmentTime, Notes)
VALUES
(4, 'P003', 3, 3, '2024-05-11', '12:00 PM', 'Headache and dizziness'),
(5, 'P004', 4, 4, '2024-05-12', '01:00 PM', 'Skin rash examination'),
(6, 'P005', 5, 5, '2024-05-13', '02:00 PM', 'Child vaccination review'),
(7, 'P006', 6, 6, '2024-05-14', '03:00 PM', 'Knee pain follow-up'),
(8, 'P007', 7, 7, '2024-05-15', '10:30 AM', 'Mental health consultation'),
(9, 'P008', 8, 8, '2024-05-16', '09:45 AM', 'Diabetes review'),
(10, 'P009', 9, 9, '2024-05-17', '04:00 PM', 'Ear infection review');

INSERT INTO appointment_medications_3nf (AppointmentID, MedicationID)
VALUES
(4, 3),
(5, 4),
(6, 5),
(7, 4),
(8, 7),
(9, 6),
(10, 5);

-- 6. DML Examples
SELECT * FROM patients_3nf WHERE PatientID = 'P003';

UPDATE patients_3nf
SET Address = '79 King Street'
WHERE PatientID = 'P003';

SELECT * FROM patients_3nf WHERE PatientID = 'P003';

INSERT INTO medications_3nf (MedicationID, MedicationName)
VALUES
(11, 'Temporary Test Medicine');

SELECT * FROM medications_3nf WHERE MedicationID = 11;

DELETE FROM medications_3nf
WHERE MedicationID = 11;

SELECT * FROM medications_3nf WHERE MedicationID = 11;

-- 7. Advanced SQL Queries
SELECT d.DoctorID, d.DoctorName, d.DoctorSpecialty, COUNT(a.AppointmentID) AS TotalAppointments
FROM doctors_3nf d
LEFT JOIN appointments_3nf a ON d.DoctorID = a.DoctorID
GROUP BY d.DoctorID, d.DoctorName, d.DoctorSpecialty
ORDER BY TotalAppointments DESC;

SELECT p.PatientID, p.PatientName, a.AppointmentID, a.AppointmentDate, a.AppointmentTime, a.Notes
FROM patients_3nf p
LEFT JOIN appointments_3nf a ON p.PatientID = a.PatientID
ORDER BY p.PatientID;

SELECT a.AppointmentID, a.AppointmentDate, a.AppointmentTime, d.DoctorName, d.DoctorSpecialty
FROM appointments_3nf a
RIGHT JOIN doctors_3nf d ON a.DoctorID = d.DoctorID
ORDER BY d.DoctorID;

SELECT p.PatientID, p.PatientName, a.AppointmentID, a.AppointmentDate, a.AppointmentTime
FROM patients_3nf p
LEFT JOIN appointments_3nf a ON p.PatientID = a.PatientID
UNION
SELECT p.PatientID, p.PatientName, a.AppointmentID, a.AppointmentDate, a.AppointmentTime
FROM patients_3nf p
RIGHT JOIN appointments_3nf a ON p.PatientID = a.PatientID;

SELECT p.PatientName, d.DoctorName, c.ClinicName, m.MedicationName, a.AppointmentDate, a.AppointmentTime, a.Notes
FROM appointments_3nf a
JOIN patients_3nf p ON a.PatientID = p.PatientID
JOIN doctors_3nf d ON a.DoctorID = d.DoctorID
JOIN clinics_3nf c ON a.ClinicID = c.ClinicID
JOIN appointment_medications_3nf am ON a.AppointmentID = am.AppointmentID
JOIN medications_3nf m ON am.MedicationID = m.MedicationID
ORDER BY a.AppointmentDate, a.AppointmentTime;

-- 8. Stored Procedure
DROP PROCEDURE IF EXISTS GetPatientAppointmentHistory;

DELIMITER //

CREATE PROCEDURE GetPatientAppointmentHistory(IN input_patient_id VARCHAR(10))
BEGIN
SELECT p.PatientID, p.PatientName, d.DoctorName, d.DoctorSpecialty, c.ClinicName, a.AppointmentDate, a.AppointmentTime, a.Notes
FROM appointments_3nf a
JOIN patients_3nf p ON a.PatientID = p.PatientID
JOIN doctors_3nf d ON a.DoctorID = d.DoctorID
JOIN clinics_3nf c ON a.ClinicID = c.ClinicID
WHERE p.PatientID = input_patient_id
ORDER BY a.AppointmentDate, a.AppointmentTime;
END //

DELIMITER ;

CALL GetPatientAppointmentHistory('P001');

-- 9. Trigger
CREATE TABLE IF NOT EXISTS appointment_audit_3nf (
AuditID INT AUTO_INCREMENT PRIMARY KEY,
AppointmentID INT,
OldNotes VARCHAR(255),
NewNotes VARCHAR(255),
ChangedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

DROP TRIGGER IF EXISTS trg_appointment_notes_update;

DELIMITER //

CREATE TRIGGER trg_appointment_notes_update
AFTER UPDATE ON appointments_3nf
FOR EACH ROW
BEGIN
IF OLD.Notes <> NEW.Notes THEN
INSERT INTO appointment_audit_3nf (AppointmentID, OldNotes, NewNotes)
VALUES (OLD.AppointmentID, OLD.Notes, NEW.Notes);
END IF;
END //

DELIMITER ;

UPDATE appointments_3nf
SET Notes = 'Headache and dizziness follow-up required'
WHERE AppointmentID = 4;

SELECT * FROM appointment_audit_3nf;

-- 10. Security Roles and Privileges
CREATE ROLE IF NOT EXISTS 'administrator_role';
CREATE ROLE IF NOT EXISTS 'doctor_role';
CREATE ROLE IF NOT EXISTS 'patient_role';
CREATE ROLE IF NOT EXISTS 'receptionist_role';

GRANT ALL PRIVILEGES ON nhs_assignment.* TO 'administrator_role';

GRANT SELECT ON nhs_assignment.patients_3nf TO 'doctor_role';
GRANT SELECT ON nhs_assignment.doctors_3nf TO 'doctor_role';
GRANT SELECT ON nhs_assignment.clinics_3nf TO 'doctor_role';
GRANT SELECT, UPDATE ON nhs_assignment.appointments_3nf TO 'doctor_role';
GRANT SELECT ON nhs_assignment.medications_3nf TO 'doctor_role';
GRANT SELECT ON nhs_assignment.appointment_medications_3nf TO 'doctor_role';

GRANT SELECT ON nhs_assignment.patients_3nf TO 'patient_role';
GRANT SELECT ON nhs_assignment.appointments_3nf TO 'patient_role';
GRANT SELECT ON nhs_assignment.medications_3nf TO 'patient_role';
GRANT SELECT ON nhs_assignment.clinics_3nf TO 'patient_role';

GRANT SELECT, INSERT, UPDATE ON nhs_assignment.appointments_3nf TO 'receptionist_role';
GRANT SELECT ON nhs_assignment.patients_3nf TO 'receptionist_role';
GRANT SELECT ON nhs_assignment.doctors_3nf TO 'receptionist_role';
GRANT SELECT ON nhs_assignment.clinics_3nf TO 'receptionist_role';

CREATE USER IF NOT EXISTS 'nhs_admin'@'localhost' IDENTIFIED BY 'AdminPass123!';
CREATE USER IF NOT EXISTS 'nhs_doctor'@'localhost' IDENTIFIED BY 'DoctorPass123!';
CREATE USER IF NOT EXISTS 'nhs_patient'@'localhost' IDENTIFIED BY 'PatientPass123!';
CREATE USER IF NOT EXISTS 'nhs_receptionist'@'localhost' IDENTIFIED BY 'ReceptionPass123!';

GRANT 'administrator_role' TO 'nhs_admin'@'localhost';
GRANT 'doctor_role' TO 'nhs_doctor'@'localhost';
GRANT 'patient_role' TO 'nhs_patient'@'localhost';
GRANT 'receptionist_role' TO 'nhs_receptionist'@'localhost';

SET DEFAULT ROLE 'administrator_role' TO 'nhs_admin'@'localhost';
SET DEFAULT ROLE 'doctor_role' TO 'nhs_doctor'@'localhost';
SET DEFAULT ROLE 'patient_role' TO 'nhs_patient'@'localhost';
SET DEFAULT ROLE 'receptionist_role' TO 'nhs_receptionist'@'localhost';

FLUSH PRIVILEGES;

SHOW GRANTS FOR 'nhs_admin'@'localhost';
SHOW GRANTS FOR 'nhs_doctor'@'localhost';
SHOW GRANTS FOR 'nhs_patient'@'localhost';
SHOW GRANTS FOR 'nhs_receptionist'@'localhost';

-- 11. Hashing
ALTER TABLE patients_3nf ADD COLUMN PasswordHash CHAR(64);

UPDATE patients_3nf
SET PasswordHash = SHA2(CONCAT(PatientID, '_SecurePass2026'), 256)
WHERE PatientID >= 'P001' AND PatientID <= 'P010';

SELECT PatientID, PatientName, PasswordHash
FROM patients_3nf;

-- 12. Transaction Management
START TRANSACTION;

INSERT INTO appointments_3nf (AppointmentID, PatientID, DoctorID, ClinicID, AppointmentDate, AppointmentTime, Notes)
VALUES (11, 'P010', 10, 10, '2024-05-18', '11:00 AM', 'Transaction test appointment');

INSERT INTO appointment_medications_3nf (AppointmentID, MedicationID)
VALUES (11, 8);

COMMIT;

SELECT * FROM appointments_3nf WHERE AppointmentID = 11;
SELECT * FROM appointment_medications_3nf WHERE AppointmentID = 11;
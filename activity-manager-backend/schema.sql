-- Drop existing database if exists and create new one
DROP DATABASE IF EXISTS college_activity_manager;
CREATE DATABASE college_activity_manager;
USE college_activity_manager;

-- ============================================================
-- Table: DEPARTMENT
-- ============================================================
CREATE TABLE DEPARTMENT (
    Department_ID INT PRIMARY KEY AUTO_INCREMENT,
    Department_Name VARCHAR(100) NOT NULL,
    HOD_Name VARCHAR(100),
    Contact_Email VARCHAR(100)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================================
-- Table: USER (with authentication fields)
-- ============================================================
CREATE TABLE USER (
    User_ID INT PRIMARY KEY AUTO_INCREMENT,
    User_Name VARCHAR(100) NOT NULL,
    User_Email VARCHAR(100) NOT NULL UNIQUE,
    User_Password VARCHAR(255) NOT NULL,
    User_Role ENUM('Teacher', 'Student', 'Club_Head', 'Admin') NOT NULL,
    Phone_Number VARCHAR(20),
    Department_ID INT,
    Registration_Date DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (Department_ID) REFERENCES DEPARTMENT(Department_ID) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================================
-- Table: ACTIVITY_SECTION (Fixed 5 sections)
-- ============================================================
CREATE TABLE ACTIVITY_SECTION (
    Section_ID INT PRIMARY KEY AUTO_INCREMENT,
    Department_ID INT NOT NULL,
    Activity_Section ENUM(
        'Departmental Activities',
        'Training and Placement',
        'Student Activities',
        'Student Achievements',
        'Other Activities'
    ) NOT NULL,
    Description TEXT,
    Created_By INT,
    Upload_Date DATETIME DEFAULT CURRENT_TIMESTAMP,
    Status ENUM('Active', 'Archived') DEFAULT 'Active',
    FOREIGN KEY (Department_ID) REFERENCES DEPARTMENT(Department_ID) ON DELETE CASCADE,
    FOREIGN KEY (Created_By) REFERENCES USER(User_ID) ON DELETE SET NULL,
    UNIQUE KEY unique_section (Department_ID, Activity_Section)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================================
-- Table: ACTIVITY_FILE (Files uploaded for sections)
-- ============================================================
CREATE TABLE ACTIVITY_FILE (
    File_ID INT PRIMARY KEY AUTO_INCREMENT,
    Section_ID INT NOT NULL,
    Department_ID INT NOT NULL,
    File_Name VARCHAR(255) NOT NULL,
    File_Path VARCHAR(500) NOT NULL,
    File_Type VARCHAR(50),
    File_Size FLOAT,
    Upload_Date DATETIME DEFAULT CURRENT_TIMESTAMP,
    Uploaded_By INT,
    Description TEXT,
    Academic_Year VARCHAR(10),
    FOREIGN KEY (Section_ID) REFERENCES ACTIVITY_SECTION(Section_ID) ON DELETE CASCADE,
    FOREIGN KEY (Department_ID) REFERENCES DEPARTMENT(Department_ID) ON DELETE CASCADE,
    FOREIGN KEY (Uploaded_By) REFERENCES USER(User_ID) ON DELETE SET NULL,
    INDEX idx_section ON Section_ID,
    INDEX idx_department ON Department_ID,
    INDEX idx_upload_date ON Upload_Date
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================================
-- Table: EVENT (For upcoming/ongoing events display)
-- ============================================================
CREATE TABLE EVENT (
    Event_ID INT PRIMARY KEY AUTO_INCREMENT,
    Event_Name VARCHAR(200) NOT NULL,
    Event_Date DATE NOT NULL,
    Event_Time TIME,
    Event_Status ENUM('Upcoming', 'Ongoing', 'Completed') DEFAULT 'Upcoming',
    Event_Venue VARCHAR(100),
    Event_Description TEXT,
    Club_Name VARCHAR(100),
    Department_ID INT,
    Created_Date DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (Department_ID) REFERENCES DEPARTMENT(Department_ID) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================================
-- Table: BUDGET_TRACKER (For budget management)
-- ============================================================
CREATE TABLE BUDGET_TRACKER (
    Budget_ID INT PRIMARY KEY AUTO_INCREMENT,
    Event_Name VARCHAR(200) NOT NULL,
    Club_Name VARCHAR(100),
    Total_Collected_Amount DECIMAL(10,2) DEFAULT 0.00,
    Total_Expenses DECIMAL(10,2) DEFAULT 0.00,
    Balance DECIMAL(10,2) DEFAULT 0.00,
    Created_By INT,
    Department_ID INT,
    Created_Date DATETIME DEFAULT CURRENT_TIMESTAMP,
    Budget_Status ENUM('Active', 'Closed') DEFAULT 'Active',
    FOREIGN KEY (Created_By) REFERENCES USER(User_ID) ON DELETE SET NULL,
    FOREIGN KEY (Department_ID) REFERENCES DEPARTMENT(Department_ID) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================================
-- Table: BUDGET_TRANSACTION (For contributions and expenses)
-- ============================================================
CREATE TABLE BUDGET_TRANSACTION (
    Transaction_ID INT PRIMARY KEY AUTO_INCREMENT,
    Budget_ID INT NOT NULL,
    Transaction_Type ENUM('Contribution', 'Expense') NOT NULL,
    Amount DECIMAL(10,2) NOT NULL,
    Description TEXT,
    Transaction_Date DATETIME DEFAULT CURRENT_TIMESTAMP,
    Added_By INT,
    Payment_Method VARCHAR(50),
    FOREIGN KEY (Budget_ID) REFERENCES BUDGET_TRACKER(Budget_ID) ON DELETE CASCADE,
    FOREIGN KEY (Added_By) REFERENCES USER(User_ID) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================================
-- Create Indexes for Better Performance
-- ============================================================
CREATE INDEX idx_activity_section ON ACTIVITY_SECTION(Department_ID);
CREATE INDEX idx_event_status ON EVENT(Event_Status);
CREATE INDEX idx_event_date ON EVENT(Event_Date);
CREATE INDEX idx_budget_status ON BUDGET_TRACKER(Budget_Status);
CREATE INDEX idx_user_email ON USER(User_Email);
CREATE INDEX idx_user_role ON USER(User_Role);

-- ============================================================
-- Insert Sample Data for Testing
-- ============================================================
INSERT INTO DEPARTMENT (Department_Name, HOD_Name, Contact_Email) VALUES
('Computer Applications (BCA)', 'Dr. Suchita Bhovar', 'bca@college.edu'),
('Commerce', 'Dr. Sharma', 'commerce@college.edu'),
('Science', 'Dr. Patel', 'science@college.edu');

-- Sample User
INSERT INTO USER (User_Name, User_Email, User_Password, User_Role, Phone_Number, Department_ID) VALUES
('Admin User', 'admin@college.edu', 'temp_password', 'Admin', '9876543210', 1),
('Dr. Suchita', 'suchita@college.edu', 'temp_password', 'Teacher', '9876543211', 1);

-- Create Activity Sections for Department 1
INSERT INTO ACTIVITY_SECTION (Department_ID, Activity_Section, Status) VALUES
(1, 'Departmental Activities', 'Active'),
(1, 'Training and Placement', 'Active'),
(1, 'Student Activities', 'Active'),
(1, 'Student Achievements', 'Active'),
(1, 'Other Activities', 'Active');

-- Create Activity Sections for Department 2
INSERT INTO ACTIVITY_SECTION (Department_ID, Activity_Section, Status) VALUES
(2, 'Departmental Activities', 'Active'),
(2, 'Training and Placement', 'Active'),
(2, 'Student Activities', 'Active'),
(2, 'Student Achievements', 'Active'),
(2, 'Other Activities', 'Active');

-- Create Activity Sections for Department 3
INSERT INTO ACTIVITY_SECTION (Department_ID, Activity_Section, Status) VALUES
(3, 'Departmental Activities', 'Active'),
(3, 'Training and Placement', 'Active'),
(3, 'Student Activities', 'Active'),
(3, 'Student Achievements', 'Active'),
(3, 'Other Activities', 'Active');

-- Sample Events
INSERT INTO EVENT (Event_Name, Event_Date, Event_Time, Event_Status, Event_Venue, Event_Description, Club_Name, Department_ID) VALUES
('Tech Fest 2024', '2024-12-15', '10:00:00', 'Upcoming', 'Main Auditorium', 'Annual technical festival', 'Tech Club', 1),
('Annual Day', '2024-12-20', '14:00:00', 'Upcoming', 'Main Auditorium', 'Annual celebration', 'General', 1);

-- Sample Budget
INSERT INTO BUDGET_TRACKER (Event_Name, Club_Name, Total_Collected_Amount, Balance, Created_By, Department_ID) VALUES
('Annual Day 2024', 'Cultural Club', 10000.00, 10000.00, 1, 1),
('Tech Fest 2024', 'Tech Club', 15000.00, 15000.00, 1, 1);

-- Sample Transactions
INSERT INTO BUDGET_TRANSACTION (Budget_ID, Transaction_Type, Amount, Description, Added_By) VALUES
(1, 'Contribution', 10000.00, 'Initial collection from students', 1),
(1, 'Expense', 2000.00, 'Decorations', 1),
(2, 'Contribution', 15000.00, 'Sponsorship and student contributions', 1);

-- ============================================================
-- Verify all tables created
-- ============================================================
SHOW TABLES;
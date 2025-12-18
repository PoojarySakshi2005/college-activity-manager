-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Dec 18, 2025 at 10:51 AM
-- Server version: 10.4.32-MariaDB
-- PHP Version: 8.1.25

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `project_college`
--

-- --------------------------------------------------------

--
-- Table structure for table `activity`
--

CREATE TABLE `activity` (
  `Activity_ID` int(11) NOT NULL,
  `Activity_Type` enum('Departmental Activities','Training and Placement','Student Activities','Student Achievements','Other Activities') NOT NULL,
  `Activity_Title` varchar(200) NOT NULL,
  `Activity_Description` text DEFAULT NULL,
  `Activity_Date` date NOT NULL,
  `Organized_By` varchar(100) DEFAULT NULL,
  `Participants_Count` int(11) DEFAULT 0,
  `Venue` varchar(100) DEFAULT NULL,
  `Department_ID` int(11) DEFAULT NULL,
  `Uploaded_By` int(11) DEFAULT NULL,
  `Upload_Date` datetime DEFAULT current_timestamp(),
  `Status` enum('Draft','Approved','Published') DEFAULT 'Draft'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `activity`
--

INSERT INTO `activity` (`Activity_ID`, `Activity_Type`, `Activity_Title`, `Activity_Description`, `Activity_Date`, `Organized_By`, `Participants_Count`, `Venue`, `Department_ID`, `Uploaded_By`, `Upload_Date`, `Status`) VALUES
(1, 'Departmental Activities', 'Guest Lecture on Data Structures', 'Guest lecture conducted by Mr. Yuvraj Wagh on Basics of Data Structure', '2024-06-25', 'Dr. Suchita Bhovar', 50, 'Hall A', 1, 1, '2025-12-07 21:55:50', 'Approved');

-- --------------------------------------------------------

--
-- Table structure for table `budget_tracker`
--

CREATE TABLE `budget_tracker` (
  `Budget_ID` int(11) NOT NULL,
  `Event_Name` varchar(200) NOT NULL,
  `Club_Name` varchar(100) DEFAULT NULL,
  `Total_Collected_Amount` decimal(10,2) DEFAULT 0.00,
  `Total_Expenses` decimal(10,2) DEFAULT 0.00,
  `Balance` decimal(10,2) DEFAULT 0.00,
  `Created_By` int(11) DEFAULT NULL,
  `Department_ID` int(11) DEFAULT NULL,
  `Created_Date` datetime DEFAULT current_timestamp(),
  `Budget_Status` enum('Active','Closed') DEFAULT 'Active'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `budget_tracker`
--

INSERT INTO `budget_tracker` (`Budget_ID`, `Event_Name`, `Club_Name`, `Total_Collected_Amount`, `Total_Expenses`, `Balance`, `Created_By`, `Department_ID`, `Created_Date`, `Budget_Status`) VALUES
(1, 'Annual Day 2024', 'Cultural Club', 10000.00, 0.00, 10000.00, 1, 1, '2025-12-07 21:55:50', 'Active');

-- --------------------------------------------------------

--
-- Table structure for table `budget_transaction`
--

CREATE TABLE `budget_transaction` (
  `Transaction_ID` int(11) NOT NULL,
  `Budget_ID` int(11) NOT NULL,
  `Transaction_Type` enum('Contribution','Expense') NOT NULL,
  `Amount` decimal(10,2) NOT NULL,
  `Description` text DEFAULT NULL,
  `Transaction_Date` datetime DEFAULT current_timestamp(),
  `Added_By` int(11) DEFAULT NULL,
  `Payment_Method` varchar(50) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `budget_transaction`
--

INSERT INTO `budget_transaction` (`Transaction_ID`, `Budget_ID`, `Transaction_Type`, `Amount`, `Description`, `Transaction_Date`, `Added_By`, `Payment_Method`) VALUES
(1, 1, 'Contribution', 10000.00, 'Initial collection from students', '2025-12-07 21:55:50', 1, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `department`
--

CREATE TABLE `department` (
  `Department_ID` int(11) NOT NULL,
  `Department_Name` varchar(100) NOT NULL,
  `HOD_Name` varchar(100) DEFAULT NULL,
  `Contact_Email` varchar(100) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `department`
--

INSERT INTO `department` (`Department_ID`, `Department_Name`, `HOD_Name`, `Contact_Email`) VALUES
(1, 'Computer Applications (BCA)', 'Dr. Suchita Bhovar', 'bca@college.edu'),
(2, 'Commerce', 'Dr. Sharma', 'commerce@college.edu');

-- --------------------------------------------------------

--
-- Table structure for table `event`
--

CREATE TABLE `event` (
  `Event_ID` int(11) NOT NULL,
  `Event_Name` varchar(200) NOT NULL,
  `Event_Date` date NOT NULL,
  `Event_Time` time DEFAULT NULL,
  `Event_Status` enum('Upcoming','Ongoing','Completed') DEFAULT 'Upcoming',
  `Event_Venue` varchar(100) DEFAULT NULL,
  `Event_Description` text DEFAULT NULL,
  `Club_Name` varchar(100) DEFAULT NULL,
  `Department_ID` int(11) DEFAULT NULL,
  `Created_Date` datetime DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `event`
--

INSERT INTO `event` (`Event_ID`, `Event_Name`, `Event_Date`, `Event_Time`, `Event_Status`, `Event_Venue`, `Event_Description`, `Club_Name`, `Department_ID`, `Created_Date`) VALUES
(1, 'Tech Fest 2024', '2024-12-15', '10:00:00', 'Upcoming', 'Main Auditorium', 'Annual technical festival', 'Tech Club', 1, '2025-12-07 21:55:50');

-- --------------------------------------------------------

--
-- Table structure for table `generated_report`
--

CREATE TABLE `generated_report` (
  `Report_ID` int(11) NOT NULL,
  `Department_ID` int(11) DEFAULT NULL,
  `Report_Period` varchar(100) DEFAULT NULL,
  `Start_Date` date DEFAULT NULL,
  `End_Date` date DEFAULT NULL,
  `Generated_Date` datetime DEFAULT current_timestamp(),
  `File_Path` varchar(500) DEFAULT NULL,
  `Generated_By` int(11) DEFAULT NULL,
  `Report_Status` enum('In Progress','Completed','Downloaded') DEFAULT 'Completed'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `supporting_document`
--

CREATE TABLE `supporting_document` (
  `Document_ID` int(11) NOT NULL,
  `Activity_ID` int(11) NOT NULL,
  `File_Name` varchar(255) NOT NULL,
  `File_Path` varchar(500) NOT NULL,
  `File_Type` varchar(50) DEFAULT NULL,
  `File_Size` float DEFAULT NULL,
  `Upload_Date` datetime DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `user`
--

CREATE TABLE `user` (
  `User_ID` int(11) NOT NULL,
  `User_Name` varchar(100) NOT NULL,
  `User_Email` varchar(100) NOT NULL,
  `User_Password` varchar(255) NOT NULL,
  `User_Role` enum('Teacher','Student','Club_Head','Admin') NOT NULL,
  `Phone_Number` varchar(20) DEFAULT NULL,
  `Department_ID` int(11) DEFAULT NULL,
  `Registration_Date` datetime DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `user`
--

INSERT INTO `user` (`User_ID`, `User_Name`, `User_Email`, `User_Password`, `User_Role`, `Phone_Number`, `Department_ID`, `Registration_Date`) VALUES
(1, 'Admin User', 'admin@college.edu', 'temp_password', 'Admin', '9876543210', 1, '2025-12-07 21:55:50');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `activity`
--
ALTER TABLE `activity`
  ADD PRIMARY KEY (`Activity_ID`),
  ADD KEY `Uploaded_By` (`Uploaded_By`),
  ADD KEY `idx_activity_type` (`Activity_Type`),
  ADD KEY `idx_activity_date` (`Activity_Date`),
  ADD KEY `idx_activity_department` (`Department_ID`);

--
-- Indexes for table `budget_tracker`
--
ALTER TABLE `budget_tracker`
  ADD PRIMARY KEY (`Budget_ID`),
  ADD KEY `Created_By` (`Created_By`),
  ADD KEY `Department_ID` (`Department_ID`),
  ADD KEY `idx_budget_status` (`Budget_Status`);

--
-- Indexes for table `budget_transaction`
--
ALTER TABLE `budget_transaction`
  ADD PRIMARY KEY (`Transaction_ID`),
  ADD KEY `Budget_ID` (`Budget_ID`),
  ADD KEY `Added_By` (`Added_By`);

--
-- Indexes for table `department`
--
ALTER TABLE `department`
  ADD PRIMARY KEY (`Department_ID`);

--
-- Indexes for table `event`
--
ALTER TABLE `event`
  ADD PRIMARY KEY (`Event_ID`),
  ADD KEY `Department_ID` (`Department_ID`),
  ADD KEY `idx_event_status` (`Event_Status`),
  ADD KEY `idx_event_date` (`Event_Date`);

--
-- Indexes for table `generated_report`
--
ALTER TABLE `generated_report`
  ADD PRIMARY KEY (`Report_ID`),
  ADD KEY `Department_ID` (`Department_ID`),
  ADD KEY `Generated_By` (`Generated_By`);

--
-- Indexes for table `supporting_document`
--
ALTER TABLE `supporting_document`
  ADD PRIMARY KEY (`Document_ID`),
  ADD KEY `Activity_ID` (`Activity_ID`);

--
-- Indexes for table `user`
--
ALTER TABLE `user`
  ADD PRIMARY KEY (`User_ID`),
  ADD UNIQUE KEY `User_Email` (`User_Email`),
  ADD KEY `Department_ID` (`Department_ID`),
  ADD KEY `idx_user_email` (`User_Email`),
  ADD KEY `idx_user_role` (`User_Role`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `activity`
--
ALTER TABLE `activity`
  MODIFY `Activity_ID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `budget_tracker`
--
ALTER TABLE `budget_tracker`
  MODIFY `Budget_ID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `budget_transaction`
--
ALTER TABLE `budget_transaction`
  MODIFY `Transaction_ID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `department`
--
ALTER TABLE `department`
  MODIFY `Department_ID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `event`
--
ALTER TABLE `event`
  MODIFY `Event_ID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `generated_report`
--
ALTER TABLE `generated_report`
  MODIFY `Report_ID` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `supporting_document`
--
ALTER TABLE `supporting_document`
  MODIFY `Document_ID` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `user`
--
ALTER TABLE `user`
  MODIFY `User_ID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `activity`
--
ALTER TABLE `activity`
  ADD CONSTRAINT `activity_ibfk_1` FOREIGN KEY (`Department_ID`) REFERENCES `department` (`Department_ID`) ON DELETE CASCADE,
  ADD CONSTRAINT `activity_ibfk_2` FOREIGN KEY (`Uploaded_By`) REFERENCES `user` (`User_ID`) ON DELETE SET NULL;

--
-- Constraints for table `budget_tracker`
--
ALTER TABLE `budget_tracker`
  ADD CONSTRAINT `budget_tracker_ibfk_1` FOREIGN KEY (`Created_By`) REFERENCES `user` (`User_ID`) ON DELETE SET NULL,
  ADD CONSTRAINT `budget_tracker_ibfk_2` FOREIGN KEY (`Department_ID`) REFERENCES `department` (`Department_ID`) ON DELETE CASCADE;

--
-- Constraints for table `budget_transaction`
--
ALTER TABLE `budget_transaction`
  ADD CONSTRAINT `budget_transaction_ibfk_1` FOREIGN KEY (`Budget_ID`) REFERENCES `budget_tracker` (`Budget_ID`) ON DELETE CASCADE,
  ADD CONSTRAINT `budget_transaction_ibfk_2` FOREIGN KEY (`Added_By`) REFERENCES `user` (`User_ID`) ON DELETE SET NULL;

--
-- Constraints for table `event`
--
ALTER TABLE `event`
  ADD CONSTRAINT `event_ibfk_1` FOREIGN KEY (`Department_ID`) REFERENCES `department` (`Department_ID`) ON DELETE CASCADE;

--
-- Constraints for table `generated_report`
--
ALTER TABLE `generated_report`
  ADD CONSTRAINT `generated_report_ibfk_1` FOREIGN KEY (`Department_ID`) REFERENCES `department` (`Department_ID`) ON DELETE CASCADE,
  ADD CONSTRAINT `generated_report_ibfk_2` FOREIGN KEY (`Generated_By`) REFERENCES `user` (`User_ID`) ON DELETE SET NULL;

--
-- Constraints for table `supporting_document`
--
ALTER TABLE `supporting_document`
  ADD CONSTRAINT `supporting_document_ibfk_1` FOREIGN KEY (`Activity_ID`) REFERENCES `activity` (`Activity_ID`) ON DELETE CASCADE;

--
-- Constraints for table `user`
--
ALTER TABLE `user`
  ADD CONSTRAINT `user_ibfk_1` FOREIGN KEY (`Department_ID`) REFERENCES `department` (`Department_ID`) ON DELETE SET NULL;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;

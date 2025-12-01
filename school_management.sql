/*
 Navicat Premium Data Transfer

 Source Server         : localhost
 Source Server Type    : MariaDB
 Source Server Version : 120002
 Source Host           : localhost:3306
 Source Schema         : school_management

 Target Server Type    : MariaDB
 Target Server Version : 120002
 File Encoding         : 65001

 Date: 16/10/2025 21:46:52
*/

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Table structure for attendance_records
-- ----------------------------
DROP TABLE IF EXISTS `attendance_records`;
CREATE TABLE `attendance_records`  (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `student_id` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_uca1400_ai_ci NOT NULL,
  `subject_id` int(11) NOT NULL,
  `section_id` int(11) NOT NULL,
  `attendance_date` date NOT NULL,
  `status` enum('Present','Absent') CHARACTER SET utf8mb4 COLLATE utf8mb4_uca1400_ai_ci NULL DEFAULT 'Absent',
  `recorded_by` int(11) NULL DEFAULT NULL,
  `recorded_at` timestamp(0) NULL DEFAULT current_timestamp() ON UPDATE CURRENT_TIMESTAMP(0),
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `unique_attendance`(`student_id`, `subject_id`, `section_id`, `attendance_date`) USING BTREE,
  INDEX `subject_id`(`subject_id`) USING BTREE,
  INDEX `section_id`(`section_id`) USING BTREE,
  INDEX `recorded_by`(`recorded_by`) USING BTREE,
  CONSTRAINT `attendance_records_ibfk_1` FOREIGN KEY (`student_id`) REFERENCES `students` (`StudentID`) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT `attendance_records_ibfk_2` FOREIGN KEY (`subject_id`) REFERENCES `subjects` (`SubjectID`) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT `attendance_records_ibfk_3` FOREIGN KEY (`section_id`) REFERENCES `sections` (`SectionID`) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT `attendance_records_ibfk_4` FOREIGN KEY (`recorded_by`) REFERENCES `users` (`UserID`) ON DELETE SET NULL ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 640 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_uca1400_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of attendance_records
-- ----------------------------
INSERT INTO `attendance_records` VALUES (146, '2024001', 1, 1, '2024-10-15', 'Absent', 1, '2025-10-06 12:47:20');
INSERT INTO `attendance_records` VALUES (147, '2024002', 1, 1, '2024-10-15', 'Present', 1, '2025-10-06 12:47:20');
INSERT INTO `attendance_records` VALUES (148, '2024001', 1, 1, '2024-10-16', 'Present', 1, '2025-10-06 12:47:20');
INSERT INTO `attendance_records` VALUES (149, '2024002', 1, 1, '2024-10-16', 'Absent', 1, '2025-10-06 12:47:20');
INSERT INTO `attendance_records` VALUES (150, '2024001', 2, 1, '2024-12-31', 'Absent', 1, '2025-10-06 12:47:41');
INSERT INTO `attendance_records` VALUES (151, '2024001', 2, 1, '2025-01-01', 'Absent', 1, '2025-10-06 13:03:40');
INSERT INTO `attendance_records` VALUES (152, '2024001', 2, 1, '2025-01-02', 'Present', 1, '2025-10-06 20:17:09');
INSERT INTO `attendance_records` VALUES (153, '2024001', 2, 1, '2025-01-05', 'Absent', 1, '2025-10-06 12:47:41');
INSERT INTO `attendance_records` VALUES (154, '2024001', 2, 1, '2025-01-06', 'Absent', 1, '2025-10-06 20:18:18');
INSERT INTO `attendance_records` VALUES (155, '2024001', 2, 1, '2025-01-07', 'Present', 1, '2025-10-06 13:02:57');
INSERT INTO `attendance_records` VALUES (156, '2024001', 2, 1, '2025-01-08', 'Absent', 1, '2025-10-06 20:18:32');
INSERT INTO `attendance_records` VALUES (157, '2024001', 2, 1, '2025-01-09', 'Present', 1, '2025-10-06 20:18:20');
INSERT INTO `attendance_records` VALUES (158, '2024001', 2, 1, '2025-01-12', 'Absent', 1, '2025-10-06 12:47:41');
INSERT INTO `attendance_records` VALUES (159, '2024001', 2, 1, '2025-01-13', 'Absent', 1, '2025-10-06 12:47:41');
INSERT INTO `attendance_records` VALUES (160, '2024001', 2, 1, '2025-01-14', 'Absent', 1, '2025-10-06 20:27:09');
INSERT INTO `attendance_records` VALUES (161, '2024001', 2, 1, '2025-01-15', 'Absent', 1, '2025-10-06 12:47:41');
INSERT INTO `attendance_records` VALUES (162, '2024001', 2, 1, '2025-01-16', 'Absent', 1, '2025-10-06 12:47:41');
INSERT INTO `attendance_records` VALUES (163, '2024001', 2, 1, '2025-01-19', 'Absent', 1, '2025-10-06 12:47:41');
INSERT INTO `attendance_records` VALUES (164, '2024001', 2, 1, '2025-01-20', 'Absent', 1, '2025-10-06 12:47:41');
INSERT INTO `attendance_records` VALUES (165, '2024001', 2, 1, '2025-01-21', 'Absent', 1, '2025-10-06 12:47:41');
INSERT INTO `attendance_records` VALUES (166, '2024001', 2, 1, '2025-01-22', 'Absent', 1, '2025-10-06 12:47:41');
INSERT INTO `attendance_records` VALUES (167, '2024001', 2, 1, '2025-01-23', 'Absent', 1, '2025-10-06 12:47:41');
INSERT INTO `attendance_records` VALUES (168, '2024001', 2, 1, '2025-01-26', 'Absent', 1, '2025-10-06 12:47:41');
INSERT INTO `attendance_records` VALUES (169, '2024001', 2, 1, '2025-01-27', 'Absent', 1, '2025-10-06 12:47:41');
INSERT INTO `attendance_records` VALUES (170, '2024001', 2, 1, '2025-01-28', 'Absent', 1, '2025-10-06 12:47:41');
INSERT INTO `attendance_records` VALUES (171, '2024001', 2, 1, '2025-01-29', 'Absent', 1, '2025-10-06 12:47:41');
INSERT INTO `attendance_records` VALUES (172, '2024001', 2, 1, '2025-01-30', 'Absent', 1, '2025-10-06 20:17:46');
INSERT INTO `attendance_records` VALUES (173, '2024002', 2, 1, '2024-12-31', 'Absent', 1, '2025-10-06 12:47:41');
INSERT INTO `attendance_records` VALUES (174, '2024002', 2, 1, '2025-01-01', 'Present', 1, '2025-10-06 13:02:19');
INSERT INTO `attendance_records` VALUES (175, '2024002', 2, 1, '2025-01-02', 'Absent', 1, '2025-10-06 12:47:41');
INSERT INTO `attendance_records` VALUES (176, '2024002', 2, 1, '2025-01-05', 'Absent', 1, '2025-10-06 12:47:41');
INSERT INTO `attendance_records` VALUES (177, '2024002', 2, 1, '2025-01-06', 'Absent', 1, '2025-10-06 12:47:41');
INSERT INTO `attendance_records` VALUES (178, '2024002', 2, 1, '2025-01-07', 'Absent', 1, '2025-10-06 12:47:41');
INSERT INTO `attendance_records` VALUES (179, '2024002', 2, 1, '2025-01-08', 'Absent', 1, '2025-10-06 12:47:41');
INSERT INTO `attendance_records` VALUES (180, '2024002', 2, 1, '2025-01-09', 'Absent', 1, '2025-10-06 12:47:41');
INSERT INTO `attendance_records` VALUES (181, '2024002', 2, 1, '2025-01-12', 'Absent', 1, '2025-10-06 12:47:41');
INSERT INTO `attendance_records` VALUES (182, '2024002', 2, 1, '2025-01-13', 'Absent', 1, '2025-10-06 12:47:41');
INSERT INTO `attendance_records` VALUES (183, '2024002', 2, 1, '2025-01-14', 'Absent', 1, '2025-10-06 12:47:41');
INSERT INTO `attendance_records` VALUES (184, '2024002', 2, 1, '2025-01-15', 'Absent', 1, '2025-10-06 12:47:41');
INSERT INTO `attendance_records` VALUES (185, '2024002', 2, 1, '2025-01-16', 'Absent', 1, '2025-10-06 12:47:41');
INSERT INTO `attendance_records` VALUES (186, '2024002', 2, 1, '2025-01-19', 'Absent', 1, '2025-10-06 12:47:41');
INSERT INTO `attendance_records` VALUES (187, '2024002', 2, 1, '2025-01-20', 'Absent', 1, '2025-10-06 12:47:41');
INSERT INTO `attendance_records` VALUES (188, '2024002', 2, 1, '2025-01-21', 'Absent', 1, '2025-10-06 12:47:41');
INSERT INTO `attendance_records` VALUES (189, '2024002', 2, 1, '2025-01-22', 'Absent', 1, '2025-10-06 12:47:41');
INSERT INTO `attendance_records` VALUES (190, '2024002', 2, 1, '2025-01-23', 'Absent', 1, '2025-10-06 12:47:41');
INSERT INTO `attendance_records` VALUES (191, '2024002', 2, 1, '2025-01-26', 'Absent', 1, '2025-10-06 12:47:41');
INSERT INTO `attendance_records` VALUES (192, '2024002', 2, 1, '2025-01-27', 'Absent', 1, '2025-10-06 12:47:41');
INSERT INTO `attendance_records` VALUES (193, '2024002', 2, 1, '2025-01-28', 'Absent', 1, '2025-10-06 12:47:41');
INSERT INTO `attendance_records` VALUES (194, '2024002', 2, 1, '2025-01-29', 'Absent', 1, '2025-10-06 12:47:41');
INSERT INTO `attendance_records` VALUES (195, '2024002', 2, 1, '2025-01-30', 'Absent', 1, '2025-10-06 12:47:41');
INSERT INTO `attendance_records` VALUES (196, '2024003', 2, 1, '2024-12-31', 'Absent', 1, '2025-10-06 12:47:41');
INSERT INTO `attendance_records` VALUES (197, '2024003', 2, 1, '2025-01-01', 'Present', 1, '2025-10-06 13:02:24');
INSERT INTO `attendance_records` VALUES (198, '2024003', 2, 1, '2025-01-02', 'Absent', 1, '2025-10-06 12:47:41');
INSERT INTO `attendance_records` VALUES (199, '2024003', 2, 1, '2025-01-05', 'Absent', 1, '2025-10-06 12:47:41');
INSERT INTO `attendance_records` VALUES (200, '2024003', 2, 1, '2025-01-06', 'Absent', 1, '2025-10-06 12:47:41');
INSERT INTO `attendance_records` VALUES (201, '2024003', 2, 1, '2025-01-07', 'Absent', 1, '2025-10-06 12:47:41');
INSERT INTO `attendance_records` VALUES (202, '2024003', 2, 1, '2025-01-08', 'Absent', 1, '2025-10-06 12:47:41');
INSERT INTO `attendance_records` VALUES (203, '2024003', 2, 1, '2025-01-09', 'Absent', 1, '2025-10-06 12:47:41');
INSERT INTO `attendance_records` VALUES (204, '2024003', 2, 1, '2025-01-12', 'Absent', 1, '2025-10-06 12:47:41');
INSERT INTO `attendance_records` VALUES (205, '2024003', 2, 1, '2025-01-13', 'Absent', 1, '2025-10-06 12:47:41');
INSERT INTO `attendance_records` VALUES (206, '2024003', 2, 1, '2025-01-14', 'Absent', 1, '2025-10-06 12:47:41');
INSERT INTO `attendance_records` VALUES (207, '2024003', 2, 1, '2025-01-15', 'Absent', 1, '2025-10-06 12:47:41');
INSERT INTO `attendance_records` VALUES (208, '2024003', 2, 1, '2025-01-16', 'Absent', 1, '2025-10-06 12:47:41');
INSERT INTO `attendance_records` VALUES (209, '2024003', 2, 1, '2025-01-19', 'Absent', 1, '2025-10-06 12:47:41');
INSERT INTO `attendance_records` VALUES (210, '2024003', 2, 1, '2025-01-20', 'Absent', 1, '2025-10-06 12:47:41');
INSERT INTO `attendance_records` VALUES (211, '2024003', 2, 1, '2025-01-21', 'Absent', 1, '2025-10-06 12:47:41');
INSERT INTO `attendance_records` VALUES (212, '2024003', 2, 1, '2025-01-22', 'Absent', 1, '2025-10-06 12:47:41');
INSERT INTO `attendance_records` VALUES (213, '2024003', 2, 1, '2025-01-23', 'Absent', 1, '2025-10-06 12:47:41');
INSERT INTO `attendance_records` VALUES (214, '2024003', 2, 1, '2025-01-26', 'Absent', 1, '2025-10-06 12:47:41');
INSERT INTO `attendance_records` VALUES (215, '2024003', 2, 1, '2025-01-27', 'Absent', 1, '2025-10-06 12:47:41');
INSERT INTO `attendance_records` VALUES (216, '2024003', 2, 1, '2025-01-28', 'Absent', 1, '2025-10-06 12:47:41');
INSERT INTO `attendance_records` VALUES (217, '2024003', 2, 1, '2025-01-29', 'Absent', 1, '2025-10-06 12:47:41');
INSERT INTO `attendance_records` VALUES (218, '2024003', 2, 1, '2025-01-30', 'Absent', 1, '2025-10-06 12:47:41');
INSERT INTO `attendance_records` VALUES (219, '2024001', 1, 1, '2024-10-01', 'Present', 1, '2025-10-06 13:01:05');
INSERT INTO `attendance_records` VALUES (220, '2024002', 1, 1, '2024-10-01', 'Absent', 1, '2025-10-06 13:01:05');
INSERT INTO `attendance_records` VALUES (221, '2024001', 1, 1, '2024-10-02', 'Absent', 1, '2025-10-06 13:01:05');
INSERT INTO `attendance_records` VALUES (222, '2024002', 1, 1, '2024-10-02', 'Present', 1, '2025-10-06 13:01:05');
INSERT INTO `attendance_records` VALUES (223, '2024001', 1, 1, '2024-10-03', 'Present', 1, '2025-10-06 13:01:05');
INSERT INTO `attendance_records` VALUES (224, '2024002', 1, 1, '2024-10-03', 'Present', 1, '2025-10-06 13:01:05');
INSERT INTO `attendance_records` VALUES (247, '2024001', 2, 1, '2025-01-03', 'Present', 1, '2025-10-06 20:17:11');
INSERT INTO `attendance_records` VALUES (248, '2024001', 2, 1, '2025-01-31', 'Present', 1, '2025-10-06 20:17:42');
INSERT INTO `attendance_records` VALUES (269, '2024003', 3, 1, '2024-12-31', 'Absent', 1, '2025-10-15 11:48:37');
INSERT INTO `attendance_records` VALUES (270, '2024003', 3, 1, '2025-01-01', 'Absent', 1, '2025-10-15 11:48:37');
INSERT INTO `attendance_records` VALUES (271, '2024003', 3, 1, '2025-01-02', 'Absent', 1, '2025-10-15 11:48:37');
INSERT INTO `attendance_records` VALUES (272, '2024003', 3, 1, '2025-01-05', 'Absent', 1, '2025-10-15 11:48:37');
INSERT INTO `attendance_records` VALUES (273, '2024003', 3, 1, '2025-01-06', 'Absent', 1, '2025-10-15 11:48:37');
INSERT INTO `attendance_records` VALUES (274, '2024003', 3, 1, '2025-01-07', 'Absent', 1, '2025-10-15 11:48:37');
INSERT INTO `attendance_records` VALUES (275, '2024003', 3, 1, '2025-01-08', 'Absent', 1, '2025-10-15 11:48:37');
INSERT INTO `attendance_records` VALUES (276, '2024003', 3, 1, '2025-01-09', 'Absent', 1, '2025-10-15 11:48:37');
INSERT INTO `attendance_records` VALUES (277, '2024003', 3, 1, '2025-01-12', 'Absent', 1, '2025-10-15 11:48:37');
INSERT INTO `attendance_records` VALUES (278, '2024003', 3, 1, '2025-01-13', 'Absent', 1, '2025-10-15 11:48:37');
INSERT INTO `attendance_records` VALUES (279, '2024003', 3, 1, '2025-01-14', 'Absent', 1, '2025-10-15 11:48:37');
INSERT INTO `attendance_records` VALUES (280, '2024003', 3, 1, '2025-01-15', 'Absent', 1, '2025-10-15 11:48:37');
INSERT INTO `attendance_records` VALUES (281, '2024003', 3, 1, '2025-01-16', 'Absent', 1, '2025-10-15 11:48:37');
INSERT INTO `attendance_records` VALUES (282, '2024003', 3, 1, '2025-01-19', 'Absent', 1, '2025-10-15 11:48:37');
INSERT INTO `attendance_records` VALUES (283, '2024003', 3, 1, '2025-01-20', 'Absent', 1, '2025-10-15 11:48:37');
INSERT INTO `attendance_records` VALUES (284, '2024003', 3, 1, '2025-01-21', 'Absent', 1, '2025-10-15 11:48:37');
INSERT INTO `attendance_records` VALUES (285, '2024003', 3, 1, '2025-01-22', 'Absent', 1, '2025-10-15 11:48:37');
INSERT INTO `attendance_records` VALUES (286, '2024003', 3, 1, '2025-01-23', 'Absent', 1, '2025-10-15 11:48:37');
INSERT INTO `attendance_records` VALUES (287, '2024003', 3, 1, '2025-01-26', 'Absent', 1, '2025-10-15 11:48:37');
INSERT INTO `attendance_records` VALUES (288, '2024003', 3, 1, '2025-01-27', 'Absent', 1, '2025-10-15 11:48:37');
INSERT INTO `attendance_records` VALUES (289, '2024003', 3, 1, '2025-01-28', 'Absent', 1, '2025-10-15 11:48:37');
INSERT INTO `attendance_records` VALUES (290, '2024003', 3, 1, '2025-01-29', 'Absent', 1, '2025-10-15 11:48:37');
INSERT INTO `attendance_records` VALUES (291, '2024003', 3, 1, '2025-01-30', 'Absent', 1, '2025-10-15 11:48:37');
INSERT INTO `attendance_records` VALUES (519, '2015100053', 2, 1, '2025-10-16', 'Present', 1, '2025-10-16 15:47:08');

-- ----------------------------
-- Table structure for room
-- ----------------------------
DROP TABLE IF EXISTS `room`;
CREATE TABLE `room`  (
  `RoomID` int(11) NOT NULL AUTO_INCREMENT,
  `RoomName` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_uca1400_ai_ci NULL DEFAULT NULL,
  PRIMARY KEY (`RoomID`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 4 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_uca1400_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of room
-- ----------------------------
INSERT INTO `room` VALUES (1, 'R1-101');
INSERT INTO `room` VALUES (2, 'R1-102');
INSERT INTO `room` VALUES (3, 'R1-103');

-- ----------------------------
-- Table structure for section_subjects
-- ----------------------------
DROP TABLE IF EXISTS `section_subjects`;
CREATE TABLE `section_subjects`  (
  `SectionID` int(11) NOT NULL,
  `SubjectID` int(11) NOT NULL,
  `TeacherID` int(11) NULL DEFAULT NULL,
  `RoomID` int(11) NULL DEFAULT NULL,
  `CreatedAt` timestamp(0) NULL DEFAULT current_timestamp(),
  `StartTime` time(0) NULL DEFAULT NULL,
  `EndTime` time(0) NULL DEFAULT NULL,
  PRIMARY KEY (`SectionID`, `SubjectID`) USING BTREE,
  INDEX `idx_section_subjects_section`(`SectionID`) USING BTREE,
  INDEX `idx_section_subjects_subject`(`SubjectID`) USING BTREE,
  INDEX `idx_section_subjects_teacher`(`TeacherID`) USING BTREE,
  CONSTRAINT `section_subjects_ibfk_1` FOREIGN KEY (`SectionID`) REFERENCES `sections` (`SectionID`) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT `section_subjects_ibfk_2` FOREIGN KEY (`SubjectID`) REFERENCES `subjects` (`SubjectID`) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT `section_subjects_ibfk_3` FOREIGN KEY (`TeacherID`) REFERENCES `teachers` (`TeacherID`) ON DELETE SET NULL ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_uca1400_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of section_subjects
-- ----------------------------
INSERT INTO `section_subjects` VALUES (1, 1, 1, 1, '2025-09-29 07:29:39', '07:00:00', '08:00:00');
INSERT INTO `section_subjects` VALUES (1, 2, 1, 1, '2025-09-29 07:29:39', '15:00:00', '16:00:00');
INSERT INTO `section_subjects` VALUES (1, 3, 1, 1, '2025-09-29 07:29:39', '09:00:00', '10:00:00');
INSERT INTO `section_subjects` VALUES (2, 1, 1, NULL, '2025-09-29 07:29:39', '07:00:00', '08:00:00');
INSERT INTO `section_subjects` VALUES (2, 3, 1, NULL, '2025-09-29 07:29:39', '08:00:00', '09:00:00');
INSERT INTO `section_subjects` VALUES (2, 4, 1, NULL, '2025-09-29 07:29:39', '09:00:00', '10:00:00');

-- ----------------------------
-- Table structure for sections
-- ----------------------------
DROP TABLE IF EXISTS `sections`;
CREATE TABLE `sections`  (
  `SectionID` int(11) NOT NULL AUTO_INCREMENT,
  `SectionName` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_uca1400_ai_ci NOT NULL,
  `CreatedAt` timestamp(0) NULL DEFAULT current_timestamp(),
  `UpdatedAt` timestamp(0) NULL DEFAULT current_timestamp() ON UPDATE CURRENT_TIMESTAMP(0),
  `StatusID` int(15) NULL DEFAULT NULL,
  PRIMARY KEY (`SectionID`) USING BTREE,
  UNIQUE INDEX `SectionName`(`SectionName`) USING BTREE,
  INDEX `idx_sections_name`(`SectionName`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 3 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_uca1400_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sections
-- ----------------------------
INSERT INTO `sections` VALUES (1, 'R1', '2025-09-29 06:02:50', '2025-10-06 20:29:57', 1);
INSERT INTO `sections` VALUES (2, 'R2', '2025-09-29 06:02:50', '2025-10-06 20:29:45', 1);

-- ----------------------------
-- Table structure for status
-- ----------------------------
DROP TABLE IF EXISTS `status`;
CREATE TABLE `status`  (
  `StatusID` int(11) NOT NULL AUTO_INCREMENT,
  `StatusName` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_uca1400_ai_ci NOT NULL,
  PRIMARY KEY (`StatusID`) USING BTREE,
  UNIQUE INDEX `StatusName`(`StatusName`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 5 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_uca1400_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of status
-- ----------------------------
INSERT INTO `status` VALUES (1, 'Active');
INSERT INTO `status` VALUES (4, 'Graduated');
INSERT INTO `status` VALUES (2, 'Inactive');
INSERT INTO `status` VALUES (3, 'Suspended');

-- ----------------------------
-- Table structure for students
-- ----------------------------
DROP TABLE IF EXISTS `students`;
CREATE TABLE `students`  (
  `StudentID` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_uca1400_ai_ci NOT NULL,
  `FirstName` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_uca1400_ai_ci NOT NULL,
  `LastName` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_uca1400_ai_ci NOT NULL,
  `MiddleName` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_uca1400_ai_ci NULL DEFAULT NULL,
  `StatusID` int(11) NOT NULL,
  `YearLevel` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_uca1400_ai_ci NOT NULL,
  `UserID` int(11) NULL DEFAULT NULL,
  `CreatedAt` timestamp(0) NULL DEFAULT current_timestamp(),
  `UpdatedAt` timestamp(0) NULL DEFAULT current_timestamp() ON UPDATE CURRENT_TIMESTAMP(0),
  PRIMARY KEY (`StudentID`) USING BTREE,
  INDEX `StatusID`(`StatusID`) USING BTREE,
  INDEX `UserID`(`UserID`) USING BTREE,
  INDEX `idx_students_name`(`FirstName`, `LastName`) USING BTREE,
  CONSTRAINT `students_ibfk_1` FOREIGN KEY (`StatusID`) REFERENCES `status` (`StatusID`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `students_ibfk_2` FOREIGN KEY (`UserID`) REFERENCES `users` (`UserID`) ON DELETE SET NULL ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_uca1400_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of students
-- ----------------------------
INSERT INTO `students` VALUES ('2015100053', 'John', 'Baptish', 'Peter', 1, 'Grade 11', NULL, '2025-09-29 07:03:46', '2025-09-29 07:03:46');
INSERT INTO `students` VALUES ('20151021011', 'John Doe', 'Recard', 'Moe', 1, 'Grade 11', NULL, '2025-09-29 10:54:56', '2025-09-29 10:54:56');
INSERT INTO `students` VALUES ('2024001', 'Jane', 'Doe', 'Marie', 1, 'Grade 10', 3, '2025-09-29 06:02:50', '2025-09-29 06:02:50');
INSERT INTO `students` VALUES ('2024002', 'Bob', 'Johnson', 'David', 1, 'Grade 10', NULL, '2025-09-29 06:02:50', '2025-09-29 06:02:50');
INSERT INTO `students` VALUES ('2024003', 'Alice', 'Wilson', 'Rose', 1, 'Grade 11', NULL, '2025-09-29 06:02:50', '2025-09-29 06:02:50');

-- ----------------------------
-- Table structure for subject_enrollments
-- ----------------------------
DROP TABLE IF EXISTS `subject_enrollments`;
CREATE TABLE `subject_enrollments`  (
  `SectionID` int(11) NOT NULL,
  `SubjectID` int(11) NOT NULL,
  `StudentID` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_uca1400_ai_ci NOT NULL,
  `EnrolledAt` timestamp(0) NULL DEFAULT current_timestamp(),
  `Status` enum('Active','Inactive','Completed','Dropped') CHARACTER SET utf8mb4 COLLATE utf8mb4_uca1400_ai_ci NULL DEFAULT 'Active',
  PRIMARY KEY (`SectionID`, `SubjectID`, `StudentID`) USING BTREE,
  INDEX `idx_subject_enrollments_section`(`SectionID`) USING BTREE,
  INDEX `idx_subject_enrollments_subject`(`SubjectID`) USING BTREE,
  INDEX `idx_subject_enrollments_student`(`StudentID`) USING BTREE,
  INDEX `idx_subject_enrollments_status`(`Status`) USING BTREE,
  CONSTRAINT `subject_enrollments_ibfk_1` FOREIGN KEY (`SectionID`) REFERENCES `sections` (`SectionID`) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT `subject_enrollments_ibfk_2` FOREIGN KEY (`SubjectID`) REFERENCES `subjects` (`SubjectID`) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT `subject_enrollments_ibfk_3` FOREIGN KEY (`StudentID`) REFERENCES `students` (`StudentID`) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT `subject_enrollments_ibfk_4` FOREIGN KEY (`SectionID`, `SubjectID`) REFERENCES `section_subjects` (`SectionID`, `SubjectID`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_uca1400_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of subject_enrollments
-- ----------------------------
INSERT INTO `subject_enrollments` VALUES (1, 1, '2024001', '2025-10-06 10:24:32', 'Active');
INSERT INTO `subject_enrollments` VALUES (1, 1, '2024002', '2025-10-06 10:24:32', 'Active');
INSERT INTO `subject_enrollments` VALUES (1, 1, '2024003', '2025-10-06 10:07:33', 'Active');
INSERT INTO `subject_enrollments` VALUES (1, 2, '2024001', '2025-10-06 12:17:58', 'Active');
INSERT INTO `subject_enrollments` VALUES (1, 2, '2024002', '2025-10-06 12:17:58', 'Active');
INSERT INTO `subject_enrollments` VALUES (1, 2, '2024003', '2025-10-06 10:25:21', 'Active');
INSERT INTO `subject_enrollments` VALUES (1, 3, '2024003', '2025-10-09 08:31:48', 'Active');
INSERT INTO `subject_enrollments` VALUES (2, 1, '2024003', '2025-10-06 10:24:32', 'Active');
INSERT INTO `subject_enrollments` VALUES (2, 3, '2024003', '2025-10-06 10:24:32', 'Active');

-- ----------------------------
-- Table structure for subjects
-- ----------------------------
DROP TABLE IF EXISTS `subjects`;
CREATE TABLE `subjects`  (
  `SubjectID` int(11) NOT NULL AUTO_INCREMENT,
  `SubjectName` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_uca1400_ai_ci NOT NULL,
  `SubjectCode` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_uca1400_ai_ci NOT NULL,
  `Room` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_uca1400_ai_ci NULL DEFAULT NULL,
  `StartTime` time(0) NULL DEFAULT NULL,
  `EndTime` time(0) NULL DEFAULT NULL,
  `StatusID` int(11) NOT NULL,
  `CreatedAt` timestamp(0) NULL DEFAULT current_timestamp(),
  `UpdatedAt` timestamp(0) NULL DEFAULT current_timestamp() ON UPDATE CURRENT_TIMESTAMP(0),
  PRIMARY KEY (`SubjectID`) USING BTREE,
  UNIQUE INDEX `SubjectCode`(`SubjectCode`) USING BTREE,
  INDEX `StatusID`(`StatusID`) USING BTREE,
  INDEX `idx_subjects_code`(`SubjectCode`) USING BTREE,
  CONSTRAINT `subjects_ibfk_1` FOREIGN KEY (`StatusID`) REFERENCES `status` (`StatusID`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 7 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_uca1400_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of subjects
-- ----------------------------
INSERT INTO `subjects` VALUES (1, 'Mathematics', 'MATH101', 'Room 101', '08:00:00', '09:00:00', 1, '2025-09-29 06:02:50', '2025-10-09 07:47:10');
INSERT INTO `subjects` VALUES (2, 'English Language', 'ENG101', 'Room 102', '09:00:00', '10:00:00', 1, '2025-09-29 06:02:50', '2025-10-09 07:47:10');
INSERT INTO `subjects` VALUES (3, 'Science', 'SCI101', 'Room 103', '10:00:00', '11:00:00', 1, '2025-09-29 06:02:50', '2025-10-09 07:47:10');
INSERT INTO `subjects` VALUES (4, 'Social Studies', 'SS101', NULL, NULL, NULL, 1, '2025-09-29 06:02:50', '2025-09-29 06:02:50');
INSERT INTO `subjects` VALUES (5, 'Physical Education', 'PE101', NULL, NULL, NULL, 1, '2025-09-29 06:02:50', '2025-09-29 06:02:50');
INSERT INTO `subjects` VALUES (6, 'Godspel', 'god1', NULL, NULL, NULL, 1, '2025-09-29 07:05:15', '2025-09-29 07:05:15');

-- ----------------------------
-- Table structure for teacher_subjects
-- ----------------------------
DROP TABLE IF EXISTS `teacher_subjects`;
CREATE TABLE `teacher_subjects`  (
  `TeacherID` int(11) NOT NULL,
  `SubjectID` int(11) NOT NULL,
  `AssignedAt` timestamp(0) NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`TeacherID`, `SubjectID`) USING BTREE,
  INDEX `SubjectID`(`SubjectID`) USING BTREE,
  CONSTRAINT `teacher_subjects_ibfk_1` FOREIGN KEY (`TeacherID`) REFERENCES `teachers` (`TeacherID`) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT `teacher_subjects_ibfk_2` FOREIGN KEY (`SubjectID`) REFERENCES `subjects` (`SubjectID`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_uca1400_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of teacher_subjects
-- ----------------------------
INSERT INTO `teacher_subjects` VALUES (1, 1, '2025-09-29 06:02:50');
INSERT INTO `teacher_subjects` VALUES (1, 3, '2025-09-29 06:02:50');

-- ----------------------------
-- Table structure for teachers
-- ----------------------------
DROP TABLE IF EXISTS `teachers`;
CREATE TABLE `teachers`  (
  `TeacherID` int(11) NOT NULL AUTO_INCREMENT,
  `FirstName` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_uca1400_ai_ci NOT NULL,
  `LastName` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_uca1400_ai_ci NOT NULL,
  `MiddleName` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_uca1400_ai_ci NULL DEFAULT NULL,
  `Role` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_uca1400_ai_ci NULL DEFAULT NULL,
  `StatusID` int(11) NOT NULL,
  `UserID` int(11) NULL DEFAULT NULL,
  `CreatedAt` timestamp(0) NULL DEFAULT current_timestamp(),
  `UpdatedAt` timestamp(0) NULL DEFAULT current_timestamp() ON UPDATE CURRENT_TIMESTAMP(0),
  PRIMARY KEY (`TeacherID`) USING BTREE,
  INDEX `StatusID`(`StatusID`) USING BTREE,
  INDEX `UserID`(`UserID`) USING BTREE,
  INDEX `idx_teachers_name`(`FirstName`, `LastName`) USING BTREE,
  CONSTRAINT `teachers_ibfk_1` FOREIGN KEY (`StatusID`) REFERENCES `status` (`StatusID`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `teachers_ibfk_2` FOREIGN KEY (`UserID`) REFERENCES `users` (`UserID`) ON DELETE SET NULL ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 3 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_uca1400_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of teachers
-- ----------------------------
INSERT INTO `teachers` VALUES (1, 'John1', 'Smith', 'Michael', 'Mathematics Teacher', 1, 2, '2025-09-29 06:02:50', '2025-09-29 07:04:11');
INSERT INTO `teachers` VALUES (2, 'Peter', 'Simon', 'Apostle', 'Teacher', 1, NULL, '2025-09-29 07:04:26', '2025-09-29 07:04:26');

-- ----------------------------
-- Table structure for users
-- ----------------------------
DROP TABLE IF EXISTS `users`;
CREATE TABLE `users`  (
  `UserID` int(11) NOT NULL AUTO_INCREMENT,
  `Email` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_uca1400_ai_ci NOT NULL,
  `Password` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_uca1400_ai_ci NOT NULL,
  `Role` enum('Admin','Teacher','Student') CHARACTER SET utf8mb4 COLLATE utf8mb4_uca1400_ai_ci NOT NULL,
  `StatusID` int(11) NOT NULL,
  `CreatedAt` timestamp(0) NULL DEFAULT current_timestamp(),
  `UpdatedAt` timestamp(0) NULL DEFAULT current_timestamp() ON UPDATE CURRENT_TIMESTAMP(0),
  PRIMARY KEY (`UserID`) USING BTREE,
  UNIQUE INDEX `Email`(`Email`) USING BTREE,
  INDEX `StatusID`(`StatusID`) USING BTREE,
  INDEX `idx_users_email`(`Email`) USING BTREE,
  CONSTRAINT `users_ibfk_1` FOREIGN KEY (`StatusID`) REFERENCES `status` (`StatusID`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 4 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_uca1400_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of users
-- ----------------------------
INSERT INTO `users` VALUES (1, 'admin@school.com', '$2a$10$manohOFxnowZRzaca0jCzOd2M7ozwe817IIkz.LnOSlsa0azVeOyu', 'Admin', 1, '2025-09-29 06:02:50', '2025-09-29 06:38:53');
INSERT INTO `users` VALUES (2, 'teacher@school.com', '$2a$10$manohOFxnowZRzaca0jCzOd2M7ozwe817IIkz.LnOSlsa0azVeOyu', 'Teacher', 1, '2025-09-29 06:02:50', '2025-09-29 06:38:53');
INSERT INTO `users` VALUES (3, 'student@school.com', '$2a$10$manohOFxnowZRzaca0jCzOd2M7ozwe817IIkz.LnOSlsa0azVeOyu', 'Student', 1, '2025-09-29 06:02:50', '2025-09-29 06:38:53');

SET FOREIGN_KEY_CHECKS = 1;

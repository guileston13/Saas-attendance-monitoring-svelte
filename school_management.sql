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

 Date: 02/12/2025 12:10:50
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
  `class_subject_id` int(11) NULL DEFAULT NULL,
  `section_id` int(11) NOT NULL,
  `attendance_date` date NOT NULL,
  `login_time` time(0) NULL DEFAULT NULL,
  `status` enum('Present','Absent','Late','') CHARACTER SET utf8mb4 COLLATE utf8mb4_uca1400_ai_ci NULL DEFAULT 'Absent',
  `recorded_by` int(11) NULL DEFAULT NULL,
  `recorded_at` timestamp(0) NULL DEFAULT current_timestamp() ON UPDATE CURRENT_TIMESTAMP(0),
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `unique_attendance`(`student_id`, `subject_id`, `section_id`, `attendance_date`) USING BTREE,
  INDEX `subject_id`(`subject_id`) USING BTREE,
  INDEX `section_id`(`section_id`) USING BTREE,
  INDEX `recorded_by`(`recorded_by`) USING BTREE,
  INDEX `idx_attendance_date_time`(`attendance_date`, `login_time`) USING BTREE,
  INDEX `idx_attendance_teacher`(`recorded_by`) USING BTREE,
  INDEX `idx_attendance_lookup`(`section_id`, `subject_id`, `student_id`, `attendance_date`) USING BTREE,
  CONSTRAINT `attendance_records_ibfk_1` FOREIGN KEY (`student_id`) REFERENCES `students` (`StudentID`) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT `attendance_records_ibfk_2` FOREIGN KEY (`subject_id`) REFERENCES `course_catalog` (`SubjectID`) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT `attendance_records_ibfk_3` FOREIGN KEY (`section_id`) REFERENCES `sections` (`SectionID`) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT `attendance_records_ibfk_4` FOREIGN KEY (`recorded_by`) REFERENCES `users` (`UserID`) ON DELETE SET NULL ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 3947 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_uca1400_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of attendance_records
-- ----------------------------
INSERT INTO `attendance_records` VALUES (2360, '2021301661', 1, NULL, 1, '2025-11-03', '17:09:31', 'Present', 1, '2025-11-24 17:09:31');
INSERT INTO `attendance_records` VALUES (2361, '2021301661', 1, NULL, 1, '2025-11-04', '17:09:32', 'Present', 1, '2025-11-24 17:09:32');
INSERT INTO `attendance_records` VALUES (2365, '2021301661', 1, NULL, 1, '2025-11-10', '17:09:40', 'Present', 1, '2025-11-24 17:09:40');
INSERT INTO `attendance_records` VALUES (2366, '2021301661', 1, NULL, 1, '2025-11-11', '17:09:41', 'Present', 1, '2025-11-24 17:09:41');
INSERT INTO `attendance_records` VALUES (2370, '2021301661', 1, NULL, 1, '2025-11-17', '17:09:44', 'Present', 1, '2025-11-24 17:09:44');
INSERT INTO `attendance_records` VALUES (2371, '2021301661', 1, NULL, 1, '2025-11-18', '17:09:46', 'Present', 1, '2025-11-24 17:09:46');
INSERT INTO `attendance_records` VALUES (2375, '2021301661', 1, NULL, 1, '2025-11-24', '17:09:57', 'Present', 1, '2025-11-24 17:09:57');
INSERT INTO `attendance_records` VALUES (2376, '2021301661', 1, NULL, 1, '2025-11-25', '17:09:57', 'Present', 1, '2025-11-24 17:09:57');
INSERT INTO `attendance_records` VALUES (2380, '2013100521', 1, NULL, 1, '2025-11-03', '17:09:33', 'Present', 1, '2025-11-24 17:09:33');
INSERT INTO `attendance_records` VALUES (2385, '2013100521', 1, NULL, 1, '2025-11-10', '17:09:40', 'Present', 1, '2025-11-24 17:09:40');
INSERT INTO `attendance_records` VALUES (2386, '2013100521', 1, NULL, 1, '2025-11-11', '17:09:42', 'Present', 1, '2025-11-24 17:09:42');
INSERT INTO `attendance_records` VALUES (2390, '2013100521', 1, NULL, 1, '2025-11-17', '17:09:44', 'Present', 1, '2025-11-24 17:09:44');
INSERT INTO `attendance_records` VALUES (2391, '2013100521', 1, NULL, 1, '2025-11-18', '17:09:47', 'Present', 1, '2025-11-24 17:09:47');
INSERT INTO `attendance_records` VALUES (2395, '2013100521', 1, NULL, 1, '2025-11-24', '17:09:56', 'Present', 1, '2025-11-24 17:09:56');
INSERT INTO `attendance_records` VALUES (2396, '2013100521', 1, NULL, 1, '2025-11-25', '17:09:58', 'Present', 1, '2025-11-24 17:09:58');
INSERT INTO `attendance_records` VALUES (2403, '2021301661', 1, NULL, 1, '2025-11-07', '17:09:34', 'Present', 1, '2025-11-24 17:09:34');
INSERT INTO `attendance_records` VALUES (2404, '2013100521', 1, NULL, 1, '2025-11-07', '17:09:35', 'Present', 1, '2025-11-24 17:09:35');
INSERT INTO `attendance_records` VALUES (2409, '2021301661', 1, NULL, 1, '2025-11-14', '17:09:43', 'Present', 1, '2025-11-24 17:09:43');
INSERT INTO `attendance_records` VALUES (2410, '2013100521', 1, NULL, 1, '2025-11-14', '17:09:43', 'Present', 1, '2025-11-24 17:09:43');
INSERT INTO `attendance_records` VALUES (2415, '2021301661', 1, NULL, 1, '2025-11-21', '17:09:54', 'Present', 1, '2025-11-24 17:09:54');
INSERT INTO `attendance_records` VALUES (2416, '2013100521', 1, NULL, 1, '2025-11-21', '17:09:55', 'Present', 1, '2025-11-24 17:09:55');
INSERT INTO `attendance_records` VALUES (2421, '2021301661', 1, NULL, 1, '2025-11-28', '17:10:01', 'Present', 1, '2025-11-24 17:10:01');
INSERT INTO `attendance_records` VALUES (2422, '2013100521', 1, NULL, 1, '2025-11-28', '17:10:03', 'Present', 1, '2025-11-24 17:10:03');
INSERT INTO `attendance_records` VALUES (2523, '2022310275', 3, NULL, 1, '2025-11-28', '20:30:50', 'Late', 1, '2025-11-28 20:30:50');
INSERT INTO `attendance_records` VALUES (2535, '2022306538', 3, NULL, 1, '2025-11-28', '20:26:52', 'Present', 1, '2025-11-28 20:26:52');
INSERT INTO `attendance_records` VALUES (2536, '2022304979', 3, NULL, 1, '2025-11-28', '20:18:37', 'Late', 1, '2025-11-28 20:18:37');
INSERT INTO `attendance_records` VALUES (2538, '2022305036', 3, NULL, 1, '2025-11-28', '20:23:45', 'Late', 1, '2025-11-28 20:23:45');
INSERT INTO `attendance_records` VALUES (2539, '2022304738', 3, NULL, 1, '2024-12-31', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2540, '2022304738', 3, NULL, 1, '2025-01-01', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2541, '2022304738', 3, NULL, 1, '2025-01-02', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2542, '2022304738', 3, NULL, 1, '2025-01-05', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2543, '2022304738', 3, NULL, 1, '2025-01-06', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2544, '2022304738', 3, NULL, 1, '2025-01-07', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2545, '2022304738', 3, NULL, 1, '2025-01-08', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2546, '2022304738', 3, NULL, 1, '2025-01-09', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2547, '2022304738', 3, NULL, 1, '2025-01-12', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2548, '2022304738', 3, NULL, 1, '2025-01-13', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2549, '2022304738', 3, NULL, 1, '2025-01-14', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2550, '2022304738', 3, NULL, 1, '2025-01-15', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2551, '2022304738', 3, NULL, 1, '2025-01-16', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2552, '2022304738', 3, NULL, 1, '2025-01-19', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2553, '2022304738', 3, NULL, 1, '2025-01-20', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2554, '2022304738', 3, NULL, 1, '2025-01-21', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2555, '2022304738', 3, NULL, 1, '2025-01-22', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2556, '2022304738', 3, NULL, 1, '2025-01-23', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2557, '2022304738', 3, NULL, 1, '2025-01-26', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2558, '2022304738', 3, NULL, 1, '2025-01-27', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2559, '2022304738', 3, NULL, 1, '2025-01-28', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2560, '2022304738', 3, NULL, 1, '2025-01-29', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2561, '2022304738', 3, NULL, 1, '2025-01-30', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2562, '2021303569', 3, NULL, 1, '2024-12-31', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2563, '2021303569', 3, NULL, 1, '2025-01-01', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2564, '2021303569', 3, NULL, 1, '2025-01-02', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2565, '2021303569', 3, NULL, 1, '2025-01-05', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2566, '2021303569', 3, NULL, 1, '2025-01-06', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2567, '2021303569', 3, NULL, 1, '2025-01-07', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2568, '2021303569', 3, NULL, 1, '2025-01-08', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2569, '2021303569', 3, NULL, 1, '2025-01-09', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2570, '2021303569', 3, NULL, 1, '2025-01-12', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2571, '2021303569', 3, NULL, 1, '2025-01-13', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2572, '2021303569', 3, NULL, 1, '2025-01-14', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2573, '2021303569', 3, NULL, 1, '2025-01-15', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2574, '2021303569', 3, NULL, 1, '2025-01-16', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2575, '2021303569', 3, NULL, 1, '2025-01-19', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2576, '2021303569', 3, NULL, 1, '2025-01-20', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2577, '2021303569', 3, NULL, 1, '2025-01-21', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2578, '2021303569', 3, NULL, 1, '2025-01-22', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2579, '2021303569', 3, NULL, 1, '2025-01-23', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2580, '2021303569', 3, NULL, 1, '2025-01-26', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2581, '2021303569', 3, NULL, 1, '2025-01-27', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2582, '2021303569', 3, NULL, 1, '2025-01-28', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2583, '2021303569', 3, NULL, 1, '2025-01-29', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2584, '2021303569', 3, NULL, 1, '2025-01-30', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2585, '2021301661', 3, NULL, 1, '2024-12-31', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2586, '2021301661', 3, NULL, 1, '2025-01-01', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2587, '2021301661', 3, NULL, 1, '2025-01-02', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2588, '2021301661', 3, NULL, 1, '2025-01-05', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2589, '2021301661', 3, NULL, 1, '2025-01-06', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2590, '2021301661', 3, NULL, 1, '2025-01-07', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2591, '2021301661', 3, NULL, 1, '2025-01-08', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2592, '2021301661', 3, NULL, 1, '2025-01-09', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2593, '2021301661', 3, NULL, 1, '2025-01-12', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2594, '2021301661', 3, NULL, 1, '2025-01-13', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2595, '2021301661', 3, NULL, 1, '2025-01-14', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2596, '2021301661', 3, NULL, 1, '2025-01-15', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2597, '2021301661', 3, NULL, 1, '2025-01-16', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2598, '2021301661', 3, NULL, 1, '2025-01-19', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2599, '2021301661', 3, NULL, 1, '2025-01-20', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2600, '2021301661', 3, NULL, 1, '2025-01-21', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2601, '2021301661', 3, NULL, 1, '2025-01-22', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2602, '2021301661', 3, NULL, 1, '2025-01-23', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2603, '2021301661', 3, NULL, 1, '2025-01-26', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2604, '2021301661', 3, NULL, 1, '2025-01-27', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2605, '2021301661', 3, NULL, 1, '2025-01-28', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2606, '2021301661', 3, NULL, 1, '2025-01-29', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2607, '2021301661', 3, NULL, 1, '2025-01-30', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2608, '2021309452', 3, NULL, 1, '2024-12-31', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2609, '2021309452', 3, NULL, 1, '2025-01-01', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2610, '2021309452', 3, NULL, 1, '2025-01-02', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2611, '2021309452', 3, NULL, 1, '2025-01-05', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2612, '2021309452', 3, NULL, 1, '2025-01-06', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2613, '2021309452', 3, NULL, 1, '2025-01-07', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2614, '2021309452', 3, NULL, 1, '2025-01-08', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2615, '2021309452', 3, NULL, 1, '2025-01-09', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2616, '2021309452', 3, NULL, 1, '2025-01-12', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2617, '2021309452', 3, NULL, 1, '2025-01-13', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2618, '2021309452', 3, NULL, 1, '2025-01-14', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2619, '2021309452', 3, NULL, 1, '2025-01-15', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2620, '2021309452', 3, NULL, 1, '2025-01-16', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2621, '2021309452', 3, NULL, 1, '2025-01-19', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2622, '2021309452', 3, NULL, 1, '2025-01-20', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2623, '2021309452', 3, NULL, 1, '2025-01-21', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2624, '2021309452', 3, NULL, 1, '2025-01-22', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2625, '2021309452', 3, NULL, 1, '2025-01-23', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2626, '2021309452', 3, NULL, 1, '2025-01-26', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2627, '2021309452', 3, NULL, 1, '2025-01-27', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2628, '2021309452', 3, NULL, 1, '2025-01-28', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2629, '2021309452', 3, NULL, 1, '2025-01-29', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2630, '2021309452', 3, NULL, 1, '2025-01-30', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2631, '2022304760', 3, NULL, 1, '2024-12-31', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2632, '2022304760', 3, NULL, 1, '2025-01-01', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2633, '2022304760', 3, NULL, 1, '2025-01-02', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2634, '2022304760', 3, NULL, 1, '2025-01-05', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2635, '2022304760', 3, NULL, 1, '2025-01-06', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2636, '2022304760', 3, NULL, 1, '2025-01-07', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2637, '2022304760', 3, NULL, 1, '2025-01-08', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2638, '2022304760', 3, NULL, 1, '2025-01-09', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2639, '2022304760', 3, NULL, 1, '2025-01-12', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2640, '2022304760', 3, NULL, 1, '2025-01-13', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2641, '2022304760', 3, NULL, 1, '2025-01-14', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2642, '2022304760', 3, NULL, 1, '2025-01-15', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2643, '2022304760', 3, NULL, 1, '2025-01-16', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2644, '2022304760', 3, NULL, 1, '2025-01-19', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2645, '2022304760', 3, NULL, 1, '2025-01-20', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2646, '2022304760', 3, NULL, 1, '2025-01-21', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2647, '2022304760', 3, NULL, 1, '2025-01-22', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2648, '2022304760', 3, NULL, 1, '2025-01-23', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2649, '2022304760', 3, NULL, 1, '2025-01-26', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2650, '2022304760', 3, NULL, 1, '2025-01-27', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2651, '2022304760', 3, NULL, 1, '2025-01-28', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2652, '2022304760', 3, NULL, 1, '2025-01-29', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2653, '2022304760', 3, NULL, 1, '2025-01-30', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2654, '2020302622', 3, NULL, 1, '2024-12-31', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2655, '2020302622', 3, NULL, 1, '2025-01-01', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2656, '2020302622', 3, NULL, 1, '2025-01-02', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2657, '2020302622', 3, NULL, 1, '2025-01-05', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2658, '2020302622', 3, NULL, 1, '2025-01-06', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2659, '2020302622', 3, NULL, 1, '2025-01-07', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2660, '2020302622', 3, NULL, 1, '2025-01-08', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2661, '2020302622', 3, NULL, 1, '2025-01-09', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2662, '2020302622', 3, NULL, 1, '2025-01-12', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2663, '2020302622', 3, NULL, 1, '2025-01-13', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2664, '2020302622', 3, NULL, 1, '2025-01-14', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2665, '2020302622', 3, NULL, 1, '2025-01-15', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2666, '2020302622', 3, NULL, 1, '2025-01-16', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2667, '2020302622', 3, NULL, 1, '2025-01-19', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2668, '2020302622', 3, NULL, 1, '2025-01-20', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2669, '2020302622', 3, NULL, 1, '2025-01-21', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2670, '2020302622', 3, NULL, 1, '2025-01-22', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2671, '2020302622', 3, NULL, 1, '2025-01-23', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2672, '2020302622', 3, NULL, 1, '2025-01-26', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2673, '2020302622', 3, NULL, 1, '2025-01-27', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2674, '2020302622', 3, NULL, 1, '2025-01-28', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2675, '2020302622', 3, NULL, 1, '2025-01-29', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2676, '2020302622', 3, NULL, 1, '2025-01-30', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2677, '2022311007', 3, NULL, 1, '2024-12-31', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2678, '2022311007', 3, NULL, 1, '2025-01-01', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2679, '2022311007', 3, NULL, 1, '2025-01-02', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2680, '2022311007', 3, NULL, 1, '2025-01-05', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2681, '2022311007', 3, NULL, 1, '2025-01-06', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2682, '2022311007', 3, NULL, 1, '2025-01-07', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2683, '2022311007', 3, NULL, 1, '2025-01-08', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2684, '2022311007', 3, NULL, 1, '2025-01-09', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2685, '2022311007', 3, NULL, 1, '2025-01-12', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2686, '2022311007', 3, NULL, 1, '2025-01-13', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2687, '2022311007', 3, NULL, 1, '2025-01-14', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2688, '2022311007', 3, NULL, 1, '2025-01-15', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2689, '2022311007', 3, NULL, 1, '2025-01-16', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2690, '2022311007', 3, NULL, 1, '2025-01-19', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2691, '2022311007', 3, NULL, 1, '2025-01-20', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2692, '2022311007', 3, NULL, 1, '2025-01-21', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2693, '2022311007', 3, NULL, 1, '2025-01-22', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2694, '2022311007', 3, NULL, 1, '2025-01-23', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2695, '2022311007', 3, NULL, 1, '2025-01-26', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2696, '2022311007', 3, NULL, 1, '2025-01-27', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2697, '2022311007', 3, NULL, 1, '2025-01-28', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2698, '2022311007', 3, NULL, 1, '2025-01-29', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2699, '2022311007', 3, NULL, 1, '2025-01-30', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2700, '2022306538', 3, NULL, 1, '2024-12-31', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2701, '2022306538', 3, NULL, 1, '2025-01-01', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2702, '2022306538', 3, NULL, 1, '2025-01-02', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2703, '2022306538', 3, NULL, 1, '2025-01-05', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2704, '2022306538', 3, NULL, 1, '2025-01-06', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2705, '2022306538', 3, NULL, 1, '2025-01-07', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2706, '2022306538', 3, NULL, 1, '2025-01-08', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2707, '2022306538', 3, NULL, 1, '2025-01-09', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2708, '2022306538', 3, NULL, 1, '2025-01-12', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2709, '2022306538', 3, NULL, 1, '2025-01-13', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2710, '2022306538', 3, NULL, 1, '2025-01-14', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2711, '2022306538', 3, NULL, 1, '2025-01-15', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2712, '2022306538', 3, NULL, 1, '2025-01-16', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2713, '2022306538', 3, NULL, 1, '2025-01-19', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2714, '2022306538', 3, NULL, 1, '2025-01-20', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2715, '2022306538', 3, NULL, 1, '2025-01-21', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2716, '2022306538', 3, NULL, 1, '2025-01-22', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2717, '2022306538', 3, NULL, 1, '2025-01-23', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2718, '2022306538', 3, NULL, 1, '2025-01-26', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2719, '2022306538', 3, NULL, 1, '2025-01-27', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2720, '2022306538', 3, NULL, 1, '2025-01-28', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2721, '2022306538', 3, NULL, 1, '2025-01-29', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2722, '2022306538', 3, NULL, 1, '2025-01-30', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2723, '2022304808', 3, NULL, 1, '2024-12-31', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2724, '2022304808', 3, NULL, 1, '2025-01-01', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2725, '2022304808', 3, NULL, 1, '2025-01-02', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2726, '2022304808', 3, NULL, 1, '2025-01-05', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2727, '2022304808', 3, NULL, 1, '2025-01-06', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2728, '2022304808', 3, NULL, 1, '2025-01-07', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2729, '2022304808', 3, NULL, 1, '2025-01-08', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2730, '2022304808', 3, NULL, 1, '2025-01-09', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2731, '2022304808', 3, NULL, 1, '2025-01-12', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2732, '2022304808', 3, NULL, 1, '2025-01-13', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2733, '2022304808', 3, NULL, 1, '2025-01-14', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2734, '2022304808', 3, NULL, 1, '2025-01-15', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2735, '2022304808', 3, NULL, 1, '2025-01-16', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2736, '2022304808', 3, NULL, 1, '2025-01-19', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2737, '2022304808', 3, NULL, 1, '2025-01-20', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2738, '2022304808', 3, NULL, 1, '2025-01-21', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2739, '2022304808', 3, NULL, 1, '2025-01-22', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2740, '2022304808', 3, NULL, 1, '2025-01-23', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2741, '2022304808', 3, NULL, 1, '2025-01-26', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2742, '2022304808', 3, NULL, 1, '2025-01-27', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2743, '2022304808', 3, NULL, 1, '2025-01-28', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2744, '2022304808', 3, NULL, 1, '2025-01-29', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2745, '2022304808', 3, NULL, 1, '2025-01-30', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2746, '2022306420', 3, NULL, 1, '2024-12-31', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2747, '2022306420', 3, NULL, 1, '2025-01-01', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2748, '2022306420', 3, NULL, 1, '2025-01-02', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2749, '2022306420', 3, NULL, 1, '2025-01-05', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2750, '2022306420', 3, NULL, 1, '2025-01-06', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2751, '2022306420', 3, NULL, 1, '2025-01-07', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2752, '2022306420', 3, NULL, 1, '2025-01-08', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2753, '2022306420', 3, NULL, 1, '2025-01-09', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2754, '2022306420', 3, NULL, 1, '2025-01-12', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2755, '2022306420', 3, NULL, 1, '2025-01-13', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2756, '2022306420', 3, NULL, 1, '2025-01-14', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2757, '2022306420', 3, NULL, 1, '2025-01-15', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2758, '2022306420', 3, NULL, 1, '2025-01-16', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2759, '2022306420', 3, NULL, 1, '2025-01-19', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2760, '2022306420', 3, NULL, 1, '2025-01-20', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2761, '2022306420', 3, NULL, 1, '2025-01-21', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2762, '2022306420', 3, NULL, 1, '2025-01-22', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2763, '2022306420', 3, NULL, 1, '2025-01-23', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2764, '2022306420', 3, NULL, 1, '2025-01-26', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2765, '2022306420', 3, NULL, 1, '2025-01-27', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2766, '2022306420', 3, NULL, 1, '2025-01-28', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2767, '2022306420', 3, NULL, 1, '2025-01-29', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2768, '2022306420', 3, NULL, 1, '2025-01-30', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2769, '2022304754', 3, NULL, 1, '2024-12-31', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2770, '2022304754', 3, NULL, 1, '2025-01-01', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2771, '2022304754', 3, NULL, 1, '2025-01-02', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2772, '2022304754', 3, NULL, 1, '2025-01-05', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2773, '2022304754', 3, NULL, 1, '2025-01-06', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2774, '2022304754', 3, NULL, 1, '2025-01-07', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2775, '2022304754', 3, NULL, 1, '2025-01-08', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2776, '2022304754', 3, NULL, 1, '2025-01-09', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2777, '2022304754', 3, NULL, 1, '2025-01-12', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2778, '2022304754', 3, NULL, 1, '2025-01-13', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2779, '2022304754', 3, NULL, 1, '2025-01-14', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2780, '2022304754', 3, NULL, 1, '2025-01-15', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2781, '2022304754', 3, NULL, 1, '2025-01-16', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2782, '2022304754', 3, NULL, 1, '2025-01-19', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2783, '2022304754', 3, NULL, 1, '2025-01-20', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2784, '2022304754', 3, NULL, 1, '2025-01-21', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2785, '2022304754', 3, NULL, 1, '2025-01-22', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2786, '2022304754', 3, NULL, 1, '2025-01-23', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2787, '2022304754', 3, NULL, 1, '2025-01-26', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2788, '2022304754', 3, NULL, 1, '2025-01-27', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2789, '2022304754', 3, NULL, 1, '2025-01-28', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2790, '2022304754', 3, NULL, 1, '2025-01-29', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2791, '2022304754', 3, NULL, 1, '2025-01-30', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2792, '2022305059', 3, NULL, 1, '2024-12-31', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2793, '2022305059', 3, NULL, 1, '2025-01-01', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2794, '2022305059', 3, NULL, 1, '2025-01-02', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2795, '2022305059', 3, NULL, 1, '2025-01-05', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2796, '2022305059', 3, NULL, 1, '2025-01-06', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2797, '2022305059', 3, NULL, 1, '2025-01-07', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2798, '2022305059', 3, NULL, 1, '2025-01-08', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2799, '2022305059', 3, NULL, 1, '2025-01-09', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2800, '2022305059', 3, NULL, 1, '2025-01-12', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2801, '2022305059', 3, NULL, 1, '2025-01-13', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2802, '2022305059', 3, NULL, 1, '2025-01-14', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2803, '2022305059', 3, NULL, 1, '2025-01-15', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2804, '2022305059', 3, NULL, 1, '2025-01-16', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2805, '2022305059', 3, NULL, 1, '2025-01-19', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2806, '2022305059', 3, NULL, 1, '2025-01-20', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2807, '2022305059', 3, NULL, 1, '2025-01-21', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2808, '2022305059', 3, NULL, 1, '2025-01-22', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2809, '2022305059', 3, NULL, 1, '2025-01-23', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2810, '2022305059', 3, NULL, 1, '2025-01-26', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2811, '2022305059', 3, NULL, 1, '2025-01-27', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2812, '2022305059', 3, NULL, 1, '2025-01-28', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2813, '2022305059', 3, NULL, 1, '2025-01-29', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2814, '2022305059', 3, NULL, 1, '2025-01-30', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2815, '2015100053', 3, NULL, 1, '2024-12-31', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2816, '2015100053', 3, NULL, 1, '2025-01-01', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2817, '2015100053', 3, NULL, 1, '2025-01-02', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2818, '2015100053', 3, NULL, 1, '2025-01-05', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2819, '2015100053', 3, NULL, 1, '2025-01-06', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2820, '2015100053', 3, NULL, 1, '2025-01-07', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2821, '2015100053', 3, NULL, 1, '2025-01-08', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2822, '2015100053', 3, NULL, 1, '2025-01-09', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2823, '2015100053', 3, NULL, 1, '2025-01-12', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2824, '2015100053', 3, NULL, 1, '2025-01-13', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2825, '2015100053', 3, NULL, 1, '2025-01-14', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2826, '2015100053', 3, NULL, 1, '2025-01-15', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2827, '2015100053', 3, NULL, 1, '2025-01-16', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2828, '2015100053', 3, NULL, 1, '2025-01-19', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2829, '2015100053', 3, NULL, 1, '2025-01-20', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2830, '2015100053', 3, NULL, 1, '2025-01-21', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2831, '2015100053', 3, NULL, 1, '2025-01-22', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2832, '2015100053', 3, NULL, 1, '2025-01-23', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2833, '2015100053', 3, NULL, 1, '2025-01-26', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2834, '2015100053', 3, NULL, 1, '2025-01-27', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2835, '2015100053', 3, NULL, 1, '2025-01-28', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2836, '2015100053', 3, NULL, 1, '2025-01-29', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2837, '2015100053', 3, NULL, 1, '2025-01-30', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2838, '2023308166', 3, NULL, 1, '2024-12-31', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2839, '2023308166', 3, NULL, 1, '2025-01-01', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2840, '2023308166', 3, NULL, 1, '2025-01-02', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2841, '2023308166', 3, NULL, 1, '2025-01-05', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2842, '2023308166', 3, NULL, 1, '2025-01-06', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2843, '2023308166', 3, NULL, 1, '2025-01-07', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2844, '2023308166', 3, NULL, 1, '2025-01-08', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2845, '2023308166', 3, NULL, 1, '2025-01-09', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2846, '2023308166', 3, NULL, 1, '2025-01-12', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2847, '2023308166', 3, NULL, 1, '2025-01-13', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2848, '2023308166', 3, NULL, 1, '2025-01-14', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2849, '2023308166', 3, NULL, 1, '2025-01-15', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2850, '2023308166', 3, NULL, 1, '2025-01-16', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2851, '2023308166', 3, NULL, 1, '2025-01-19', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2852, '2023308166', 3, NULL, 1, '2025-01-20', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2853, '2023308166', 3, NULL, 1, '2025-01-21', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2854, '2023308166', 3, NULL, 1, '2025-01-22', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2855, '2023308166', 3, NULL, 1, '2025-01-23', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2856, '2023308166', 3, NULL, 1, '2025-01-26', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2857, '2023308166', 3, NULL, 1, '2025-01-27', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2858, '2023308166', 3, NULL, 1, '2025-01-28', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2859, '2023308166', 3, NULL, 1, '2025-01-29', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2860, '2023308166', 3, NULL, 1, '2025-01-30', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2861, '2022303307', 3, NULL, 1, '2024-12-31', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2862, '2022303307', 3, NULL, 1, '2025-01-01', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2863, '2022303307', 3, NULL, 1, '2025-01-02', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2864, '2022303307', 3, NULL, 1, '2025-01-05', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2865, '2022303307', 3, NULL, 1, '2025-01-06', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2866, '2022303307', 3, NULL, 1, '2025-01-07', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2867, '2022303307', 3, NULL, 1, '2025-01-08', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2868, '2022303307', 3, NULL, 1, '2025-01-09', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2869, '2022303307', 3, NULL, 1, '2025-01-12', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2870, '2022303307', 3, NULL, 1, '2025-01-13', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2871, '2022303307', 3, NULL, 1, '2025-01-14', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2872, '2022303307', 3, NULL, 1, '2025-01-15', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2873, '2022303307', 3, NULL, 1, '2025-01-16', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2874, '2022303307', 3, NULL, 1, '2025-01-19', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2875, '2022303307', 3, NULL, 1, '2025-01-20', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2876, '2022303307', 3, NULL, 1, '2025-01-21', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2877, '2022303307', 3, NULL, 1, '2025-01-22', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2878, '2022303307', 3, NULL, 1, '2025-01-23', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2879, '2022303307', 3, NULL, 1, '2025-01-26', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2880, '2022303307', 3, NULL, 1, '2025-01-27', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2881, '2022303307', 3, NULL, 1, '2025-01-28', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2882, '2022303307', 3, NULL, 1, '2025-01-29', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2883, '2022303307', 3, NULL, 1, '2025-01-30', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2884, '2022310275', 3, NULL, 1, '2024-12-31', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2885, '2022310275', 3, NULL, 1, '2025-01-01', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2886, '2022310275', 3, NULL, 1, '2025-01-02', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2887, '2022310275', 3, NULL, 1, '2025-01-05', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2888, '2022310275', 3, NULL, 1, '2025-01-06', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2889, '2022310275', 3, NULL, 1, '2025-01-07', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2890, '2022310275', 3, NULL, 1, '2025-01-08', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2891, '2022310275', 3, NULL, 1, '2025-01-09', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2892, '2022310275', 3, NULL, 1, '2025-01-12', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2893, '2022310275', 3, NULL, 1, '2025-01-13', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2894, '2022310275', 3, NULL, 1, '2025-01-14', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2895, '2022310275', 3, NULL, 1, '2025-01-15', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2896, '2022310275', 3, NULL, 1, '2025-01-16', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2897, '2022310275', 3, NULL, 1, '2025-01-19', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2898, '2022310275', 3, NULL, 1, '2025-01-20', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2899, '2022310275', 3, NULL, 1, '2025-01-21', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2900, '2022310275', 3, NULL, 1, '2025-01-22', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2901, '2022310275', 3, NULL, 1, '2025-01-23', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2902, '2022310275', 3, NULL, 1, '2025-01-26', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2903, '2022310275', 3, NULL, 1, '2025-01-27', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2904, '2022310275', 3, NULL, 1, '2025-01-28', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2905, '2022310275', 3, NULL, 1, '2025-01-29', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2906, '2022310275', 3, NULL, 1, '2025-01-30', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2907, '2023307876', 3, NULL, 1, '2024-12-31', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2908, '2023307876', 3, NULL, 1, '2025-01-01', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2909, '2023307876', 3, NULL, 1, '2025-01-02', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2910, '2023307876', 3, NULL, 1, '2025-01-05', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2911, '2023307876', 3, NULL, 1, '2025-01-06', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2912, '2023307876', 3, NULL, 1, '2025-01-07', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2913, '2023307876', 3, NULL, 1, '2025-01-08', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2914, '2023307876', 3, NULL, 1, '2025-01-09', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2915, '2023307876', 3, NULL, 1, '2025-01-12', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2916, '2023307876', 3, NULL, 1, '2025-01-13', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2917, '2023307876', 3, NULL, 1, '2025-01-14', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2918, '2023307876', 3, NULL, 1, '2025-01-15', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2919, '2023307876', 3, NULL, 1, '2025-01-16', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2920, '2023307876', 3, NULL, 1, '2025-01-19', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2921, '2023307876', 3, NULL, 1, '2025-01-20', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2922, '2023307876', 3, NULL, 1, '2025-01-21', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2923, '2023307876', 3, NULL, 1, '2025-01-22', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2924, '2023307876', 3, NULL, 1, '2025-01-23', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2925, '2023307876', 3, NULL, 1, '2025-01-26', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2926, '2023307876', 3, NULL, 1, '2025-01-27', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2927, '2023307876', 3, NULL, 1, '2025-01-28', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2928, '2023307876', 3, NULL, 1, '2025-01-29', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2929, '2023307876', 3, NULL, 1, '2025-01-30', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2930, '2022303249', 3, NULL, 1, '2024-12-31', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2931, '2022303249', 3, NULL, 1, '2025-01-01', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2932, '2022303249', 3, NULL, 1, '2025-01-02', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2933, '2022303249', 3, NULL, 1, '2025-01-05', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2934, '2022303249', 3, NULL, 1, '2025-01-06', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2935, '2022303249', 3, NULL, 1, '2025-01-07', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2936, '2022303249', 3, NULL, 1, '2025-01-08', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2937, '2022303249', 3, NULL, 1, '2025-01-09', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2938, '2022303249', 3, NULL, 1, '2025-01-12', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2939, '2022303249', 3, NULL, 1, '2025-01-13', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2940, '2022303249', 3, NULL, 1, '2025-01-14', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2941, '2022303249', 3, NULL, 1, '2025-01-15', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2942, '2022303249', 3, NULL, 1, '2025-01-16', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2943, '2022303249', 3, NULL, 1, '2025-01-19', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2944, '2022303249', 3, NULL, 1, '2025-01-20', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2945, '2022303249', 3, NULL, 1, '2025-01-21', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2946, '2022303249', 3, NULL, 1, '2025-01-22', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2947, '2022303249', 3, NULL, 1, '2025-01-23', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2948, '2022303249', 3, NULL, 1, '2025-01-26', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2949, '2022303249', 3, NULL, 1, '2025-01-27', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2950, '2022303249', 3, NULL, 1, '2025-01-28', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2951, '2022303249', 3, NULL, 1, '2025-01-29', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2952, '2022303249', 3, NULL, 1, '2025-01-30', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2953, '2023308193', 3, NULL, 1, '2024-12-31', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2954, '2023308193', 3, NULL, 1, '2025-01-01', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2955, '2023308193', 3, NULL, 1, '2025-01-02', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2956, '2023308193', 3, NULL, 1, '2025-01-05', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2957, '2023308193', 3, NULL, 1, '2025-01-06', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2958, '2023308193', 3, NULL, 1, '2025-01-07', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2959, '2023308193', 3, NULL, 1, '2025-01-08', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2960, '2023308193', 3, NULL, 1, '2025-01-09', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2961, '2023308193', 3, NULL, 1, '2025-01-12', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2962, '2023308193', 3, NULL, 1, '2025-01-13', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2963, '2023308193', 3, NULL, 1, '2025-01-14', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2964, '2023308193', 3, NULL, 1, '2025-01-15', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2965, '2023308193', 3, NULL, 1, '2025-01-16', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2966, '2023308193', 3, NULL, 1, '2025-01-19', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2967, '2023308193', 3, NULL, 1, '2025-01-20', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2968, '2023308193', 3, NULL, 1, '2025-01-21', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2969, '2023308193', 3, NULL, 1, '2025-01-22', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2970, '2023308193', 3, NULL, 1, '2025-01-23', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2971, '2023308193', 3, NULL, 1, '2025-01-26', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2972, '2023308193', 3, NULL, 1, '2025-01-27', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2973, '2023308193', 3, NULL, 1, '2025-01-28', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2974, '2023308193', 3, NULL, 1, '2025-01-29', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2975, '2023308193', 3, NULL, 1, '2025-01-30', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2976, '2022310570', 3, NULL, 1, '2024-12-31', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2977, '2022310570', 3, NULL, 1, '2025-01-01', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2978, '2022310570', 3, NULL, 1, '2025-01-02', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2979, '2022310570', 3, NULL, 1, '2025-01-05', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2980, '2022310570', 3, NULL, 1, '2025-01-06', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2981, '2022310570', 3, NULL, 1, '2025-01-07', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2982, '2022310570', 3, NULL, 1, '2025-01-08', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2983, '2022310570', 3, NULL, 1, '2025-01-09', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2984, '2022310570', 3, NULL, 1, '2025-01-12', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2985, '2022310570', 3, NULL, 1, '2025-01-13', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2986, '2022310570', 3, NULL, 1, '2025-01-14', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2987, '2022310570', 3, NULL, 1, '2025-01-15', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2988, '2022310570', 3, NULL, 1, '2025-01-16', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2989, '2022310570', 3, NULL, 1, '2025-01-19', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2990, '2022310570', 3, NULL, 1, '2025-01-20', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2991, '2022310570', 3, NULL, 1, '2025-01-21', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2992, '2022310570', 3, NULL, 1, '2025-01-22', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2993, '2022310570', 3, NULL, 1, '2025-01-23', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2994, '2022310570', 3, NULL, 1, '2025-01-26', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2995, '2022310570', 3, NULL, 1, '2025-01-27', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2996, '2022310570', 3, NULL, 1, '2025-01-28', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2997, '2022310570', 3, NULL, 1, '2025-01-29', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2998, '2022310570', 3, NULL, 1, '2025-01-30', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (2999, '2021304973', 3, NULL, 1, '2024-12-31', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3000, '2021304973', 3, NULL, 1, '2025-01-01', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3001, '2021304973', 3, NULL, 1, '2025-01-02', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3002, '2021304973', 3, NULL, 1, '2025-01-05', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3003, '2021304973', 3, NULL, 1, '2025-01-06', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3004, '2021304973', 3, NULL, 1, '2025-01-07', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3005, '2021304973', 3, NULL, 1, '2025-01-08', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3006, '2021304973', 3, NULL, 1, '2025-01-09', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3007, '2021304973', 3, NULL, 1, '2025-01-12', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3008, '2021304973', 3, NULL, 1, '2025-01-13', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3009, '2021304973', 3, NULL, 1, '2025-01-14', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3010, '2021304973', 3, NULL, 1, '2025-01-15', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3011, '2021304973', 3, NULL, 1, '2025-01-16', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3012, '2021304973', 3, NULL, 1, '2025-01-19', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3013, '2021304973', 3, NULL, 1, '2025-01-20', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3014, '2021304973', 3, NULL, 1, '2025-01-21', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3015, '2021304973', 3, NULL, 1, '2025-01-22', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3016, '2021304973', 3, NULL, 1, '2025-01-23', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3017, '2021304973', 3, NULL, 1, '2025-01-26', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3018, '2021304973', 3, NULL, 1, '2025-01-27', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3019, '2021304973', 3, NULL, 1, '2025-01-28', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3020, '2021304973', 3, NULL, 1, '2025-01-29', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3021, '2021304973', 3, NULL, 1, '2025-01-30', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3022, '20151021011', 3, NULL, 1, '2024-12-31', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3023, '20151021011', 3, NULL, 1, '2025-01-01', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3024, '20151021011', 3, NULL, 1, '2025-01-02', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3025, '20151021011', 3, NULL, 1, '2025-01-05', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3026, '20151021011', 3, NULL, 1, '2025-01-06', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3027, '20151021011', 3, NULL, 1, '2025-01-07', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3028, '20151021011', 3, NULL, 1, '2025-01-08', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3029, '20151021011', 3, NULL, 1, '2025-01-09', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3030, '20151021011', 3, NULL, 1, '2025-01-12', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3031, '20151021011', 3, NULL, 1, '2025-01-13', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3032, '20151021011', 3, NULL, 1, '2025-01-14', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3033, '20151021011', 3, NULL, 1, '2025-01-15', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3034, '20151021011', 3, NULL, 1, '2025-01-16', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3035, '20151021011', 3, NULL, 1, '2025-01-19', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3036, '20151021011', 3, NULL, 1, '2025-01-20', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3037, '20151021011', 3, NULL, 1, '2025-01-21', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3038, '20151021011', 3, NULL, 1, '2025-01-22', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3039, '20151021011', 3, NULL, 1, '2025-01-23', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3040, '20151021011', 3, NULL, 1, '2025-01-26', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3041, '20151021011', 3, NULL, 1, '2025-01-27', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3042, '20151021011', 3, NULL, 1, '2025-01-28', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3043, '20151021011', 3, NULL, 1, '2025-01-29', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3044, '20151021011', 3, NULL, 1, '2025-01-30', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3045, '2022305036', 3, NULL, 1, '2024-12-31', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3046, '2022305036', 3, NULL, 1, '2025-01-01', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3047, '2022305036', 3, NULL, 1, '2025-01-02', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3048, '2022305036', 3, NULL, 1, '2025-01-05', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3049, '2022305036', 3, NULL, 1, '2025-01-06', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3050, '2022305036', 3, NULL, 1, '2025-01-07', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3051, '2022305036', 3, NULL, 1, '2025-01-08', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3052, '2022305036', 3, NULL, 1, '2025-01-09', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3053, '2022305036', 3, NULL, 1, '2025-01-12', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3054, '2022305036', 3, NULL, 1, '2025-01-13', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3055, '2022305036', 3, NULL, 1, '2025-01-14', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3056, '2022305036', 3, NULL, 1, '2025-01-15', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3057, '2022305036', 3, NULL, 1, '2025-01-16', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3058, '2022305036', 3, NULL, 1, '2025-01-19', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3059, '2022305036', 3, NULL, 1, '2025-01-20', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3060, '2022305036', 3, NULL, 1, '2025-01-21', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3061, '2022305036', 3, NULL, 1, '2025-01-22', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3062, '2022305036', 3, NULL, 1, '2025-01-23', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3063, '2022305036', 3, NULL, 1, '2025-01-26', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3064, '2022305036', 3, NULL, 1, '2025-01-27', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3065, '2022305036', 3, NULL, 1, '2025-01-28', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3066, '2022305036', 3, NULL, 1, '2025-01-29', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3067, '2022305036', 3, NULL, 1, '2025-01-30', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3068, '2022304192', 3, NULL, 1, '2024-12-31', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3069, '2022304192', 3, NULL, 1, '2025-01-01', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3070, '2022304192', 3, NULL, 1, '2025-01-02', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3071, '2022304192', 3, NULL, 1, '2025-01-05', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3072, '2022304192', 3, NULL, 1, '2025-01-06', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3073, '2022304192', 3, NULL, 1, '2025-01-07', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3074, '2022304192', 3, NULL, 1, '2025-01-08', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3075, '2022304192', 3, NULL, 1, '2025-01-09', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3076, '2022304192', 3, NULL, 1, '2025-01-12', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3077, '2022304192', 3, NULL, 1, '2025-01-13', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3078, '2022304192', 3, NULL, 1, '2025-01-14', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3079, '2022304192', 3, NULL, 1, '2025-01-15', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3080, '2022304192', 3, NULL, 1, '2025-01-16', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3081, '2022304192', 3, NULL, 1, '2025-01-19', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3082, '2022304192', 3, NULL, 1, '2025-01-20', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3083, '2022304192', 3, NULL, 1, '2025-01-21', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3084, '2022304192', 3, NULL, 1, '2025-01-22', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3085, '2022304192', 3, NULL, 1, '2025-01-23', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3086, '2022304192', 3, NULL, 1, '2025-01-26', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3087, '2022304192', 3, NULL, 1, '2025-01-27', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3088, '2022304192', 3, NULL, 1, '2025-01-28', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3089, '2022304192', 3, NULL, 1, '2025-01-29', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3090, '2022304192', 3, NULL, 1, '2025-01-30', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3091, '2022304716', 3, NULL, 1, '2024-12-31', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3092, '2022304716', 3, NULL, 1, '2025-01-01', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3093, '2022304716', 3, NULL, 1, '2025-01-02', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3094, '2022304716', 3, NULL, 1, '2025-01-05', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3095, '2022304716', 3, NULL, 1, '2025-01-06', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3096, '2022304716', 3, NULL, 1, '2025-01-07', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3097, '2022304716', 3, NULL, 1, '2025-01-08', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3098, '2022304716', 3, NULL, 1, '2025-01-09', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3099, '2022304716', 3, NULL, 1, '2025-01-12', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3100, '2022304716', 3, NULL, 1, '2025-01-13', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3101, '2022304716', 3, NULL, 1, '2025-01-14', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3102, '2022304716', 3, NULL, 1, '2025-01-15', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3103, '2022304716', 3, NULL, 1, '2025-01-16', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3104, '2022304716', 3, NULL, 1, '2025-01-19', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3105, '2022304716', 3, NULL, 1, '2025-01-20', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3106, '2022304716', 3, NULL, 1, '2025-01-21', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3107, '2022304716', 3, NULL, 1, '2025-01-22', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3108, '2022304716', 3, NULL, 1, '2025-01-23', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3109, '2022304716', 3, NULL, 1, '2025-01-26', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3110, '2022304716', 3, NULL, 1, '2025-01-27', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3111, '2022304716', 3, NULL, 1, '2025-01-28', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3112, '2022304716', 3, NULL, 1, '2025-01-29', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3113, '2022304716', 3, NULL, 1, '2025-01-30', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3114, '2022304979', 3, NULL, 1, '2024-12-31', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3115, '2022304979', 3, NULL, 1, '2025-01-01', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3116, '2022304979', 3, NULL, 1, '2025-01-02', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3117, '2022304979', 3, NULL, 1, '2025-01-05', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3118, '2022304979', 3, NULL, 1, '2025-01-06', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3119, '2022304979', 3, NULL, 1, '2025-01-07', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3120, '2022304979', 3, NULL, 1, '2025-01-08', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3121, '2022304979', 3, NULL, 1, '2025-01-09', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3122, '2022304979', 3, NULL, 1, '2025-01-12', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3123, '2022304979', 3, NULL, 1, '2025-01-13', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3124, '2022304979', 3, NULL, 1, '2025-01-14', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3125, '2022304979', 3, NULL, 1, '2025-01-15', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3126, '2022304979', 3, NULL, 1, '2025-01-16', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3127, '2022304979', 3, NULL, 1, '2025-01-19', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3128, '2022304979', 3, NULL, 1, '2025-01-20', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3129, '2022304979', 3, NULL, 1, '2025-01-21', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3130, '2022304979', 3, NULL, 1, '2025-01-22', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3131, '2022304979', 3, NULL, 1, '2025-01-23', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3132, '2022304979', 3, NULL, 1, '2025-01-26', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3133, '2022304979', 3, NULL, 1, '2025-01-27', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3134, '2022304979', 3, NULL, 1, '2025-01-28', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3135, '2022304979', 3, NULL, 1, '2025-01-29', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3136, '2022304979', 3, NULL, 1, '2025-01-30', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3137, '2022305208', 3, NULL, 1, '2024-12-31', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3138, '2022305208', 3, NULL, 1, '2025-01-01', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3139, '2022305208', 3, NULL, 1, '2025-01-02', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3140, '2022305208', 3, NULL, 1, '2025-01-05', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3141, '2022305208', 3, NULL, 1, '2025-01-06', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3142, '2022305208', 3, NULL, 1, '2025-01-07', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3143, '2022305208', 3, NULL, 1, '2025-01-08', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3144, '2022305208', 3, NULL, 1, '2025-01-09', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3145, '2022305208', 3, NULL, 1, '2025-01-12', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3146, '2022305208', 3, NULL, 1, '2025-01-13', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3147, '2022305208', 3, NULL, 1, '2025-01-14', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3148, '2022305208', 3, NULL, 1, '2025-01-15', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3149, '2022305208', 3, NULL, 1, '2025-01-16', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3150, '2022305208', 3, NULL, 1, '2025-01-19', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3151, '2022305208', 3, NULL, 1, '2025-01-20', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3152, '2022305208', 3, NULL, 1, '2025-01-21', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3153, '2022305208', 3, NULL, 1, '2025-01-22', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3154, '2022305208', 3, NULL, 1, '2025-01-23', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3155, '2022305208', 3, NULL, 1, '2025-01-26', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3156, '2022305208', 3, NULL, 1, '2025-01-27', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3157, '2022305208', 3, NULL, 1, '2025-01-28', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3158, '2022305208', 3, NULL, 1, '2025-01-29', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3159, '2022305208', 3, NULL, 1, '2025-01-30', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3160, '2022306426', 3, NULL, 1, '2024-12-31', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3161, '2022306426', 3, NULL, 1, '2025-01-01', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3162, '2022306426', 3, NULL, 1, '2025-01-02', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3163, '2022306426', 3, NULL, 1, '2025-01-05', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3164, '2022306426', 3, NULL, 1, '2025-01-06', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3165, '2022306426', 3, NULL, 1, '2025-01-07', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3166, '2022306426', 3, NULL, 1, '2025-01-08', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3167, '2022306426', 3, NULL, 1, '2025-01-09', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3168, '2022306426', 3, NULL, 1, '2025-01-12', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3169, '2022306426', 3, NULL, 1, '2025-01-13', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3170, '2022306426', 3, NULL, 1, '2025-01-14', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3171, '2022306426', 3, NULL, 1, '2025-01-15', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3172, '2022306426', 3, NULL, 1, '2025-01-16', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3173, '2022306426', 3, NULL, 1, '2025-01-19', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3174, '2022306426', 3, NULL, 1, '2025-01-20', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3175, '2022306426', 3, NULL, 1, '2025-01-21', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3176, '2022306426', 3, NULL, 1, '2025-01-22', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3177, '2022306426', 3, NULL, 1, '2025-01-23', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3178, '2022306426', 3, NULL, 1, '2025-01-26', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3179, '2022306426', 3, NULL, 1, '2025-01-27', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3180, '2022306426', 3, NULL, 1, '2025-01-28', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3181, '2022306426', 3, NULL, 1, '2025-01-29', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3182, '2022306426', 3, NULL, 1, '2025-01-30', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3183, '2023308308', 3, NULL, 1, '2024-12-31', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3184, '2023308308', 3, NULL, 1, '2025-01-01', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3185, '2023308308', 3, NULL, 1, '2025-01-02', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3186, '2023308308', 3, NULL, 1, '2025-01-05', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3187, '2023308308', 3, NULL, 1, '2025-01-06', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3188, '2023308308', 3, NULL, 1, '2025-01-07', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3189, '2023308308', 3, NULL, 1, '2025-01-08', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3190, '2023308308', 3, NULL, 1, '2025-01-09', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3191, '2023308308', 3, NULL, 1, '2025-01-12', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3192, '2023308308', 3, NULL, 1, '2025-01-13', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3193, '2023308308', 3, NULL, 1, '2025-01-14', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3194, '2023308308', 3, NULL, 1, '2025-01-15', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3195, '2023308308', 3, NULL, 1, '2025-01-16', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3196, '2023308308', 3, NULL, 1, '2025-01-19', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3197, '2023308308', 3, NULL, 1, '2025-01-20', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3198, '2023308308', 3, NULL, 1, '2025-01-21', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3199, '2023308308', 3, NULL, 1, '2025-01-22', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3200, '2023308308', 3, NULL, 1, '2025-01-23', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3201, '2023308308', 3, NULL, 1, '2025-01-26', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3202, '2023308308', 3, NULL, 1, '2025-01-27', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3203, '2023308308', 3, NULL, 1, '2025-01-28', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3204, '2023308308', 3, NULL, 1, '2025-01-29', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3205, '2023308308', 3, NULL, 1, '2025-01-30', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3206, '2023308162', 3, NULL, 1, '2024-12-31', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3207, '2023308162', 3, NULL, 1, '2025-01-01', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3208, '2023308162', 3, NULL, 1, '2025-01-02', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3209, '2023308162', 3, NULL, 1, '2025-01-05', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3210, '2023308162', 3, NULL, 1, '2025-01-06', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3211, '2023308162', 3, NULL, 1, '2025-01-07', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3212, '2023308162', 3, NULL, 1, '2025-01-08', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3213, '2023308162', 3, NULL, 1, '2025-01-09', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3214, '2023308162', 3, NULL, 1, '2025-01-12', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3215, '2023308162', 3, NULL, 1, '2025-01-13', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3216, '2023308162', 3, NULL, 1, '2025-01-14', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3217, '2023308162', 3, NULL, 1, '2025-01-15', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3218, '2023308162', 3, NULL, 1, '2025-01-16', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3219, '2023308162', 3, NULL, 1, '2025-01-19', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3220, '2023308162', 3, NULL, 1, '2025-01-20', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3221, '2023308162', 3, NULL, 1, '2025-01-21', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3222, '2023308162', 3, NULL, 1, '2025-01-22', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3223, '2023308162', 3, NULL, 1, '2025-01-23', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3224, '2023308162', 3, NULL, 1, '2025-01-26', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3225, '2023308162', 3, NULL, 1, '2025-01-27', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3226, '2023308162', 3, NULL, 1, '2025-01-28', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3227, '2023308162', 3, NULL, 1, '2025-01-29', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3228, '2023308162', 3, NULL, 1, '2025-01-30', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3229, '2013100521', 3, NULL, 1, '2024-12-31', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3230, '2013100521', 3, NULL, 1, '2025-01-01', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3231, '2013100521', 3, NULL, 1, '2025-01-02', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3232, '2013100521', 3, NULL, 1, '2025-01-05', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3233, '2013100521', 3, NULL, 1, '2025-01-06', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3234, '2013100521', 3, NULL, 1, '2025-01-07', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3235, '2013100521', 3, NULL, 1, '2025-01-08', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3236, '2013100521', 3, NULL, 1, '2025-01-09', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3237, '2013100521', 3, NULL, 1, '2025-01-12', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3238, '2013100521', 3, NULL, 1, '2025-01-13', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3239, '2013100521', 3, NULL, 1, '2025-01-14', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3240, '2013100521', 3, NULL, 1, '2025-01-15', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3241, '2013100521', 3, NULL, 1, '2025-01-16', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3242, '2013100521', 3, NULL, 1, '2025-01-19', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3243, '2013100521', 3, NULL, 1, '2025-01-20', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3244, '2013100521', 3, NULL, 1, '2025-01-21', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3245, '2013100521', 3, NULL, 1, '2025-01-22', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3246, '2013100521', 3, NULL, 1, '2025-01-23', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3247, '2013100521', 3, NULL, 1, '2025-01-26', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3248, '2013100521', 3, NULL, 1, '2025-01-27', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3249, '2013100521', 3, NULL, 1, '2025-01-28', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3250, '2013100521', 3, NULL, 1, '2025-01-29', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3251, '2013100521', 3, NULL, 1, '2025-01-30', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3252, '2022305203', 3, NULL, 1, '2024-12-31', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3253, '2022305203', 3, NULL, 1, '2025-01-01', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3254, '2022305203', 3, NULL, 1, '2025-01-02', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3255, '2022305203', 3, NULL, 1, '2025-01-05', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3256, '2022305203', 3, NULL, 1, '2025-01-06', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3257, '2022305203', 3, NULL, 1, '2025-01-07', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3258, '2022305203', 3, NULL, 1, '2025-01-08', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3259, '2022305203', 3, NULL, 1, '2025-01-09', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3260, '2022305203', 3, NULL, 1, '2025-01-12', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3261, '2022305203', 3, NULL, 1, '2025-01-13', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3262, '2022305203', 3, NULL, 1, '2025-01-14', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3263, '2022305203', 3, NULL, 1, '2025-01-15', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3264, '2022305203', 3, NULL, 1, '2025-01-16', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3265, '2022305203', 3, NULL, 1, '2025-01-19', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3266, '2022305203', 3, NULL, 1, '2025-01-20', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3267, '2022305203', 3, NULL, 1, '2025-01-21', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3268, '2022305203', 3, NULL, 1, '2025-01-22', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3269, '2022305203', 3, NULL, 1, '2025-01-23', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3270, '2022305203', 3, NULL, 1, '2025-01-26', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3271, '2022305203', 3, NULL, 1, '2025-01-27', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3272, '2022305203', 3, NULL, 1, '2025-01-28', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3273, '2022305203', 3, NULL, 1, '2025-01-29', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3274, '2022305203', 3, NULL, 1, '2025-01-30', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3275, '2023307875', 3, NULL, 1, '2024-12-31', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3276, '2023307875', 3, NULL, 1, '2025-01-01', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3277, '2023307875', 3, NULL, 1, '2025-01-02', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3278, '2023307875', 3, NULL, 1, '2025-01-05', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3279, '2023307875', 3, NULL, 1, '2025-01-06', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3280, '2023307875', 3, NULL, 1, '2025-01-07', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3281, '2023307875', 3, NULL, 1, '2025-01-08', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3282, '2023307875', 3, NULL, 1, '2025-01-09', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3283, '2023307875', 3, NULL, 1, '2025-01-12', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3284, '2023307875', 3, NULL, 1, '2025-01-13', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3285, '2023307875', 3, NULL, 1, '2025-01-14', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3286, '2023307875', 3, NULL, 1, '2025-01-15', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3287, '2023307875', 3, NULL, 1, '2025-01-16', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3288, '2023307875', 3, NULL, 1, '2025-01-19', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3289, '2023307875', 3, NULL, 1, '2025-01-20', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3290, '2023307875', 3, NULL, 1, '2025-01-21', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3291, '2023307875', 3, NULL, 1, '2025-01-22', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3292, '2023307875', 3, NULL, 1, '2025-01-23', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3293, '2023307875', 3, NULL, 1, '2025-01-26', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3294, '2023307875', 3, NULL, 1, '2025-01-27', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3295, '2023307875', 3, NULL, 1, '2025-01-28', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3296, '2023307875', 3, NULL, 1, '2025-01-29', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3297, '2023307875', 3, NULL, 1, '2025-01-30', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3298, '2023307823', 3, NULL, 1, '2024-12-31', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3299, '2023307823', 3, NULL, 1, '2025-01-01', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3300, '2023307823', 3, NULL, 1, '2025-01-02', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3301, '2023307823', 3, NULL, 1, '2025-01-05', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3302, '2023307823', 3, NULL, 1, '2025-01-06', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3303, '2023307823', 3, NULL, 1, '2025-01-07', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3304, '2023307823', 3, NULL, 1, '2025-01-08', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3305, '2023307823', 3, NULL, 1, '2025-01-09', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3306, '2023307823', 3, NULL, 1, '2025-01-12', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3307, '2023307823', 3, NULL, 1, '2025-01-13', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3308, '2023307823', 3, NULL, 1, '2025-01-14', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3309, '2023307823', 3, NULL, 1, '2025-01-15', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3310, '2023307823', 3, NULL, 1, '2025-01-16', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3311, '2023307823', 3, NULL, 1, '2025-01-19', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3312, '2023307823', 3, NULL, 1, '2025-01-20', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3313, '2023307823', 3, NULL, 1, '2025-01-21', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3314, '2023307823', 3, NULL, 1, '2025-01-22', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3315, '2023307823', 3, NULL, 1, '2025-01-23', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3316, '2023307823', 3, NULL, 1, '2025-01-26', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3317, '2023307823', 3, NULL, 1, '2025-01-27', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3318, '2023307823', 3, NULL, 1, '2025-01-28', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3319, '2023307823', 3, NULL, 1, '2025-01-29', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3320, '2023307823', 3, NULL, 1, '2025-01-30', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3321, '2022301730', 3, NULL, 1, '2024-12-31', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3322, '2022301730', 3, NULL, 1, '2025-01-01', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3323, '2022301730', 3, NULL, 1, '2025-01-02', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3324, '2022301730', 3, NULL, 1, '2025-01-05', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3325, '2022301730', 3, NULL, 1, '2025-01-06', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3326, '2022301730', 3, NULL, 1, '2025-01-07', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3327, '2022301730', 3, NULL, 1, '2025-01-08', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3328, '2022301730', 3, NULL, 1, '2025-01-09', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3329, '2022301730', 3, NULL, 1, '2025-01-12', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3330, '2022301730', 3, NULL, 1, '2025-01-13', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3331, '2022301730', 3, NULL, 1, '2025-01-14', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3332, '2022301730', 3, NULL, 1, '2025-01-15', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3333, '2022301730', 3, NULL, 1, '2025-01-16', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3334, '2022301730', 3, NULL, 1, '2025-01-19', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3335, '2022301730', 3, NULL, 1, '2025-01-20', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3336, '2022301730', 3, NULL, 1, '2025-01-21', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3337, '2022301730', 3, NULL, 1, '2025-01-22', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3338, '2022301730', 3, NULL, 1, '2025-01-23', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3339, '2022301730', 3, NULL, 1, '2025-01-26', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3340, '2022301730', 3, NULL, 1, '2025-01-27', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3341, '2022301730', 3, NULL, 1, '2025-01-28', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3342, '2022301730', 3, NULL, 1, '2025-01-29', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3343, '2022301730', 3, NULL, 1, '2025-01-30', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3344, '2022310247', 3, NULL, 1, '2024-12-31', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3345, '2022310247', 3, NULL, 1, '2025-01-01', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3346, '2022310247', 3, NULL, 1, '2025-01-02', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3347, '2022310247', 3, NULL, 1, '2025-01-05', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3348, '2022310247', 3, NULL, 1, '2025-01-06', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3349, '2022310247', 3, NULL, 1, '2025-01-07', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3350, '2022310247', 3, NULL, 1, '2025-01-08', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3351, '2022310247', 3, NULL, 1, '2025-01-09', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3352, '2022310247', 3, NULL, 1, '2025-01-12', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3353, '2022310247', 3, NULL, 1, '2025-01-13', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3354, '2022310247', 3, NULL, 1, '2025-01-14', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3355, '2022310247', 3, NULL, 1, '2025-01-15', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3356, '2022310247', 3, NULL, 1, '2025-01-16', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3357, '2022310247', 3, NULL, 1, '2025-01-19', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3358, '2022310247', 3, NULL, 1, '2025-01-20', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3359, '2022310247', 3, NULL, 1, '2025-01-21', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3360, '2022310247', 3, NULL, 1, '2025-01-22', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3361, '2022310247', 3, NULL, 1, '2025-01-23', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3362, '2022310247', 3, NULL, 1, '2025-01-26', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3363, '2022310247', 3, NULL, 1, '2025-01-27', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3364, '2022310247', 3, NULL, 1, '2025-01-28', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3365, '2022310247', 3, NULL, 1, '2025-01-29', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3366, '2022310247', 3, NULL, 1, '2025-01-30', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3367, '2022305040', 3, NULL, 1, '2024-12-31', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3368, '2022305040', 3, NULL, 1, '2025-01-01', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3369, '2022305040', 3, NULL, 1, '2025-01-02', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3370, '2022305040', 3, NULL, 1, '2025-01-05', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3371, '2022305040', 3, NULL, 1, '2025-01-06', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3372, '2022305040', 3, NULL, 1, '2025-01-07', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3373, '2022305040', 3, NULL, 1, '2025-01-08', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3374, '2022305040', 3, NULL, 1, '2025-01-09', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3375, '2022305040', 3, NULL, 1, '2025-01-12', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3376, '2022305040', 3, NULL, 1, '2025-01-13', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3377, '2022305040', 3, NULL, 1, '2025-01-14', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3378, '2022305040', 3, NULL, 1, '2025-01-15', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3379, '2022305040', 3, NULL, 1, '2025-01-16', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3380, '2022305040', 3, NULL, 1, '2025-01-19', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3381, '2022305040', 3, NULL, 1, '2025-01-20', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3382, '2022305040', 3, NULL, 1, '2025-01-21', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3383, '2022305040', 3, NULL, 1, '2025-01-22', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3384, '2022305040', 3, NULL, 1, '2025-01-23', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3385, '2022305040', 3, NULL, 1, '2025-01-26', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3386, '2022305040', 3, NULL, 1, '2025-01-27', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3387, '2022305040', 3, NULL, 1, '2025-01-28', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3388, '2022305040', 3, NULL, 1, '2025-01-29', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3389, '2022305040', 3, NULL, 1, '2025-01-30', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3390, '2022305211', 3, NULL, 1, '2024-12-31', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3391, '2022305211', 3, NULL, 1, '2025-01-01', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3392, '2022305211', 3, NULL, 1, '2025-01-02', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3393, '2022305211', 3, NULL, 1, '2025-01-05', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3394, '2022305211', 3, NULL, 1, '2025-01-06', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3395, '2022305211', 3, NULL, 1, '2025-01-07', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3396, '2022305211', 3, NULL, 1, '2025-01-08', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3397, '2022305211', 3, NULL, 1, '2025-01-09', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3398, '2022305211', 3, NULL, 1, '2025-01-12', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3399, '2022305211', 3, NULL, 1, '2025-01-13', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3400, '2022305211', 3, NULL, 1, '2025-01-14', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3401, '2022305211', 3, NULL, 1, '2025-01-15', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3402, '2022305211', 3, NULL, 1, '2025-01-16', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3403, '2022305211', 3, NULL, 1, '2025-01-19', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3404, '2022305211', 3, NULL, 1, '2025-01-20', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3405, '2022305211', 3, NULL, 1, '2025-01-21', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3406, '2022305211', 3, NULL, 1, '2025-01-22', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3407, '2022305211', 3, NULL, 1, '2025-01-23', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3408, '2022305211', 3, NULL, 1, '2025-01-26', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3409, '2022305211', 3, NULL, 1, '2025-01-27', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3410, '2022305211', 3, NULL, 1, '2025-01-28', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3411, '2022305211', 3, NULL, 1, '2025-01-29', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3412, '2022305211', 3, NULL, 1, '2025-01-30', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3413, '2022310250', 3, NULL, 1, '2024-12-31', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3414, '2022310250', 3, NULL, 1, '2025-01-01', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3415, '2022310250', 3, NULL, 1, '2025-01-02', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3416, '2022310250', 3, NULL, 1, '2025-01-05', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3417, '2022310250', 3, NULL, 1, '2025-01-06', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3418, '2022310250', 3, NULL, 1, '2025-01-07', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3419, '2022310250', 3, NULL, 1, '2025-01-08', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3420, '2022310250', 3, NULL, 1, '2025-01-09', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3421, '2022310250', 3, NULL, 1, '2025-01-12', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3422, '2022310250', 3, NULL, 1, '2025-01-13', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3423, '2022310250', 3, NULL, 1, '2025-01-14', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3424, '2022310250', 3, NULL, 1, '2025-01-15', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3425, '2022310250', 3, NULL, 1, '2025-01-16', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3426, '2022310250', 3, NULL, 1, '2025-01-19', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3427, '2022310250', 3, NULL, 1, '2025-01-20', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3428, '2022310250', 3, NULL, 1, '2025-01-21', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3429, '2022310250', 3, NULL, 1, '2025-01-22', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3430, '2022310250', 3, NULL, 1, '2025-01-23', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3431, '2022310250', 3, NULL, 1, '2025-01-26', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3432, '2022310250', 3, NULL, 1, '2025-01-27', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3433, '2022310250', 3, NULL, 1, '2025-01-28', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3434, '2022310250', 3, NULL, 1, '2025-01-29', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3435, '2022310250', 3, NULL, 1, '2025-01-30', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3436, '2023307890', 3, NULL, 1, '2024-12-31', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3437, '2023307890', 3, NULL, 1, '2025-01-01', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3438, '2023307890', 3, NULL, 1, '2025-01-02', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3439, '2023307890', 3, NULL, 1, '2025-01-05', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3440, '2023307890', 3, NULL, 1, '2025-01-06', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3441, '2023307890', 3, NULL, 1, '2025-01-07', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3442, '2023307890', 3, NULL, 1, '2025-01-08', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3443, '2023307890', 3, NULL, 1, '2025-01-09', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3444, '2023307890', 3, NULL, 1, '2025-01-12', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3445, '2023307890', 3, NULL, 1, '2025-01-13', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3446, '2023307890', 3, NULL, 1, '2025-01-14', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3447, '2023307890', 3, NULL, 1, '2025-01-15', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3448, '2023307890', 3, NULL, 1, '2025-01-16', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3449, '2023307890', 3, NULL, 1, '2025-01-19', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3450, '2023307890', 3, NULL, 1, '2025-01-20', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3451, '2023307890', 3, NULL, 1, '2025-01-21', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3452, '2023307890', 3, NULL, 1, '2025-01-22', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3453, '2023307890', 3, NULL, 1, '2025-01-23', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3454, '2023307890', 3, NULL, 1, '2025-01-26', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3455, '2023307890', 3, NULL, 1, '2025-01-27', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3456, '2023307890', 3, NULL, 1, '2025-01-28', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3457, '2023307890', 3, NULL, 1, '2025-01-29', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3458, '2023307890', 3, NULL, 1, '2025-01-30', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3459, '2020307345', 3, NULL, 1, '2024-12-31', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3460, '2020307345', 3, NULL, 1, '2025-01-01', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3461, '2020307345', 3, NULL, 1, '2025-01-02', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3462, '2020307345', 3, NULL, 1, '2025-01-05', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3463, '2020307345', 3, NULL, 1, '2025-01-06', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3464, '2020307345', 3, NULL, 1, '2025-01-07', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3465, '2020307345', 3, NULL, 1, '2025-01-08', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3466, '2020307345', 3, NULL, 1, '2025-01-09', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3467, '2020307345', 3, NULL, 1, '2025-01-12', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3468, '2020307345', 3, NULL, 1, '2025-01-13', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3469, '2020307345', 3, NULL, 1, '2025-01-14', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3470, '2020307345', 3, NULL, 1, '2025-01-15', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3471, '2020307345', 3, NULL, 1, '2025-01-16', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3472, '2020307345', 3, NULL, 1, '2025-01-19', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3473, '2020307345', 3, NULL, 1, '2025-01-20', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3474, '2020307345', 3, NULL, 1, '2025-01-21', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3475, '2020307345', 3, NULL, 1, '2025-01-22', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3476, '2020307345', 3, NULL, 1, '2025-01-23', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3477, '2020307345', 3, NULL, 1, '2025-01-26', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3478, '2020307345', 3, NULL, 1, '2025-01-27', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3479, '2020307345', 3, NULL, 1, '2025-01-28', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3480, '2020307345', 3, NULL, 1, '2025-01-29', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3481, '2020307345', 3, NULL, 1, '2025-01-30', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3482, '2022310895', 3, NULL, 1, '2024-12-31', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3483, '2022310895', 3, NULL, 1, '2025-01-01', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3484, '2022310895', 3, NULL, 1, '2025-01-02', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3485, '2022310895', 3, NULL, 1, '2025-01-05', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3486, '2022310895', 3, NULL, 1, '2025-01-06', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3487, '2022310895', 3, NULL, 1, '2025-01-07', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3488, '2022310895', 3, NULL, 1, '2025-01-08', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3489, '2022310895', 3, NULL, 1, '2025-01-09', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3490, '2022310895', 3, NULL, 1, '2025-01-12', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3491, '2022310895', 3, NULL, 1, '2025-01-13', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3492, '2022310895', 3, NULL, 1, '2025-01-14', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3493, '2022310895', 3, NULL, 1, '2025-01-15', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3494, '2022310895', 3, NULL, 1, '2025-01-16', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3495, '2022310895', 3, NULL, 1, '2025-01-19', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3496, '2022310895', 3, NULL, 1, '2025-01-20', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3497, '2022310895', 3, NULL, 1, '2025-01-21', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3498, '2022310895', 3, NULL, 1, '2025-01-22', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3499, '2022310895', 3, NULL, 1, '2025-01-23', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3500, '2022310895', 3, NULL, 1, '2025-01-26', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3501, '2022310895', 3, NULL, 1, '2025-01-27', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3502, '2022310895', 3, NULL, 1, '2025-01-28', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3503, '2022310895', 3, NULL, 1, '2025-01-29', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3504, '2022310895', 3, NULL, 1, '2025-01-30', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3505, '2022304246', 3, NULL, 1, '2024-12-31', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3506, '2022304246', 3, NULL, 1, '2025-01-01', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3507, '2022304246', 3, NULL, 1, '2025-01-02', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3508, '2022304246', 3, NULL, 1, '2025-01-05', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3509, '2022304246', 3, NULL, 1, '2025-01-06', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3510, '2022304246', 3, NULL, 1, '2025-01-07', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3511, '2022304246', 3, NULL, 1, '2025-01-08', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3512, '2022304246', 3, NULL, 1, '2025-01-09', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3513, '2022304246', 3, NULL, 1, '2025-01-12', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3514, '2022304246', 3, NULL, 1, '2025-01-13', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3515, '2022304246', 3, NULL, 1, '2025-01-14', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3516, '2022304246', 3, NULL, 1, '2025-01-15', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3517, '2022304246', 3, NULL, 1, '2025-01-16', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3518, '2022304246', 3, NULL, 1, '2025-01-19', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3519, '2022304246', 3, NULL, 1, '2025-01-20', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3520, '2022304246', 3, NULL, 1, '2025-01-21', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3521, '2022304246', 3, NULL, 1, '2025-01-22', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3522, '2022304246', 3, NULL, 1, '2025-01-23', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3523, '2022304246', 3, NULL, 1, '2025-01-26', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3524, '2022304246', 3, NULL, 1, '2025-01-27', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3525, '2022304246', 3, NULL, 1, '2025-01-28', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3526, '2022304246', 3, NULL, 1, '2025-01-29', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3527, '2022304246', 3, NULL, 1, '2025-01-30', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3528, '2022304191', 3, NULL, 1, '2024-12-31', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3529, '2022304191', 3, NULL, 1, '2025-01-01', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3530, '2022304191', 3, NULL, 1, '2025-01-02', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3531, '2022304191', 3, NULL, 1, '2025-01-05', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3532, '2022304191', 3, NULL, 1, '2025-01-06', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3533, '2022304191', 3, NULL, 1, '2025-01-07', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3534, '2022304191', 3, NULL, 1, '2025-01-08', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3535, '2022304191', 3, NULL, 1, '2025-01-09', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3536, '2022304191', 3, NULL, 1, '2025-01-12', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3537, '2022304191', 3, NULL, 1, '2025-01-13', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3538, '2022304191', 3, NULL, 1, '2025-01-14', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3539, '2022304191', 3, NULL, 1, '2025-01-15', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3540, '2022304191', 3, NULL, 1, '2025-01-16', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3541, '2022304191', 3, NULL, 1, '2025-01-19', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3542, '2022304191', 3, NULL, 1, '2025-01-20', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3543, '2022304191', 3, NULL, 1, '2025-01-21', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3544, '2022304191', 3, NULL, 1, '2025-01-22', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3545, '2022304191', 3, NULL, 1, '2025-01-23', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3546, '2022304191', 3, NULL, 1, '2025-01-26', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3547, '2022304191', 3, NULL, 1, '2025-01-27', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3548, '2022304191', 3, NULL, 1, '2025-01-28', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3549, '2022304191', 3, NULL, 1, '2025-01-29', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3550, '2022304191', 3, NULL, 1, '2025-01-30', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3551, '2022304991', 3, NULL, 1, '2024-12-31', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3552, '2022304991', 3, NULL, 1, '2025-01-01', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3553, '2022304991', 3, NULL, 1, '2025-01-02', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3554, '2022304991', 3, NULL, 1, '2025-01-05', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3555, '2022304991', 3, NULL, 1, '2025-01-06', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3556, '2022304991', 3, NULL, 1, '2025-01-07', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3557, '2022304991', 3, NULL, 1, '2025-01-08', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3558, '2022304991', 3, NULL, 1, '2025-01-09', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3559, '2022304991', 3, NULL, 1, '2025-01-12', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3560, '2022304991', 3, NULL, 1, '2025-01-13', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3561, '2022304991', 3, NULL, 1, '2025-01-14', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3562, '2022304991', 3, NULL, 1, '2025-01-15', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3563, '2022304991', 3, NULL, 1, '2025-01-16', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3564, '2022304991', 3, NULL, 1, '2025-01-19', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3565, '2022304991', 3, NULL, 1, '2025-01-20', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3566, '2022304991', 3, NULL, 1, '2025-01-21', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3567, '2022304991', 3, NULL, 1, '2025-01-22', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3568, '2022304991', 3, NULL, 1, '2025-01-23', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3569, '2022304991', 3, NULL, 1, '2025-01-26', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3570, '2022304991', 3, NULL, 1, '2025-01-27', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3571, '2022304991', 3, NULL, 1, '2025-01-28', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3572, '2022304991', 3, NULL, 1, '2025-01-29', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3573, '2022304991', 3, NULL, 1, '2025-01-30', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3574, '2021305768', 3, NULL, 1, '2024-12-31', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3575, '2021305768', 3, NULL, 1, '2025-01-01', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3576, '2021305768', 3, NULL, 1, '2025-01-02', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3577, '2021305768', 3, NULL, 1, '2025-01-05', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3578, '2021305768', 3, NULL, 1, '2025-01-06', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3579, '2021305768', 3, NULL, 1, '2025-01-07', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3580, '2021305768', 3, NULL, 1, '2025-01-08', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3581, '2021305768', 3, NULL, 1, '2025-01-09', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3582, '2021305768', 3, NULL, 1, '2025-01-12', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3583, '2021305768', 3, NULL, 1, '2025-01-13', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3584, '2021305768', 3, NULL, 1, '2025-01-14', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3585, '2021305768', 3, NULL, 1, '2025-01-15', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3586, '2021305768', 3, NULL, 1, '2025-01-16', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3587, '2021305768', 3, NULL, 1, '2025-01-19', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3588, '2021305768', 3, NULL, 1, '2025-01-20', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3589, '2021305768', 3, NULL, 1, '2025-01-21', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3590, '2021305768', 3, NULL, 1, '2025-01-22', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3591, '2021305768', 3, NULL, 1, '2025-01-23', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3592, '2021305768', 3, NULL, 1, '2025-01-26', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3593, '2021305768', 3, NULL, 1, '2025-01-27', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3594, '2021305768', 3, NULL, 1, '2025-01-28', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3595, '2021305768', 3, NULL, 1, '2025-01-29', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3596, '2021305768', 3, NULL, 1, '2025-01-30', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3597, '2022310245', 3, NULL, 1, '2024-12-31', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3598, '2022310245', 3, NULL, 1, '2025-01-01', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3599, '2022310245', 3, NULL, 1, '2025-01-02', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3600, '2022310245', 3, NULL, 1, '2025-01-05', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3601, '2022310245', 3, NULL, 1, '2025-01-06', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3602, '2022310245', 3, NULL, 1, '2025-01-07', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3603, '2022310245', 3, NULL, 1, '2025-01-08', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3604, '2022310245', 3, NULL, 1, '2025-01-09', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3605, '2022310245', 3, NULL, 1, '2025-01-12', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3606, '2022310245', 3, NULL, 1, '2025-01-13', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3607, '2022310245', 3, NULL, 1, '2025-01-14', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3608, '2022310245', 3, NULL, 1, '2025-01-15', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3609, '2022310245', 3, NULL, 1, '2025-01-16', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3610, '2022310245', 3, NULL, 1, '2025-01-19', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3611, '2022310245', 3, NULL, 1, '2025-01-20', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3612, '2022310245', 3, NULL, 1, '2025-01-21', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3613, '2022310245', 3, NULL, 1, '2025-01-22', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3614, '2022310245', 3, NULL, 1, '2025-01-23', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3615, '2022310245', 3, NULL, 1, '2025-01-26', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3616, '2022310245', 3, NULL, 1, '2025-01-27', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3617, '2022310245', 3, NULL, 1, '2025-01-28', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3618, '2022310245', 3, NULL, 1, '2025-01-29', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3619, '2022310245', 3, NULL, 1, '2025-01-30', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3620, '2022305241', 3, NULL, 1, '2024-12-31', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3621, '2022305241', 3, NULL, 1, '2025-01-01', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3622, '2022305241', 3, NULL, 1, '2025-01-02', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3623, '2022305241', 3, NULL, 1, '2025-01-05', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3624, '2022305241', 3, NULL, 1, '2025-01-06', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3625, '2022305241', 3, NULL, 1, '2025-01-07', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3626, '2022305241', 3, NULL, 1, '2025-01-08', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3627, '2022305241', 3, NULL, 1, '2025-01-09', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3628, '2022305241', 3, NULL, 1, '2025-01-12', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3629, '2022305241', 3, NULL, 1, '2025-01-13', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3630, '2022305241', 3, NULL, 1, '2025-01-14', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3631, '2022305241', 3, NULL, 1, '2025-01-15', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3632, '2022305241', 3, NULL, 1, '2025-01-16', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3633, '2022305241', 3, NULL, 1, '2025-01-19', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3634, '2022305241', 3, NULL, 1, '2025-01-20', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3635, '2022305241', 3, NULL, 1, '2025-01-21', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3636, '2022305241', 3, NULL, 1, '2025-01-22', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3637, '2022305241', 3, NULL, 1, '2025-01-23', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3638, '2022305241', 3, NULL, 1, '2025-01-26', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3639, '2022305241', 3, NULL, 1, '2025-01-27', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3640, '2022305241', 3, NULL, 1, '2025-01-28', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3641, '2022305241', 3, NULL, 1, '2025-01-29', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3642, '2022305241', 3, NULL, 1, '2025-01-30', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3643, '2023307846', 3, NULL, 1, '2024-12-31', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3644, '2023307846', 3, NULL, 1, '2025-01-01', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3645, '2023307846', 3, NULL, 1, '2025-01-02', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3646, '2023307846', 3, NULL, 1, '2025-01-05', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3647, '2023307846', 3, NULL, 1, '2025-01-06', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3648, '2023307846', 3, NULL, 1, '2025-01-07', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3649, '2023307846', 3, NULL, 1, '2025-01-08', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3650, '2023307846', 3, NULL, 1, '2025-01-09', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3651, '2023307846', 3, NULL, 1, '2025-01-12', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3652, '2023307846', 3, NULL, 1, '2025-01-13', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3653, '2023307846', 3, NULL, 1, '2025-01-14', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3654, '2023307846', 3, NULL, 1, '2025-01-15', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3655, '2023307846', 3, NULL, 1, '2025-01-16', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3656, '2023307846', 3, NULL, 1, '2025-01-19', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3657, '2023307846', 3, NULL, 1, '2025-01-20', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3658, '2023307846', 3, NULL, 1, '2025-01-21', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3659, '2023307846', 3, NULL, 1, '2025-01-22', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3660, '2023307846', 3, NULL, 1, '2025-01-23', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3661, '2023307846', 3, NULL, 1, '2025-01-26', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3662, '2023307846', 3, NULL, 1, '2025-01-27', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3663, '2023307846', 3, NULL, 1, '2025-01-28', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3664, '2023307846', 3, NULL, 1, '2025-01-29', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3665, '2023307846', 3, NULL, 1, '2025-01-30', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3666, '2022304841', 3, NULL, 1, '2024-12-31', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3667, '2022304841', 3, NULL, 1, '2025-01-01', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3668, '2022304841', 3, NULL, 1, '2025-01-02', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3669, '2022304841', 3, NULL, 1, '2025-01-05', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3670, '2022304841', 3, NULL, 1, '2025-01-06', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3671, '2022304841', 3, NULL, 1, '2025-01-07', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3672, '2022304841', 3, NULL, 1, '2025-01-08', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3673, '2022304841', 3, NULL, 1, '2025-01-09', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3674, '2022304841', 3, NULL, 1, '2025-01-12', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3675, '2022304841', 3, NULL, 1, '2025-01-13', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3676, '2022304841', 3, NULL, 1, '2025-01-14', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3677, '2022304841', 3, NULL, 1, '2025-01-15', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3678, '2022304841', 3, NULL, 1, '2025-01-16', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3679, '2022304841', 3, NULL, 1, '2025-01-19', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3680, '2022304841', 3, NULL, 1, '2025-01-20', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3681, '2022304841', 3, NULL, 1, '2025-01-21', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3682, '2022304841', 3, NULL, 1, '2025-01-22', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3683, '2022304841', 3, NULL, 1, '2025-01-23', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3684, '2022304841', 3, NULL, 1, '2025-01-26', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3685, '2022304841', 3, NULL, 1, '2025-01-27', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3686, '2022304841', 3, NULL, 1, '2025-01-28', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3687, '2022304841', 3, NULL, 1, '2025-01-29', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3688, '2022304841', 3, NULL, 1, '2025-01-30', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3689, '2023307947', 3, NULL, 1, '2024-12-31', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3690, '2023307947', 3, NULL, 1, '2025-01-01', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3691, '2023307947', 3, NULL, 1, '2025-01-02', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3692, '2023307947', 3, NULL, 1, '2025-01-05', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3693, '2023307947', 3, NULL, 1, '2025-01-06', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3694, '2023307947', 3, NULL, 1, '2025-01-07', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3695, '2023307947', 3, NULL, 1, '2025-01-08', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3696, '2023307947', 3, NULL, 1, '2025-01-09', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3697, '2023307947', 3, NULL, 1, '2025-01-12', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3698, '2023307947', 3, NULL, 1, '2025-01-13', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3699, '2023307947', 3, NULL, 1, '2025-01-14', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3700, '2023307947', 3, NULL, 1, '2025-01-15', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3701, '2023307947', 3, NULL, 1, '2025-01-16', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3702, '2023307947', 3, NULL, 1, '2025-01-19', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3703, '2023307947', 3, NULL, 1, '2025-01-20', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3704, '2023307947', 3, NULL, 1, '2025-01-21', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3705, '2023307947', 3, NULL, 1, '2025-01-22', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3706, '2023307947', 3, NULL, 1, '2025-01-23', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3707, '2023307947', 3, NULL, 1, '2025-01-26', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3708, '2023307947', 3, NULL, 1, '2025-01-27', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3709, '2023307947', 3, NULL, 1, '2025-01-28', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3710, '2023307947', 3, NULL, 1, '2025-01-29', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3711, '2023307947', 3, NULL, 1, '2025-01-30', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3712, '2022304730', 3, NULL, 1, '2024-12-31', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3713, '2022304730', 3, NULL, 1, '2025-01-01', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3714, '2022304730', 3, NULL, 1, '2025-01-02', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3715, '2022304730', 3, NULL, 1, '2025-01-05', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3716, '2022304730', 3, NULL, 1, '2025-01-06', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3717, '2022304730', 3, NULL, 1, '2025-01-07', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3718, '2022304730', 3, NULL, 1, '2025-01-08', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3719, '2022304730', 3, NULL, 1, '2025-01-09', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3720, '2022304730', 3, NULL, 1, '2025-01-12', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3721, '2022304730', 3, NULL, 1, '2025-01-13', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3722, '2022304730', 3, NULL, 1, '2025-01-14', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3723, '2022304730', 3, NULL, 1, '2025-01-15', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3724, '2022304730', 3, NULL, 1, '2025-01-16', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3725, '2022304730', 3, NULL, 1, '2025-01-19', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3726, '2022304730', 3, NULL, 1, '2025-01-20', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3727, '2022304730', 3, NULL, 1, '2025-01-21', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3728, '2022304730', 3, NULL, 1, '2025-01-22', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3729, '2022304730', 3, NULL, 1, '2025-01-23', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3730, '2022304730', 3, NULL, 1, '2025-01-26', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3731, '2022304730', 3, NULL, 1, '2025-01-27', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3732, '2022304730', 3, NULL, 1, '2025-01-28', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3733, '2022304730', 3, NULL, 1, '2025-01-29', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3734, '2022304730', 3, NULL, 1, '2025-01-30', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3735, '2021301086', 3, NULL, 1, '2024-12-31', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3736, '2021301086', 3, NULL, 1, '2025-01-01', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3737, '2021301086', 3, NULL, 1, '2025-01-02', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3738, '2021301086', 3, NULL, 1, '2025-01-05', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3739, '2021301086', 3, NULL, 1, '2025-01-06', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3740, '2021301086', 3, NULL, 1, '2025-01-07', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3741, '2021301086', 3, NULL, 1, '2025-01-08', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3742, '2021301086', 3, NULL, 1, '2025-01-09', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3743, '2021301086', 3, NULL, 1, '2025-01-12', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3744, '2021301086', 3, NULL, 1, '2025-01-13', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3745, '2021301086', 3, NULL, 1, '2025-01-14', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3746, '2021301086', 3, NULL, 1, '2025-01-15', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3747, '2021301086', 3, NULL, 1, '2025-01-16', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3748, '2021301086', 3, NULL, 1, '2025-01-19', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3749, '2021301086', 3, NULL, 1, '2025-01-20', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3750, '2021301086', 3, NULL, 1, '2025-01-21', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3751, '2021301086', 3, NULL, 1, '2025-01-22', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3752, '2021301086', 3, NULL, 1, '2025-01-23', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3753, '2021301086', 3, NULL, 1, '2025-01-26', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3754, '2021301086', 3, NULL, 1, '2025-01-27', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3755, '2021301086', 3, NULL, 1, '2025-01-28', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3756, '2021301086', 3, NULL, 1, '2025-01-29', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3757, '2021301086', 3, NULL, 1, '2025-01-30', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3758, '2022303605', 3, NULL, 1, '2024-12-31', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3759, '2022303605', 3, NULL, 1, '2025-01-01', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3760, '2022303605', 3, NULL, 1, '2025-01-02', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3761, '2022303605', 3, NULL, 1, '2025-01-05', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3762, '2022303605', 3, NULL, 1, '2025-01-06', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3763, '2022303605', 3, NULL, 1, '2025-01-07', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3764, '2022303605', 3, NULL, 1, '2025-01-08', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3765, '2022303605', 3, NULL, 1, '2025-01-09', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3766, '2022303605', 3, NULL, 1, '2025-01-12', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3767, '2022303605', 3, NULL, 1, '2025-01-13', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3768, '2022303605', 3, NULL, 1, '2025-01-14', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3769, '2022303605', 3, NULL, 1, '2025-01-15', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3770, '2022303605', 3, NULL, 1, '2025-01-16', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3771, '2022303605', 3, NULL, 1, '2025-01-19', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3772, '2022303605', 3, NULL, 1, '2025-01-20', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3773, '2022303605', 3, NULL, 1, '2025-01-21', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3774, '2022303605', 3, NULL, 1, '2025-01-22', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3775, '2022303605', 3, NULL, 1, '2025-01-23', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3776, '2022303605', 3, NULL, 1, '2025-01-26', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3777, '2022303605', 3, NULL, 1, '2025-01-27', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3778, '2022303605', 3, NULL, 1, '2025-01-28', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3779, '2022303605', 3, NULL, 1, '2025-01-29', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3780, '2022303605', 3, NULL, 1, '2025-01-30', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3781, '2022305244', 3, NULL, 1, '2024-12-31', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3782, '2022305244', 3, NULL, 1, '2025-01-01', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3783, '2022305244', 3, NULL, 1, '2025-01-02', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3784, '2022305244', 3, NULL, 1, '2025-01-05', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3785, '2022305244', 3, NULL, 1, '2025-01-06', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3786, '2022305244', 3, NULL, 1, '2025-01-07', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3787, '2022305244', 3, NULL, 1, '2025-01-08', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3788, '2022305244', 3, NULL, 1, '2025-01-09', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3789, '2022305244', 3, NULL, 1, '2025-01-12', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3790, '2022305244', 3, NULL, 1, '2025-01-13', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3791, '2022305244', 3, NULL, 1, '2025-01-14', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3792, '2022305244', 3, NULL, 1, '2025-01-15', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3793, '2022305244', 3, NULL, 1, '2025-01-16', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3794, '2022305244', 3, NULL, 1, '2025-01-19', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3795, '2022305244', 3, NULL, 1, '2025-01-20', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3796, '2022305244', 3, NULL, 1, '2025-01-21', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3797, '2022305244', 3, NULL, 1, '2025-01-22', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3798, '2022305244', 3, NULL, 1, '2025-01-23', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3799, '2022305244', 3, NULL, 1, '2025-01-26', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3800, '2022305244', 3, NULL, 1, '2025-01-27', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3801, '2022305244', 3, NULL, 1, '2025-01-28', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3802, '2022305244', 3, NULL, 1, '2025-01-29', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3803, '2022305244', 3, NULL, 1, '2025-01-30', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3804, '2023306090', 3, NULL, 1, '2024-12-31', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3805, '2023306090', 3, NULL, 1, '2025-01-01', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3806, '2023306090', 3, NULL, 1, '2025-01-02', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3807, '2023306090', 3, NULL, 1, '2025-01-05', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3808, '2023306090', 3, NULL, 1, '2025-01-06', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3809, '2023306090', 3, NULL, 1, '2025-01-07', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3810, '2023306090', 3, NULL, 1, '2025-01-08', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3811, '2023306090', 3, NULL, 1, '2025-01-09', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3812, '2023306090', 3, NULL, 1, '2025-01-12', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3813, '2023306090', 3, NULL, 1, '2025-01-13', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3814, '2023306090', 3, NULL, 1, '2025-01-14', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3815, '2023306090', 3, NULL, 1, '2025-01-15', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3816, '2023306090', 3, NULL, 1, '2025-01-16', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3817, '2023306090', 3, NULL, 1, '2025-01-19', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3818, '2023306090', 3, NULL, 1, '2025-01-20', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3819, '2023306090', 3, NULL, 1, '2025-01-21', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3820, '2023306090', 3, NULL, 1, '2025-01-22', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3821, '2023306090', 3, NULL, 1, '2025-01-23', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3822, '2023306090', 3, NULL, 1, '2025-01-26', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3823, '2023306090', 3, NULL, 1, '2025-01-27', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3824, '2023306090', 3, NULL, 1, '2025-01-28', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3825, '2023306090', 3, NULL, 1, '2025-01-29', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3826, '2023306090', 3, NULL, 1, '2025-01-30', NULL, '', 1, '2025-11-28 20:20:34');
INSERT INTO `attendance_records` VALUES (3827, '2022310570', 3, NULL, 1, '2025-11-28', '20:26:41', 'Present', 1, '2025-11-28 20:26:41');
INSERT INTO `attendance_records` VALUES (3835, '2021305768', 3, NULL, 1, '2025-11-28', '20:23:51', 'Late', 1, '2025-11-28 20:23:51');
INSERT INTO `attendance_records` VALUES (3837, '2022304738', 3, NULL, 1, '2025-11-28', NULL, 'Absent', 1, '2025-11-28 20:25:28');
INSERT INTO `attendance_records` VALUES (3842, '2022304738', 3, NULL, 1, '2025-11-25', '20:26:42', 'Present', 1, '2025-11-28 20:26:42');
INSERT INTO `attendance_records` VALUES (3847, '2021301661', 2, NULL, 1, '2025-11-02', NULL, '', 1, '2025-12-02 09:57:19');
INSERT INTO `attendance_records` VALUES (3848, '2021301661', 2, NULL, 1, '2025-11-03', NULL, '', 1, '2025-12-02 09:57:19');
INSERT INTO `attendance_records` VALUES (3849, '2021301661', 2, NULL, 1, '2025-11-04', NULL, '', 1, '2025-12-02 09:57:19');
INSERT INTO `attendance_records` VALUES (3850, '2021301661', 2, NULL, 1, '2025-11-05', NULL, '', 1, '2025-12-02 09:57:19');
INSERT INTO `attendance_records` VALUES (3851, '2021301661', 2, NULL, 1, '2025-11-06', NULL, '', 1, '2025-12-02 09:57:19');
INSERT INTO `attendance_records` VALUES (3852, '2021301661', 2, NULL, 1, '2025-11-09', NULL, '', 1, '2025-12-02 09:57:19');
INSERT INTO `attendance_records` VALUES (3853, '2021301661', 2, NULL, 1, '2025-11-10', NULL, '', 1, '2025-12-02 09:57:19');
INSERT INTO `attendance_records` VALUES (3854, '2021301661', 2, NULL, 1, '2025-11-11', NULL, '', 1, '2025-12-02 09:57:19');
INSERT INTO `attendance_records` VALUES (3855, '2021301661', 2, NULL, 1, '2025-11-12', NULL, '', 1, '2025-12-02 09:57:19');
INSERT INTO `attendance_records` VALUES (3856, '2021301661', 2, NULL, 1, '2025-11-13', NULL, '', 1, '2025-12-02 09:57:19');
INSERT INTO `attendance_records` VALUES (3857, '2021301661', 2, NULL, 1, '2025-11-16', NULL, '', 1, '2025-12-02 09:57:19');
INSERT INTO `attendance_records` VALUES (3858, '2021301661', 2, NULL, 1, '2025-11-17', NULL, '', 1, '2025-12-02 09:57:19');
INSERT INTO `attendance_records` VALUES (3859, '2021301661', 2, NULL, 1, '2025-11-18', NULL, '', 1, '2025-12-02 09:57:19');
INSERT INTO `attendance_records` VALUES (3860, '2021301661', 2, NULL, 1, '2025-11-19', NULL, '', 1, '2025-12-02 09:57:19');
INSERT INTO `attendance_records` VALUES (3861, '2021301661', 2, NULL, 1, '2025-11-20', NULL, '', 1, '2025-12-02 09:57:19');
INSERT INTO `attendance_records` VALUES (3862, '2021301661', 2, NULL, 1, '2025-11-23', NULL, '', 1, '2025-12-02 09:57:19');
INSERT INTO `attendance_records` VALUES (3863, '2021301661', 2, NULL, 1, '2025-11-24', NULL, '', 1, '2025-12-02 09:57:19');
INSERT INTO `attendance_records` VALUES (3864, '2021301661', 2, NULL, 1, '2025-11-25', NULL, '', 1, '2025-12-02 09:57:19');
INSERT INTO `attendance_records` VALUES (3865, '2021301661', 2, NULL, 1, '2025-11-26', NULL, '', 1, '2025-12-02 09:57:19');
INSERT INTO `attendance_records` VALUES (3866, '2021301661', 2, NULL, 1, '2025-11-27', NULL, '', 1, '2025-12-02 09:57:19');
INSERT INTO `attendance_records` VALUES (3867, '2023307876', 2, NULL, 1, '2025-11-02', NULL, '', 1, '2025-12-02 09:57:19');
INSERT INTO `attendance_records` VALUES (3868, '2023307876', 2, NULL, 1, '2025-11-03', NULL, '', 1, '2025-12-02 09:57:19');
INSERT INTO `attendance_records` VALUES (3869, '2023307876', 2, NULL, 1, '2025-11-04', NULL, '', 1, '2025-12-02 09:57:19');
INSERT INTO `attendance_records` VALUES (3870, '2023307876', 2, NULL, 1, '2025-11-05', NULL, '', 1, '2025-12-02 09:57:19');
INSERT INTO `attendance_records` VALUES (3871, '2023307876', 2, NULL, 1, '2025-11-06', NULL, '', 1, '2025-12-02 09:57:19');
INSERT INTO `attendance_records` VALUES (3872, '2023307876', 2, NULL, 1, '2025-11-09', NULL, '', 1, '2025-12-02 09:57:19');
INSERT INTO `attendance_records` VALUES (3873, '2023307876', 2, NULL, 1, '2025-11-10', NULL, '', 1, '2025-12-02 09:57:19');
INSERT INTO `attendance_records` VALUES (3874, '2023307876', 2, NULL, 1, '2025-11-11', NULL, '', 1, '2025-12-02 09:57:19');
INSERT INTO `attendance_records` VALUES (3875, '2023307876', 2, NULL, 1, '2025-11-12', NULL, '', 1, '2025-12-02 09:57:19');
INSERT INTO `attendance_records` VALUES (3876, '2023307876', 2, NULL, 1, '2025-11-13', NULL, '', 1, '2025-12-02 09:57:19');
INSERT INTO `attendance_records` VALUES (3877, '2023307876', 2, NULL, 1, '2025-11-16', NULL, '', 1, '2025-12-02 09:57:19');
INSERT INTO `attendance_records` VALUES (3878, '2023307876', 2, NULL, 1, '2025-11-17', NULL, '', 1, '2025-12-02 09:57:19');
INSERT INTO `attendance_records` VALUES (3879, '2023307876', 2, NULL, 1, '2025-11-18', NULL, '', 1, '2025-12-02 09:57:19');
INSERT INTO `attendance_records` VALUES (3880, '2023307876', 2, NULL, 1, '2025-11-19', NULL, '', 1, '2025-12-02 09:57:19');
INSERT INTO `attendance_records` VALUES (3881, '2023307876', 2, NULL, 1, '2025-11-20', NULL, '', 1, '2025-12-02 09:57:19');
INSERT INTO `attendance_records` VALUES (3882, '2023307876', 2, NULL, 1, '2025-11-23', NULL, '', 1, '2025-12-02 09:57:19');
INSERT INTO `attendance_records` VALUES (3883, '2023307876', 2, NULL, 1, '2025-11-24', NULL, '', 1, '2025-12-02 09:57:19');
INSERT INTO `attendance_records` VALUES (3884, '2023307876', 2, NULL, 1, '2025-11-25', NULL, '', 1, '2025-12-02 09:57:19');
INSERT INTO `attendance_records` VALUES (3885, '2023307876', 2, NULL, 1, '2025-11-26', NULL, '', 1, '2025-12-02 09:57:19');
INSERT INTO `attendance_records` VALUES (3886, '2023307876', 2, NULL, 1, '2025-11-27', NULL, '', 1, '2025-12-02 09:57:19');
INSERT INTO `attendance_records` VALUES (3887, '2022304979', 2, NULL, 1, '2025-11-02', NULL, '', 1, '2025-12-02 09:57:19');
INSERT INTO `attendance_records` VALUES (3888, '2022304979', 2, NULL, 1, '2025-11-03', NULL, '', 1, '2025-12-02 09:57:19');
INSERT INTO `attendance_records` VALUES (3889, '2022304979', 2, NULL, 1, '2025-11-04', NULL, '', 1, '2025-12-02 09:57:19');
INSERT INTO `attendance_records` VALUES (3890, '2022304979', 2, NULL, 1, '2025-11-05', NULL, '', 1, '2025-12-02 09:57:19');
INSERT INTO `attendance_records` VALUES (3891, '2022304979', 2, NULL, 1, '2025-11-06', NULL, '', 1, '2025-12-02 09:57:19');
INSERT INTO `attendance_records` VALUES (3892, '2022304979', 2, NULL, 1, '2025-11-09', NULL, '', 1, '2025-12-02 09:57:19');
INSERT INTO `attendance_records` VALUES (3893, '2022304979', 2, NULL, 1, '2025-11-10', NULL, '', 1, '2025-12-02 09:57:19');
INSERT INTO `attendance_records` VALUES (3894, '2022304979', 2, NULL, 1, '2025-11-11', NULL, '', 1, '2025-12-02 09:57:19');
INSERT INTO `attendance_records` VALUES (3895, '2022304979', 2, NULL, 1, '2025-11-12', NULL, '', 1, '2025-12-02 09:57:19');
INSERT INTO `attendance_records` VALUES (3896, '2022304979', 2, NULL, 1, '2025-11-13', NULL, '', 1, '2025-12-02 09:57:19');
INSERT INTO `attendance_records` VALUES (3897, '2022304979', 2, NULL, 1, '2025-11-16', NULL, '', 1, '2025-12-02 09:57:19');
INSERT INTO `attendance_records` VALUES (3898, '2022304979', 2, NULL, 1, '2025-11-17', NULL, '', 1, '2025-12-02 09:57:19');
INSERT INTO `attendance_records` VALUES (3899, '2022304979', 2, NULL, 1, '2025-11-18', NULL, '', 1, '2025-12-02 09:57:19');
INSERT INTO `attendance_records` VALUES (3900, '2022304979', 2, NULL, 1, '2025-11-19', NULL, '', 1, '2025-12-02 09:57:19');
INSERT INTO `attendance_records` VALUES (3901, '2022304979', 2, NULL, 1, '2025-11-20', NULL, '', 1, '2025-12-02 09:57:19');
INSERT INTO `attendance_records` VALUES (3902, '2022304979', 2, NULL, 1, '2025-11-23', NULL, '', 1, '2025-12-02 09:57:19');
INSERT INTO `attendance_records` VALUES (3903, '2022304979', 2, NULL, 1, '2025-11-24', NULL, '', 1, '2025-12-02 09:57:19');
INSERT INTO `attendance_records` VALUES (3904, '2022304979', 2, NULL, 1, '2025-11-25', NULL, '', 1, '2025-12-02 09:57:19');
INSERT INTO `attendance_records` VALUES (3905, '2022304979', 2, NULL, 1, '2025-11-26', NULL, '', 1, '2025-12-02 09:57:19');
INSERT INTO `attendance_records` VALUES (3906, '2022304979', 2, NULL, 1, '2025-11-27', NULL, '', 1, '2025-12-02 09:57:19');
INSERT INTO `attendance_records` VALUES (3907, '2023307846', 2, NULL, 1, '2025-11-02', NULL, '', 1, '2025-12-02 09:57:19');
INSERT INTO `attendance_records` VALUES (3908, '2023307846', 2, NULL, 1, '2025-11-03', NULL, '', 1, '2025-12-02 09:57:19');
INSERT INTO `attendance_records` VALUES (3909, '2023307846', 2, NULL, 1, '2025-11-04', NULL, '', 1, '2025-12-02 09:57:19');
INSERT INTO `attendance_records` VALUES (3910, '2023307846', 2, NULL, 1, '2025-11-05', NULL, '', 1, '2025-12-02 09:57:19');
INSERT INTO `attendance_records` VALUES (3911, '2023307846', 2, NULL, 1, '2025-11-06', NULL, '', 1, '2025-12-02 09:57:19');
INSERT INTO `attendance_records` VALUES (3912, '2023307846', 2, NULL, 1, '2025-11-09', NULL, '', 1, '2025-12-02 09:57:19');
INSERT INTO `attendance_records` VALUES (3913, '2023307846', 2, NULL, 1, '2025-11-10', NULL, '', 1, '2025-12-02 09:57:19');
INSERT INTO `attendance_records` VALUES (3914, '2023307846', 2, NULL, 1, '2025-11-11', NULL, '', 1, '2025-12-02 09:57:19');
INSERT INTO `attendance_records` VALUES (3915, '2023307846', 2, NULL, 1, '2025-11-12', NULL, '', 1, '2025-12-02 09:57:19');
INSERT INTO `attendance_records` VALUES (3916, '2023307846', 2, NULL, 1, '2025-11-13', NULL, '', 1, '2025-12-02 09:57:19');
INSERT INTO `attendance_records` VALUES (3917, '2023307846', 2, NULL, 1, '2025-11-16', NULL, '', 1, '2025-12-02 09:57:19');
INSERT INTO `attendance_records` VALUES (3918, '2023307846', 2, NULL, 1, '2025-11-17', NULL, '', 1, '2025-12-02 09:57:19');
INSERT INTO `attendance_records` VALUES (3919, '2023307846', 2, NULL, 1, '2025-11-18', NULL, '', 1, '2025-12-02 09:57:19');
INSERT INTO `attendance_records` VALUES (3920, '2023307846', 2, NULL, 1, '2025-11-19', NULL, '', 1, '2025-12-02 09:57:19');
INSERT INTO `attendance_records` VALUES (3921, '2023307846', 2, NULL, 1, '2025-11-20', NULL, '', 1, '2025-12-02 09:57:19');
INSERT INTO `attendance_records` VALUES (3922, '2023307846', 2, NULL, 1, '2025-11-23', NULL, '', 1, '2025-12-02 09:57:19');
INSERT INTO `attendance_records` VALUES (3923, '2023307846', 2, NULL, 1, '2025-11-24', NULL, '', 1, '2025-12-02 09:57:19');
INSERT INTO `attendance_records` VALUES (3924, '2023307846', 2, NULL, 1, '2025-11-25', NULL, '', 1, '2025-12-02 09:57:19');
INSERT INTO `attendance_records` VALUES (3925, '2023307846', 2, NULL, 1, '2025-11-26', NULL, '', 1, '2025-12-02 09:57:19');
INSERT INTO `attendance_records` VALUES (3926, '2023307846', 2, NULL, 1, '2025-11-27', NULL, '', 1, '2025-12-02 09:57:19');
INSERT INTO `attendance_records` VALUES (3927, '2022304841', 2, NULL, 1, '2025-11-02', NULL, '', 1, '2025-12-02 09:57:19');
INSERT INTO `attendance_records` VALUES (3928, '2022304841', 2, NULL, 1, '2025-11-03', NULL, '', 1, '2025-12-02 09:57:19');
INSERT INTO `attendance_records` VALUES (3929, '2022304841', 2, NULL, 1, '2025-11-04', NULL, '', 1, '2025-12-02 09:57:19');
INSERT INTO `attendance_records` VALUES (3930, '2022304841', 2, NULL, 1, '2025-11-05', NULL, '', 1, '2025-12-02 09:57:19');
INSERT INTO `attendance_records` VALUES (3931, '2022304841', 2, NULL, 1, '2025-11-06', NULL, '', 1, '2025-12-02 09:57:19');
INSERT INTO `attendance_records` VALUES (3932, '2022304841', 2, NULL, 1, '2025-11-09', NULL, '', 1, '2025-12-02 09:57:19');
INSERT INTO `attendance_records` VALUES (3933, '2022304841', 2, NULL, 1, '2025-11-10', NULL, '', 1, '2025-12-02 09:57:19');
INSERT INTO `attendance_records` VALUES (3934, '2022304841', 2, NULL, 1, '2025-11-11', NULL, '', 1, '2025-12-02 09:57:19');
INSERT INTO `attendance_records` VALUES (3935, '2022304841', 2, NULL, 1, '2025-11-12', NULL, '', 1, '2025-12-02 09:57:19');
INSERT INTO `attendance_records` VALUES (3936, '2022304841', 2, NULL, 1, '2025-11-13', NULL, '', 1, '2025-12-02 09:57:19');
INSERT INTO `attendance_records` VALUES (3937, '2022304841', 2, NULL, 1, '2025-11-16', NULL, '', 1, '2025-12-02 09:57:19');
INSERT INTO `attendance_records` VALUES (3938, '2022304841', 2, NULL, 1, '2025-11-17', NULL, '', 1, '2025-12-02 09:57:19');
INSERT INTO `attendance_records` VALUES (3939, '2022304841', 2, NULL, 1, '2025-11-18', NULL, '', 1, '2025-12-02 09:57:19');
INSERT INTO `attendance_records` VALUES (3940, '2022304841', 2, NULL, 1, '2025-11-19', NULL, '', 1, '2025-12-02 09:57:19');
INSERT INTO `attendance_records` VALUES (3941, '2022304841', 2, NULL, 1, '2025-11-20', NULL, '', 1, '2025-12-02 09:57:19');
INSERT INTO `attendance_records` VALUES (3942, '2022304841', 2, NULL, 1, '2025-11-23', NULL, '', 1, '2025-12-02 09:57:19');
INSERT INTO `attendance_records` VALUES (3943, '2022304841', 2, NULL, 1, '2025-11-24', NULL, '', 1, '2025-12-02 09:57:19');
INSERT INTO `attendance_records` VALUES (3944, '2022304841', 2, NULL, 1, '2025-11-25', NULL, '', 1, '2025-12-02 09:57:19');
INSERT INTO `attendance_records` VALUES (3945, '2022304841', 2, NULL, 1, '2025-11-26', NULL, '', 1, '2025-12-02 09:57:19');
INSERT INTO `attendance_records` VALUES (3946, '2022304841', 2, NULL, 1, '2025-11-27', NULL, '', 1, '2025-12-02 09:57:19');

-- ----------------------------
-- Table structure for course_catalog
-- ----------------------------
DROP TABLE IF EXISTS `course_catalog`;
CREATE TABLE `course_catalog`  (
  `SubjectID` int(11) NOT NULL AUTO_INCREMENT,
  `SubjectName` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `SubjectCode` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `RoomID` int(100) NULL DEFAULT NULL,
  `StartTime` time(0) NULL DEFAULT NULL,
  `EndTime` time(0) NULL DEFAULT NULL,
  `StatusID` int(11) NOT NULL,
  `CreatedAt` timestamp(0) NULL DEFAULT current_timestamp(),
  `UpdatedAt` timestamp(0) NULL DEFAULT current_timestamp() ON UPDATE CURRENT_TIMESTAMP(0),
  PRIMARY KEY (`SubjectID`) USING BTREE,
  UNIQUE INDEX `SubjectCode`(`SubjectCode`) USING BTREE,
  INDEX `StatusID`(`StatusID`) USING BTREE,
  INDEX `idx_subjects_code`(`SubjectCode`) USING BTREE,
  CONSTRAINT `course_catalog_ibfk_1` FOREIGN KEY (`StatusID`) REFERENCES `status` (`StatusID`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 8 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of course_catalog
-- ----------------------------
INSERT INTO `course_catalog` VALUES (1, 'Mathematics', 'MATH101', 2, '08:00:00', '09:00:00', 1, '2025-09-29 06:02:50', '2025-11-22 14:06:27');
INSERT INTO `course_catalog` VALUES (2, 'English Language', 'ENG101', 2, '09:00:00', '10:00:00', 1, '2025-09-29 06:02:50', '2025-11-22 13:56:52');
INSERT INTO `course_catalog` VALUES (3, 'Science', 'SCI101', 3, '10:00:00', '11:00:00', 1, '2025-09-29 06:02:50', '2025-11-22 13:56:50');
INSERT INTO `course_catalog` VALUES (4, 'Social Studies', 'SS101', NULL, NULL, NULL, 1, '2025-09-29 06:02:50', '2025-09-29 06:02:50');
INSERT INTO `course_catalog` VALUES (5, 'Physical Education', 'PE101', NULL, NULL, NULL, 1, '2025-09-29 06:02:50', '2025-09-29 06:02:50');
INSERT INTO `course_catalog` VALUES (6, 'Godspel', 'god1', 1, '13:41:00', '14:41:00', 1, '2025-09-29 07:05:15', '2025-11-22 14:06:12');
INSERT INTO `course_catalog` VALUES (7, 'Electronic Laws & Standards', 'ET 421', 1, NULL, '13:00:19', 1, '2025-11-27 13:00:19', '2025-11-27 17:14:46');

-- ----------------------------
-- Table structure for room
-- ----------------------------
DROP TABLE IF EXISTS `room`;
CREATE TABLE `room`  (
  `RoomID` int(11) NOT NULL AUTO_INCREMENT,
  `RoomName` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_uca1400_ai_ci NULL DEFAULT NULL,
  `Building` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_uca1400_ai_ci NULL DEFAULT NULL,
  `Capacity` int(11) NULL DEFAULT NULL,
  `StatusID` int(11) NULL DEFAULT 1,
  `CreatedAt` timestamp(0) NULL DEFAULT current_timestamp(),
  `UpdatedAt` timestamp(0) NULL DEFAULT current_timestamp() ON UPDATE CURRENT_TIMESTAMP(0),
  PRIMARY KEY (`RoomID`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 24 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_uca1400_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of room
-- ----------------------------
INSERT INTO `room` VALUES (1, 'R1-101', NULL, NULL, 1, '2025-11-24 03:50:47', '2025-11-24 03:50:47');
INSERT INTO `room` VALUES (2, 'R1-102', NULL, NULL, 1, '2025-11-24 03:50:47', '2025-11-24 03:50:47');

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
  `Monday` tinyint(1) NULL DEFAULT 0,
  `Tuesday` tinyint(1) NULL DEFAULT 0,
  `Wednesday` tinyint(1) NULL DEFAULT 0,
  `Thursday` tinyint(1) NULL DEFAULT 0,
  `Friday` tinyint(1) NULL DEFAULT 0,
  `MondayStart` time(0) NULL DEFAULT NULL,
  `MondayEnd` time(0) NULL DEFAULT NULL,
  `TuesdayStart` time(0) NULL DEFAULT NULL,
  `TuesdayEnd` time(0) NULL DEFAULT NULL,
  `WednesdayStart` time(0) NULL DEFAULT NULL,
  `WednesdayEnd` time(0) NULL DEFAULT NULL,
  `ThursdayStart` time(0) NULL DEFAULT NULL,
  `ThursdayEnd` time(0) NULL DEFAULT NULL,
  `FridayStart` time(0) NULL DEFAULT NULL,
  `FridayEnd` time(0) NULL DEFAULT NULL,
  `MondayTeacher` int(11) NULL DEFAULT NULL,
  `TuesdayTeacher` int(11) NULL DEFAULT NULL,
  `WednesdayTeacher` int(11) NULL DEFAULT NULL,
  `ThursdayTeacher` int(11) NULL DEFAULT NULL,
  `FridayTeacher` int(11) NULL DEFAULT NULL,
  `MondayRoom` int(11) NULL DEFAULT NULL,
  `TuesdayRoom` int(11) NULL DEFAULT NULL,
  `WednesdayRoom` int(11) NULL DEFAULT NULL,
  `ThursdayRoom` int(11) NULL DEFAULT NULL,
  `FridayRoom` int(11) NULL DEFAULT NULL,
  PRIMARY KEY (`SectionID`, `SubjectID`) USING BTREE,
  INDEX `idx_section_subjects_section`(`SectionID`) USING BTREE,
  INDEX `idx_section_subjects_subject`(`SubjectID`) USING BTREE,
  INDEX `idx_section_subjects_teacher`(`TeacherID`) USING BTREE,
  INDEX `idx_section_subjects_time`(`RoomID`, `StartTime`, `EndTime`) USING BTREE,
  INDEX `fk_section_subjects_monday_teacher`(`MondayTeacher`) USING BTREE,
  INDEX `fk_section_subjects_tuesday_teacher`(`TuesdayTeacher`) USING BTREE,
  INDEX `fk_section_subjects_wednesday_teacher`(`WednesdayTeacher`) USING BTREE,
  INDEX `fk_section_subjects_thursday_teacher`(`ThursdayTeacher`) USING BTREE,
  INDEX `fk_section_subjects_friday_teacher`(`FridayTeacher`) USING BTREE,
  CONSTRAINT `fk_section_subjects_friday_teacher` FOREIGN KEY (`FridayTeacher`) REFERENCES `teachers` (`TeacherID`) ON DELETE SET NULL ON UPDATE RESTRICT,
  CONSTRAINT `fk_section_subjects_monday_teacher` FOREIGN KEY (`MondayTeacher`) REFERENCES `teachers` (`TeacherID`) ON DELETE SET NULL ON UPDATE RESTRICT,
  CONSTRAINT `fk_section_subjects_thursday_teacher` FOREIGN KEY (`ThursdayTeacher`) REFERENCES `teachers` (`TeacherID`) ON DELETE SET NULL ON UPDATE RESTRICT,
  CONSTRAINT `fk_section_subjects_tuesday_teacher` FOREIGN KEY (`TuesdayTeacher`) REFERENCES `teachers` (`TeacherID`) ON DELETE SET NULL ON UPDATE RESTRICT,
  CONSTRAINT `fk_section_subjects_wednesday_teacher` FOREIGN KEY (`WednesdayTeacher`) REFERENCES `teachers` (`TeacherID`) ON DELETE SET NULL ON UPDATE RESTRICT,
  CONSTRAINT `section_subjects_ibfk_1` FOREIGN KEY (`SectionID`) REFERENCES `sections` (`SectionID`) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT `section_subjects_ibfk_3` FOREIGN KEY (`TeacherID`) REFERENCES `teachers` (`TeacherID`) ON DELETE SET NULL ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_uca1400_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of section_subjects
-- ----------------------------
INSERT INTO `section_subjects` VALUES (1, 1, 1, 1, '2025-09-29 07:29:39', NULL, NULL, 1, 1, 1, 0, 0, '10:00:00', '11:00:00', '08:00:00', '09:00:00', '09:15:00', '09:15:00', NULL, NULL, NULL, NULL, 1, 2, 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO `section_subjects` VALUES (1, 2, 1, 1, '2025-09-29 07:29:39', '15:00:00', '16:00:00', 0, 0, 0, 0, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO `section_subjects` VALUES (1, 3, NULL, 1, '2025-09-29 07:29:39', NULL, NULL, 0, 0, 0, 0, 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '19:00:00', '21:00:00', NULL, NULL, NULL, NULL, 1, NULL, NULL, NULL, NULL, NULL);
INSERT INTO `section_subjects` VALUES (1, 6, 1, NULL, '2025-11-27 12:22:09', NULL, NULL, 1, 0, 0, 0, 0, '12:18:00', '12:18:00', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 3, NULL, NULL, NULL, NULL, 23, NULL, NULL, NULL, NULL);
INSERT INTO `section_subjects` VALUES (1, 7, NULL, 1, '2025-11-27 13:04:07', NULL, NULL, 0, 0, 0, 1, 1, NULL, NULL, NULL, NULL, NULL, NULL, '18:00:00', '21:00:00', '13:00:00', '17:00:00', NULL, NULL, NULL, 5, 5, NULL, NULL, NULL, 1, 1);
INSERT INTO `section_subjects` VALUES (1, 8, NULL, NULL, '2025-11-27 13:13:24', NULL, NULL, 0, 1, 0, 1, 0, NULL, NULL, '10:30:00', '12:00:00', NULL, NULL, '10:30:00', '12:00:00', NULL, NULL, NULL, 5, NULL, 5, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO `section_subjects` VALUES (1, 9, NULL, NULL, '2025-11-27 17:18:01', NULL, NULL, 0, 0, 0, 1, 1, NULL, NULL, NULL, NULL, NULL, NULL, '18:00:00', '21:00:00', '13:00:00', '16:00:00', NULL, NULL, NULL, 5, 5, NULL, NULL, NULL, 1, 1);
INSERT INTO `section_subjects` VALUES (2, 1, 1, NULL, '2025-09-29 07:29:39', '07:00:00', '08:00:00', 0, 0, 0, 0, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO `section_subjects` VALUES (2, 3, 1, NULL, '2025-09-29 07:29:39', '08:00:00', '09:00:00', 0, 0, 0, 0, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO `section_subjects` VALUES (2, 4, 1, 1, '2025-09-29 07:29:39', '09:00:00', '10:00:00', 0, 0, 0, 0, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO `section_subjects` VALUES (3, 1, NULL, NULL, '2025-12-01 18:25:15', NULL, NULL, 0, 0, 0, 0, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO `section_subjects` VALUES (3, 2, NULL, NULL, '2025-12-01 18:25:15', NULL, NULL, 0, 0, 0, 0, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO `section_subjects` VALUES (3, 3, NULL, NULL, '2025-12-01 18:25:15', NULL, NULL, 0, 0, 0, 0, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO `section_subjects` VALUES (3, 4, NULL, NULL, '2025-12-01 18:25:15', NULL, NULL, 0, 0, 0, 0, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO `section_subjects` VALUES (3, 5, NULL, NULL, '2025-12-01 18:25:15', NULL, NULL, 0, 0, 0, 0, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO `section_subjects` VALUES (3, 6, NULL, NULL, '2025-12-01 18:25:15', NULL, NULL, 0, 0, 0, 0, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO `section_subjects` VALUES (3, 7, NULL, NULL, '2025-12-01 18:25:15', NULL, NULL, 0, 0, 0, 0, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO `section_subjects` VALUES (3, 8, NULL, NULL, '2025-12-01 18:25:15', NULL, NULL, 0, 0, 0, 0, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO `section_subjects` VALUES (3, 10, 5, 1, '2025-12-02 11:34:31', NULL, NULL, 1, 0, 0, 0, 0, '07:00:00', '08:00:00', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 5, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO `section_subjects` VALUES (4, 1, NULL, NULL, '2025-12-02 11:38:26', NULL, NULL, 0, 0, 0, 0, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO `section_subjects` VALUES (4, 2, NULL, NULL, '2025-12-02 11:38:26', NULL, NULL, 0, 0, 0, 0, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO `section_subjects` VALUES (4, 3, NULL, NULL, '2025-12-02 11:38:26', NULL, NULL, 0, 0, 0, 0, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO `section_subjects` VALUES (4, 4, NULL, NULL, '2025-12-02 11:38:26', NULL, NULL, 0, 0, 0, 0, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO `section_subjects` VALUES (4, 5, NULL, NULL, '2025-12-02 11:38:26', NULL, NULL, 0, 0, 0, 0, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO `section_subjects` VALUES (4, 6, NULL, NULL, '2025-12-02 11:38:26', NULL, NULL, 0, 0, 0, 0, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO `section_subjects` VALUES (4, 7, NULL, NULL, '2025-12-02 11:38:26', NULL, NULL, 0, 0, 0, 0, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO `section_subjects` VALUES (4, 8, NULL, NULL, '2025-12-02 11:38:26', NULL, NULL, 0, 0, 0, 0, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO `section_subjects` VALUES (4, 10, NULL, NULL, '2025-12-02 11:38:26', NULL, NULL, 0, 0, 0, 0, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO `section_subjects` VALUES (4, 11, NULL, NULL, '2025-12-02 11:38:26', NULL, NULL, 0, 0, 0, 0, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);

-- ----------------------------
-- Table structure for sections
-- ----------------------------
DROP TABLE IF EXISTS `sections`;
CREATE TABLE `sections`  (
  `SectionID` int(11) NOT NULL AUTO_INCREMENT,
  `SectionName` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `semester` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `school_year` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `CreatedAt` timestamp(0) NULL DEFAULT current_timestamp(),
  `UpdatedAt` timestamp(0) NULL DEFAULT current_timestamp() ON UPDATE CURRENT_TIMESTAMP(0),
  `StatusID` int(15) NULL DEFAULT NULL,
  `SchoolYear` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '2024-2025',
  PRIMARY KEY (`SectionID`) USING BTREE,
  UNIQUE INDEX `SectionName`(`SectionName`) USING BTREE,
  INDEX `idx_sections_name`(`SectionName`) USING BTREE,
  INDEX `fk_sections_status`(`StatusID`) USING BTREE,
  CONSTRAINT `fk_sections_status` FOREIGN KEY (`StatusID`) REFERENCES `status` (`StatusID`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 5 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sections
-- ----------------------------
INSERT INTO `sections` VALUES (1, 'TN401', '1st Semester', NULL, '2025-09-29 06:02:50', '2025-11-27 13:31:33', 1, '2024-2025');
INSERT INTO `sections` VALUES (2, 'TN301', '1st Semester', NULL, '2025-09-29 06:02:50', '2025-11-27 13:33:09', 1, '2024-2025');
INSERT INTO `sections` VALUES (3, 'TN101', NULL, NULL, '2025-12-01 18:25:15', '2025-12-01 18:25:15', 1, '2024-2025');
INSERT INTO `sections` VALUES (4, 'MST102', NULL, NULL, '2025-12-02 11:38:26', '2025-12-02 11:38:26', 1, '2024-2025');

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
INSERT INTO `students` VALUES ('2013100521', 'Jonel', 'Jonel', 'Jonel', 1, '3rd Year', NULL, '2025-11-23 05:04:37', '2025-11-27 13:41:04');
INSERT INTO `students` VALUES ('2015100053', 'John', 'Baptish', 'Peter', 1, '3rd Year', NULL, '2025-09-29 07:03:46', '2025-11-27 13:41:04');
INSERT INTO `students` VALUES ('20151021011', 'Dom', 'de Guzman', 'A', 1, '4th Year', NULL, '2025-11-21 17:33:13', '2025-11-27 13:41:14');
INSERT INTO `students` VALUES ('2020302622', 'Erica Mae', 'Achacoso', 'Daguplo', 1, '3rd Year', NULL, '2025-11-21 15:45:33', '2025-11-27 13:41:04');
INSERT INTO `students` VALUES ('2020307345', 'Jesserhyll ', 'Nanale', 'L.', 1, '4th Year', NULL, '2025-11-27 17:03:04', '2025-11-27 17:03:04');
INSERT INTO `students` VALUES ('2021301086', 'Gabriel', 'Tan', 'Dura', 1, '3rd Year', NULL, '2025-11-21 15:41:19', '2025-11-27 13:41:04');
INSERT INTO `students` VALUES ('2021301661', 'Adrian', 'Abatayo', 'B.', 1, '3rd Year', NULL, '2025-11-21 15:43:03', '2025-11-27 13:41:04');
INSERT INTO `students` VALUES ('2021303569', 'Bernadette', 'Abarca', NULL, 1, '3rd Year', NULL, '2025-11-21 15:38:50', '2025-11-27 13:41:04');
INSERT INTO `students` VALUES ('2021304973', 'Bethel ', 'Campugan', 'P.', 1, '4th Year', NULL, '2025-11-27 18:16:17', '2025-11-27 18:16:17');
INSERT INTO `students` VALUES ('2021305768', 'Dheryl Joy', 'Quinal', 'N/A', 1, '3rd Year', NULL, '2025-11-21 15:42:29', '2025-11-27 13:41:04');
INSERT INTO `students` VALUES ('2021309452', 'Charles Louise ', 'Abrio', 'R.', 1, '4th Year', NULL, '2025-11-27 17:08:17', '2025-11-27 17:08:17');
INSERT INTO `students` VALUES ('2022301730', 'Phillip Samuel', 'Lugay', 'Biwang', 1, '3rd Year', NULL, '2025-11-21 15:40:46', '2025-11-27 13:41:04');
INSERT INTO `students` VALUES ('2022303249', 'Jay Chris', 'Cabigon', 'A', 1, '3rd Year', NULL, '2025-11-21 16:28:11', '2025-11-27 13:41:04');
INSERT INTO `students` VALUES ('2022303307', 'Gilson', 'Belangel', 'Piquero', 1, '3rd Year', NULL, '2025-11-21 15:48:10', '2025-11-27 13:41:04');
INSERT INTO `students` VALUES ('2022303605', 'Via', 'Tundag', 'Tagapulot', 1, '3rd Year', NULL, '2025-11-21 15:44:12', '2025-11-27 13:41:04');
INSERT INTO `students` VALUES ('2022304191', 'Ian Christian', 'Pairat', 'O.', 1, '4th Year', NULL, '2025-11-27 17:08:50', '2025-11-27 17:08:50');
INSERT INTO `students` VALUES ('2022304192', 'Irene', 'Egao', 'D.', 1, '4th Year', NULL, '2025-11-27 17:03:31', '2025-11-27 17:03:31');
INSERT INTO `students` VALUES ('2022304246', 'Cliford', 'Paimalan', 'T.', 1, '4th Year', NULL, '2025-11-27 16:59:04', '2025-11-27 16:59:04');
INSERT INTO `students` VALUES ('2022304716', 'Pia Grace', 'Ellezo', 'B.', 1, '4th Year', NULL, '2025-11-27 17:05:11', '2025-11-27 17:05:11');
INSERT INTO `students` VALUES ('2022304730', 'Ilaiza Mae', 'Taghap', 'A.', 1, '4th Year', NULL, '2025-11-27 17:02:21', '2025-11-27 17:02:21');
INSERT INTO `students` VALUES ('2022304738', 'Rob Ryan', 'Abadilla', 'R.', 1, '4th Year', NULL, '2025-11-27 17:09:46', '2025-11-27 17:09:46');
INSERT INTO `students` VALUES ('2022304754', 'Dan Rowena Severina ', 'Aquino', 'D.', 1, '4th Year', NULL, '2025-11-27 17:00:44', '2025-11-27 17:00:44');
INSERT INTO `students` VALUES ('2022304760', 'Melch Catherine', 'Absuelo', 'M.', 1, '4th Year', NULL, '2025-11-27 16:59:32', '2025-11-27 16:59:32');
INSERT INTO `students` VALUES ('2022304808', 'Texillah', 'Antiquera', 'E.', 1, '4th Year', NULL, '2025-11-27 17:04:44', '2025-11-27 17:04:44');
INSERT INTO `students` VALUES ('2022304841', 'Andre Dale Miguel', 'Sotes', 'S.', 1, '4th Year', NULL, '2025-11-27 16:57:21', '2025-11-27 16:57:21');
INSERT INTO `students` VALUES ('2022304979', 'Gerjen Mae', 'Espinosa', 'L.', 1, '4th Year', NULL, '2025-11-27 16:55:57', '2025-11-27 16:55:57');
INSERT INTO `students` VALUES ('2022304991', 'Francis Jean', 'Pedrosa', 'B.', 1, '4th Year', NULL, '2025-11-27 17:05:51', '2025-11-27 17:05:51');
INSERT INTO `students` VALUES ('2022305036', 'Marc Ray', 'Del Puerto', 'L.', 1, '4th Year', NULL, '2025-11-27 19:37:32', '2025-11-27 19:37:32');
INSERT INTO `students` VALUES ('2022305040', 'Reighna Jee', 'Mipranum', 'B.', 1, '4th Year', NULL, '2025-11-27 17:00:09', '2025-11-27 17:00:09');
INSERT INTO `students` VALUES ('2022305059', 'Kurt Andrey ', 'Ballesteros', 'C', 1, '4th Year', NULL, '2025-11-27 20:06:04', '2025-11-27 20:06:04');
INSERT INTO `students` VALUES ('2022305203', 'Jenelyn', 'Lagno', NULL, 1, '4th Year', NULL, '2025-11-27 17:09:12', '2025-11-27 17:09:12');
INSERT INTO `students` VALUES ('2022305208', 'Mikaela Louise', 'Fulminar', 'D.', 1, '4th Year', NULL, '2025-11-27 16:57:54', '2025-11-27 16:57:54');
INSERT INTO `students` VALUES ('2022305211', 'Ara Karylle', 'Morales', 'T.', 1, '4th Year', NULL, '2025-11-27 16:58:26', '2025-11-27 16:58:26');
INSERT INTO `students` VALUES ('2022305241', 'Janlee', 'Sastrillo', NULL, 1, '4th Year', NULL, '2025-11-27 20:04:35', '2025-11-27 20:04:35');
INSERT INTO `students` VALUES ('2022305244', 'Cherry Joyce ', 'Umpad', 'N.', 1, '4th Year', NULL, '2025-11-27 17:01:15', '2025-11-27 17:01:15');
INSERT INTO `students` VALUES ('2022306420', 'Marlou Christmae', 'Apdian', 'A.', 1, '4th Year', NULL, '2025-11-27 17:07:40', '2025-11-27 17:07:40');
INSERT INTO `students` VALUES ('2022306426', 'Cherry Mae', 'Gabato', 'L.', 1, '4th Year', NULL, '2025-11-27 19:03:44', '2025-11-27 19:03:44');
INSERT INTO `students` VALUES ('2022306538', 'Julie Ann', 'Amasola', 'B.', 1, '4th Year', NULL, '2025-11-27 17:10:46', '2025-11-27 17:10:46');
INSERT INTO `students` VALUES ('2022310245', 'Benigno Jr.', 'Salvaña', 'D.', 1, '4th Year', NULL, '2025-11-27 17:01:49', '2025-11-27 17:01:49');
INSERT INTO `students` VALUES ('2022310247', 'Hannah', 'Madronal', 'M.', 1, '4th Year', NULL, '2025-11-27 17:06:43', '2025-11-27 20:36:21');
INSERT INTO `students` VALUES ('2022310250', 'Angela May', 'Muit', 'S.', 1, '4th Year', NULL, '2025-11-27 16:56:46', '2025-11-27 16:56:46');
INSERT INTO `students` VALUES ('2022310275', 'Jhon Dave', 'Betancor', 'M.', 1, '4th Year', NULL, '2025-11-27 18:10:53', '2025-11-27 18:10:53');
INSERT INTO `students` VALUES ('2022310570', 'Genevie', 'Calising', 'P.', 1, '4th Year', NULL, '2025-11-27 19:15:53', '2025-11-27 19:15:53');
INSERT INTO `students` VALUES ('2022310895', 'Desiree Mayen Bless', 'Nudos', 'T.', 1, '4th Year', NULL, '2025-11-27 17:07:11', '2025-11-27 17:07:11');
INSERT INTO `students` VALUES ('2022311007', 'Lenuel', 'Alvarado', 'A.', 1, '4th Year', NULL, '2025-11-27 17:10:14', '2025-11-27 17:10:14');
INSERT INTO `students` VALUES ('2023306090', 'Jackie France ', 'Variacion', 'Suarez', 1, '3rd Year', NULL, '2025-11-21 15:35:27', '2025-11-27 13:41:04');
INSERT INTO `students` VALUES ('2023307823', 'Val Jasper', 'Lloren', 'Magatao', 1, '3rd Year', NULL, '2025-11-21 15:44:37', '2025-11-27 13:41:04');
INSERT INTO `students` VALUES ('2023307846', 'Angel Mekyla', 'Sayson', 'D', 1, '3rd Year', NULL, '2025-11-21 16:01:55', '2025-11-27 13:41:04');
INSERT INTO `students` VALUES ('2023307875', 'RUEBEN', 'LEGASPI', 'FRANCISCO', 1, '3rd Year', NULL, '2025-11-21 15:36:07', '2025-11-27 13:41:04');
INSERT INTO `students` VALUES ('2023307876', 'Althea Grace', 'Bierneza', 'Lechugas', 1, '3rd Year', NULL, '2025-11-21 15:47:16', '2025-11-27 13:41:04');
INSERT INTO `students` VALUES ('2023307890', 'Jay Lloyd', 'Mutia', 'Vivares', 1, '3rd Year', NULL, '2025-11-21 15:40:18', '2025-11-27 13:41:04');
INSERT INTO `students` VALUES ('2023307947', 'Phillip', 'Tabanera', 'Quilang', 1, '3rd Year', NULL, '2025-11-21 15:39:33', '2025-11-27 13:41:04');
INSERT INTO `students` VALUES ('2023308162', 'Kart Vincent ', 'Jerado', 'B', 1, '3rd Year', NULL, '2025-11-21 15:48:48', '2025-11-27 13:41:04');
INSERT INTO `students` VALUES ('2023308166', 'JACKY', 'BARON', 'TANIO', 1, '3rd Year', NULL, '2025-11-21 15:37:06', '2025-11-27 13:41:04');
INSERT INTO `students` VALUES ('2023308193', 'Dvkid ', 'Caipang', 'B.', 1, '3rd Year', NULL, '2025-11-21 15:37:46', '2025-11-27 13:41:04');
INSERT INTO `students` VALUES ('2023308308', 'LYKA', 'GONZALO', 'DALUCAN', 1, '3rd Year', NULL, '2025-11-21 15:50:30', '2025-11-27 13:41:04');

-- ----------------------------
-- Table structure for subject_enrollments
-- ----------------------------
DROP TABLE IF EXISTS `subject_enrollments`;
CREATE TABLE `subject_enrollments`  (
  `SectionID` int(11) NOT NULL,
  `SubjectID` int(11) NOT NULL,
  `StudentID` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_uca1400_ai_ci NOT NULL,
  `EnrolledAt` timestamp(0) NULL DEFAULT current_timestamp(),
  `Status` enum('Active','Inactive','Completed','Dropped') CHARACTER SET utf8mb4 COLLATE utf8mb4_uca1400_ai_ci NOT NULL DEFAULT 'Active',
  PRIMARY KEY (`SectionID`, `SubjectID`, `StudentID`) USING BTREE,
  INDEX `idx_subject_enrollments_section`(`SectionID`) USING BTREE,
  INDEX `idx_subject_enrollments_subject`(`SubjectID`) USING BTREE,
  INDEX `idx_subject_enrollments_student`(`StudentID`) USING BTREE,
  INDEX `idx_subject_enrollments_status`(`Status`) USING BTREE,
  CONSTRAINT `subject_enrollments_ibfk_1` FOREIGN KEY (`SectionID`) REFERENCES `sections` (`SectionID`) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT `subject_enrollments_ibfk_3` FOREIGN KEY (`StudentID`) REFERENCES `students` (`StudentID`) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT `subject_enrollments_ibfk4` FOREIGN KEY (`SubjectID`) REFERENCES `subjects` (`SubjectID`) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_uca1400_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of subject_enrollments
-- ----------------------------
INSERT INTO `subject_enrollments` VALUES (4, 7, '2021301661', '2025-12-02 12:07:52', 'Active');
INSERT INTO `subject_enrollments` VALUES (4, 7, '2023307876', '2025-12-02 12:07:52', 'Active');

-- ----------------------------
-- Table structure for subject_schedules
-- ----------------------------
DROP TABLE IF EXISTS `subject_schedules`;
CREATE TABLE `subject_schedules`  (
  `ScheduleID` int(11) NOT NULL AUTO_INCREMENT,
  `SectionID` int(11) NOT NULL,
  `SubjectID` int(11) NOT NULL,
  `Weekdays` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_uca1400_ai_ci NOT NULL COMMENT 'M, T, W, Th, F, MW, TTh, MWF, TThS, etc.',
  `StartTime` time(0) NOT NULL,
  `EndTime` time(0) NOT NULL,
  `RoomID` int(11) NULL DEFAULT NULL,
  `CreatedAt` timestamp(0) NULL DEFAULT current_timestamp(),
  `UpdatedAt` timestamp(0) NULL DEFAULT current_timestamp() ON UPDATE CURRENT_TIMESTAMP(0),
  PRIMARY KEY (`ScheduleID`) USING BTREE,
  UNIQUE INDEX `unique_section_subject_schedule`(`SectionID`, `SubjectID`, `Weekdays`, `StartTime`) USING BTREE,
  INDEX `RoomID`(`RoomID`) USING BTREE,
  INDEX `idx_subject_schedules_section`(`SectionID`) USING BTREE,
  INDEX `idx_subject_schedules_subject`(`SubjectID`) USING BTREE,
  INDEX `idx_subject_schedules_weekdays`(`Weekdays`) USING BTREE,
  INDEX `idx_subject_schedules_time`(`StartTime`, `EndTime`) USING BTREE,
  CONSTRAINT `subject_schedules_ibfk_1` FOREIGN KEY (`SectionID`) REFERENCES `sections` (`SectionID`) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT `subject_schedules_ibfk_2` FOREIGN KEY (`SubjectID`) REFERENCES `course_catalog` (`SubjectID`) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT `subject_schedules_ibfk_3` FOREIGN KEY (`RoomID`) REFERENCES `room` (`RoomID`) ON DELETE SET NULL ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 7 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_uca1400_ai_ci COMMENT = 'Flexible schedules for subjects with specific weekdays' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of subject_schedules
-- ----------------------------
INSERT INTO `subject_schedules` VALUES (1, 2, 1, 'MWF', '07:00:00', '08:00:00', 1, '2025-11-24 03:53:00', '2025-12-01 20:05:02');
INSERT INTO `subject_schedules` VALUES (2, 2, 3, 'MWF', '08:00:00', '09:00:00', 1, '2025-11-24 03:53:00', '2025-12-01 20:04:10');
INSERT INTO `subject_schedules` VALUES (3, 2, 4, 'MWF', '09:00:00', '10:00:00', 1, '2025-11-24 03:53:00', '2025-12-01 20:05:00');
INSERT INTO `subject_schedules` VALUES (4, 1, 1, 'MWF', '09:00:00', '10:00:00', 1, '2025-11-24 03:53:00', '2025-11-24 03:53:00');
INSERT INTO `subject_schedules` VALUES (5, 1, 3, 'MWF', '09:00:00', '10:00:00', 1, '2025-11-24 03:53:00', '2025-11-24 03:53:00');
INSERT INTO `subject_schedules` VALUES (6, 1, 2, 'MWF', '15:00:00', '16:00:00', 1, '2025-11-24 03:53:00', '2025-11-24 03:53:00');

-- ----------------------------
-- Table structure for subjects
-- ----------------------------
DROP TABLE IF EXISTS `subjects`;
CREATE TABLE `subjects`  (
  `SubjectID` int(11) NOT NULL AUTO_INCREMENT,
  `section_id` int(11) NULL DEFAULT NULL,
  `subject_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `subject_code` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `teacher_id` int(11) NULL DEFAULT NULL,
  `created_at` timestamp(0) NULL DEFAULT current_timestamp(),
  `updated_at` timestamp(0) NULL DEFAULT current_timestamp() ON UPDATE CURRENT_TIMESTAMP(0),
  `StatusID` int(11) NULL DEFAULT NULL,
  PRIMARY KEY (`SubjectID`) USING BTREE,
  INDEX `section_id`(`section_id`) USING BTREE,
  INDEX `teacher_id`(`teacher_id`) USING BTREE,
  CONSTRAINT `subjects_ibfk_1` FOREIGN KEY (`section_id`) REFERENCES `sections` (`SectionID`) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT `subjects_ibfk_2` FOREIGN KEY (`teacher_id`) REFERENCES `teachers` (`TeacherID`) ON DELETE SET NULL ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 12 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of subjects
-- ----------------------------
INSERT INTO `subjects` VALUES (1, 1, 'Mathematics', 'MATH101', 1, '2025-11-23 13:50:07', '2025-11-25 12:47:45', 1);
INSERT INTO `subjects` VALUES (2, 1, 'English Language', 'ENG101', 1, '2025-11-23 13:50:07', '2025-11-25 12:47:45', 1);
INSERT INTO `subjects` VALUES (3, 1, 'Science', 'SCI101', 1, '2025-11-23 13:50:07', '2025-11-25 12:47:45', 1);
INSERT INTO `subjects` VALUES (4, 2, 'Mathematics', 'SS101', 1, '2025-11-23 13:50:07', '2025-11-25 12:47:45', 1);
INSERT INTO `subjects` VALUES (5, 2, 'Science', 'PE101', 1, '2025-11-23 13:50:07', '2025-11-25 12:47:45', 1);
INSERT INTO `subjects` VALUES (6, 2, 'Social Studies', 'god1', 1, '2025-11-23 13:50:07', '2025-11-25 12:47:45', 1);
INSERT INTO `subjects` VALUES (7, 1, 'ELECTIVE 3', 'te 103', 1, '2025-11-27 13:12:00', '2025-11-28 19:59:35', 1);
INSERT INTO `subjects` VALUES (8, 1, 'Electronic Laws & Standards', 'ET 421', 1, '2025-11-27 17:12:00', '2025-11-28 19:59:43', 1);
INSERT INTO `subjects` VALUES (10, NULL, 'Personality Development Human Relation', 'PDHR', NULL, '2025-12-02 10:20:13', '2025-12-02 10:20:13', 1);
INSERT INTO `subjects` VALUES (11, NULL, 'Research and Project Development 2', 'RD102', NULL, '2025-12-02 11:38:05', '2025-12-02 11:38:05', 1);

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
  CONSTRAINT `teacher_subjects_ibfk_2` FOREIGN KEY (`SubjectID`) REFERENCES `course_catalog` (`SubjectID`) ON DELETE CASCADE ON UPDATE RESTRICT
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
) ENGINE = InnoDB AUTO_INCREMENT = 7 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_uca1400_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of teachers
-- ----------------------------
INSERT INTO `teachers` VALUES (1, 'John1', 'Smith', 'Michael', 'Mathematics Teacher', 1, 2, '2025-09-29 06:02:50', '2025-09-29 07:04:11');
INSERT INTO `teachers` VALUES (2, 'Peter', 'Simon ...', 'Apostle', 'Teacher', 1, NULL, '2025-09-29 07:04:26', '2025-11-22 12:16:32');
INSERT INTO `teachers` VALUES (3, 'Jim', 'Parker', 'E', 'Teacher', 1, NULL, '2025-11-24 09:50:50', '2025-11-24 09:50:50');
INSERT INTO `teachers` VALUES (5, 'Franklin Rey', 'Pacquiao', NULL, 'Teacher', 1, NULL, '2025-11-27 17:11:28', '2025-11-27 17:11:28');
INSERT INTO `teachers` VALUES (6, 'Christine Marie', 'Madrid', 'J.', 'Teacher', 1, NULL, '2025-12-02 11:37:13', '2025-12-02 11:37:13');

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

-- ----------------------------
-- View structure for v_subject_schedules
-- ----------------------------
DROP VIEW IF EXISTS `v_subject_schedules`;
CREATE ALGORITHM = UNDEFINED DEFINER = `root`@`localhost` SQL SECURITY DEFINER VIEW `v_subject_schedules` AS SELECT 
    sch.ScheduleID,
    sec.SectionID,
    sec.SectionName,
    sec.Semester,
    sec.SchoolYear,
    sub.SubjectID,
    sub.SubjectName,
    sub.SubjectCode,
    ss.TeacherID,
    CONCAT(t.FirstName, ' ', t.LastName) as TeacherName,
    sch.Weekdays,
    sch.StartTime,
    sch.EndTime,
    sch.RoomID,
    r.RoomName,
    r.Building,
    COUNT(DISTINCT se.StudentID) as EnrolledStudents
FROM subject_schedules sch
JOIN sections sec ON sch.SectionID = sec.SectionID
JOIN course_catalog sub ON sch.SubjectID = sub.SubjectID
LEFT JOIN section_subjects ss ON sch.SectionID = ss.SectionID AND sch.SubjectID = ss.SubjectID
LEFT JOIN teachers t ON ss.TeacherID = t.TeacherID
LEFT JOIN room r ON sch.RoomID = r.RoomID
LEFT JOIN subject_enrollments se ON sch.SectionID = se.SectionID 
    AND sch.SubjectID = se.SubjectID 
    AND se.Status = 'Active'
GROUP BY 
    sch.ScheduleID, sec.SectionID, sec.SectionName, sec.Semester, sec.SchoolYear,
    sub.SubjectID, sub.SubjectName, sub.SubjectCode, ss.TeacherID,
    t.FirstName, t.LastName, sch.Weekdays, sch.StartTime, sch.EndTime,
    sch.RoomID, r.RoomName, r.Building ; ;

-- ----------------------------
-- View structure for v_teacher_subject_schedules
-- ----------------------------
DROP VIEW IF EXISTS `v_teacher_subject_schedules`;
CREATE ALGORITHM = UNDEFINED DEFINER = `root`@`localhost` SQL SECURITY DEFINER VIEW `v_teacher_subject_schedules` AS SELECT 
    t.TeacherID,
    CONCAT(t.FirstName, ' ', t.LastName) as TeacherName,
    sec.SectionID,
    sec.SectionName,
    sec.Semester,
    sec.SchoolYear,
    sub.SubjectID,
    sub.SubjectName,
    sub.SubjectCode,
    sch.ScheduleID,
    sch.Weekdays,
    sch.StartTime,
    sch.EndTime,
    sch.RoomID,
    r.RoomName,
    r.Building,
    ss.TeacherID as AssignedTeacherID
FROM teachers t
JOIN section_subjects ss ON t.TeacherID = ss.TeacherID
JOIN sections sec ON ss.SectionID = sec.SectionID
JOIN course_catalog sub ON ss.SubjectID = sub.SubjectID
LEFT JOIN subject_schedules sch ON ss.SectionID = sch.SectionID AND ss.SubjectID = sch.SubjectID
LEFT JOIN room r ON sch.RoomID = r.RoomID
WHERE t.StatusID = 1 AND sec.StatusID = 1
ORDER BY t.TeacherID, sec.SectionName, sub.SubjectName ;

-- ----------------------------
-- Procedure structure for get_subject_attendance_dates
-- ----------------------------
DROP PROCEDURE IF EXISTS `get_subject_attendance_dates`;
delimiter ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `get_subject_attendance_dates`(
    IN p_section_id INT,
    IN p_subject_id INT,
    IN p_year INT,
    IN p_month INT
)
BEGIN
    DECLARE v_start_date DATE;
    DECLARE v_end_date DATE;
    DECLARE v_current_date DATE;
    DECLARE v_weekdays VARCHAR(20);
    DECLARE done INT DEFAULT FALSE;
    
    
    CREATE TEMPORARY TABLE IF NOT EXISTS temp_attendance_dates (
        attendance_date DATE,
        weekday_name VARCHAR(10),
        day_of_month INT,
        schedule_id INT,
        weekdays_pattern VARCHAR(20),
        start_time TIME,
        end_time TIME,
        room_name VARCHAR(100)
    );
    
    
    TRUNCATE TABLE temp_attendance_dates;
    
    
    SET v_start_date = STR_TO_DATE(CONCAT(p_year, '-', LPAD(p_month, 2, '0'), '-01'), '%Y-%m-%d');
    SET v_end_date = LAST_DAY(v_start_date);
    SET v_current_date = v_start_date;
    
    
    WHILE v_current_date <= v_end_date DO
        
        INSERT INTO temp_attendance_dates
        SELECT 
            v_current_date as attendance_date,
            DATE_FORMAT(v_current_date, '%a') as weekday_name,
            DAY(v_current_date) as day_of_month,
            sch.ScheduleID,
            sch.Weekdays as weekdays_pattern,
            sch.StartTime,
            sch.EndTime,
            r.RoomName
        FROM subject_schedules sch
        LEFT JOIN room r ON sch.RoomID = r.RoomID
        WHERE sch.SectionID = p_section_id
        AND sch.SubjectID = p_subject_id
        AND matches_weekday_pattern(v_current_date, sch.Weekdays) = TRUE;
        
        SET v_current_date = DATE_ADD(v_current_date, INTERVAL 1 DAY);
    END WHILE;
    
    
    SELECT * FROM temp_attendance_dates ORDER BY attendance_date;
    
    
    DROP TEMPORARY TABLE temp_attendance_dates;
END
;;
delimiter ;

-- ----------------------------
-- Function structure for matches_weekday_pattern
-- ----------------------------
DROP FUNCTION IF EXISTS `matches_weekday_pattern`;
delimiter ;;
CREATE DEFINER=`root`@`localhost` FUNCTION `matches_weekday_pattern`(check_date DATE,
    weekdays_pattern VARCHAR(20)
) RETURNS tinyint(1)
    DETERMINISTIC
BEGIN
    DECLARE day_of_week INT;
    DECLARE day_name VARCHAR(3);
    
    
    SET day_of_week = DAYOFWEEK(check_date);
    
    
    SET day_name = CASE day_of_week
        WHEN 1 THEN 'Su'  
        WHEN 2 THEN 'M'   
        WHEN 3 THEN 'T'   
        WHEN 4 THEN 'W'   
        WHEN 5 THEN 'Th'  
        WHEN 6 THEN 'F'   
        WHEN 7 THEN 'S'   
    END;
    
    
    
    IF day_name = 'Th' THEN
        RETURN LOCATE('Th', weekdays_pattern) > 0;
    ELSEIF day_name = 'T' THEN
        
        RETURN (LOCATE('T', weekdays_pattern) > 0 AND 
                (LOCATE('Th', weekdays_pattern) = 0 OR 
                 LOCATE(CONCAT('T'), weekdays_pattern) <> LOCATE('Th', weekdays_pattern)));
    ELSE
        RETURN LOCATE(day_name, weekdays_pattern) > 0;
    END IF;
END
;;
delimiter ;

SET FOREIGN_KEY_CHECKS = 1;

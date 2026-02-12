/*
 Navicat Premium Dump SQL

 Source Server         : conn
 Source Server Type    : MySQL
 Source Server Version : 100432 (10.4.32-MariaDB)
 Source Host           : localhost:3306
 Source Schema         : cinema_booking

 Target Server Type    : MySQL
 Target Server Version : 100432 (10.4.32-MariaDB)
 File Encoding         : 65001

 Date: 12/02/2026 16:28:28
*/

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Table structure for bookings
-- ----------------------------
DROP TABLE IF EXISTS `bookings`;
CREATE TABLE `bookings`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `user_id` bigint NOT NULL,
  `showtime_id` bigint NOT NULL,
  `total_price` double NOT NULL,
  `booking_date` timestamp NOT NULL DEFAULT current_timestamp(),
  `status` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT 'PENDING',
  `version` int NULL DEFAULT 0,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `user_id`(`user_id` ASC) USING BTREE,
  INDEX `showtime_id`(`showtime_id` ASC) USING BTREE,
  CONSTRAINT `bookings_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `bookings_ibfk_2` FOREIGN KEY (`showtime_id`) REFERENCES `showtimes` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 10 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of bookings
-- ----------------------------
INSERT INTO `bookings` VALUES (1, 4, 3, 180000, '2026-02-09 15:10:59', 'CONFIRMED', 0);
INSERT INTO `bookings` VALUES (2, 5, 3, 130000, '2026-02-09 15:10:59', 'CANCELLED', 0);
INSERT INTO `bookings` VALUES (3, 1, 1, 150000, '2026-02-11 21:45:40', 'CANCELLED', 0);
INSERT INTO `bookings` VALUES (5, 1, 2, 150000, '2026-02-11 22:56:12', 'CANCELLED', 0);
INSERT INTO `bookings` VALUES (8, 1, 1, 150000, '2026-02-12 01:42:46', 'CONFIRMED', 0);
INSERT INTO `bookings` VALUES (9, 1, 1, 50000, '2026-02-12 01:47:48', 'CANCELLED', 1);

-- ----------------------------
-- Table structure for movies
-- ----------------------------
DROP TABLE IF EXISTS `movies`;
CREATE TABLE `movies`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `title` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL,
  `duration` int NOT NULL,
  `poster_url` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 10 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of movies
-- ----------------------------
INSERT INTO `movies` VALUES (1, 'Dune: Part Two', 'Paul Atreides unites with Chani and the Fremen while on a warpath of revenge.', 166, 'https://image.url/dune2.jpg');
INSERT INTO `movies` VALUES (2, 'Kung Fu Panda 4', 'Po is set to become the Spiritual Leader of the Valley of Peace.', 94, 'https://image.url/panda4.jpg');
INSERT INTO `movies` VALUES (3, 'Godzilla x Kong: The New Empire', 'Two ancient titans clash in an epic battle as humans unravel their intertwined origins.', 115, 'https://image.url/gxk.jpg');
INSERT INTO `movies` VALUES (4, 'Mai', 'A Vietnamese psychological romance film directed by Tran Thanh.', 131, 'https://image.url/mai.jpg');
INSERT INTO `movies` VALUES (5, 'Exhuma', 'A wealthy family in LA experiences paranormal events.', 134, 'https://image.url/exhuma.jpg');
INSERT INTO `movies` VALUES (8, 'Avatar', 'Protect our planet', 120, '/uploads/1770652126254_Screenshot 2024-12-28 233113.png');
INSERT INTO `movies` VALUES (9, 'Avatar', 'Protect our planet', 120, '/uploads/1770652163318_Untitled.jpg');

-- ----------------------------
-- Table structure for rooms
-- ----------------------------
DROP TABLE IF EXISTS `rooms`;
CREATE TABLE `rooms`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `total_seat` int NULL DEFAULT 0,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 4 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of rooms
-- ----------------------------
INSERT INTO `rooms` VALUES (1, 'Room 01 - Standard', 25);
INSERT INTO `rooms` VALUES (2, 'Room 02 - VIP', 20);
INSERT INTO `rooms` VALUES (3, 'Room 03 - IMAX', 100);

-- ----------------------------
-- Table structure for seats
-- ----------------------------
DROP TABLE IF EXISTS `seats`;
CREATE TABLE `seats`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `room_id` bigint NOT NULL,
  `row_name` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `seat_number` int NOT NULL,
  `seat_type` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT 'NORMAL',
  `is_active` tinyint(1) NULL DEFAULT 1,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `room_id`(`room_id` ASC) USING BTREE,
  CONSTRAINT `seats_ibfk_1` FOREIGN KEY (`room_id`) REFERENCES `rooms` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 30 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of seats
-- ----------------------------
INSERT INTO `seats` VALUES (1, 1, 'A', 1, 'NORMAL', 1);
INSERT INTO `seats` VALUES (2, 1, 'A', 2, 'NORMAL', 1);
INSERT INTO `seats` VALUES (3, 1, 'A', 3, 'NORMAL', 1);
INSERT INTO `seats` VALUES (4, 1, 'A', 4, 'NORMAL', 1);
INSERT INTO `seats` VALUES (5, 1, 'A', 5, 'NORMAL', 1);
INSERT INTO `seats` VALUES (6, 1, 'B', 1, 'NORMAL', 1);
INSERT INTO `seats` VALUES (7, 1, 'B', 2, 'NORMAL', 1);
INSERT INTO `seats` VALUES (8, 1, 'B', 3, 'NORMAL', 1);
INSERT INTO `seats` VALUES (9, 1, 'B', 4, 'NORMAL', 1);
INSERT INTO `seats` VALUES (10, 1, 'B', 5, 'NORMAL', 1);
INSERT INTO `seats` VALUES (11, 1, 'C', 1, 'NORMAL', 1);
INSERT INTO `seats` VALUES (12, 1, 'C', 2, 'NORMAL', 1);
INSERT INTO `seats` VALUES (13, 1, 'C', 3, 'NORMAL', 1);
INSERT INTO `seats` VALUES (14, 1, 'C', 4, 'NORMAL', 1);
INSERT INTO `seats` VALUES (15, 1, 'C', 5, 'NORMAL', 1);
INSERT INTO `seats` VALUES (16, 1, 'D', 1, 'VIP', 1);
INSERT INTO `seats` VALUES (17, 1, 'D', 2, 'VIP', 1);
INSERT INTO `seats` VALUES (18, 1, 'D', 3, 'VIP', 1);
INSERT INTO `seats` VALUES (19, 1, 'D', 4, 'VIP', 1);
INSERT INTO `seats` VALUES (20, 1, 'D', 5, 'VIP', 1);
INSERT INTO `seats` VALUES (21, 1, 'E', 1, 'VIP', 1);
INSERT INTO `seats` VALUES (22, 1, 'E', 2, 'VIP', 1);
INSERT INTO `seats` VALUES (23, 1, 'E', 3, 'VIP', 1);
INSERT INTO `seats` VALUES (24, 1, 'E', 4, 'VIP', 1);
INSERT INTO `seats` VALUES (25, 1, 'E', 5, 'VIP', 1);
INSERT INTO `seats` VALUES (26, 2, 'A', 1, 'COUPLE', 1);
INSERT INTO `seats` VALUES (27, 2, 'A', 2, 'COUPLE', 1);
INSERT INTO `seats` VALUES (28, 2, 'B', 1, 'COUPLE', 1);
INSERT INTO `seats` VALUES (29, 2, 'B', 2, 'COUPLE', 1);

-- ----------------------------
-- Table structure for showtime_seats
-- ----------------------------
DROP TABLE IF EXISTS `showtime_seats`;
CREATE TABLE `showtime_seats`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `showtime_id` bigint NOT NULL,
  `seat_id` bigint NOT NULL,
  `status` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT 'AVAILABLE',
  `price` double NOT NULL,
  `booking_id` bigint NULL DEFAULT NULL,
  `version` int NULL DEFAULT 0,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `showtime_id`(`showtime_id` ASC, `seat_id` ASC) USING BTREE,
  INDEX `seat_id`(`seat_id` ASC) USING BTREE,
  INDEX `booking_id`(`booking_id` ASC) USING BTREE,
  CONSTRAINT `showtime_seats_ibfk_1` FOREIGN KEY (`showtime_id`) REFERENCES `showtimes` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `showtime_seats_ibfk_2` FOREIGN KEY (`seat_id`) REFERENCES `seats` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `showtime_seats_ibfk_3` FOREIGN KEY (`booking_id`) REFERENCES `bookings` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 61 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of showtime_seats
-- ----------------------------
INSERT INTO `showtime_seats` VALUES (1, 1, 1, 'BOOKED', 50000, 8, 0);
INSERT INTO `showtime_seats` VALUES (2, 1, 2, 'BOOKED', 50000, 8, 0);
INSERT INTO `showtime_seats` VALUES (3, 1, 3, 'BOOKED', 50000, 8, 0);
INSERT INTO `showtime_seats` VALUES (4, 1, 4, 'AVAILABLE', 50000, 9, 1);
INSERT INTO `showtime_seats` VALUES (5, 1, 5, 'AVAILABLE', 50000, NULL, 0);
INSERT INTO `showtime_seats` VALUES (6, 1, 6, 'AVAILABLE', 50000, NULL, 0);
INSERT INTO `showtime_seats` VALUES (7, 1, 7, 'AVAILABLE', 50000, NULL, 0);
INSERT INTO `showtime_seats` VALUES (8, 1, 8, 'AVAILABLE', 50000, NULL, 0);
INSERT INTO `showtime_seats` VALUES (9, 1, 9, 'AVAILABLE', 50000, NULL, 0);
INSERT INTO `showtime_seats` VALUES (10, 1, 10, 'AVAILABLE', 50000, NULL, 0);
INSERT INTO `showtime_seats` VALUES (11, 1, 11, 'AVAILABLE', 50000, NULL, 0);
INSERT INTO `showtime_seats` VALUES (12, 1, 12, 'AVAILABLE', 50000, NULL, 0);
INSERT INTO `showtime_seats` VALUES (13, 1, 13, 'AVAILABLE', 50000, NULL, 0);
INSERT INTO `showtime_seats` VALUES (14, 1, 14, 'AVAILABLE', 50000, NULL, 0);
INSERT INTO `showtime_seats` VALUES (15, 1, 15, 'AVAILABLE', 50000, NULL, 0);
INSERT INTO `showtime_seats` VALUES (16, 1, 16, 'AVAILABLE', 75000, NULL, 0);
INSERT INTO `showtime_seats` VALUES (17, 1, 17, 'AVAILABLE', 75000, NULL, 0);
INSERT INTO `showtime_seats` VALUES (18, 1, 18, 'AVAILABLE', 75000, NULL, 0);
INSERT INTO `showtime_seats` VALUES (19, 1, 19, 'AVAILABLE', 75000, NULL, 0);
INSERT INTO `showtime_seats` VALUES (20, 1, 20, 'AVAILABLE', 75000, NULL, 0);
INSERT INTO `showtime_seats` VALUES (21, 1, 21, 'AVAILABLE', 75000, NULL, 0);
INSERT INTO `showtime_seats` VALUES (22, 1, 22, 'AVAILABLE', 75000, NULL, 0);
INSERT INTO `showtime_seats` VALUES (23, 1, 23, 'AVAILABLE', 75000, NULL, 0);
INSERT INTO `showtime_seats` VALUES (24, 1, 24, 'AVAILABLE', 75000, NULL, 0);
INSERT INTO `showtime_seats` VALUES (25, 1, 25, 'AVAILABLE', 75000, NULL, 0);
INSERT INTO `showtime_seats` VALUES (32, 3, 1, 'AVAILABLE', 50000, NULL, 0);
INSERT INTO `showtime_seats` VALUES (33, 3, 2, 'AVAILABLE', 50000, NULL, 0);
INSERT INTO `showtime_seats` VALUES (34, 3, 3, 'AVAILABLE', 50000, NULL, 0);
INSERT INTO `showtime_seats` VALUES (35, 3, 4, 'AVAILABLE', 50000, 2, 0);
INSERT INTO `showtime_seats` VALUES (36, 3, 5, 'AVAILABLE', 50000, 2, 0);
INSERT INTO `showtime_seats` VALUES (37, 3, 6, 'AVAILABLE', 50000, NULL, 0);
INSERT INTO `showtime_seats` VALUES (38, 3, 7, 'AVAILABLE', 50000, NULL, 0);
INSERT INTO `showtime_seats` VALUES (39, 3, 8, 'AVAILABLE', 50000, NULL, 0);
INSERT INTO `showtime_seats` VALUES (40, 3, 9, 'AVAILABLE', 50000, NULL, 0);
INSERT INTO `showtime_seats` VALUES (41, 3, 10, 'AVAILABLE', 50000, NULL, 0);
INSERT INTO `showtime_seats` VALUES (42, 3, 11, 'AVAILABLE', 50000, NULL, 0);
INSERT INTO `showtime_seats` VALUES (43, 3, 12, 'AVAILABLE', 50000, NULL, 0);
INSERT INTO `showtime_seats` VALUES (44, 3, 13, 'AVAILABLE', 50000, NULL, 0);
INSERT INTO `showtime_seats` VALUES (45, 3, 14, 'AVAILABLE', 50000, NULL, 0);
INSERT INTO `showtime_seats` VALUES (46, 3, 15, 'AVAILABLE', 50000, NULL, 0);
INSERT INTO `showtime_seats` VALUES (47, 3, 16, 'BOOKED', 75000, 1, 0);
INSERT INTO `showtime_seats` VALUES (48, 3, 17, 'BOOKED', 75000, 1, 0);
INSERT INTO `showtime_seats` VALUES (49, 3, 18, 'AVAILABLE', 75000, NULL, 0);
INSERT INTO `showtime_seats` VALUES (50, 3, 19, 'AVAILABLE', 75000, NULL, 0);
INSERT INTO `showtime_seats` VALUES (51, 3, 20, 'AVAILABLE', 75000, NULL, 0);
INSERT INTO `showtime_seats` VALUES (52, 3, 21, 'AVAILABLE', 75000, NULL, 0);
INSERT INTO `showtime_seats` VALUES (53, 3, 22, 'AVAILABLE', 75000, NULL, 0);
INSERT INTO `showtime_seats` VALUES (54, 3, 23, 'AVAILABLE', 75000, NULL, 0);
INSERT INTO `showtime_seats` VALUES (55, 3, 24, 'AVAILABLE', 75000, NULL, 0);
INSERT INTO `showtime_seats` VALUES (56, 3, 25, 'AVAILABLE', 75000, NULL, 0);
INSERT INTO `showtime_seats` VALUES (57, 7, 26, 'AVAILABLE', 90000, NULL, 0);
INSERT INTO `showtime_seats` VALUES (58, 7, 27, 'AVAILABLE', 90000, NULL, 0);
INSERT INTO `showtime_seats` VALUES (59, 7, 28, 'AVAILABLE', 90000, NULL, 0);
INSERT INTO `showtime_seats` VALUES (60, 7, 29, 'AVAILABLE', 90000, NULL, 0);

-- ----------------------------
-- Table structure for showtimes
-- ----------------------------
DROP TABLE IF EXISTS `showtimes`;
CREATE TABLE `showtimes`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `movie_id` bigint NOT NULL,
  `room_id` bigint NOT NULL,
  `start_time` datetime NOT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `movie_id`(`movie_id` ASC) USING BTREE,
  INDEX `room_id`(`room_id` ASC) USING BTREE,
  CONSTRAINT `showtimes_ibfk_1` FOREIGN KEY (`movie_id`) REFERENCES `movies` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `showtimes_ibfk_2` FOREIGN KEY (`room_id`) REFERENCES `rooms` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 8 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of showtimes
-- ----------------------------
INSERT INTO `showtimes` VALUES (1, 1, 1, '2026-02-10 09:00:00');
INSERT INTO `showtimes` VALUES (2, 1, 1, '2026-02-10 14:30:00');
INSERT INTO `showtimes` VALUES (3, 2, 1, '2026-02-10 20:00:00');
INSERT INTO `showtimes` VALUES (4, 1, 2, '2026-02-12 19:00:00');
INSERT INTO `showtimes` VALUES (5, 1, 2, '2026-02-12 19:00:00');
INSERT INTO `showtimes` VALUES (7, 2, 2, '2026-02-12 19:00:00');

-- ----------------------------
-- Table structure for users
-- ----------------------------
DROP TABLE IF EXISTS `users`;
CREATE TABLE `users`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `email` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `password` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `full_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `role` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT 'CUSTOMER',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `email`(`email` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 7 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of users
-- ----------------------------
INSERT INTO `users` VALUES (1, 'admin@cinema.com', 'admin123', 'Quản Trị Viên', 'ROLE_ADMIN');
INSERT INTO `users` VALUES (2, 'staff_01@cinema.com', 'staff123', 'Nhân Viên Bán Vé 1', 'ROLE_STAFF');
INSERT INTO `users` VALUES (3, 'staff_02@cinema.com', 'staff123', 'Nhân Viên Soát Vé', 'ROLE_STAFF');
INSERT INTO `users` VALUES (4, 'khanh@gmail.com', 'user123', 'Nguyễn Duy Khánh', 'ROLE_CUSTOMER');
INSERT INTO `users` VALUES (5, 'customer1@gmail.com', 'user123', 'Trần Văn A', 'ROLE_CUSTOMER');
INSERT INTO `users` VALUES (6, 'customer2@gmail.com', 'user123', 'Lê Thị B', 'ROLE_CUSTOMER');

SET FOREIGN_KEY_CHECKS = 1;

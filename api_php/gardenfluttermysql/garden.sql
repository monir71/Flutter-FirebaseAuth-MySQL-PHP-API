-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: May 02, 2026 at 02:52 PM
-- Server version: 10.4.32-MariaDB
-- PHP Version: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `garden`
--

-- --------------------------------------------------------

--
-- Table structure for table `exp`
--

CREATE TABLE `exp` (
  `exp_id` int(10) UNSIGNED NOT NULL,
  `owner_id` int(10) NOT NULL,
  `garden_id` int(10) NOT NULL,
  `exp_amount` int(10) NOT NULL,
  `exp_date` varchar(20) NOT NULL,
  `exp_desc` varchar(100) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `exp`
--

INSERT INTO `exp` (`exp_id`, `owner_id`, `garden_id`, `exp_amount`, `exp_date`, `exp_desc`) VALUES
(1, 1, 1, 4200, '25/12/2024', 'Cow Dung 4 Trolly'),
(2, 1, 1, 3800, '25/12/2024', 'TSP and MOP'),
(3, 1, 1, 2980, '25/12/2024', 'Fertilizer from Natore'),
(4, 1, 1, 1200, '25/12/2024', 'DAP from Bonpara'),
(5, 1, 1, 2870, '25/12/2024', 'Net for Fenching 4 Roll'),
(6, 1, 1, 530, '25/12/2024', 'Van Fare'),
(7, 1, 1, 2600, '25/12/2024', 'TSP (Mill) from Jalil Mama'),
(8, 1, 1, 1100, '01/01/2025', 'Compost  2 Bags 80Kg'),
(9, 1, 1, 270, '01/01/2025', 'Net for Fenching 45 Feet'),
(10, 1, 1, 4830, '01/01/2025', 'Pillar and Wire'),
(11, 1, 1, 500, '01/01/2025', 'Van Fare'),
(12, 1, 1, 1800, '01/01/2025', 'Land Cultivation 4 times'),
(13, 1, 1, 6400, '01/01/2025', 'Guava Pland 270 Pieces'),
(14, 1, 1, 200, '01/01/2025', 'Van Fare'),
(15, 1, 1, 15000, '05/01/2025', 'Onion Plant'),
(16, 1, 1, 1200, '05/01/2025', 'Van Fare'),
(17, 1, 1, 2000, '05/01/2025', 'Compost  4 Bags 160Kg'),
(18, 1, 1, 800, '05/01/2025', 'Irrigation'),
(19, 1, 1, 700, '05/01/2025', 'Panida 800ml'),
(20, 1, 1, 550, '05/01/2025', 'Imitab 400ml'),
(21, 1, 1, 320, '05/01/2025', 'Elics 100ml '),
(22, 1, 1, 400, '05/01/2025', 'Mancogeb and Symox 500g'),
(23, 1, 1, 200, '05/01/2025', 'Green Tree 2 Kg'),
(24, 1, 1, 500, '05/01/2025', 'Paper Tree 1K'),
(25, 1, 1, 200, '05/01/2025', 'Green Tree 2 Kg'),
(26, 1, 1, 850, '10/01/2025', 'Redomil Gold 500g'),
(27, 1, 1, 75, '10/01/2025', 'Promoter Plus 3 Pieces'),
(28, 1, 1, 600, '10/01/2025', 'Urea 20 Kg'),
(29, 1, 1, 450, '10/01/2025', 'Magma 3 Kg'),
(30, 1, 1, 1700, '10/01/2025', 'Redomil Gold 1 Kg'),
(31, 1, 1, 200, '10/01/2025', 'Promoter Plus 8 Pieces'),
(32, 1, 1, 580, '10/01/2025', 'Solomon 200 ml'),
(33, 1, 1, 390, '10/01/2025', 'BioForti 500ml'),
(34, 1, 1, 410, '15/01/2025', 'Calibebr 3 Pkt'),
(35, 1, 1, 290, '15/01/2025', 'Score 100 ml'),
(36, 1, 1, 580, '15/01/2025', 'Solomon 200 ml'),
(37, 1, 1, 3000, '15/01/2025', 'Papaya Tree 100 Pieces'),
(38, 1, 1, 620, '15/01/2025', 'Theovit 22 Kg'),
(39, 1, 1, 900, '20/01/2025', 'DAP 30 Kg'),
(40, 1, 1, 550, '20/01/2025', 'Zinc 2 Kg'),
(41, 1, 1, 1000, '20/01/2025', 'Irrigation'),
(42, 1, 1, 515, '20/01/2025', 'Imitab 400 ml'),
(43, 1, 1, 1030, '20/01/2025', 'Luna 100 ml'),
(44, 1, 1, 490, '20/01/2025', 'Tilt 150 ml'),
(45, 1, 1, 515, '20/01/2025', 'Mancogeb and Symox 500g'),
(46, 1, 1, 1050, '20/01/2025', 'Luna 100 ml'),
(47, 1, 1, 1020, '20/01/2025', 'Luna 100 ml'),
(48, 1, 1, 320, '20/01/2025', 'Tablet 4p'),
(49, 1, 1, 510, '25/01/2025', 'Denim Feed and Others'),
(50, 1, 1, 2650, '25/01/2025', 'Urea 28, TSP 28, MOP 14, Dana 1, Theov 1Kg'),
(51, 1, 1, 500, '01/04/2025', 'Van Fare for Onion'),
(52, 1, 1, 800, '01/04/2025', 'Paper Plant 1000 Pieces'),
(53, 1, 1, 5700, '14/04/2025', 'Jujube Plant 240 Pieces'),
(54, 1, 1, 150, '14/04/2025', 'Van Fare for Jujube plant'),
(55, 1, 1, 300, '14/04/2025', 'Solomon 100 ml'),
(56, 1, 1, 350, '14/04/2025', 'Shizophen 100 ml'),
(57, 1, 1, 120, '20/04/2025', 'Mitosin 20 ml'),
(58, 1, 1, 1000, '20/04/2025', 'Irrigation'),
(59, 1, 1, 120, '20/04/2025', 'Churanto 100 ml'),
(60, 1, 1, 500, '20/04/2025', 'Jadid 400 ml'),
(61, 1, 1, 180, '20/04/2025', 'Tared 50 ml'),
(62, 1, 1, 1000, '20/04/2025', 'Irrigation'),
(63, 1, 1, 350, '30/04/2025', 'Tared 100 ml'),
(64, 1, 1, 100, '30/04/2025', 'Lali'),
(65, 1, 1, 100, '30/04/2025', 'Pata Bish 3 Pkt'),
(66, 1, 1, 1000, '30/04/2025', 'Irrigation'),
(67, 1, 1, 85, '30/04/2025', 'Rope, Salt, Blade'),
(68, 1, 1, 1200, '30/04/2025', 'Cow Dung Deli 600 Pieces'),
(69, 1, 1, 300, '30/04/2025', 'Van Fare for Cow Dung Deli'),
(70, 1, 1, 500, '30/04/2025', 'Onion Van Fare'),
(71, 1, 1, 200, '30/04/2025', 'Van Fare for Onion'),
(72, 1, 1, 200, '23/06/2025', 'Van Fare'),
(73, 1, 1, 200, '26/06/2025', 'Van Fare'),
(74, 1, 1, 200, '27/06/2025', 'Van Fare'),
(75, 1, 1, 200, '30/06/2025', 'Van Fare'),
(76, 1, 1, 200, '12/07/2025', 'Van Fare'),
(77, 1, 1, 350, '13/07/2025', 'Grass Kill Medicine (Tarek Mama)'),
(78, 1, 1, 30000, '01/01/2025', 'Land Lease 1st Year'),
(79, 1, 1, 70, '02/09/2025', 'Onion Khajna'),
(80, 1, 1, 125, '02/09/2025', 'Breakfast 5 Person'),
(81, 1, 1, 60, '02/09/2025', 'Bodna 1 Piece'),
(82, 1, 1, 100, '02/09/2025', 'Mini Soap 12 Pieces'),
(83, 1, 1, 800, '02/09/2025', 'Chicken Tanduri 6 Person'),
(84, 1, 1, 370, '02/09/2025', 'Alamgir\'s Shop'),
(85, 1, 1, 120, '02/09/2025', 'Rifat Van Tube'),
(86, 1, 1, 500, '02/09/2025', 'Rifat Van Fare'),
(87, 1, 1, 1100, '02/09/2025', 'Pachua Hotel Bill'),
(88, 1, 1, 250, '02/09/2025', 'Breakfast 4 Person'),
(89, 1, 1, 300, '02/09/2025', 'Rifat Van Fare'),
(90, 1, 1, 255, '02/09/2025', 'Roap and Speed and Salt'),
(91, 1, 1, 100, '02/09/2025', 'Garden Inspection Van Fare'),
(92, 1, 1, 200, '02/09/2025', 'Van Fare'),
(93, 1, 1, 60, '02/09/2025', 'Breakfast 2 Person'),
(94, 1, 1, 1485, '02/09/2025', 'NH Cultural Program 13 Person'),
(95, 1, 1, 200, '02/09/2025', 'Van Fare'),
(96, 1, 1, 300, '02/09/2025', 'Solomon 100 ml'),
(97, 1, 1, 250, '02/09/2025', 'Van Fare'),
(98, 1, 1, 400, '02/09/2025', 'Rifat Van Fare'),
(99, 1, 1, 170, '02/09/2025', 'Snacks Bill'),
(100, 1, 1, 250, '02/09/2025', 'Dhoinchi Visit and Snacks'),
(101, 1, 1, 400, '02/09/2025', 'Van Fare'),
(102, 1, 1, 200, '02/09/2025', 'Van Fare'),
(103, 1, 1, 2355, '02/09/2025', 'NH Farewell Party'),
(104, 1, 1, 100, '02/09/2025', 'Van Fare'),
(105, 1, 1, 265, '02/09/2025', 'Snacks at Garden'),
(106, 1, 1, 210, '02/09/2025', 'Lunch Bill'),
(107, 1, 1, 500, '02/09/2025', 'Van Fare'),
(108, 1, 1, 100, '02/09/2025', 'Van Fare'),
(109, 1, 1, 200, '23/09/2025', 'Van Fare'),
(110, 1, 1, 100, '26/09/2025', 'Van Fare'),
(111, 1, 1, 200, '02/10/2025', 'Van Fare'),
(112, 1, 1, 14600, '02/10/2025', 'Kabir\'s Shop Outstanding Bill'),
(113, 1, 1, 9000, '02/10/2025', 'Kabir\'s Shop Outstanding Bill'),
(114, 1, 1, 300, '30/11/2025', 'Solomon 100 ml'),
(115, 1, 1, 775, '30/11/2025', 'MOP 20 Kg and TSP 20 Kg'),
(116, 1, 1, 225, '30/11/2025', 'Sobicron'),
(117, 1, 1, 3000, '30/11/2025', 'Compost  6 Bags 240Kg'),
(118, 1, 1, 350, '30/11/2025', 'Activo'),
(119, 1, 1, 1000, '21/11/2025', 'Irrigation'),
(120, 1, 1, 400, '30/11/2025', 'Poly 1 Bundle'),
(121, 1, 1, 100, '03/12/2025', 'Van Fare'),
(122, 1, 1, 80, '03/12/2025', 'Water  Bottles'),
(123, 1, 1, 1000, '03/12/2025', 'Irrigation'),
(124, 1, 1, 300, '03/12/2025', 'Khata 2 Pieces'),
(125, 1, 1, 400, '03/12/2025', 'Poly 1 Bundle'),
(126, 1, 1, 1000, '01/01/2026', 'Irrigation'),
(127, 1, 1, 1000, '15/01/2026', 'Irrigation'),
(128, 1, 1, 200, '16/10/2025', 'Van Fare'),
(129, 1, 1, 300, '15/01/2026', 'Van Fare Fishing and Onion Plantation'),
(130, 1, 1, 3000, '15/01/2026', 'Bamboo 10 Pieces'),
(131, 1, 1, 1500, '15/01/2026', 'Fertilizer and Spray'),
(132, 1, 1, 1000, '15/01/2026', 'Cabriotop and Bongo and Van Fare'),
(133, 1, 1, 60, '15/01/2026', 'Van Fare'),
(134, 1, 1, 500, '15/01/2026', 'Van Fare for Jujube Sell'),
(135, 1, 1, 30000, '15/01/2026', 'Land Lease 2nd Year'),
(136, 1, 1, 500, '15/01/2026', 'Tomato Plant'),
(137, 1, 1, 370, '15/01/2026', 'Poly 1 Bundle'),
(138, 1, 1, 320, '15/01/2026', 'Zipsam 10 Kg from Chaknazirpur'),
(139, 1, 1, 5000, '19/01/2026', 'Kabir\'s Shop Outstanding Bill'),
(140, 1, 1, 200, '19/01/2026', 'Van Fare'),
(141, 1, 1, 100, '19/01/2026', 'Van Fare'),
(142, 1, 1, 200, '19/01/2026', 'Van Fare'),
(143, 1, 1, 100, '19/01/2026', 'Van Fare'),
(144, 1, 1, 200, '26/01/2026', 'Van Fare'),
(145, 1, 1, 200, '02/02/2026', 'Van Fare'),
(146, 1, 1, 120, '02/02/2026', 'Breakfast 4 Person'),
(147, 1, 1, 200, '03/02/2026', 'Van Fare'),
(148, 1, 1, 520, '03/02/2026', 'Spade 1 Piece'),
(149, 1, 1, 115, '03/02/2026', 'Wire'),
(150, 1, 1, 200, '04/02/2026', 'Van Fare'),
(151, 1, 1, 210, '04/02/2026', 'Breakfast 7 Person'),
(152, 1, 1, 800, '04/02/2026', 'Labour 2 Person'),
(153, 1, 1, 800, '05/02/2026', 'Labour 2 Person'),
(154, 1, 1, 200, '05/02/2026', 'Van Fare'),
(155, 1, 1, 800, '06/02/2026', 'Labour 2 Person'),
(156, 1, 1, 3350, '06/02/2026', 'House Rent and Others of February'),
(157, 1, 1, 80, '07/02/2026', 'Van Fare'),
(158, 1, 1, 800, '09/02/2026', 'Labour 2 Person'),
(159, 1, 1, 200, '09/02/2026', 'Van Fare'),
(160, 1, 1, 150, '09/02/2026', 'Breakfast 5 Person'),
(161, 1, 1, 250, '10/02/2026', 'Breakfast 4 Person'),
(162, 1, 1, 800, '10/02/2026', 'Labour 2 Person'),
(163, 1, 1, 200, '10/02/2026', 'Van Fare'),
(164, 1, 1, 200, '17/02/2026', 'Van Fare'),
(165, 1, 1, 110, '17/02/2026', 'Van Fare'),
(166, 1, 1, 1000, '17/02/2026', 'Irrigation'),
(167, 1, 1, 305, '17/02/2026', 'Wire 2 Kg'),
(168, 1, 1, 200, '27/02/2026', 'Van Fare'),
(169, 1, 1, 50, '26/02/2026', 'Van Fare'),
(170, 1, 1, 500, '03/03/2026', 'Rifat Van Fare'),
(171, 1, 1, 3500, '03/03/2026', 'House Rent and Others of March'),
(172, 1, 1, 800, '10/03/2026', 'Labour 2 Person'),
(173, 1, 1, 1200, '11/03/2026', 'Labour 3 Person'),
(174, 1, 1, 800, '11/03/2026', 'Cow Dung Van Fare'),
(175, 1, 1, 800, '11/03/2026', 'Cow Dung'),
(176, 1, 1, 2500, '11/03/2026', 'Cow Dung Deli 1000 Pieces'),
(177, 1, 1, 2050, '11/03/2026', 'Fertilizer from Pappu'),
(178, 1, 1, 1000, '13/03/2026', 'Irrigation'),
(179, 1, 1, 2424, '12/04/2026', 'Kabir\'s Shop Outstanding Bill'),
(180, 1, 2, 1700, '01/01/2026', 'Land Cultivation 2 times'),
(181, 1, 2, 320, '01/01/2026', 'Grass Kill Medicine'),
(182, 1, 2, 400, '01/01/2026', 'Ladder'),
(183, 1, 2, 220, '01/01/2026', 'Mustard Seed 1.5 Kg'),
(184, 1, 2, 1050, '01/01/2026', 'Urea 35 Kg'),
(185, 1, 2, 180, '01/01/2026', 'Magma 6 Kg'),
(186, 1, 2, 1050, '01/01/2026', 'Pipe 5 Kg'),
(187, 1, 2, 220, '01/01/2026', 'Green Charge 500gm'),
(188, 1, 2, 150, '01/01/2026', 'Zinc 3 Pkt'),
(189, 1, 2, 100, '01/01/2026', 'Mancogeb 100gm'),
(190, 1, 2, 1500, '01/01/2026', 'Cow Dung'),
(191, 1, 2, 1700, '01/01/2026', 'Mustard Threshing'),
(192, 1, 2, 7490, '12/04/2026', 'Kabir\'s Shop Outstanding Bill'),
(193, 1, 2, 33000, '01/01/2026', 'Land Lease 1st Year'),
(194, 1, 2, 1050, '20/04/2026', 'Fertilizer from Abdulpur'),
(195, 1, 3, 35000, '02/04/2026', 'Land Lease 1st Year'),
(196, 1, 3, 35000, '02/04/2026', 'Land Lease 2nd Year'),
(197, 1, 3, 300, '02/04/2026', 'Stamp'),
(198, 1, 3, 1000, '05/04/2026', 'Land Cultivation 1 time'),
(199, 1, 3, 1780, '05/04/2026', 'Lime and Trycodarma'),
(200, 1, 3, 13250, '18/04/2026', 'Guava and Jujube Plant'),
(201, 1, 3, 400, '18/04/2026', 'Van Fare'),
(202, 1, 3, 1540, '20/04/2026', 'Diesel 11 Litre'),
(203, 1, 3, 2650, '20/04/2026', 'Spray Machine'),
(204, 1, 4, 40000, '14/04/2026', 'Land Lease 1st Year'),
(205, 1, 4, 450, '14/04/2026', 'Stamp and Van Fare'),
(206, 1, 4, 200, '20/04/2026', 'Cow Dung'),
(207, 1, 4, 2000, '20/04/2026', 'Land Cultivation 2 times'),
(208, 1, 4, 1700, '20/04/2026', 'Lime and Trycodarma'),
(209, 1, 4, 13250, '18/04/2026', 'Guava and Jujube Plant'),
(210, 1, 4, 400, '20/04/2026', 'Van Fare');

-- --------------------------------------------------------

--
-- Table structure for table `fin_partner`
--

CREATE TABLE `fin_partner` (
  `partner_id` int(10) UNSIGNED NOT NULL,
  `partner_name` varchar(50) NOT NULL,
  `partner_inst` varchar(100) NOT NULL,
  `partner_photo` varchar(50) NOT NULL,
  `garden_index` varchar(100) DEFAULT ''
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `fin_partner`
--

INSERT INTO `fin_partner` (`partner_id`, `partner_name`, `partner_inst`, `partner_photo`, `garden_index`) VALUES
(1, 'Md Sazdar Hossain', 'M/S Sazdar Traders, Bonpara, Natore', '1777616075.jpg', '1,');

-- --------------------------------------------------------

--
-- Table structure for table `fund`
--

CREATE TABLE `fund` (
  `fund_id` int(10) UNSIGNED NOT NULL,
  `owner_id` int(10) NOT NULL,
  `garden_id` int(10) NOT NULL,
  `fund_amount` int(10) NOT NULL,
  `fund_date` varchar(20) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `fund`
--

INSERT INTO `fund` (`fund_id`, `owner_id`, `garden_id`, `fund_amount`, `fund_date`) VALUES
(1, 5, 2, 5390, '01/01/2026'),
(2, 5, 2, 4500, '10/01/2026'),
(3, 2, 2, 9000, '01/01/2026'),
(4, 3, 2, 9000, '01/01/2026'),
(5, 1, 2, 10500, '01/01/2026'),
(6, 1, 2, 7490, '10/01/2026'),
(7, 1, 2, 1500, '20/01/2026'),
(8, 3, 2, 1700, '10/01/2026'),
(9, 5, 2, 3000, '30/01/2026'),
(10, 1, 3, 25000, '01/01/2026'),
(11, 2, 3, 25000, '01/01/2026'),
(12, 3, 3, 25000, '01/01/2026'),
(13, 5, 3, 25000, '01/01/2026'),
(14, 1, 4, 3000, '01/01/2026'),
(15, 3, 4, 20000, '01/01/2026'),
(16, 5, 4, 25000, '01/01/2026'),
(17, 1, 1, 108350, '01/01/2025'),
(18, 2, 1, 19000, '01/01/2025'),
(19, 2, 1, 4700, '01/01/2025'),
(20, 3, 1, 1300, '01/01/2025'),
(21, 3, 1, 305, '01/01/2025');

-- --------------------------------------------------------

--
-- Table structure for table `gardenindex`
--

CREATE TABLE `gardenindex` (
  `garden_id` int(10) UNSIGNED NOT NULL,
  `garden_name` varchar(100) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `gardenindex`
--

INSERT INTO `gardenindex` (`garden_id`, `garden_name`) VALUES
(1, 'G-1 Dhupail NH Garden'),
(2, 'G-2 Saiful Kaka 34 Katha'),
(3, 'G-3 Zia Member 2 Bigha'),
(4, 'G-4 Ali Dada 2 Bigha');

-- --------------------------------------------------------

--
-- Table structure for table `income`
--

CREATE TABLE `income` (
  `income_id` int(10) UNSIGNED NOT NULL,
  `owner_id` int(10) NOT NULL,
  `garden_id` int(10) NOT NULL,
  `income_source` varchar(100) NOT NULL,
  `income_amount` int(10) NOT NULL,
  `income_date` varchar(20) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `income`
--

INSERT INTO `income` (`income_id`, `owner_id`, `garden_id`, `income_source`, `income_amount`, `income_date`) VALUES
(1, 1, 1, 'Onion Sell - Mohiuddin Chacha', 3500, '23/08/2025'),
(2, 1, 1, 'Onion Sell - Bonpara', 9860, '23/08/2025'),
(3, 1, 1, 'Onion Sell - Lalpur', 6900, '26/08/2025'),
(4, 1, 1, 'Onion Sell - Bonpara', 12590, '29/08/2025'),
(5, 1, 1, 'Papaya and Pui Sell', 2720, '01/09/2025'),
(6, 1, 1, 'Onion Sell - Lalpur', 520, '03/09/2025'),
(7, 1, 1, 'Onion Sell - Dayarampur', 2565, '07/09/2025'),
(8, 1, 1, 'Onion Sell - Dayarampur', 2330, '10/09/2025'),
(9, 1, 1, 'Onion Sell - Shuvo', 1500, '10/09/2025'),
(10, 1, 1, 'Jujube Sell - Bonpara', 1600, '06/01/2026'),
(11, 1, 1, 'Jujube Sell - Bonpara', 2050, '09/01/2026'),
(12, 1, 1, 'Jujube Sell - Bonpara', 7500, '14/01/2026'),
(13, 1, 1, 'Jujube Sell - Bonpara', 5570, '15/01/2026'),
(14, 1, 1, 'Jujube Sell - Bonpara', 3840, '23/01/2026'),
(15, 1, 1, 'Jujube Sell - Bonpara', 9500, '25/01/2026'),
(16, 1, 1, 'Jujube Sell - Bonpara', 5500, '26/01/2026'),
(17, 1, 1, 'Jujube Sell - Bonpara', 1280, '07/02/2026'),
(18, 1, 1, 'Guava Sell - Bonpara', 550, '04/02/2026'),
(19, 1, 1, 'Guava Sell - Bonpara', 400, '20/02/2026'),
(20, 1, 1, 'Guava Sell - Bonpara', 2560, '26/02/2026'),
(21, 1, 1, 'Guava Sell - Bonpara', 5610, '02/03/2026'),
(22, 1, 1, 'Guava Sell - Bonpara', 200, '09/03/2026'),
(23, 1, 1, 'Guava Sell - Bonpara', 600, '11/03/2026');

-- --------------------------------------------------------

--
-- Table structure for table `loan`
--

CREATE TABLE `loan` (
  `loan_id` int(10) UNSIGNED NOT NULL,
  `loan_inst` varchar(100) NOT NULL,
  `loan_purpose` varchar(100) NOT NULL,
  `garden_id` int(10) NOT NULL,
  `loan_amount` int(10) NOT NULL,
  `loan_date` varchar(20) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `loan`
--

INSERT INTO `loan` (`loan_id`, `loan_inst`, `loan_purpose`, `garden_id`, `loan_amount`, `loan_date`) VALUES
(1, '1', 'For supporting the garden expenditure', 1, 100000, '01/05/2026');

-- --------------------------------------------------------

--
-- Table structure for table `owner`
--

CREATE TABLE `owner` (
  `owner_id` int(10) UNSIGNED NOT NULL,
  `owner_name` varchar(50) NOT NULL,
  `owner_photo` varchar(50) NOT NULL,
  `garden_index` varchar(100) DEFAULT ''
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `owner`
--

INSERT INTO `owner` (`owner_id`, `owner_name`, `owner_photo`, `garden_index`) VALUES
(1, 'Md Moniruzzaman', '1777693055.png', '1,2,3,4,'),
(2, 'Fahim Monaem', '1777693084.jpg', '1,2,3,4,'),
(3, 'Sohanur Rahman', '1777693109.jpg', '1,2,3,4,'),
(4, 'Md Mahim Ali', '1777693131.jpg', '1,'),
(5, 'Md Somrat Ali', '1777693163.jpg', '2,3,4,');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `exp`
--
ALTER TABLE `exp`
  ADD PRIMARY KEY (`exp_id`);

--
-- Indexes for table `fin_partner`
--
ALTER TABLE `fin_partner`
  ADD PRIMARY KEY (`partner_id`);

--
-- Indexes for table `fund`
--
ALTER TABLE `fund`
  ADD PRIMARY KEY (`fund_id`);

--
-- Indexes for table `gardenindex`
--
ALTER TABLE `gardenindex`
  ADD PRIMARY KEY (`garden_id`);

--
-- Indexes for table `income`
--
ALTER TABLE `income`
  ADD PRIMARY KEY (`income_id`);

--
-- Indexes for table `loan`
--
ALTER TABLE `loan`
  ADD PRIMARY KEY (`loan_id`);

--
-- Indexes for table `owner`
--
ALTER TABLE `owner`
  ADD PRIMARY KEY (`owner_id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `exp`
--
ALTER TABLE `exp`
  MODIFY `exp_id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=211;

--
-- AUTO_INCREMENT for table `fin_partner`
--
ALTER TABLE `fin_partner`
  MODIFY `partner_id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `fund`
--
ALTER TABLE `fund`
  MODIFY `fund_id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=22;

--
-- AUTO_INCREMENT for table `gardenindex`
--
ALTER TABLE `gardenindex`
  MODIFY `garden_id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `income`
--
ALTER TABLE `income`
  MODIFY `income_id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=24;

--
-- AUTO_INCREMENT for table `loan`
--
ALTER TABLE `loan`
  MODIFY `loan_id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `owner`
--
ALTER TABLE `owner`
  MODIFY `owner_id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;

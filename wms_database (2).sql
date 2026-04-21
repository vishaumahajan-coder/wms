-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Apr 13, 2026 at 03:14 PM
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
-- Database: `wms_database`
--

-- --------------------------------------------------------

--
-- Table structure for table `batches`
--

CREATE TABLE `batches` (
  `id` int(11) NOT NULL,
  `batch_number` varchar(255) NOT NULL,
  `company_id` int(11) NOT NULL,
  `product_id` int(11) NOT NULL,
  `warehouse_id` int(11) NOT NULL,
  `location_id` int(11) DEFAULT NULL,
  `quantity` decimal(12,3) DEFAULT 0.000,
  `reserved` decimal(12,3) DEFAULT 0.000,
  `unit_cost` decimal(12,2) DEFAULT NULL,
  `received_date` date DEFAULT NULL,
  `expiry_date` date DEFAULT NULL,
  `manufacturing_date` date DEFAULT NULL,
  `supplier_id` int(11) DEFAULT NULL,
  `status` varchar(255) DEFAULT 'ACTIVE',
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `batches`
--

INSERT INTO `batches` (`id`, `batch_number`, `company_id`, `product_id`, `warehouse_id`, `location_id`, `quantity`, `reserved`, `unit_cost`, `received_date`, `expiry_date`, `manufacturing_date`, `supplier_id`, `status`, `created_at`, `updated_at`) VALUES
(4, '5g', 1, 105, 8, 8, 11.000, 0.000, 0.02, '2026-03-06', '2026-03-23', NULL, 4, 'ACTIVE', '2026-03-19 09:18:56', '2026-03-19 09:18:56');

-- --------------------------------------------------------

--
-- Table structure for table `bundles`
--

CREATE TABLE `bundles` (
  `id` int(11) NOT NULL,
  `company_id` int(11) NOT NULL,
  `sku` varchar(255) NOT NULL,
  `name` varchar(255) NOT NULL,
  `cost_price` decimal(12,2) DEFAULT 0.00,
  `selling_price` decimal(12,2) DEFAULT 0.00,
  `status` varchar(255) DEFAULT 'ACTIVE',
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `description` text DEFAULT NULL,
  `currency` varchar(255) DEFAULT 'USD'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `bundles`
--

INSERT INTO `bundles` (`id`, `company_id`, `sku`, `name`, `cost_price`, `selling_price`, `status`, `created_at`, `updated_at`, `description`, `currency`) VALUES
(4, 1, '1234', 'ABC Pvt Ltd', 5.00, 30.00, 'ACTIVE', '2026-04-10 11:11:19', '2026-04-10 11:11:19', 'ASDFGHJK', 'USD'),
(5, 1, 'ds8t8tw', 'ABC Pvt Ltd', 39.00, 50.00, 'ACTIVE', '2026-04-10 11:26:03', '2026-04-10 11:26:03', 'asdfg', 'USD');

-- --------------------------------------------------------

--
-- Table structure for table `bundle_items`
--

CREATE TABLE `bundle_items` (
  `id` int(11) NOT NULL,
  `bundle_id` int(11) NOT NULL,
  `product_id` int(11) NOT NULL,
  `quantity` decimal(12,3) DEFAULT 0.000,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `bundle_items`
--

INSERT INTO `bundle_items` (`id`, `bundle_id`, `product_id`, `quantity`, `created_at`, `updated_at`) VALUES
(5, 4, 112, 1.000, '2026-04-10 11:11:19', '2026-04-10 11:11:19');

-- --------------------------------------------------------

--
-- Table structure for table `categories`
--

CREATE TABLE `categories` (
  `id` int(11) NOT NULL,
  `company_id` int(11) NOT NULL,
  `name` varchar(255) NOT NULL,
  `code` varchar(255) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `categories`
--

INSERT INTO `categories` (`id`, `company_id`, `name`, `code`, `created_at`, `updated_at`) VALUES
(9, 1, 'demo ', '3434343', '2026-03-06 13:15:42', '2026-03-06 13:15:42'),
(10, 1, 'laptopr', '23', '2026-03-19 08:52:26', '2026-03-19 08:52:26'),
(11, 1, '1', '1', '2026-04-10 09:49:18', '2026-04-10 09:49:18'),
(12, 1, '2', '2', '2026-04-10 09:49:18', '2026-04-10 09:49:18'),
(13, 1, 'ABC Pvt Ltd', 'Auto-generated', '2026-04-10 11:25:44', '2026-04-10 11:25:44');

-- --------------------------------------------------------

--
-- Table structure for table `companies`
--

CREATE TABLE `companies` (
  `id` int(11) NOT NULL,
  `name` varchar(255) NOT NULL,
  `code` varchar(255) NOT NULL,
  `email` varchar(255) DEFAULT NULL,
  `phone` varchar(255) DEFAULT NULL,
  `address` text DEFAULT NULL,
  `status` varchar(255) DEFAULT 'ACTIVE',
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `companies`
--

INSERT INTO `companies` (`id`, `name`, `code`, `email`, `phone`, `address`, `status`, `created_at`, `updated_at`) VALUES
(1, 'water supply', '25005', NULL, '04545454555', 'demo\ndemo', 'ACTIVE', '2026-01-28 11:43:12', '2026-01-31 13:16:38'),
(8, 'Demo Company', 'DEMO', 'contact@demo.com', '+44 20 1234 5678', '100 Business Park, London', 'ACTIVE', '2026-04-10 11:28:26', '2026-04-10 11:28:26');

-- --------------------------------------------------------

--
-- Table structure for table `customers`
--

CREATE TABLE `customers` (
  `id` int(11) NOT NULL,
  `company_id` int(11) NOT NULL,
  `name` varchar(255) NOT NULL,
  `email` varchar(255) DEFAULT NULL,
  `phone` varchar(255) DEFAULT NULL,
  `address` text DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `code` varchar(255) DEFAULT NULL,
  `type` varchar(255) DEFAULT NULL,
  `contact_person` varchar(255) DEFAULT NULL,
  `country` varchar(255) DEFAULT NULL,
  `state` varchar(255) DEFAULT NULL,
  `city` varchar(255) DEFAULT NULL,
  `tier` varchar(255) DEFAULT NULL,
  `segment` varchar(255) DEFAULT NULL,
  `credit_limit` decimal(15,2) DEFAULT 0.00,
  `payment_terms` varchar(255) DEFAULT NULL,
  `status` varchar(255) DEFAULT 'ACTIVE',
  `postcode` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `customers`
--

INSERT INTO `customers` (`id`, `company_id`, `name`, `email`, `phone`, `address`, `created_at`, `updated_at`, `code`, `type`, `contact_person`, `country`, `state`, `city`, `tier`, `segment`, `credit_limit`, `payment_terms`, `status`, `postcode`) VALUES
(6, 1, 'ram', 'ram@gmail.com', '555544331', 'indore', '2026-03-19 09:38:14', '2026-03-19 09:38:14', '23', 'B2C', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'ACTIVE', '2633');

-- --------------------------------------------------------

--
-- Table structure for table `cycle_counts`
--

CREATE TABLE `cycle_counts` (
  `id` int(11) NOT NULL,
  `reference_number` varchar(255) DEFAULT NULL,
  `company_id` int(11) NOT NULL,
  `count_name` varchar(255) NOT NULL,
  `count_type` varchar(255) DEFAULT NULL,
  `location_id` int(11) DEFAULT NULL,
  `scheduled_date` date DEFAULT NULL,
  `notes` text DEFAULT NULL,
  `status` varchar(255) DEFAULT 'PENDING',
  `items_count` int(11) DEFAULT 0,
  `discrepancies` int(11) DEFAULT 0,
  `counted_by` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `cycle_counts`
--

INSERT INTO `cycle_counts` (`id`, `reference_number`, `company_id`, `count_name`, `count_type`, `location_id`, `scheduled_date`, `notes`, `status`, `items_count`, `discrepancies`, `counted_by`, `created_at`, `updated_at`) VALUES
(3, 'CC-00003', 1, 'cc', 'PARTIAL', 8, '2026-03-17', 'k', 'PENDING', 0, 0, NULL, '2026-03-19 09:13:55', '2026-03-19 09:13:55');

-- --------------------------------------------------------

--
-- Table structure for table `goods_receipts`
--

CREATE TABLE `goods_receipts` (
  `id` int(11) NOT NULL,
  `company_id` int(11) NOT NULL,
  `purchase_order_id` int(11) NOT NULL,
  `gr_number` varchar(255) NOT NULL,
  `status` varchar(255) DEFAULT 'pending',
  `notes` text DEFAULT NULL,
  `total_expected` int(11) DEFAULT 0,
  `total_received` int(11) DEFAULT 0,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `warehouse_id` int(11) DEFAULT NULL,
  `delivery_type` varchar(255) DEFAULT NULL,
  `eta` datetime DEFAULT NULL,
  `total_to_book` int(11) DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `goods_receipt_items`
--

CREATE TABLE `goods_receipt_items` (
  `id` int(11) NOT NULL,
  `goods_receipt_id` int(11) NOT NULL,
  `product_id` int(11) NOT NULL,
  `product_name` varchar(255) DEFAULT NULL,
  `product_sku` varchar(255) DEFAULT NULL,
  `expected_qty` int(11) DEFAULT 0,
  `received_qty` int(11) DEFAULT 0,
  `quality_status` varchar(255) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `inventory`
--

CREATE TABLE `inventory` (
  `id` int(11) NOT NULL,
  `warehouse_id` int(11) NOT NULL,
  `product_id` int(11) NOT NULL,
  `quantity` int(11) DEFAULT 0,
  `reserved_quantity` int(11) DEFAULT 0,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `inventory`
--

INSERT INTO `inventory` (`id`, `warehouse_id`, `product_id`, `quantity`, `reserved_quantity`, `created_at`, `updated_at`) VALUES
(1, 7, 90, 50, 0, '2026-03-19 07:46:35', '2026-03-19 07:46:35'),
(2, 8, 90, 20, 0, '2026-03-19 07:46:35', '2026-03-19 07:46:35'),
(3, 8, 105, 0, 0, '2026-04-10 09:50:03', '2026-04-10 10:09:52'),
(4, 7, 105, 1, 0, '2026-04-10 10:09:52', '2026-04-10 10:09:52'),
(5, 8, 101, 1, 0, '2026-04-10 10:12:23', '2026-04-10 10:12:23');

-- --------------------------------------------------------

--
-- Table structure for table `inventory_adjustments`
--

CREATE TABLE `inventory_adjustments` (
  `id` int(11) NOT NULL,
  `reference_number` varchar(255) DEFAULT NULL,
  `company_id` int(11) NOT NULL,
  `product_id` int(11) NOT NULL,
  `warehouse_id` int(11) DEFAULT NULL,
  `type` varchar(255) NOT NULL,
  `quantity` decimal(12,3) DEFAULT 0.000,
  `reason` varchar(255) DEFAULT NULL,
  `notes` text DEFAULT NULL,
  `status` varchar(255) DEFAULT 'PENDING',
  `created_by` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `batch_id` int(11) DEFAULT NULL,
  `location_id` int(11) DEFAULT NULL,
  `client_id` int(11) DEFAULT NULL,
  `best_before_date` date DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  `batch_number` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `inventory_adjustments`
--

INSERT INTO `inventory_adjustments` (`id`, `reference_number`, `company_id`, `product_id`, `warehouse_id`, `type`, `quantity`, `reason`, `notes`, `status`, `created_by`, `created_at`, `updated_at`, `batch_id`, `location_id`, `client_id`, `best_before_date`, `user_id`, `batch_number`) VALUES
(86, 'ADJ-BW1NOGW2', 1, 90, 7, 'INCREASE', 5.500, 'SCAN_IN', 'Stock In — 4:55:05 PM', 'COMPLETED', 2, '2026-03-07 11:25:05', '2026-03-07 11:25:05', NULL, NULL, NULL, NULL, NULL, NULL),
(87, 'ADJ-BW1NOGXM', 1, 90, 7, 'DECREASE', 2.000, 'SCAN_OUT', 'Stock Out — 4:55:17 PM', 'COMPLETED', 2, '2026-03-07 11:25:17', '2026-03-07 11:25:17', NULL, NULL, NULL, NULL, NULL, NULL),
(88, 'ADJ-BW1NOGX1', 1, 90, 7, 'INCREASE', 1.000, 'SCAN_IN', 'Stock In — 4:55:36 PM', 'COMPLETED', 2, '2026-03-07 11:25:36', '2026-03-07 11:25:36', NULL, NULL, NULL, NULL, NULL, NULL),
(89, 'ADJ-BW1NOG02', 1, 90, 7, 'INCREASE', 1.000, 'Auto Fast Scan IN', NULL, 'COMPLETED', 2, '2026-03-07 11:25:51', '2026-03-07 11:25:51', NULL, NULL, NULL, NULL, NULL, NULL),
(90, 'ADJ-BW1NOG1S', 1, 90, 7, 'DECREASE', 1.000, 'Auto Fast Scan OUT', NULL, 'COMPLETED', 2, '2026-03-07 11:26:11', '2026-03-07 11:26:11', NULL, NULL, NULL, NULL, NULL, NULL),
(91, 'ADJ-BW1NOG45', 1, 90, 8, 'INCREASE', 4.500, 'SCAN_IN', 'Stock In — 4:56:42 PM', 'COMPLETED', 2, '2026-03-07 11:26:42', '2026-03-07 11:26:42', NULL, NULL, NULL, NULL, NULL, NULL),
(92, 'ADJ-BW1NOG51', 1, 90, 7, 'INCREASE', 1.000, 'Auto Fast Scan IN', NULL, 'COMPLETED', 2, '2026-03-07 11:27:09', '2026-03-07 11:27:09', NULL, NULL, NULL, NULL, NULL, NULL),
(93, 'ADJ-BW1NOHC3', 1, 90, 8, 'INCREASE', 1.500, 'SCAN_IN', 'Stock In — 5:03:39 PM', 'COMPLETED', 2, '2026-03-07 11:33:39', '2026-03-07 11:33:39', NULL, NULL, NULL, NULL, NULL, NULL),
(94, 'ADJ-BW1NOWP6', 1, 90, 7, 'INCREASE', 94.500, 'SCAN_IN', 'Stock In — 5:22:09 PM', 'COMPLETED', 2, '2026-03-07 11:52:09', '2026-03-07 11:52:09', NULL, NULL, NULL, NULL, NULL, NULL),
(95, 'PROD-16', 1, 90, 7, 'DECREASE', 50.000, 'Consumed for Production Order #16', NULL, 'COMPLETED', 2, '2026-03-07 11:52:37', '2026-03-07 11:52:37', NULL, NULL, NULL, NULL, NULL, NULL),
(96, 'PROD-16', 1, 90, 8, 'INCREASE', 50.000, 'Produced from Production Order #16', NULL, 'COMPLETED', 2, '2026-03-07 11:52:53', '2026-03-07 11:52:53', NULL, NULL, NULL, NULL, NULL, NULL),
(97, 'ADJ-BW1NYJDK', 1, 98, 7, 'INCREASE', 12.000, 'Opening Stock', 'Initial stock added during product creation', 'COMPLETED', 2, '2026-03-07 12:38:20', '2026-03-07 12:38:20', NULL, NULL, NULL, NULL, NULL, NULL),
(98, 'ADJ-BW1NYNFO', 1, 98, 7, 'INCREASE', 1.120, 'SCAN_IN', 'Stock In — 6:23:12 PM', 'COMPLETED', 2, '2026-03-07 12:53:12', '2026-03-07 12:53:12', NULL, NULL, NULL, NULL, NULL, NULL),
(99, 'ADJ-BW1NYZB1', 1, 98, 7, 'INCREASE', 1.120, 'SCAN_IN', 'Stock In — 6:31:14 PM', 'COMPLETED', 2, '2026-03-07 13:01:14', '2026-03-07 13:01:14', NULL, NULL, NULL, NULL, NULL, NULL),
(100, 'ADJ-BW1NYZFT', 1, 98, 7, 'INCREASE', 1.440, 'SCAN_IN', 'Stock In — 6:31:52 PM', 'COMPLETED', 2, '2026-03-07 13:01:52', '2026-03-07 13:01:52', NULL, NULL, NULL, NULL, NULL, NULL),
(101, 'ADJ-BW1NY2FX', 1, 98, 7, 'INCREASE', 1.123, 'SCAN_IN', 'Stock In — 6:38:56 PM', 'COMPLETED', 2, '2026-03-07 13:08:56', '2026-03-07 13:08:56', NULL, NULL, NULL, NULL, NULL, NULL),
(102, 'ADJ-BW1NY2DR', 1, 98, 7, 'INCREASE', 1.123, 'SCAN_IN', 'Stock In — 6:43:28 PM', 'COMPLETED', 2, '2026-03-07 13:13:28', '2026-03-07 13:13:28', NULL, NULL, NULL, NULL, NULL, NULL),
(103, 'ADJ-BW1NZGE5', 1, 98, 7, 'INCREASE', 1.122, 'SCAN_IN', 'Stock In — 7:06:34 PM', 'COMPLETED', 2, '2026-03-07 13:36:34', '2026-03-07 13:36:34', NULL, NULL, NULL, NULL, NULL, NULL),
(104, 'PROD-18', 1, 90, 8, 'DECREASE', 1.000, 'Consumed for Production Order #18', NULL, 'COMPLETED', 2, '2026-03-11 11:35:07', '2026-03-11 11:35:07', NULL, NULL, NULL, NULL, NULL, NULL),
(105, 'PROD-18', 1, 90, 8, 'INCREASE', 1.000, 'Produced from Production Order #18', NULL, 'COMPLETED', 2, '2026-03-11 11:35:51', '2026-03-11 11:35:51', NULL, NULL, NULL, NULL, NULL, NULL),
(106, 'PROD-19', 1, 90, 7, 'DECREASE', 0.002, 'Consumed for Production Order #19', NULL, 'COMPLETED', 2, '2026-03-11 11:57:03', '2026-03-11 11:57:03', NULL, NULL, NULL, NULL, NULL, NULL),
(107, 'PROD-19', 1, 90, 8, 'INCREASE', 1.000, 'Produced from Production Order #19', NULL, 'COMPLETED', 2, '2026-03-11 11:57:21', '2026-03-11 11:57:21', NULL, NULL, NULL, NULL, NULL, NULL),
(108, 'PROD-20', 1, 90, 7, 'DECREASE', 0.002, 'Consumed for Production Order #20', NULL, 'COMPLETED', 2, '2026-03-11 12:07:06', '2026-03-11 12:07:06', NULL, NULL, NULL, NULL, NULL, NULL),
(109, 'PROD-21', 1, 90, 7, 'DECREASE', 0.002, 'Consumed for Production Order #21', NULL, 'COMPLETED', 2, '2026-03-11 12:10:58', '2026-03-11 12:10:58', NULL, NULL, NULL, NULL, NULL, NULL),
(110, 'PROD-21', 1, 90, 8, 'INCREASE', 1.000, 'Produced from Production Order #21', NULL, 'COMPLETED', 2, '2026-03-11 12:11:06', '2026-03-11 12:11:06', NULL, NULL, NULL, NULL, NULL, NULL),
(113, 'ADJ-BW1TMGHV', 1, 101, 8, 'INCREASE', 1.000, 'SCAN_IN', 'Stock In — 5:55:02 PM', 'COMPLETED', 2, '2026-03-11 12:25:02', '2026-03-11 12:25:02', NULL, NULL, NULL, NULL, NULL, NULL),
(114, 'ADJ-BW4YEG5S', 1, 106, 8, 'INCREASE', 4.000, 'Manual Stock In', NULL, 'COMPLETED', 2, '2026-03-23 08:37:44', '2026-03-23 08:37:44', NULL, 8, 6, NULL, NULL, NULL),
(115, 'ADJ-BW4YEG9T', 1, 106, 8, 'INCREASE', 1.000, 'Manual Stock In', NULL, 'COMPLETED', 2, '2026-03-23 08:38:33', '2026-03-23 08:38:33', NULL, 8, 6, NULL, NULL, NULL),
(116, 'ADJ-BW5ZCTV4', 1, 105, 8, 'INCREASE', 1.000, '6757', NULL, 'COMPLETED', 2, '2026-04-10 09:50:03', '2026-04-10 09:50:03', NULL, 8, 6, '2026-04-09', NULL, '1234'),
(117, 'ADJ-BW5ZCXLU', 1, 101, 8, 'INCREASE', 1.000, '43422', NULL, 'COMPLETED', 2, '2026-04-10 10:12:23', '2026-04-10 10:12:23', NULL, 8, 6, '2026-04-11', NULL, '3435');

-- --------------------------------------------------------

--
-- Table structure for table `inventory_logs`
--

CREATE TABLE `inventory_logs` (
  `id` int(11) NOT NULL,
  `product_id` int(11) NOT NULL,
  `warehouse_id` int(11) NOT NULL,
  `type` varchar(255) NOT NULL,
  `quantity` int(11) NOT NULL,
  `reference_id` varchar(255) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `batch_id` int(11) DEFAULT NULL,
  `location_id` int(11) DEFAULT NULL,
  `client_id` int(11) DEFAULT NULL,
  `best_before_date` date DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  `reason` varchar(255) DEFAULT NULL,
  `batch_number` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `inventory_logs`
--

INSERT INTO `inventory_logs` (`id`, `product_id`, `warehouse_id`, `type`, `quantity`, `reference_id`, `created_at`, `updated_at`, `batch_id`, `location_id`, `client_id`, `best_before_date`, `user_id`, `reason`, `batch_number`) VALUES
(1, 90, 7, 'IN', 100, 'REF-IN-1', '2026-03-19 07:46:35', '2026-03-19 07:46:35', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(2, 90, 7, 'OUT', 30, 'REF-OUT-1', '2026-03-19 07:46:35', '2026-03-19 07:46:35', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(3, 90, 7, 'TRANSFER', 20, 'To WH: 8', '2026-03-19 07:46:35', '2026-03-19 07:46:35', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(4, 90, 8, 'TRANSFER', 20, 'From WH: 7', '2026-03-19 07:46:35', '2026-03-19 07:46:35', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(5, 106, 8, 'IN', 4, 'ADJ-BW4YEG5S', '2026-03-23 08:37:44', '2026-03-23 08:37:44', NULL, 8, 6, NULL, 2, 'Manual Stock In', NULL),
(6, 106, 8, 'IN', 1, 'ADJ-BW4YEG9T', '2026-03-23 08:38:33', '2026-03-23 08:38:33', NULL, 8, 6, NULL, 2, 'Manual Stock In', NULL),
(7, 105, 8, 'IN', 1, 'ADJ-BW5ZCTV4', '2026-04-10 09:50:03', '2026-04-10 09:50:03', NULL, 8, 6, '2026-04-09', 2, '6757', '1234'),
(8, 105, 8, 'TRANSFER', -1, 'TRANSFER: 8:8 -> 7:9', '2026-04-10 10:09:52', '2026-04-10 10:09:52', NULL, 8, 6, '2026-04-11', 2, 'Internal Transfer', '5g'),
(9, 105, 7, 'TRANSFER', 1, 'TRANSFER: 8:8 -> 7:9', '2026-04-10 10:09:52', '2026-04-10 10:09:52', NULL, 9, 6, '2026-04-11', 2, 'Internal Transfer', '5g'),
(10, 101, 8, 'IN', 1, 'ADJ-BW5ZCXLU', '2026-04-10 10:12:23', '2026-04-10 10:12:23', NULL, 8, 6, '2026-04-11', 2, '43422', '3435');

-- --------------------------------------------------------

--
-- Table structure for table `locations`
--

CREATE TABLE `locations` (
  `id` int(11) NOT NULL,
  `zone_id` int(11) NOT NULL,
  `name` varchar(255) NOT NULL,
  `code` varchar(255) DEFAULT NULL,
  `aisle` varchar(255) DEFAULT NULL,
  `rack` varchar(255) DEFAULT NULL,
  `shelf` varchar(255) DEFAULT NULL,
  `bin` varchar(255) DEFAULT NULL,
  `location_type` varchar(255) DEFAULT NULL,
  `pick_sequence` int(11) DEFAULT NULL,
  `max_weight` decimal(10,2) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `heat_sensitive` varchar(255) DEFAULT NULL,
  `warehouse_id` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `locations`
--

INSERT INTO `locations` (`id`, `zone_id`, `name`, `code`, `aisle`, `rack`, `shelf`, `bin`, `location_type`, `pick_sequence`, `max_weight`, `created_at`, `updated_at`, `heat_sensitive`, `warehouse_id`) VALUES
(8, 6, 'kkkk', NULL, 'k', 'k', 'k', 'k', 'PICK', 2, 0.03, '2026-03-18 09:39:23', '2026-04-13 13:12:21', 'yes', NULL),
(9, 7, 'zzzz', 'z', 'z', 'z', 'z', 'z', 'PICK', 2, 0.03, '2026-04-08 14:53:57', '2026-04-13 13:12:21', 'yes', NULL),
(10, 8, 'ARSB', NULL, 'A', 'R', 'S', 'B', 'BULK', 78, 89.00, '2026-04-10 10:19:25', '2026-04-13 13:12:21', 'yes', NULL),
(11, 10, 'ARSB', NULL, 'A', 'R', 'S', 'B', 'QUARANTINE', 67, 78.00, '2026-04-10 11:25:01', '2026-04-13 13:12:21', 'yes', NULL);

-- --------------------------------------------------------

--
-- Table structure for table `movements`
--

CREATE TABLE `movements` (
  `id` int(11) NOT NULL,
  `company_id` int(11) NOT NULL,
  `type` varchar(255) NOT NULL,
  `product_id` int(11) NOT NULL,
  `batch_id` int(11) DEFAULT NULL,
  `from_location_id` int(11) DEFAULT NULL,
  `to_location_id` int(11) DEFAULT NULL,
  `quantity` decimal(12,3) DEFAULT 0.000,
  `reason` varchar(255) DEFAULT NULL,
  `notes` text DEFAULT NULL,
  `created_by` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `warehouse_id` int(11) DEFAULT NULL,
  `from_warehouse_id` int(11) DEFAULT NULL,
  `to_warehouse_id` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `movements`
--

INSERT INTO `movements` (`id`, `company_id`, `type`, `product_id`, `batch_id`, `from_location_id`, `to_location_id`, `quantity`, `reason`, `notes`, `created_by`, `created_at`, `updated_at`, `warehouse_id`, `from_warehouse_id`, `to_warehouse_id`) VALUES
(47, 1, 'INCREASE', 90, NULL, NULL, NULL, 100.000, 'Opening Stock', NULL, 2, '2026-03-06 13:16:05', '2026-03-06 13:16:05', 7, NULL, NULL),
(48, 1, 'DECREASE', 90, NULL, NULL, NULL, 1.000, 'SCAN_OUT', 'Stock Out — 6:53:59 PM', 2, '2026-03-06 13:24:00', '2026-03-06 13:24:00', 7, NULL, NULL),
(49, 1, 'INCREASE', 90, NULL, NULL, NULL, 1.000, 'Auto Fast Scan IN', 'Reference: ADJ-BW1LEHNQ', 2, '2026-03-06 13:35:07', '2026-03-06 13:35:07', 7, NULL, NULL),
(50, 1, 'DECREASE', 90, NULL, NULL, NULL, 2.000, 'SCAN_OUT', 'Stock Out — 7:13:03 PM', 2, '2026-03-06 13:43:04', '2026-03-06 13:43:04', 7, NULL, NULL),
(51, 1, 'INCREASE', 90, NULL, NULL, NULL, 1.000, 'SCAN_IN', 'Stock In — 3:40:07 PM', 2, '2026-03-07 10:10:07', '2026-03-07 10:10:07', 8, NULL, NULL),
(52, 1, 'INCREASE', 90, NULL, NULL, NULL, 1.000, 'SCAN_IN', 'Stock In — 3:49:07 PM', 2, '2026-03-07 10:19:07', '2026-03-07 10:19:07', 8, NULL, NULL),
(53, 1, 'INCREASE', 90, NULL, NULL, NULL, 1.000, 'SCAN_IN', 'Stock In — 3:56:35 PM', 2, '2026-03-07 10:26:35', '2026-03-07 10:26:35', 8, NULL, NULL),
(63, 1, 'INCREASE', 90, NULL, NULL, NULL, 1.500, 'SCAN_IN', 'Stock In — 4:11:55 PM', 2, '2026-03-07 10:41:55', '2026-03-07 10:41:55', 7, NULL, NULL),
(64, 1, 'INCREASE', 90, NULL, NULL, NULL, 4.500, 'SCAN_IN', 'Stock In — 4:25:21 PM', 2, '2026-03-07 10:55:22', '2026-03-07 10:55:22', 7, NULL, NULL),
(65, 1, 'INCREASE', 90, NULL, NULL, NULL, 2.500, 'SCAN_IN', 'Stock In — 4:32:36 PM', 2, '2026-03-07 11:02:36', '2026-03-07 11:02:36', 8, NULL, NULL),
(66, 1, 'INCREASE', 90, NULL, NULL, NULL, 4.500, 'SCAN_IN', 'Stock In — 4:44:13 PM', 2, '2026-03-07 11:14:13', '2026-03-07 11:14:13', 7, NULL, NULL),
(67, 1, 'INCREASE', 90, NULL, NULL, NULL, 4.500, 'SCAN_IN', 'Stock In — 4:45:36 PM', 2, '2026-03-07 11:15:36', '2026-03-07 11:15:36', 8, NULL, NULL),
(68, 1, 'DECREASE', 90, NULL, NULL, NULL, 2.000, 'SCAN_OUT', 'Stock Out — 4:46:05 PM', 2, '2026-03-07 11:16:05', '2026-03-07 11:16:05', 8, NULL, NULL),
(69, 1, 'INCREASE', 90, NULL, NULL, NULL, 1.000, 'Auto Fast Scan IN', 'Reference: ADJ-BW1NOGFJ', 2, '2026-03-07 11:16:40', '2026-03-07 11:16:40', 8, NULL, NULL),
(70, 1, 'INCREASE', 90, NULL, NULL, NULL, 1.000, 'Auto Fast Scan IN', 'Reference: ADJ-BW1NOGJJ', 2, '2026-03-07 11:17:27', '2026-03-07 11:17:27', 8, NULL, NULL),
(71, 1, 'INCREASE', 90, NULL, NULL, NULL, 5.500, 'SCAN_IN', 'Stock In — 4:55:05 PM', 2, '2026-03-07 11:25:05', '2026-03-07 11:25:05', 7, NULL, NULL),
(72, 1, 'DECREASE', 90, NULL, NULL, NULL, 2.000, 'SCAN_OUT', 'Stock Out — 4:55:17 PM', 2, '2026-03-07 11:25:17', '2026-03-07 11:25:17', 7, NULL, NULL),
(73, 1, 'INCREASE', 90, NULL, NULL, NULL, 1.000, 'SCAN_IN', 'Stock In — 4:55:36 PM', 2, '2026-03-07 11:25:36', '2026-03-07 11:25:36', 7, NULL, NULL),
(74, 1, 'INCREASE', 90, NULL, NULL, NULL, 1.000, 'Auto Fast Scan IN', 'Reference: ADJ-BW1NOG02', 2, '2026-03-07 11:25:51', '2026-03-07 11:25:51', 7, NULL, NULL),
(75, 1, 'DECREASE', 90, NULL, NULL, NULL, 1.000, 'Auto Fast Scan OUT', 'Reference: ADJ-BW1NOG1S', 2, '2026-03-07 11:26:11', '2026-03-07 11:26:11', 7, NULL, NULL),
(76, 1, 'INCREASE', 90, NULL, NULL, NULL, 4.500, 'SCAN_IN', 'Stock In — 4:56:42 PM', 2, '2026-03-07 11:26:42', '2026-03-07 11:26:42', 8, NULL, NULL),
(77, 1, 'INCREASE', 90, NULL, NULL, NULL, 1.000, 'Auto Fast Scan IN', 'Reference: ADJ-BW1NOG51', 2, '2026-03-07 11:27:09', '2026-03-07 11:27:09', 7, NULL, NULL),
(78, 1, 'INCREASE', 90, NULL, NULL, NULL, 1.500, 'SCAN_IN', 'Stock In — 5:03:39 PM', 2, '2026-03-07 11:33:39', '2026-03-07 11:33:39', 8, NULL, NULL),
(79, 1, 'INCREASE', 90, NULL, NULL, NULL, 94.500, 'SCAN_IN', 'Stock In — 5:22:09 PM', 2, '2026-03-07 11:52:09', '2026-03-07 11:52:09', 7, NULL, NULL),
(80, 1, 'DECREASE', 90, NULL, NULL, NULL, 50.000, 'Consumed for Production Order #16', NULL, 2, '2026-03-07 11:52:37', '2026-03-07 11:52:37', 7, NULL, NULL),
(81, 1, 'INCREASE', 90, NULL, NULL, NULL, 50.000, 'Produced from Production Order #16', NULL, 2, '2026-03-07 11:52:53', '2026-03-07 11:52:53', 8, NULL, NULL),
(82, 1, 'INCREASE', 98, NULL, NULL, NULL, 12.000, 'Opening Stock', NULL, 2, '2026-03-07 12:38:20', '2026-03-07 12:38:20', 7, NULL, NULL),
(83, 1, 'INCREASE', 98, NULL, NULL, NULL, 1.120, 'SCAN_IN', 'Stock In — 6:23:12 PM', 2, '2026-03-07 12:53:12', '2026-03-07 12:53:12', 7, NULL, NULL),
(84, 1, 'INCREASE', 98, NULL, NULL, NULL, 1.120, 'SCAN_IN', 'Stock In — 6:31:14 PM', 2, '2026-03-07 13:01:14', '2026-03-07 13:01:14', 7, NULL, NULL),
(85, 1, 'INCREASE', 98, NULL, NULL, NULL, 1.440, 'SCAN_IN', 'Stock In — 6:31:52 PM', 2, '2026-03-07 13:01:52', '2026-03-07 13:01:52', 7, NULL, NULL),
(86, 1, 'INCREASE', 98, NULL, NULL, NULL, 1.123, 'SCAN_IN', 'Stock In — 6:38:56 PM', 2, '2026-03-07 13:08:57', '2026-03-07 13:08:57', 7, NULL, NULL),
(87, 1, 'INCREASE', 98, NULL, NULL, NULL, 1.123, 'SCAN_IN', 'Stock In — 6:43:28 PM', 2, '2026-03-07 13:13:28', '2026-03-07 13:13:28', 7, NULL, NULL),
(88, 1, 'INCREASE', 98, NULL, NULL, NULL, 1.122, 'SCAN_IN', 'Stock In — 7:06:34 PM', 2, '2026-03-07 13:36:34', '2026-03-07 13:36:34', 7, NULL, NULL),
(89, 1, 'DECREASE', 90, NULL, NULL, NULL, 1.000, 'Consumed for Production Order #18', NULL, 2, '2026-03-11 11:35:07', '2026-03-11 11:35:07', 8, NULL, NULL),
(90, 1, 'INCREASE', 90, NULL, NULL, NULL, 1.000, 'Produced from Production Order #18', NULL, 2, '2026-03-11 11:35:51', '2026-03-11 11:35:51', 8, NULL, NULL),
(91, 1, 'DECREASE', 90, NULL, NULL, NULL, 0.002, 'Consumed for Production Order #19', NULL, 2, '2026-03-11 11:57:03', '2026-03-11 11:57:03', 7, NULL, NULL),
(92, 1, 'INCREASE', 90, NULL, NULL, NULL, 1.000, 'Produced from Production Order #19', NULL, 2, '2026-03-11 11:57:22', '2026-03-11 11:57:22', 8, NULL, NULL),
(93, 1, 'DECREASE', 90, NULL, NULL, NULL, 0.002, 'Consumed for Production Order #20', NULL, 2, '2026-03-11 12:07:06', '2026-03-11 12:07:06', 7, NULL, NULL),
(94, 1, 'DECREASE', 90, NULL, NULL, NULL, 0.002, 'Consumed for Production Order #21', NULL, 2, '2026-03-11 12:10:58', '2026-03-11 12:10:58', 7, NULL, NULL),
(95, 1, 'INCREASE', 90, NULL, NULL, NULL, 1.000, 'Produced from Production Order #21', NULL, 2, '2026-03-11 12:11:06', '2026-03-11 12:11:06', 8, NULL, NULL),
(98, 1, 'INCREASE', 101, NULL, NULL, NULL, 1.000, 'SCAN_IN', 'Stock In — 5:55:02 PM', 2, '2026-03-11 12:25:02', '2026-03-11 12:25:02', 8, NULL, NULL),
(99, 1, 'TRANSFER', 105, NULL, 8, 9, 1.000, 'Internal Transfer', NULL, 2, '2026-04-10 10:09:52', '2026-04-10 10:09:52', NULL, 8, 7);

-- --------------------------------------------------------

--
-- Table structure for table `notifications`
--

CREATE TABLE `notifications` (
  `id` int(11) NOT NULL,
  `company_id` int(11) NOT NULL,
  `user_id` int(11) DEFAULT NULL,
  `title` varchar(255) NOT NULL,
  `message` text NOT NULL,
  `type` enum('info','warning','success','error') DEFAULT 'info',
  `priority` enum('low','medium','high') DEFAULT 'medium',
  `is_read` tinyint(1) DEFAULT 0,
  `link` varchar(255) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `notifications`
--

INSERT INTO `notifications` (`id`, `company_id`, `user_id`, `title`, `message`, `type`, `priority`, `is_read`, `link`, `created_at`, `updated_at`) VALUES
(3, 1, NULL, 'Low Stock Alert', 'Product Palm Heights Luxury Villa (6767) is below reorder level. Current: 2.5, Min: 12', 'warning', 'high', 0, '/products?highlight=90', '2026-03-07 11:22:23', '2026-03-07 11:22:23');

-- --------------------------------------------------------

--
-- Table structure for table `order_items`
--

CREATE TABLE `order_items` (
  `id` int(11) NOT NULL,
  `sales_order_id` int(11) NOT NULL,
  `product_id` int(11) NOT NULL,
  `quantity` decimal(12,3) DEFAULT 0.000,
  `unit_price` decimal(12,2) DEFAULT 0.00,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `packing_tasks`
--

CREATE TABLE `packing_tasks` (
  `id` int(11) NOT NULL,
  `sales_order_id` int(11) NOT NULL,
  `pick_list_id` int(11) DEFAULT NULL,
  `assigned_to` int(11) DEFAULT NULL,
  `status` varchar(255) DEFAULT 'NOT_STARTED',
  `packed_at` datetime DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `pick_lists`
--

CREATE TABLE `pick_lists` (
  `id` int(11) NOT NULL,
  `sales_order_id` int(11) NOT NULL,
  `warehouse_id` int(11) NOT NULL,
  `assigned_to` int(11) DEFAULT NULL,
  `status` varchar(255) DEFAULT 'NOT_STARTED',
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `pick_list_items`
--

CREATE TABLE `pick_list_items` (
  `id` int(11) NOT NULL,
  `pick_list_id` int(11) NOT NULL,
  `product_id` int(11) NOT NULL,
  `quantity_required` decimal(12,3) DEFAULT 0.000,
  `quantity_picked` decimal(12,3) DEFAULT 0.000,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `production_formulas`
--

CREATE TABLE `production_formulas` (
  `id` int(11) NOT NULL,
  `company_id` int(11) NOT NULL,
  `product_id` int(11) NOT NULL,
  `name` varchar(255) NOT NULL,
  `description` text DEFAULT NULL,
  `is_default` tinyint(1) DEFAULT 1,
  `status` varchar(255) DEFAULT 'ACTIVE',
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `production_formulas`
--

INSERT INTO `production_formulas` (`id`, `company_id`, `product_id`, `name`, `description`, `is_default`, `status`, `created_at`, `updated_at`) VALUES
(31, 1, 90, 'demo dem,o', NULL, 0, 'ACTIVE', '2026-03-11 11:56:00', '2026-03-11 11:56:00');

-- --------------------------------------------------------

--
-- Table structure for table `production_formula_items`
--

CREATE TABLE `production_formula_items` (
  `id` int(11) NOT NULL,
  `formula_id` int(11) NOT NULL,
  `product_id` int(11) NOT NULL,
  `quantity_per_unit` decimal(12,4) NOT NULL DEFAULT 1.0000,
  `unit` varchar(255) DEFAULT NULL,
  `warehouse_id` int(11) DEFAULT NULL,
  `wastage_percentage` decimal(5,2) DEFAULT 0.00,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `production_formula_items`
--

INSERT INTO `production_formula_items` (`id`, `formula_id`, `product_id`, `quantity_per_unit`, `unit`, `warehouse_id`, `wastage_percentage`, `created_at`, `updated_at`) VALUES
(77, 31, 90, 2.0000, 'g', 7, 0.00, '2026-03-11 11:56:00', '2026-03-11 11:56:00');

-- --------------------------------------------------------

--
-- Table structure for table `production_orders`
--

CREATE TABLE `production_orders` (
  `id` int(11) NOT NULL,
  `company_id` int(11) NOT NULL,
  `product_id` int(11) NOT NULL,
  `warehouse_id` int(11) NOT NULL,
  `quantity_goal` int(11) DEFAULT 0,
  `quantity_produced` int(11) DEFAULT 0,
  `status` varchar(255) DEFAULT 'DRAFT',
  `notes` text DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `formula_id` int(11) DEFAULT NULL,
  `production_area_id` int(11) DEFAULT NULL,
  `target_warehouse_id` int(11) DEFAULT NULL,
  `start_date` datetime DEFAULT NULL,
  `completion_date` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `production_orders`
--

INSERT INTO `production_orders` (`id`, `company_id`, `product_id`, `warehouse_id`, `quantity_goal`, `quantity_produced`, `status`, `notes`, `created_at`, `updated_at`, `formula_id`, `production_area_id`, `target_warehouse_id`, `start_date`, `completion_date`) VALUES
(16, 1, 90, 8, 50, 50, 'COMPLETED', 'opt', '2026-03-07 11:50:56', '2026-03-07 11:52:53', 26, 1, 8, '2026-03-07 11:52:37', '2026-03-07 11:52:53'),
(18, 1, 90, 8, 1, 1, 'COMPLETED', 'opt', '2026-03-11 11:34:25', '2026-03-11 11:35:51', 29, 1, 8, '2026-03-11 11:35:07', '2026-03-11 11:35:51'),
(19, 1, 90, 8, 1, 1, 'COMPLETED', 'opt', '2026-03-11 11:56:19', '2026-03-11 11:57:22', 31, 1, 8, '2026-03-11 11:57:03', '2026-03-11 11:57:22'),
(21, 1, 90, 8, 1, 1, 'COMPLETED', 'opt', '2026-03-11 12:07:33', '2026-03-11 12:11:06', 31, 1, 8, '2026-03-11 12:10:58', '2026-03-11 12:11:06'),
(22, 1, 90, 8, 1, 0, 'VALIDATED', 'opt', '2026-03-11 12:16:17', '2026-03-11 12:16:18', 31, 1, 8, NULL, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `production_order_items`
--

CREATE TABLE `production_order_items` (
  `id` int(11) NOT NULL,
  `production_order_id` int(11) NOT NULL,
  `product_id` int(11) NOT NULL,
  `quantity_required` int(11) DEFAULT 0,
  `quantity_picked` int(11) DEFAULT 0,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `warehouse_id` int(11) DEFAULT NULL,
  `unit` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `production_order_items`
--

INSERT INTO `production_order_items` (`id`, `production_order_id`, `product_id`, `quantity_required`, `quantity_picked`, `created_at`, `updated_at`, `warehouse_id`, `unit`) VALUES
(31, 16, 90, 50, 0, '2026-03-07 11:50:56', '2026-03-07 11:50:56', 7, 'kg'),
(33, 18, 90, 1, 0, '2026-03-11 11:34:25', '2026-03-11 11:34:25', 8, 'g'),
(34, 19, 90, 2, 0, '2026-03-11 11:56:19', '2026-03-11 11:56:19', 7, 'g'),
(36, 21, 90, 2, 0, '2026-03-11 12:07:33', '2026-03-11 12:07:33', 7, 'g'),
(37, 22, 90, 2, 0, '2026-03-11 12:16:17', '2026-03-11 12:16:17', 7, 'g');

-- --------------------------------------------------------

--
-- Table structure for table `products`
--

CREATE TABLE `products` (
  `id` int(11) NOT NULL,
  `company_id` int(11) NOT NULL,
  `category_id` int(11) DEFAULT NULL,
  `name` varchar(255) NOT NULL,
  `sku` varchar(255) NOT NULL,
  `barcode` varchar(255) DEFAULT NULL,
  `price` decimal(12,2) DEFAULT 0.00,
  `reorder_level` int(11) DEFAULT 0,
  `status` varchar(255) DEFAULT 'ACTIVE',
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `description` text DEFAULT NULL,
  `color` varchar(255) DEFAULT NULL,
  `product_type` varchar(255) DEFAULT NULL,
  `unit_of_measure` varchar(255) DEFAULT NULL,
  `cost_price` decimal(12,2) DEFAULT NULL,
  `vat_rate` decimal(5,2) DEFAULT NULL,
  `vat_code` varchar(255) DEFAULT NULL,
  `customs_tariff` varchar(255) DEFAULT NULL,
  `marketplace_skus` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`marketplace_skus`)),
  `heat_sensitive` varchar(255) DEFAULT NULL,
  `perishable` varchar(255) DEFAULT NULL,
  `require_batch_tracking` varchar(255) DEFAULT NULL,
  `shelf_life_days` int(11) DEFAULT NULL,
  `length` decimal(10,2) DEFAULT NULL,
  `width` decimal(10,2) DEFAULT NULL,
  `height` decimal(10,2) DEFAULT NULL,
  `dimension_unit` varchar(255) DEFAULT NULL,
  `weight` decimal(10,3) DEFAULT NULL,
  `weight_unit` varchar(255) DEFAULT NULL,
  `reorder_qty` int(11) DEFAULT NULL,
  `max_stock` int(11) DEFAULT NULL,
  `images` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`images`)),
  `supplier_id` int(11) DEFAULT NULL,
  `cartons` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`cartons`)),
  `price_lists` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`price_lists`)),
  `supplier_products` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`supplier_products`)),
  `alternative_skus` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`alternative_skus`)),
  `currency` varchar(255) DEFAULT 'EUR',
  `pack_size` int(11) DEFAULT 1,
  `best_before_date_warning_period_days` int(11) DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `products`
--

INSERT INTO `products` (`id`, `company_id`, `category_id`, `name`, `sku`, `barcode`, `price`, `reorder_level`, `status`, `created_at`, `updated_at`, `description`, `color`, `product_type`, `unit_of_measure`, `cost_price`, `vat_rate`, `vat_code`, `customs_tariff`, `marketplace_skus`, `heat_sensitive`, `perishable`, `require_batch_tracking`, `shelf_life_days`, `length`, `width`, `height`, `dimension_unit`, `weight`, `weight_unit`, `reorder_qty`, `max_stock`, `images`, `supplier_id`, `cartons`, `price_lists`, `supplier_products`, `alternative_skus`, `currency`, `pack_size`, `best_before_date_warning_period_days`) VALUES
(90, 1, 9, 'Palm Heights Luxury Villa', '6767', '6564546567766', 0.00, 12, 'ACTIVE', '2026-03-06 13:16:05', '2026-03-07 11:13:34', 'opt', 'blue', 'SIMPLE', 'KG', 0.00, 20.00, NULL, NULL, '{\"hdSku\":null,\"hdSaleSku\":null,\"warehouseId\":7,\"ebayId\":null,\"amazonSku\":null,\"amazonSkuSplitBefore\":null,\"amazonMpnSku\":null,\"amazonIdSku\":null}', NULL, NULL, NULL, NULL, 0.00, 0.00, 0.00, 'cm', 0.000, 'kg', 12, 120, '[]', NULL, '[]', '{\"AMAZON\":null,\"EBAY\":null,\"SHOPIFY\":null,\"DIRECT\":0}', '[]', NULL, 'USD', 1, 0),
(98, 1, 9, 'demo dem,o', '676712', '6564546567766', 0.00, 12, 'ACTIVE', '2026-03-07 12:38:20', '2026-03-07 12:38:20', 'opt', 'blue', 'RAW_MATERIAL', 'EACH', 0.00, 20.00, NULL, NULL, '{\"hdSku\":null,\"hdSaleSku\":null,\"warehouseId\":7,\"ebayId\":null,\"amazonSku\":null,\"amazonSkuSplitBefore\":null,\"amazonMpnSku\":null,\"amazonIdSku\":null}', NULL, NULL, NULL, NULL, 0.00, 0.00, 0.00, 'cm', 0.000, 'kg', NULL, 14, '[]', NULL, '[]', NULL, '[]', NULL, 'USD', 1, 0),
(101, 1, NULL, 'demo dem,o233332', '23232323323232', '23233233', 0.00, 0, 'ACTIVE', '2026-03-11 12:24:46', '2026-03-11 12:24:46', NULL, 'blue', 'SIMPLE', 'EACH', 0.00, 20.00, NULL, NULL, '{\"hdSku\":null,\"hdSaleSku\":null,\"warehouseId\":8,\"ebayId\":null,\"amazonSku\":null,\"amazonSkuSplitBefore\":null,\"amazonMpnSku\":null,\"amazonIdSku\":null}', NULL, NULL, NULL, NULL, 0.00, 0.00, 0.00, 'cm', 0.000, 'kg', NULL, NULL, '[]', NULL, '[]', NULL, '[]', NULL, 'USD', 1, 0);
INSERT INTO `products` (`id`, `company_id`, `category_id`, `name`, `sku`, `barcode`, `price`, `reorder_level`, `status`, `created_at`, `updated_at`, `description`, `color`, `product_type`, `unit_of_measure`, `cost_price`, `vat_rate`, `vat_code`, `customs_tariff`, `marketplace_skus`, `heat_sensitive`, `perishable`, `require_batch_tracking`, `shelf_life_days`, `length`, `width`, `height`, `dimension_unit`, `weight`, `weight_unit`, `reorder_qty`, `max_stock`, `images`, `supplier_id`, `cartons`, `price_lists`, `supplier_products`, `alternative_skus`, `currency`, `pack_size`, `best_before_date_warning_period_days`) VALUES
(105, 1, NULL, 'fghfg', 'bff', 'y556', 77777.00, 2, 'ACTIVE', '2026-03-19 07:05:39', '2026-03-19 07:05:39', 'fhgf', 'redf', 'BUNDLE', 'EACH', 6666.00, 20.00, 'jg', 'gggg', '{\"hdSku\":\"hh\",\"hdSaleSku\":\"hhh\",\"warehouseId\":8,\"ebayId\":\"56\",\"amazonSku\":\"5\",\"amazonSkuSplitBefore\":\"5\",\"amazonMpnSku\":\"5\",\"amazonIdSku\":\"6\"}', 'yes', 'yes', 'yes', 2, 0.02, 0.02, 0.06, 'm', 0.001, 'kg', 1, 4, '[\"data:image/png;base64,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a0SH5YC2NcHAjQRIgARIgARIgARIgARIIMYE2DwJkAAJkEBEC0DVMomuLaKFG/ODLd7Io5V4tEELQC4zJEACJEACJEACcUCAXSABEiABEiABEiCBDkzAZwFojGsBCNf34q5vjJvOfNX1AR4P1zeGfKylJlwOHg/XN8ZNj0I+uJEACZBAEwnwNBIgARIgARIgARIgARIgARLoiAR8FoC+d/ohvCUX810u5APR5dWyDG1N+WjmROXpJEACJEACJEACJEACJEACJEACJEAC7Z8ARxhAwGcBqFoda8El2h36Qogcwlo6xlxOwHcAinRyJwESIAESIAESIAESIAESaBABFiIBEiABElACPgtA1faIzquWZRfTXcs/0YqSj4hMrDmgRjrBnQRIgARIgARIgAQaQYBFSYAESIAESIAESKCDE0gA9N1solQR7ZbodgA3boymQzb1mY8QHsYoF8ED9ckHITyMUS4tw0drpSMBEiCBxhJgeRIgARIgARIgARIgARIgARLoqAREAVgjuhvjt/yDEw9+pxvzfZaQ5GPlJZby0YzJWueporPUy1xnGWaSAAmQAAmQAAmQAAmQAAmQAAmQAAnEPYE22cHTp2tarN8Jos1xlR5qsSUNiRbEWgKG+mC+Kr0QysWLg3xahY9wbonZYIxz/U6fPt0S1bNOEiABEiABEiABEiABEiCBVifABkmABEigbRFwdBI1MMZEveP+dwC6lm2qDbTtiBYwyGe+cwFCuXhx8mkdPsI56rPArVAuJU6dPuXG6JEACZAACZAACbQLAhwECZAACZAACZAACbQRAqdOn8bpFrICTAAcyyeItk8VIIyTR5AlH+KPB1pokymA6uqTLVQ7qyUBEoglAbZNAiRAAiRAAiRAAiRAAiRAAvFO4MSJk0hIiL71n45bFICuaaFo/1QBAjBujMAmDyiGeJQHFdwmuDpPMcagU6dOomk/hSNHj4MbCZAACZAACZAACZAACZAACZAACZBAmyTQJjt95OgxnDp10uomjBG9VJRHkaBaHtF1SbXxZ+kV75Zo7F8NWl1+EP1JAHdLSEgQTXsCTp6oxlEqAV0q9EiABEiABEiABEiABEigLRJgn0mABEig7RA4euy46CJOWOWf6iZaouf2HYCOTqUGxohyRbSB6gVafkGSA+PM10vh50U+wTxaVD5Qo421iDPGoHPnzoD4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CgSoAGwFyGyCBEiABEiABEiABEiABEiABEigLgLMIwESIAESaEkCVAC2JF3WTQIkQAIkQAIkQAIk0HACLEkCJEACJEACJEACJNAiBKgAbBGsrJQESIAESKCpBHgeCZAACZAACZAACZAACZAACZBAdAlQARhdnqwtOgRYCwmQAAmQAAmQAAmQAAmQAAmQAAmQQPsnwBG2EgEqAFsJNJshARIgARIgARIgARIgARIgARIIR4BpJEACJEACLU2ACsCWJsz6SYAESIAESIAESIAE6ifAEiRAAiRAAiRAAiRAAi1GgArAFkPLikmABEiABBpLgOVJgARIgARIgARIgARIgARIgASiT4AKwOgzZY3NI8CzSYAESIAESIAESIAESIAESIAESIAE2j8BjrAVCVAB2Iqw2RQJkAAJkAAJkAAJkAAJkAAJkEAgAYZJgARIgARagwAVgK1BmW2QAAmQAAmQAAmQAAlEJsAcEiABEiABEiABEiCBFiVABWCL4mXlJEACJEACDSXAciRAAiRAAiRAAiRAAiRAAiRAAi1DgArAluHKWptGgGeRAAmQAAmQAAmQAAmQAAmQAAmQAAm0fwIcYSsToAKwlYGzORIgARIgARIgARIgARIgARIgASVARwIkQAIk0FoEqABsLdJshwRIgARIgARIgARIoDYBppAACZAACZAACZAACbQ4ASoAWxwxGyABEiABEqiPAPNJgARIgARIgARIgARIgARIgARajgAVgC3HljU3jgBLkwAJkAAJkAAJkAAJkAAJkAAJkAAJtH8CHGEMCPw/AAAA//89tTN7AAAABklEQVQDADKErSe035/XAAAAAElFTkSuQmCC\"]', 4, '[]', NULL, '[]', NULL, 'EUR', 1, 0);
INSERT INTO `products` (`id`, `company_id`, `category_id`, `name`, `sku`, `barcode`, `price`, `reorder_level`, `status`, `created_at`, `updated_at`, `description`, `color`, `product_type`, `unit_of_measure`, `cost_price`, `vat_rate`, `vat_code`, `customs_tariff`, `marketplace_skus`, `heat_sensitive`, `perishable`, `require_batch_tracking`, `shelf_life_days`, `length`, `width`, `height`, `dimension_unit`, `weight`, `weight_unit`, `reorder_qty`, `max_stock`, `images`, `supplier_id`, `cartons`, `price_lists`, `supplier_products`, `alternative_skus`, `currency`, `pack_size`, `best_before_date_warning_period_days`) VALUES
(106, 1, NULL, 'JSON Test Product', 'JSON-SKU-1773909832942', NULL, 0.00, 0, 'ACTIVE', '2026-03-19 08:43:52', '2026-03-19 08:43:52', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '{\"warehouseId\":7}', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'EUR', 1, 0),
(107, 1, 10, 'lap', 'prd001', '5', 0.00, 0, 'ACTIVE', '2026-03-19 09:59:10', '2026-03-19 10:00:39', 'b,', 'redt', 'SIMPLE', 'EACH', 0.00, 20.00, NULL, NULL, '{\"hdSku\":null,\"hdSaleSku\":null,\"warehouseId\":null,\"ebayId\":null,\"amazonSku\":null,\"amazonSkuSplitBefore\":null,\"amazonMpnSku\":null,\"amazonIdSku\":null}', NULL, NULL, NULL, NULL, 0.00, 0.00, 0.00, 'cm', 0.000, 'kg', 0, 0, '[]', 5, '[]', NULL, '[{\"id\":\"sp-1773914439893\",\"supplierId\":5,\"supplierSku\":\"1\",\"caseSize\":1,\"caseCost\":12,\"unitCost\":\"12.0000\"}]', NULL, 'EUR', 1, 0),
(108, 1, NULL, 'table', 'prd003', '534', 234.00, 12, 'ACTIVE', '2026-03-19 10:02:16', '2026-03-19 10:03:28', 'tg', 'blue', 'SIMPLE', 'EACH', 123.00, 20.00, NULL, NULL, '{\"hdSku\":null,\"hdSaleSku\":null,\"warehouseId\":7,\"ebayId\":null,\"amazonSku\":null,\"amazonSkuSplitBefore\":null,\"amazonMpnSku\":null,\"amazonIdSku\":null}', 'yes', 'yes', 'yes', 2, 0.00, 0.00, 0.00, 'cm', 0.000, 'kg', 3, 90, '[]', 5, '[]', '{\"AMAZON\":null,\"EBAY\":null,\"SHOPIFY\":null,\"DIRECT\":234}', '[]', NULL, 'EUR', 1, 0),
(109, 1, 9, 'test 1', 'ss', '1233', 500.00, 5, 'ACTIVE', '2026-03-28 10:48:39', '2026-03-28 10:48:39', 'ssfsf', 'red', 'BUNDLE', 'BOX', 100.00, 20.00, 'sdsfs', 'sds', '{\"hdSku\":\"sdsd\",\"hdSaleSku\":\"sdsd\",\"warehouseId\":9,\"ebayId\":\"sds\",\"amazonSku\":\"sds\",\"amazonSkuSplitBefore\":\"ds\",\"amazonMpnSku\":\"dds\",\"amazonIdSku\":\"dsd\"}', 'yes', 'yes', 'yes', 50, 0.30, 0.40, 1.00, 'm', 11.000, 'kg', 10, 6, '[]', 5, '[]', NULL, '[]', NULL, 'EUR', 1, 0),
(110, 1, 11, 'Sample Product 1', 'SKU-001', '5012345678903', 15.00, 5, 'ACTIVE', '2026-04-10 09:49:18', '2026-04-10 11:05:05', 'Sample description', NULL, 'SIMPLE', 'EACH', 10.00, 20.00, 'A_FOOD', '12', '{\"hdSku\":\"HD_SKU_1\",\"hdSaleSku\":\"HD_SALE_1\",\"warehouseId\":\"WH_001\",\"ebayId\":\"EBAY_001\",\"amazonSku\":\"AMZ_001\",\"amazonSkuSplitBefore\":\"AMZ_B1\",\"amazonMpnSku\":\"AMZ_MPN_1\",\"amazonIdSku\":\"AMZ_ID_1\"}', 'yes', 'yes', 'yes', 365, 30.00, 20.00, 15.00, 'cm', 0.500, 'kg', 10, 100, '[{\"uid\":\"url-1775814557908\",\"url\":\"https://cdn.shopify.com/s/files/example.jpg\",\"name\":\"Imported Image\"}]', 6, '[{\"id\":\"c-0\",\"barcode\":\"CARTON-BAR-001\",\"caseSize\":48,\"description\":\"Case of 48\"}]', '{\"AMAZON\":null,\"EBAY\":null,\"SHOPIFY\":null,\"DIRECT\":15}', '[]', NULL, 'EUR', 1, 28),
(111, 1, 12, 'Sample Product 2', 'SKU-002', '5012345678904', 35.00, 10, 'ACTIVE', '2026-04-10 09:49:18', '2026-04-10 09:49:29', 'Another product', NULL, 'SIMPLE', 'BOX', 25.50, 20.00, 'B_STANDARD', '18', '{\"hdSku\":\"EBAY_002\",\"hdSaleSku\":\"AMZ_002\",\"warehouseId\":\"AMZ_B2\",\"ebayId\":\"AMZ_MPN_2\",\"amazonSku\":\"AMZ_ID_2\",\"amazonSkuSplitBefore\":null,\"amazonMpnSku\":null,\"amazonIdSku\":\"AMAZON\"}', 'no', 'yes', 'yes', 180, 40.00, 25.00, 20.00, 'cm', 1.200, 'kg', 20, 200, '[{\"uid\":\"url-1775814557908\",\"url\":\"HD_SALE_2\",\"name\":\"Imported Image\"}]', 7, '[{\"id\":\"c-0\",\"barcode\":\"CARTON-BAR-002\",\"caseSize\":24,\"description\":\"Box of 24\"}]', '{\"AMAZON\":null,\"EBAY\":null,\"SHOPIFY\":null,\"DIRECT\":35}', '[]', NULL, 'EUR', 1, 0),
(112, 1, 11, 'Third Product', 'SKU-003', '5012345678905', 12.00, 2, 'ACTIVE', '2026-04-10 09:49:18', '2026-04-10 09:49:18', 'Full data example', NULL, 'SIMPLE', 'KG', 5.00, 5.00, 'C_ZERO', '0', '{\"hdSku\":null,\"hdSaleSku\":null,\"warehouseId\":null,\"ebayId\":null,\"amazonSku\":null,\"amazonSkuSplitBefore\":null,\"amazonMpnSku\":null,\"amazonIdSku\":null}', 'no', 'no', 'no', 90, 10.00, 10.00, 10.00, 'cm', 0.250, 'kg', 5, 50, NULL, 6, NULL, NULL, NULL, NULL, 'EUR', 1, 0),
(113, 1, 13, 'ABC Pvt Ltd', '1234', '12345', 30.00, 0, 'ACTIVE', '2026-04-10 11:27:01', '2026-04-10 11:27:01', 'asdfghjkl', NULL, 'BUNDLE', 'BOX', 20.00, 20.00, '124566', NULL, '{\"hdSku\":null,\"hdSaleSku\":null,\"warehouseId\":null,\"ebayId\":null,\"amazonSku\":null,\"amazonSkuSplitBefore\":null,\"amazonMpnSku\":null,\"amazonIdSku\":null}', 'yes', 'yes', 'yes', NULL, 0.00, 0.00, 0.00, 'cm', 0.000, 'kg', 0, 0, '[]', 4, '[]', NULL, '[]', NULL, 'EUR', 1, 28);

-- --------------------------------------------------------

--
-- Table structure for table `product_stocks`
--

CREATE TABLE `product_stocks` (
  `id` int(11) NOT NULL,
  `product_id` int(11) NOT NULL,
  `warehouse_id` int(11) NOT NULL,
  `location_id` int(11) DEFAULT NULL,
  `quantity` decimal(12,3) DEFAULT 0.000,
  `reserved` decimal(12,3) DEFAULT 0.000,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `status` varchar(255) DEFAULT 'ACTIVE',
  `lot_number` varchar(255) DEFAULT NULL,
  `batch_number` varchar(255) DEFAULT NULL,
  `serial_number` varchar(255) DEFAULT NULL,
  `best_before_date` date DEFAULT NULL,
  `batch_id` int(11) DEFAULT NULL,
  `client_id` int(11) DEFAULT NULL,
  `reason` varchar(255) DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `product_stocks`
--

INSERT INTO `product_stocks` (`id`, `product_id`, `warehouse_id`, `location_id`, `quantity`, `reserved`, `created_at`, `updated_at`, `status`, `lot_number`, `batch_number`, `serial_number`, `best_before_date`, `batch_id`, `client_id`, `reason`, `user_id`) VALUES
(69, 90, 7, NULL, 49.994, 0.000, '2026-03-07 11:25:05', '2026-03-11 12:10:58', 'ACTIVE', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(70, 90, 8, NULL, 58.000, 0.000, '2026-03-07 11:26:42', '2026-03-11 12:11:06', 'ACTIVE', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(71, 98, 7, NULL, 19.048, 0.000, '2026-03-07 12:38:20', '2026-03-07 13:36:34', 'ACTIVE', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(73, 101, 8, NULL, 1.000, 0.000, '2026-03-11 12:24:46', '2026-03-11 12:25:02', 'ACTIVE', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(74, 105, 8, 8, 11.000, 0.000, '2026-03-19 09:18:56', '2026-03-19 09:18:56', 'ACTIVE', NULL, '5g', NULL, NULL, NULL, NULL, NULL, NULL),
(75, 106, 8, 8, 4.000, 0.000, '2026-03-23 08:37:44', '2026-03-23 08:38:33', 'ACTIVE', NULL, NULL, NULL, NULL, NULL, 6, 'Manual Stock In', 2),
(76, 105, 8, 8, 0.000, 0.000, '2026-04-10 09:50:03', '2026-04-10 10:09:52', 'ACTIVE', NULL, '1234', NULL, '2026-04-09', NULL, 6, '6757', 2),
(77, 105, 7, 9, 1.000, 0.000, '2026-04-10 10:09:52', '2026-04-10 10:09:52', 'ACTIVE', NULL, '5g', NULL, '2026-04-11', NULL, 6, NULL, NULL),
(78, 101, 8, 8, 1.000, 0.000, '2026-04-10 10:12:23', '2026-04-10 10:12:23', 'ACTIVE', NULL, '3435', NULL, '2026-04-11', NULL, 6, '43422', 2);

-- --------------------------------------------------------

--
-- Table structure for table `purchase_orders`
--

CREATE TABLE `purchase_orders` (
  `id` int(11) NOT NULL,
  `company_id` int(11) NOT NULL,
  `supplier_id` int(11) NOT NULL,
  `po_number` varchar(255) NOT NULL,
  `status` varchar(255) DEFAULT 'pending',
  `total_amount` decimal(12,2) DEFAULT 0.00,
  `expected_delivery` datetime DEFAULT NULL,
  `notes` text DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `warehouse_id` int(11) DEFAULT NULL,
  `client_id` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `purchase_order_items`
--

CREATE TABLE `purchase_order_items` (
  `id` int(11) NOT NULL,
  `purchase_order_id` int(11) NOT NULL,
  `product_id` int(11) NOT NULL,
  `product_name` varchar(255) DEFAULT NULL,
  `product_sku` varchar(255) DEFAULT NULL,
  `quantity` decimal(12,3) DEFAULT 0.000,
  `unit_price` decimal(12,2) DEFAULT 0.00,
  `total_price` decimal(12,2) DEFAULT 0.00,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `replenishment_configs`
--

CREATE TABLE `replenishment_configs` (
  `id` int(11) NOT NULL,
  `company_id` int(11) NOT NULL,
  `product_id` int(11) NOT NULL,
  `min_stock_level` int(11) NOT NULL DEFAULT 0,
  `max_stock_level` int(11) NOT NULL DEFAULT 0,
  `reorder_point` int(11) NOT NULL DEFAULT 0,
  `reorder_quantity` int(11) NOT NULL DEFAULT 0,
  `auto_create_tasks` tinyint(1) NOT NULL DEFAULT 1,
  `status` varchar(255) DEFAULT 'ACTIVE',
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `replenishment_tasks`
--

CREATE TABLE `replenishment_tasks` (
  `id` int(11) NOT NULL,
  `company_id` int(11) NOT NULL,
  `product_id` int(11) NOT NULL,
  `from_location_id` int(11) NOT NULL,
  `to_location_id` int(11) NOT NULL,
  `task_number` varchar(255) NOT NULL,
  `quantity_needed` int(11) NOT NULL DEFAULT 0,
  `quantity_completed` int(11) NOT NULL DEFAULT 0,
  `priority` varchar(255) DEFAULT 'MEDIUM',
  `notes` text DEFAULT NULL,
  `status` varchar(255) DEFAULT 'PENDING',
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `reports`
--

CREATE TABLE `reports` (
  `id` int(11) NOT NULL,
  `company_id` int(11) NOT NULL,
  `report_name` varchar(255) NOT NULL,
  `report_type` varchar(255) NOT NULL,
  `category` varchar(255) DEFAULT NULL,
  `start_date` date DEFAULT NULL,
  `end_date` date DEFAULT NULL,
  `format` varchar(255) DEFAULT 'PDF',
  `schedule` varchar(255) DEFAULT 'ONCE',
  `status` varchar(255) DEFAULT 'COMPLETED',
  `last_run_at` datetime DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `returns`
--

CREATE TABLE `returns` (
  `id` int(11) NOT NULL,
  `company_id` int(11) NOT NULL,
  `rma_number` varchar(255) NOT NULL,
  `sales_order_id` int(11) NOT NULL,
  `shipment_id` int(11) NOT NULL,
  `customer_id` int(11) DEFAULT NULL,
  `status` varchar(255) DEFAULT 'RMA_CREATED',
  `return_type` varchar(255) NOT NULL,
  `reason` varchar(255) NOT NULL,
  `recovery_value` decimal(10,2) DEFAULT 0.00,
  `refund_amount` decimal(10,2) DEFAULT 0.00,
  `notes` text DEFAULT NULL,
  `received_at` datetime DEFAULT NULL,
  `inspected_at` datetime DEFAULT NULL,
  `completed_at` datetime DEFAULT NULL,
  `created_by` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `sales_orders`
--

CREATE TABLE `sales_orders` (
  `id` int(11) NOT NULL,
  `company_id` int(11) NOT NULL,
  `order_number` varchar(255) NOT NULL,
  `customer_id` int(11) DEFAULT NULL,
  `status` varchar(255) DEFAULT 'DRAFT',
  `total_amount` decimal(12,2) DEFAULT 0.00,
  `created_by` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `order_date` date DEFAULT NULL,
  `required_date` date DEFAULT NULL,
  `priority` varchar(255) DEFAULT 'MEDIUM',
  `sales_channel` varchar(255) DEFAULT 'DIRECT',
  `order_type` varchar(255) DEFAULT NULL,
  `reference_number` varchar(255) DEFAULT NULL,
  `notes` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `shipments`
--

CREATE TABLE `shipments` (
  `id` int(11) NOT NULL,
  `sales_order_id` int(11) NOT NULL,
  `company_id` int(11) NOT NULL,
  `packed_by` int(11) DEFAULT NULL,
  `courier_name` varchar(255) DEFAULT NULL,
  `tracking_number` varchar(255) DEFAULT NULL,
  `weight` decimal(10,2) DEFAULT NULL,
  `dispatch_date` date DEFAULT NULL,
  `delivery_status` varchar(255) DEFAULT 'READY_TO_SHIP',
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `stock_deducted` tinyint(1) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `suppliers`
--

CREATE TABLE `suppliers` (
  `id` int(11) NOT NULL,
  `company_id` int(11) NOT NULL,
  `code` varchar(255) NOT NULL,
  `name` varchar(255) NOT NULL,
  `email` varchar(255) DEFAULT NULL,
  `phone` varchar(255) DEFAULT NULL,
  `address` text DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `suppliers`
--

INSERT INTO `suppliers` (`id`, `company_id`, `code`, `name`, `email`, `phone`, `address`, `created_at`, `updated_at`) VALUES
(4, 1, 'zn-2', 'sumit', 'sumit@gmail.com', '3212345612', 'jabalpur', '2026-03-18 09:42:18', '2026-03-18 09:42:18'),
(5, 1, '001s', 'ssss', 's@gmail.com', '3212345612', 's', '2026-03-19 09:54:19', '2026-03-19 09:54:19'),
(6, 1, '1', '1', NULL, NULL, NULL, '2026-04-10 09:49:18', '2026-04-10 09:49:18'),
(7, 1, '2', '2', NULL, NULL, NULL, '2026-04-10 09:49:18', '2026-04-10 09:49:18');

-- --------------------------------------------------------

--
-- Table structure for table `supplier_products`
--

CREATE TABLE `supplier_products` (
  `id` int(11) NOT NULL,
  `company_id` int(11) NOT NULL,
  `supplier_id` int(11) NOT NULL,
  `product_id` int(11) NOT NULL,
  `supplier_sku` varchar(255) DEFAULT NULL,
  `supplier_product_name` varchar(255) DEFAULT NULL,
  `pack_size` int(11) DEFAULT 1,
  `cost_price` decimal(10,2) DEFAULT 0.00,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `id` int(11) NOT NULL,
  `email` varchar(255) NOT NULL,
  `password_hash` varchar(255) NOT NULL,
  `name` varchar(255) NOT NULL,
  `role` varchar(255) NOT NULL,
  `company_id` int(11) DEFAULT NULL,
  `warehouse_id` int(11) DEFAULT NULL,
  `status` varchar(255) DEFAULT 'ACTIVE',
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`id`, `email`, `password_hash`, `name`, `role`, `company_id`, `warehouse_id`, `status`, `created_at`, `updated_at`) VALUES
(1, 'admin@kiaan-wms.com', '$2a$10$zp9P4AQJkoZYTNgaKUisrO7BtUYHOq0HKkY7qqFJVsI/TwB.vUQvC', 'Super Administrator', 'super_admin', NULL, NULL, 'ACTIVE', '2026-01-28 17:03:36', '2026-01-28 17:03:36'),
(2, 'companyadmin@kiaan-wms.com', '$2a$10$yr4OsrOJNog3T1pquW9bbemISOFMVe05APIoYhzNlHbZorVndG8iG', 'company', 'company_admin', 1, NULL, 'ACTIVE', '2026-01-28 11:43:48', '2026-01-29 05:56:26'),
(5, 'inventorymanager@kiaan-wms.com', '$2a$10$Apx7xoWN5j6GnyXD7C/NSOFy/CdXCAHfZ8gpBRPJdvALpdXBqP/5W', 'inventory manager', 'inventory_manager', 1, NULL, 'ACTIVE', '2026-01-29 05:48:45', '2026-01-29 05:56:39'),
(6, 'warehousemanager@kiaan-wms.com', '$2a$10$SWJ1eXW31/55yE0D0Y7E1uwrMSq4R5Qy0EcdIArePi5SbbRfaw5SW', 'warehouse manager 1', 'warehouse_manager', 1, NULL, 'ACTIVE', '2026-01-29 05:49:21', '2026-01-30 07:28:58'),
(14, 'piker@gmail.com', '$2a$10$lPS6kFTeXH5YmLWLI.as3u4.xCLmVvEWucJE8sAtpX0ODaGppkPv2', 'piker', 'picker', 1, 7, 'ACTIVE', '2026-03-19 06:19:35', '2026-03-19 06:19:35'),
(15, 'packer@gmail.com', '$2a$10$Kv1p7WNJ2BXqT.buBp/uj./yuc/MsazHvv4jM3XAfa6S3cgjCp3Su', 'packer', 'packer', 1, 7, 'ACTIVE', '2026-03-19 06:20:09', '2026-03-19 06:20:09'),
(16, 'picker@kiaan-wms.com', '$2a$10$5krFuN5o2dpejk/Z/NcTmuCGUcdOLOcMDD2X0.ud4.ob1CU.GXBci', 'Picker User', 'picker', 8, 13, 'ACTIVE', '2026-04-10 11:28:26', '2026-04-10 11:28:26'),
(17, 'packer@kiaan-wms.com', '$2a$10$HASW.sw3ugcA615n8tDRv.X8xUhPZo96CXDdedpdaGVaaNydsPNGG', 'Packer User', 'packer', 8, 13, 'ACTIVE', '2026-04-10 11:28:27', '2026-04-10 11:28:27'),
(18, 'viewer@kiaan-wms.com', '$2a$10$yABfwjGn2gz3/RlwUuFJMesy/In8rCkr84F.yvUwrpXPiQON1j8km', 'Viewer User', 'viewer', 8, 13, 'ACTIVE', '2026-04-10 11:28:27', '2026-04-10 11:28:27');

-- --------------------------------------------------------

--
-- Table structure for table `vat_codes`
--

CREATE TABLE `vat_codes` (
  `id` int(11) NOT NULL,
  `company_id` int(11) DEFAULT NULL,
  `code` varchar(255) NOT NULL,
  `label` varchar(255) DEFAULT NULL,
  `rate_percent` decimal(5,2) NOT NULL DEFAULT 0.00,
  `country_code` varchar(10) DEFAULT 'UK',
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `warehouses`
--

CREATE TABLE `warehouses` (
  `id` int(11) NOT NULL,
  `company_id` int(11) NOT NULL,
  `name` varchar(255) NOT NULL,
  `code` varchar(255) NOT NULL,
  `warehouse_type` varchar(255) DEFAULT NULL,
  `address` text DEFAULT NULL,
  `phone` varchar(255) DEFAULT NULL,
  `capacity` int(11) DEFAULT NULL,
  `status` varchar(255) DEFAULT 'ACTIVE',
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `warehouses`
--

INSERT INTO `warehouses` (`id`, `company_id`, `name`, `code`, `warehouse_type`, `address`, `phone`, `capacity`, `status`, `created_at`, `updated_at`) VALUES
(7, 1, 'a', '3434343', 'MAIN', 'demo', '04545454555', 999999, 'ACTIVE', '2026-03-06 13:15:20', '2026-03-07 10:31:58'),
(8, 1, 'b', '343434312', 'MAIN', 'demo\ndemo', '123456789', NULL, 'ACTIVE', '2026-03-07 10:00:46', '2026-03-07 10:00:46'),
(9, 1, 'FFD Warehouse', 'FFD-WH-01', 'INTERNAL', 'ljlkj', '2222222222', 20, 'ACTIVE', '2026-03-23 09:31:23', '2026-03-23 10:20:53'),
(10, 1, '3PL Warehouse', '3PL-WH-01', 'THIRD_PARTY', NULL, NULL, NULL, 'ACTIVE', '2026-03-23 09:31:23', '2026-03-23 09:31:23'),
(11, 1, 'Amazon Prep Warehouse', 'AMZ-PREP-01', 'INTERNAL', NULL, NULL, NULL, 'ACTIVE', '2026-03-23 09:31:23', '2026-03-23 09:31:23'),
(12, 1, 'ABC Pvt Ltd', 'Auto-generated', 'STANDARD', '44 slama ', '9876543210', 100, 'ACTIVE', '2026-04-10 11:24:09', '2026-04-10 11:24:09'),
(13, 8, 'London Hub', 'LDN-001', NULL, '123 Warehouse St, London', NULL, NULL, 'ACTIVE', '2026-04-10 11:28:26', '2026-04-10 11:28:26');

-- --------------------------------------------------------

--
-- Table structure for table `zones`
--

CREATE TABLE `zones` (
  `id` int(11) NOT NULL,
  `warehouse_id` int(11) NOT NULL,
  `name` varchar(255) NOT NULL,
  `code` varchar(255) DEFAULT NULL,
  `zone_type` varchar(255) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `company_id` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `zones`
--

INSERT INTO `zones` (`id`, `warehouse_id`, `name`, `code`, `zone_type`, `created_at`, `updated_at`, `company_id`) VALUES
(6, 8, 'k', 'zn-1', 'FROZEN', '2026-03-18 09:38:46', '2026-03-18 09:38:46', NULL),
(7, 7, 'new', 'zn-2', 'STANDARD', '2026-03-19 07:26:31', '2026-03-19 07:26:31', NULL),
(8, 8, 'ABC Pvt Ltd', 'abc', 'STANDARD', '2026-04-10 10:18:40', '2026-04-10 10:18:40', 1),
(9, 8, 'asdfg', 'Auto-generated', 'FROZEN', '2026-04-10 11:10:29', '2026-04-10 11:10:29', 1),
(10, 12, 'ABC Pvt Ltd', 'Auto-generated', 'COLD', '2026-04-10 11:24:27', '2026-04-10 11:24:27', 1);

--
-- Indexes for dumped tables
--

--
-- Indexes for table `batches`
--
ALTER TABLE `batches`
  ADD PRIMARY KEY (`id`),
  ADD KEY `company_id` (`company_id`),
  ADD KEY `product_id` (`product_id`),
  ADD KEY `warehouse_id` (`warehouse_id`),
  ADD KEY `location_id` (`location_id`),
  ADD KEY `supplier_id` (`supplier_id`);

--
-- Indexes for table `bundles`
--
ALTER TABLE `bundles`
  ADD PRIMARY KEY (`id`),
  ADD KEY `bundles_company_id` (`company_id`);

--
-- Indexes for table `bundle_items`
--
ALTER TABLE `bundle_items`
  ADD PRIMARY KEY (`id`),
  ADD KEY `bundle_items_bundle_id` (`bundle_id`),
  ADD KEY `bundle_items_product_id` (`product_id`);

--
-- Indexes for table `categories`
--
ALTER TABLE `categories`
  ADD PRIMARY KEY (`id`),
  ADD KEY `categories_company_id` (`company_id`);

--
-- Indexes for table `companies`
--
ALTER TABLE `companies`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `companies_code` (`code`);

--
-- Indexes for table `customers`
--
ALTER TABLE `customers`
  ADD PRIMARY KEY (`id`),
  ADD KEY `customers_company_id` (`company_id`);

--
-- Indexes for table `cycle_counts`
--
ALTER TABLE `cycle_counts`
  ADD PRIMARY KEY (`id`),
  ADD KEY `company_id` (`company_id`),
  ADD KEY `location_id` (`location_id`),
  ADD KEY `counted_by` (`counted_by`);

--
-- Indexes for table `goods_receipts`
--
ALTER TABLE `goods_receipts`
  ADD PRIMARY KEY (`id`),
  ADD KEY `company_id` (`company_id`),
  ADD KEY `purchase_order_id` (`purchase_order_id`);

--
-- Indexes for table `goods_receipt_items`
--
ALTER TABLE `goods_receipt_items`
  ADD PRIMARY KEY (`id`),
  ADD KEY `goods_receipt_id` (`goods_receipt_id`),
  ADD KEY `product_id` (`product_id`);

--
-- Indexes for table `inventory`
--
ALTER TABLE `inventory`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `inventory_warehouse_id_product_id` (`warehouse_id`,`product_id`),
  ADD KEY `product_id` (`product_id`);

--
-- Indexes for table `inventory_adjustments`
--
ALTER TABLE `inventory_adjustments`
  ADD PRIMARY KEY (`id`),
  ADD KEY `company_id` (`company_id`),
  ADD KEY `product_id` (`product_id`),
  ADD KEY `warehouse_id` (`warehouse_id`),
  ADD KEY `created_by` (`created_by`);

--
-- Indexes for table `inventory_logs`
--
ALTER TABLE `inventory_logs`
  ADD PRIMARY KEY (`id`),
  ADD KEY `product_id` (`product_id`),
  ADD KEY `warehouse_id` (`warehouse_id`);

--
-- Indexes for table `locations`
--
ALTER TABLE `locations`
  ADD PRIMARY KEY (`id`),
  ADD KEY `locations_zone_id` (`zone_id`);

--
-- Indexes for table `movements`
--
ALTER TABLE `movements`
  ADD PRIMARY KEY (`id`),
  ADD KEY `company_id` (`company_id`),
  ADD KEY `product_id` (`product_id`),
  ADD KEY `batch_id` (`batch_id`),
  ADD KEY `from_location_id` (`from_location_id`),
  ADD KEY `to_location_id` (`to_location_id`),
  ADD KEY `created_by` (`created_by`);

--
-- Indexes for table `notifications`
--
ALTER TABLE `notifications`
  ADD PRIMARY KEY (`id`),
  ADD KEY `company_id` (`company_id`),
  ADD KEY `user_id` (`user_id`);

--
-- Indexes for table `order_items`
--
ALTER TABLE `order_items`
  ADD PRIMARY KEY (`id`),
  ADD KEY `order_items_sales_order_id` (`sales_order_id`),
  ADD KEY `order_items_product_id` (`product_id`);

--
-- Indexes for table `packing_tasks`
--
ALTER TABLE `packing_tasks`
  ADD PRIMARY KEY (`id`),
  ADD KEY `packing_tasks_sales_order_id` (`sales_order_id`),
  ADD KEY `packing_tasks_pick_list_id` (`pick_list_id`),
  ADD KEY `packing_tasks_assigned_to` (`assigned_to`);

--
-- Indexes for table `pick_lists`
--
ALTER TABLE `pick_lists`
  ADD PRIMARY KEY (`id`),
  ADD KEY `pick_lists_sales_order_id` (`sales_order_id`),
  ADD KEY `pick_lists_warehouse_id` (`warehouse_id`),
  ADD KEY `pick_lists_assigned_to` (`assigned_to`);

--
-- Indexes for table `pick_list_items`
--
ALTER TABLE `pick_list_items`
  ADD PRIMARY KEY (`id`),
  ADD KEY `pick_list_items_pick_list_id` (`pick_list_id`),
  ADD KEY `pick_list_items_product_id` (`product_id`);

--
-- Indexes for table `production_formulas`
--
ALTER TABLE `production_formulas`
  ADD PRIMARY KEY (`id`),
  ADD KEY `product_id` (`product_id`);

--
-- Indexes for table `production_formula_items`
--
ALTER TABLE `production_formula_items`
  ADD PRIMARY KEY (`id`),
  ADD KEY `formula_id` (`formula_id`),
  ADD KEY `product_id` (`product_id`);

--
-- Indexes for table `production_orders`
--
ALTER TABLE `production_orders`
  ADD PRIMARY KEY (`id`),
  ADD KEY `company_id` (`company_id`),
  ADD KEY `product_id` (`product_id`),
  ADD KEY `warehouse_id` (`warehouse_id`);

--
-- Indexes for table `production_order_items`
--
ALTER TABLE `production_order_items`
  ADD PRIMARY KEY (`id`),
  ADD KEY `production_order_id` (`production_order_id`),
  ADD KEY `product_id` (`product_id`);

--
-- Indexes for table `products`
--
ALTER TABLE `products`
  ADD PRIMARY KEY (`id`),
  ADD KEY `products_company_id` (`company_id`),
  ADD KEY `products_category_id` (`category_id`),
  ADD KEY `supplier_id` (`supplier_id`);

--
-- Indexes for table `product_stocks`
--
ALTER TABLE `product_stocks`
  ADD PRIMARY KEY (`id`),
  ADD KEY `product_stocks_product_id` (`product_id`),
  ADD KEY `product_stocks_warehouse_id` (`warehouse_id`),
  ADD KEY `product_stocks_location_id` (`location_id`);

--
-- Indexes for table `purchase_orders`
--
ALTER TABLE `purchase_orders`
  ADD PRIMARY KEY (`id`),
  ADD KEY `company_id` (`company_id`),
  ADD KEY `supplier_id` (`supplier_id`);

--
-- Indexes for table `purchase_order_items`
--
ALTER TABLE `purchase_order_items`
  ADD PRIMARY KEY (`id`),
  ADD KEY `purchase_order_id` (`purchase_order_id`),
  ADD KEY `product_id` (`product_id`);

--
-- Indexes for table `replenishment_configs`
--
ALTER TABLE `replenishment_configs`
  ADD PRIMARY KEY (`id`),
  ADD KEY `company_id` (`company_id`),
  ADD KEY `product_id` (`product_id`);

--
-- Indexes for table `replenishment_tasks`
--
ALTER TABLE `replenishment_tasks`
  ADD PRIMARY KEY (`id`),
  ADD KEY `company_id` (`company_id`),
  ADD KEY `product_id` (`product_id`),
  ADD KEY `from_location_id` (`from_location_id`),
  ADD KEY `to_location_id` (`to_location_id`);

--
-- Indexes for table `reports`
--
ALTER TABLE `reports`
  ADD PRIMARY KEY (`id`),
  ADD KEY `company_id` (`company_id`);

--
-- Indexes for table `returns`
--
ALTER TABLE `returns`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `rma_number` (`rma_number`),
  ADD UNIQUE KEY `rma_number_2` (`rma_number`),
  ADD UNIQUE KEY `rma_number_3` (`rma_number`),
  ADD UNIQUE KEY `rma_number_4` (`rma_number`),
  ADD UNIQUE KEY `rma_number_5` (`rma_number`),
  ADD UNIQUE KEY `rma_number_6` (`rma_number`),
  ADD UNIQUE KEY `rma_number_7` (`rma_number`),
  ADD UNIQUE KEY `rma_number_8` (`rma_number`),
  ADD UNIQUE KEY `rma_number_9` (`rma_number`),
  ADD UNIQUE KEY `rma_number_10` (`rma_number`),
  ADD UNIQUE KEY `rma_number_11` (`rma_number`),
  ADD UNIQUE KEY `rma_number_12` (`rma_number`),
  ADD UNIQUE KEY `rma_number_13` (`rma_number`),
  ADD UNIQUE KEY `rma_number_14` (`rma_number`),
  ADD UNIQUE KEY `rma_number_15` (`rma_number`),
  ADD UNIQUE KEY `rma_number_16` (`rma_number`),
  ADD UNIQUE KEY `rma_number_17` (`rma_number`),
  ADD UNIQUE KEY `rma_number_18` (`rma_number`),
  ADD UNIQUE KEY `rma_number_19` (`rma_number`),
  ADD UNIQUE KEY `rma_number_20` (`rma_number`),
  ADD UNIQUE KEY `rma_number_21` (`rma_number`),
  ADD UNIQUE KEY `rma_number_22` (`rma_number`),
  ADD UNIQUE KEY `rma_number_23` (`rma_number`),
  ADD UNIQUE KEY `rma_number_24` (`rma_number`),
  ADD UNIQUE KEY `rma_number_25` (`rma_number`),
  ADD UNIQUE KEY `rma_number_26` (`rma_number`),
  ADD UNIQUE KEY `rma_number_27` (`rma_number`),
  ADD UNIQUE KEY `rma_number_28` (`rma_number`),
  ADD UNIQUE KEY `rma_number_29` (`rma_number`),
  ADD KEY `company_id` (`company_id`),
  ADD KEY `sales_order_id` (`sales_order_id`),
  ADD KEY `shipment_id` (`shipment_id`),
  ADD KEY `customer_id` (`customer_id`);

--
-- Indexes for table `sales_orders`
--
ALTER TABLE `sales_orders`
  ADD PRIMARY KEY (`id`),
  ADD KEY `sales_orders_company_id` (`company_id`),
  ADD KEY `sales_orders_customer_id` (`customer_id`),
  ADD KEY `sales_orders_created_by` (`created_by`);

--
-- Indexes for table `shipments`
--
ALTER TABLE `shipments`
  ADD PRIMARY KEY (`id`),
  ADD KEY `shipments_sales_order_id` (`sales_order_id`),
  ADD KEY `shipments_company_id` (`company_id`),
  ADD KEY `shipments_packed_by` (`packed_by`);

--
-- Indexes for table `suppliers`
--
ALTER TABLE `suppliers`
  ADD PRIMARY KEY (`id`),
  ADD KEY `suppliers_company_id` (`company_id`);

--
-- Indexes for table `supplier_products`
--
ALTER TABLE `supplier_products`
  ADD PRIMARY KEY (`id`),
  ADD KEY `company_id` (`company_id`),
  ADD KEY `supplier_id` (`supplier_id`),
  ADD KEY `product_id` (`product_id`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `users_email` (`email`),
  ADD UNIQUE KEY `email` (`email`),
  ADD UNIQUE KEY `email_2` (`email`),
  ADD UNIQUE KEY `email_3` (`email`),
  ADD UNIQUE KEY `email_4` (`email`),
  ADD UNIQUE KEY `email_5` (`email`),
  ADD UNIQUE KEY `email_6` (`email`),
  ADD UNIQUE KEY `email_7` (`email`),
  ADD UNIQUE KEY `email_8` (`email`),
  ADD UNIQUE KEY `email_9` (`email`),
  ADD UNIQUE KEY `email_10` (`email`),
  ADD UNIQUE KEY `email_11` (`email`),
  ADD UNIQUE KEY `email_12` (`email`),
  ADD UNIQUE KEY `email_13` (`email`),
  ADD UNIQUE KEY `email_14` (`email`),
  ADD UNIQUE KEY `email_15` (`email`),
  ADD UNIQUE KEY `email_16` (`email`),
  ADD UNIQUE KEY `email_17` (`email`),
  ADD UNIQUE KEY `email_18` (`email`),
  ADD UNIQUE KEY `email_19` (`email`),
  ADD UNIQUE KEY `email_20` (`email`),
  ADD UNIQUE KEY `email_21` (`email`),
  ADD UNIQUE KEY `email_22` (`email`),
  ADD UNIQUE KEY `email_23` (`email`),
  ADD UNIQUE KEY `email_24` (`email`),
  ADD UNIQUE KEY `email_25` (`email`),
  ADD UNIQUE KEY `email_26` (`email`),
  ADD UNIQUE KEY `email_27` (`email`),
  ADD UNIQUE KEY `email_28` (`email`),
  ADD UNIQUE KEY `email_29` (`email`),
  ADD UNIQUE KEY `email_30` (`email`),
  ADD UNIQUE KEY `email_31` (`email`),
  ADD UNIQUE KEY `email_32` (`email`),
  ADD UNIQUE KEY `email_33` (`email`),
  ADD UNIQUE KEY `email_34` (`email`),
  ADD UNIQUE KEY `email_35` (`email`),
  ADD UNIQUE KEY `email_36` (`email`),
  ADD UNIQUE KEY `email_37` (`email`),
  ADD UNIQUE KEY `email_38` (`email`),
  ADD UNIQUE KEY `email_39` (`email`),
  ADD UNIQUE KEY `email_40` (`email`),
  ADD UNIQUE KEY `email_41` (`email`),
  ADD UNIQUE KEY `email_42` (`email`),
  ADD UNIQUE KEY `email_43` (`email`),
  ADD UNIQUE KEY `email_44` (`email`),
  ADD UNIQUE KEY `email_45` (`email`),
  ADD UNIQUE KEY `email_46` (`email`),
  ADD UNIQUE KEY `email_47` (`email`),
  ADD UNIQUE KEY `email_48` (`email`),
  ADD UNIQUE KEY `email_49` (`email`),
  ADD UNIQUE KEY `email_50` (`email`),
  ADD UNIQUE KEY `email_51` (`email`),
  ADD UNIQUE KEY `email_52` (`email`),
  ADD UNIQUE KEY `email_53` (`email`),
  ADD UNIQUE KEY `email_54` (`email`),
  ADD UNIQUE KEY `email_55` (`email`),
  ADD UNIQUE KEY `email_56` (`email`),
  ADD UNIQUE KEY `email_57` (`email`),
  ADD UNIQUE KEY `email_58` (`email`),
  ADD UNIQUE KEY `email_59` (`email`),
  ADD UNIQUE KEY `email_60` (`email`),
  ADD KEY `users_company_id` (`company_id`),
  ADD KEY `users_warehouse_id` (`warehouse_id`);

--
-- Indexes for table `vat_codes`
--
ALTER TABLE `vat_codes`
  ADD PRIMARY KEY (`id`),
  ADD KEY `company_id` (`company_id`);

--
-- Indexes for table `warehouses`
--
ALTER TABLE `warehouses`
  ADD PRIMARY KEY (`id`),
  ADD KEY `warehouses_company_id` (`company_id`);

--
-- Indexes for table `zones`
--
ALTER TABLE `zones`
  ADD PRIMARY KEY (`id`),
  ADD KEY `zones_warehouse_id` (`warehouse_id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `batches`
--
ALTER TABLE `batches`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `bundles`
--
ALTER TABLE `bundles`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `bundle_items`
--
ALTER TABLE `bundle_items`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `categories`
--
ALTER TABLE `categories`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=14;

--
-- AUTO_INCREMENT for table `companies`
--
ALTER TABLE `companies`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT for table `customers`
--
ALTER TABLE `customers`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT for table `cycle_counts`
--
ALTER TABLE `cycle_counts`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `goods_receipts`
--
ALTER TABLE `goods_receipts`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=13;

--
-- AUTO_INCREMENT for table `goods_receipt_items`
--
ALTER TABLE `goods_receipt_items`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=13;

--
-- AUTO_INCREMENT for table `inventory`
--
ALTER TABLE `inventory`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `inventory_adjustments`
--
ALTER TABLE `inventory_adjustments`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=118;

--
-- AUTO_INCREMENT for table `inventory_logs`
--
ALTER TABLE `inventory_logs`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT for table `locations`
--
ALTER TABLE `locations`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=12;

--
-- AUTO_INCREMENT for table `movements`
--
ALTER TABLE `movements`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=100;

--
-- AUTO_INCREMENT for table `notifications`
--
ALTER TABLE `notifications`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `order_items`
--
ALTER TABLE `order_items`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;

--
-- AUTO_INCREMENT for table `packing_tasks`
--
ALTER TABLE `packing_tasks`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;

--
-- AUTO_INCREMENT for table `pick_lists`
--
ALTER TABLE `pick_lists`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;

--
-- AUTO_INCREMENT for table `pick_list_items`
--
ALTER TABLE `pick_list_items`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;

--
-- AUTO_INCREMENT for table `production_formulas`
--
ALTER TABLE `production_formulas`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=32;

--
-- AUTO_INCREMENT for table `production_formula_items`
--
ALTER TABLE `production_formula_items`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=78;

--
-- AUTO_INCREMENT for table `production_orders`
--
ALTER TABLE `production_orders`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=23;

--
-- AUTO_INCREMENT for table `production_order_items`
--
ALTER TABLE `production_order_items`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=38;

--
-- AUTO_INCREMENT for table `products`
--
ALTER TABLE `products`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=114;

--
-- AUTO_INCREMENT for table `product_stocks`
--
ALTER TABLE `product_stocks`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=79;

--
-- AUTO_INCREMENT for table `purchase_orders`
--
ALTER TABLE `purchase_orders`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;

--
-- AUTO_INCREMENT for table `purchase_order_items`
--
ALTER TABLE `purchase_order_items`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;

--
-- AUTO_INCREMENT for table `replenishment_configs`
--
ALTER TABLE `replenishment_configs`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `replenishment_tasks`
--
ALTER TABLE `replenishment_tasks`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `reports`
--
ALTER TABLE `reports`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `returns`
--
ALTER TABLE `returns`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `sales_orders`
--
ALTER TABLE `sales_orders`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;

--
-- AUTO_INCREMENT for table `shipments`
--
ALTER TABLE `shipments`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;

--
-- AUTO_INCREMENT for table `suppliers`
--
ALTER TABLE `suppliers`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT for table `supplier_products`
--
ALTER TABLE `supplier_products`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=19;

--
-- AUTO_INCREMENT for table `vat_codes`
--
ALTER TABLE `vat_codes`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `warehouses`
--
ALTER TABLE `warehouses`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=14;

--
-- AUTO_INCREMENT for table `zones`
--
ALTER TABLE `zones`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `batches`
--
ALTER TABLE `batches`
  ADD CONSTRAINT `batches_ibfk_166` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `batches_ibfk_167` FOREIGN KEY (`warehouse_id`) REFERENCES `warehouses` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `batches_ibfk_168` FOREIGN KEY (`location_id`) REFERENCES `locations` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  ADD CONSTRAINT `batches_ibfk_169` FOREIGN KEY (`supplier_id`) REFERENCES `suppliers` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  ADD CONSTRAINT `batches_ibfk_61` FOREIGN KEY (`company_id`) REFERENCES `companies` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `bundles`
--
ALTER TABLE `bundles`
  ADD CONSTRAINT `bundles_ibfk_1` FOREIGN KEY (`company_id`) REFERENCES `companies` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `bundle_items`
--
ALTER TABLE `bundle_items`
  ADD CONSTRAINT `bundle_items_ibfk_113` FOREIGN KEY (`bundle_id`) REFERENCES `bundles` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `bundle_items_ibfk_114` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE NO ACTION ON UPDATE CASCADE;

--
-- Constraints for table `categories`
--
ALTER TABLE `categories`
  ADD CONSTRAINT `categories_ibfk_1` FOREIGN KEY (`company_id`) REFERENCES `companies` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `customers`
--
ALTER TABLE `customers`
  ADD CONSTRAINT `customers_ibfk_1` FOREIGN KEY (`company_id`) REFERENCES `companies` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `cycle_counts`
--
ALTER TABLE `cycle_counts`
  ADD CONSTRAINT `cycle_counts_ibfk_40` FOREIGN KEY (`company_id`) REFERENCES `companies` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `cycle_counts_ibfk_93` FOREIGN KEY (`location_id`) REFERENCES `locations` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  ADD CONSTRAINT `cycle_counts_ibfk_94` FOREIGN KEY (`counted_by`) REFERENCES `users` (`id`) ON DELETE SET NULL ON UPDATE CASCADE;

--
-- Constraints for table `goods_receipts`
--
ALTER TABLE `goods_receipts`
  ADD CONSTRAINT `goods_receipts_ibfk_109` FOREIGN KEY (`company_id`) REFERENCES `companies` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `goods_receipts_ibfk_110` FOREIGN KEY (`purchase_order_id`) REFERENCES `purchase_orders` (`id`) ON DELETE NO ACTION ON UPDATE CASCADE;

--
-- Constraints for table `goods_receipt_items`
--
ALTER TABLE `goods_receipt_items`
  ADD CONSTRAINT `goods_receipt_items_ibfk_109` FOREIGN KEY (`goods_receipt_id`) REFERENCES `goods_receipts` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `goods_receipt_items_ibfk_110` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE NO ACTION ON UPDATE CASCADE;

--
-- Constraints for table `inventory`
--
ALTER TABLE `inventory`
  ADD CONSTRAINT `inventory_ibfk_1` FOREIGN KEY (`warehouse_id`) REFERENCES `warehouses` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `inventory_ibfk_2` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `inventory_adjustments`
--
ALTER TABLE `inventory_adjustments`
  ADD CONSTRAINT `inventory_adjustments_ibfk_140` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `inventory_adjustments_ibfk_141` FOREIGN KEY (`warehouse_id`) REFERENCES `warehouses` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  ADD CONSTRAINT `inventory_adjustments_ibfk_142` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  ADD CONSTRAINT `inventory_adjustments_ibfk_61` FOREIGN KEY (`company_id`) REFERENCES `companies` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `inventory_logs`
--
ALTER TABLE `inventory_logs`
  ADD CONSTRAINT `inventory_logs_ibfk_1` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `inventory_logs_ibfk_2` FOREIGN KEY (`warehouse_id`) REFERENCES `warehouses` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `locations`
--
ALTER TABLE `locations`
  ADD CONSTRAINT `locations_ibfk_1` FOREIGN KEY (`zone_id`) REFERENCES `zones` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `movements`
--
ALTER TABLE `movements`
  ADD CONSTRAINT `movements_ibfk_192` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `movements_ibfk_193` FOREIGN KEY (`batch_id`) REFERENCES `batches` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  ADD CONSTRAINT `movements_ibfk_194` FOREIGN KEY (`from_location_id`) REFERENCES `locations` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  ADD CONSTRAINT `movements_ibfk_195` FOREIGN KEY (`to_location_id`) REFERENCES `locations` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  ADD CONSTRAINT `movements_ibfk_196` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  ADD CONSTRAINT `movements_ibfk_61` FOREIGN KEY (`company_id`) REFERENCES `companies` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `notifications`
--
ALTER TABLE `notifications`
  ADD CONSTRAINT `notifications_ibfk_1` FOREIGN KEY (`company_id`) REFERENCES `companies` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `notifications_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE SET NULL ON UPDATE CASCADE;

--
-- Constraints for table `order_items`
--
ALTER TABLE `order_items`
  ADD CONSTRAINT `order_items_ibfk_113` FOREIGN KEY (`sales_order_id`) REFERENCES `sales_orders` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `order_items_ibfk_114` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE NO ACTION ON UPDATE CASCADE;

--
-- Constraints for table `packing_tasks`
--
ALTER TABLE `packing_tasks`
  ADD CONSTRAINT `packing_tasks_ibfk_169` FOREIGN KEY (`sales_order_id`) REFERENCES `sales_orders` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `packing_tasks_ibfk_170` FOREIGN KEY (`pick_list_id`) REFERENCES `pick_lists` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  ADD CONSTRAINT `packing_tasks_ibfk_171` FOREIGN KEY (`assigned_to`) REFERENCES `users` (`id`) ON DELETE SET NULL ON UPDATE CASCADE;

--
-- Constraints for table `pick_lists`
--
ALTER TABLE `pick_lists`
  ADD CONSTRAINT `pick_lists_ibfk_169` FOREIGN KEY (`sales_order_id`) REFERENCES `sales_orders` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `pick_lists_ibfk_170` FOREIGN KEY (`warehouse_id`) REFERENCES `warehouses` (`id`) ON DELETE NO ACTION ON UPDATE CASCADE,
  ADD CONSTRAINT `pick_lists_ibfk_171` FOREIGN KEY (`assigned_to`) REFERENCES `users` (`id`) ON DELETE SET NULL ON UPDATE CASCADE;

--
-- Constraints for table `pick_list_items`
--
ALTER TABLE `pick_list_items`
  ADD CONSTRAINT `pick_list_items_ibfk_113` FOREIGN KEY (`pick_list_id`) REFERENCES `pick_lists` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `pick_list_items_ibfk_114` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE NO ACTION ON UPDATE CASCADE;

--
-- Constraints for table `production_formulas`
--
ALTER TABLE `production_formulas`
  ADD CONSTRAINT `production_formulas_ibfk_1` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `production_formula_items`
--
ALTER TABLE `production_formula_items`
  ADD CONSTRAINT `production_formula_items_ibfk_1` FOREIGN KEY (`formula_id`) REFERENCES `production_formulas` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `production_formula_items_ibfk_2` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE NO ACTION ON UPDATE CASCADE;

--
-- Constraints for table `production_orders`
--
ALTER TABLE `production_orders`
  ADD CONSTRAINT `production_orders_ibfk_1` FOREIGN KEY (`company_id`) REFERENCES `companies` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `production_orders_ibfk_2` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `production_orders_ibfk_3` FOREIGN KEY (`warehouse_id`) REFERENCES `warehouses` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `production_order_items`
--
ALTER TABLE `production_order_items`
  ADD CONSTRAINT `production_order_items_ibfk_1` FOREIGN KEY (`production_order_id`) REFERENCES `production_orders` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `production_order_items_ibfk_2` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `products`
--
ALTER TABLE `products`
  ADD CONSTRAINT `products_ibfk_163` FOREIGN KEY (`company_id`) REFERENCES `companies` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `products_ibfk_164` FOREIGN KEY (`category_id`) REFERENCES `categories` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  ADD CONSTRAINT `products_ibfk_165` FOREIGN KEY (`supplier_id`) REFERENCES `suppliers` (`id`) ON DELETE SET NULL ON UPDATE CASCADE;

--
-- Constraints for table `product_stocks`
--
ALTER TABLE `product_stocks`
  ADD CONSTRAINT `product_stocks_ibfk_169` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `product_stocks_ibfk_170` FOREIGN KEY (`warehouse_id`) REFERENCES `warehouses` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `product_stocks_ibfk_171` FOREIGN KEY (`location_id`) REFERENCES `locations` (`id`) ON DELETE SET NULL ON UPDATE CASCADE;

--
-- Constraints for table `purchase_orders`
--
ALTER TABLE `purchase_orders`
  ADD CONSTRAINT `purchase_orders_ibfk_111` FOREIGN KEY (`company_id`) REFERENCES `companies` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `purchase_orders_ibfk_112` FOREIGN KEY (`supplier_id`) REFERENCES `suppliers` (`id`) ON DELETE NO ACTION ON UPDATE CASCADE;

--
-- Constraints for table `purchase_order_items`
--
ALTER TABLE `purchase_order_items`
  ADD CONSTRAINT `purchase_order_items_ibfk_111` FOREIGN KEY (`purchase_order_id`) REFERENCES `purchase_orders` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `purchase_order_items_ibfk_112` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE NO ACTION ON UPDATE CASCADE;

--
-- Constraints for table `replenishment_configs`
--
ALTER TABLE `replenishment_configs`
  ADD CONSTRAINT `replenishment_configs_ibfk_11` FOREIGN KEY (`company_id`) REFERENCES `companies` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `replenishment_configs_ibfk_12` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `replenishment_tasks`
--
ALTER TABLE `replenishment_tasks`
  ADD CONSTRAINT `replenishment_tasks_ibfk_100` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `replenishment_tasks_ibfk_101` FOREIGN KEY (`from_location_id`) REFERENCES `locations` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `replenishment_tasks_ibfk_102` FOREIGN KEY (`to_location_id`) REFERENCES `locations` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `replenishment_tasks_ibfk_21` FOREIGN KEY (`company_id`) REFERENCES `companies` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `reports`
--
ALTER TABLE `reports`
  ADD CONSTRAINT `reports_ibfk_1` FOREIGN KEY (`company_id`) REFERENCES `companies` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `returns`
--
ALTER TABLE `returns`
  ADD CONSTRAINT `returns_ibfk_113` FOREIGN KEY (`company_id`) REFERENCES `companies` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `returns_ibfk_114` FOREIGN KEY (`sales_order_id`) REFERENCES `sales_orders` (`id`) ON DELETE NO ACTION ON UPDATE CASCADE,
  ADD CONSTRAINT `returns_ibfk_115` FOREIGN KEY (`shipment_id`) REFERENCES `shipments` (`id`) ON DELETE NO ACTION ON UPDATE CASCADE,
  ADD CONSTRAINT `returns_ibfk_116` FOREIGN KEY (`customer_id`) REFERENCES `customers` (`id`) ON DELETE SET NULL ON UPDATE CASCADE;

--
-- Constraints for table `sales_orders`
--
ALTER TABLE `sales_orders`
  ADD CONSTRAINT `sales_orders_ibfk_144` FOREIGN KEY (`company_id`) REFERENCES `companies` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `sales_orders_ibfk_145` FOREIGN KEY (`customer_id`) REFERENCES `customers` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  ADD CONSTRAINT `sales_orders_ibfk_93` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`) ON DELETE SET NULL ON UPDATE CASCADE;

--
-- Constraints for table `shipments`
--
ALTER TABLE `shipments`
  ADD CONSTRAINT `shipments_ibfk_169` FOREIGN KEY (`sales_order_id`) REFERENCES `sales_orders` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `shipments_ibfk_170` FOREIGN KEY (`company_id`) REFERENCES `companies` (`id`) ON DELETE NO ACTION ON UPDATE CASCADE,
  ADD CONSTRAINT `shipments_ibfk_171` FOREIGN KEY (`packed_by`) REFERENCES `users` (`id`) ON DELETE SET NULL ON UPDATE CASCADE;

--
-- Constraints for table `suppliers`
--
ALTER TABLE `suppliers`
  ADD CONSTRAINT `suppliers_ibfk_1` FOREIGN KEY (`company_id`) REFERENCES `companies` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `supplier_products`
--
ALTER TABLE `supplier_products`
  ADD CONSTRAINT `supplier_products_ibfk_1` FOREIGN KEY (`company_id`) REFERENCES `companies` (`id`) ON DELETE NO ACTION ON UPDATE CASCADE,
  ADD CONSTRAINT `supplier_products_ibfk_2` FOREIGN KEY (`supplier_id`) REFERENCES `suppliers` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `supplier_products_ibfk_3` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `users`
--
ALTER TABLE `users`
  ADD CONSTRAINT `users_ibfk_117` FOREIGN KEY (`company_id`) REFERENCES `companies` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  ADD CONSTRAINT `users_ibfk_118` FOREIGN KEY (`warehouse_id`) REFERENCES `warehouses` (`id`) ON DELETE SET NULL ON UPDATE CASCADE;

--
-- Constraints for table `vat_codes`
--
ALTER TABLE `vat_codes`
  ADD CONSTRAINT `vat_codes_ibfk_1` FOREIGN KEY (`company_id`) REFERENCES `companies` (`id`) ON DELETE SET NULL ON UPDATE CASCADE;

--
-- Constraints for table `warehouses`
--
ALTER TABLE `warehouses`
  ADD CONSTRAINT `warehouses_ibfk_1` FOREIGN KEY (`company_id`) REFERENCES `companies` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `zones`
--
ALTER TABLE `zones`
  ADD CONSTRAINT `zones_ibfk_1` FOREIGN KEY (`warehouse_id`) REFERENCES `warehouses` (`id`) ON DELETE NO ACTION ON UPDATE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;

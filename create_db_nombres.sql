-- phpMyAdmin SQL Dump
-- version 4.6.4
-- https://www.phpmyadmin.net/
--
-- Host: localhost
-- Generation Time: Nov 01, 2016 at 03:11 AM
-- Server version: 5.7.16
-- PHP Version: 5.5.27

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `nombres`
--
CREATE DATABASE IF NOT EXISTS `nombres` DEFAULT CHARACTER SET latin1 COLLATE latin1_swedish_ci;
USE `nombres`;

-- --------------------------------------------------------

--
-- Table structure for table `nombres`
--

DROP TABLE IF EXISTS `nombres`;
CREATE TABLE `nombres` (
  `name` varchar(100) NOT NULL,
  `quantity` int(11) NOT NULL,
  `year` int(11) NOT NULL,
  `gender` varchar(1) NOT NULL,
  `percentage` float NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `nombres`
--
ALTER TABLE `nombres`
  ADD KEY `name` (`name`),
  ADD KEY `year` (`year`);

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;

DROP TABLE IF EXISTS `nombres_crudos`;

CREATE TABLE `nombres_crudos` AS 
(SELECT DISTINCT `name` FROM `nombres_sample`);

DROP TABLE IF EXISTS `anios`;

CREATE TABLE `anios` AS
(SELECT DISTINCT `year` FROM `nombres_sample`);

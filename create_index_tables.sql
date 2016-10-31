DROP TABLE IF EXISTS `nombres_crudos`;
CREATE TABLE `nombres_crudos` AS 
SELECT DISTINCT `name` FROM `nombres`;
ALTER TABLE `nombres_crudos`
    ADD KEY `name` (`name`);

DROP TABLE IF EXISTS `anios`;
CREATE TABLE `anios` AS
SELECT DISTINCT `year` FROM `nombres`;
ALTER TABLE `anios`
    ADD KEY `year` (`year`);
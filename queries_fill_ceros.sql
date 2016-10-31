DROP TABLE IF EXISTS `nombres_con_ceros`;

CREATE TABLE `nombres_con_ceros` AS
SELECT `nombres_crudos`.`name`, `anios`.`year`, SUM(COALESCE(`nombres_sample`.`quantity`,0))
FROM `nombres_crudos`
CROSS JOIN `anios`
LEFT JOIN `nombres_sample`
ON (`nombres_crudos`.`name`=`nombres_sample`.`name` AND `anios`.`year`=`nombres_sample`.`year`)
GROUP BY `nombres_crudos`.`name`, `anios`.`year`;
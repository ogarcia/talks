/*
 * database.sql
 * Copyright (C) 2018 Óscar García Amor <ogarcia@connectical.com>
 *
 * Distributed under terms of the GNU GPLv3 license.
 */

DROP TABLE IF EXISTS `user`;
CREATE TABLE `user` (
  `id` int(6) unsigned NOT NULL AUTO_INCREMENT,
  `username` varchar(30) NOT NULL,
  `password` char(40) NOT NULL,
  `firstname` varchar(30) NOT NULL,
  `lastname` varchar(30) NOT NULL,
  `email` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8;

LOCK TABLES `user` WRITE;
INSERT INTO `user` VALUES (1,'jdoe','388ad1c312a488ee9e12998fe097f2258fa8d5ee','John','Doe','jdoe@example.com'),(2,'ttascon','f50581cf7669efd1a2e2d2da34429ca495377ce0','Teresa','Tascon','tetas@example.com'),(3,'rgilbert','358fd21338e63839a852977e8cf4a1a19c7a2099','Ron','Gilbert','gilbert@example.com'),(4,'mrajoy','90cedc8ca319f3c2d385c1ef91cea6785e6211f9','Mariano','Rajoy','enb@example.com');
UNLOCK TABLES;

-- vim:et

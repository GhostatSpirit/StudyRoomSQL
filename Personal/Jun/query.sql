-- MySQL dump 10.13  Distrib 5.7.17, for macos10.12 (x86_64)
--
-- Host: localhost    Database: studyroom
-- ------------------------------------------------------
-- Server version	5.7.17

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `Library`
--

DROP TABLE IF EXISTS `Library`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Library` (
  `libraryId` int(11) NOT NULL AUTO_INCREMENT,
  `libraryName` varchar(255) NOT NULL,
  `address` varchar(255) NOT NULL,
  `phone` varchar(255) NOT NULL,
  PRIMARY KEY (`libraryId`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Library`
--

LOCK TABLES `Library` WRITE;
/*!40000 ALTER TABLE `Library` DISABLE KEYS */;
INSERT INTO `Library` VALUES (1,'xintu','xxlu','18621544542');
/*!40000 ALTER TABLE `Library` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `Room`
--

DROP TABLE IF EXISTS `Room`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Room` (
  `roomId` int(11) NOT NULL AUTO_INCREMENT,
  `roomName` varchar(255) NOT NULL,
  `libraryId` int(11) NOT NULL,
  `capacity` int(11) NOT NULL,
  `hasProjector` tinyint(1) NOT NULL,
  PRIMARY KEY (`roomId`),
  KEY `FK_ownRoom` (`libraryId`),
  CONSTRAINT `FK_ownRoom` FOREIGN KEY (`libraryId`) REFERENCES `Library` (`libraryId`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Room`
--

LOCK TABLES `Room` WRITE;
/*!40000 ALTER TABLE `Room` DISABLE KEYS */;
INSERT INTO `Room` VALUES (1,'101',1,4,1);
/*!40000 ALTER TABLE `Room` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `RoomOrder`
--

DROP TABLE IF EXISTS `RoomOrder`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `RoomOrder` (
  `orderId` int(11) NOT NULL AUTO_INCREMENT,
  `reviewerId` int(11) DEFAULT NULL,
  `scorerId` int(11) DEFAULT NULL,
  `applicantId` int(11) NOT NULL,
  `createTime` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `memberNum` int(11) NOT NULL,
  `status` int(11) NOT NULL,
  `isPublic` tinyint(1) NOT NULL,
  `orderPassword` varchar(255) DEFAULT NULL,
  `score` int(11) DEFAULT NULL,
  PRIMARY KEY (`orderId`),
  KEY `FK_applyUser` (`applicantId`),
  KEY `FK_asReviewer` (`reviewerId`),
  KEY `FK_asScorer` (`scorerId`),
  CONSTRAINT `FK_applyUser` FOREIGN KEY (`applicantId`) REFERENCES `User` (`userId`),
  CONSTRAINT `FK_asReviewer` FOREIGN KEY (`reviewerId`) REFERENCES `User` (`userId`),
  CONSTRAINT `FK_asScorer` FOREIGN KEY (`scorerId`) REFERENCES `User` (`userId`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `RoomOrder`
--

LOCK TABLES `RoomOrder` WRITE;
/*!40000 ALTER TABLE `RoomOrder` DISABLE KEYS */;
INSERT INTO `RoomOrder` VALUES (1,NULL,NULL,1,'2017-05-17 06:51:06',4,0,1,'12345',NULL),(2,NULL,NULL,1,'2017-05-17 07:34:44',6,0,1,'123456',NULL);
/*!40000 ALTER TABLE `RoomOrder` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `Slot`
--

DROP TABLE IF EXISTS `Slot`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Slot` (
  `slotId` int(11) NOT NULL AUTO_INCREMENT,
  `roomId` int(11) NOT NULL,
  `orderId` int(11) DEFAULT NULL,
  `startTime` datetime NOT NULL,
  `endTime` datetime NOT NULL,
  `isUsable` tinyint(1) NOT NULL,
  PRIMARY KEY (`slotId`),
  KEY `FK_OrderInSlot` (`orderId`),
  KEY `FK_SlotInRoom` (`roomId`),
  CONSTRAINT `FK_OrderInSlot` FOREIGN KEY (`orderId`) REFERENCES `RoomOrder` (`orderId`),
  CONSTRAINT `FK_SlotInRoom` FOREIGN KEY (`roomId`) REFERENCES `Room` (`roomId`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Slot`
--

LOCK TABLES `Slot` WRITE;
/*!40000 ALTER TABLE `Slot` DISABLE KEYS */;
INSERT INTO `Slot` VALUES (1,1,NULL,'2017-05-01 08:00:00','2017-05-01 08:30:00',1),(2,1,1,'2017-05-01 08:30:00','2017-05-01 09:00:00',1),(3,1,1,'2017-05-01 09:00:00','2017-05-01 09:30:00',1),(4,1,1,'2017-05-01 09:30:00','2017-05-01 10:00:00',1),(5,1,2,'2017-05-01 09:30:00','2017-05-01 10:00:00',1),(6,1,2,'2017-05-01 10:00:00','2017-05-01 10:30:00',1);
/*!40000 ALTER TABLE `Slot` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `User`
--

DROP TABLE IF EXISTS `User`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `User` (
  `userId` int(11) NOT NULL AUTO_INCREMENT,
  `userScore` int(11) NOT NULL,
  `role` int(11) NOT NULL,
  `username` varchar(255) NOT NULL,
  `password` varchar(255) NOT NULL,
  PRIMARY KEY (`userId`),
  KEY `AK_Identifier_2` (`username`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `User`
--

LOCK TABLES `User` WRITE;
/*!40000 ALTER TABLE `User` DISABLE KEYS */;
INSERT INTO `User` VALUES (1,100,0,'lykavin','123456'),(2,100,0,'ghost','123456');
/*!40000 ALTER TABLE `User` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `asMember`
--

DROP TABLE IF EXISTS `asMember`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `asMember` (
  `orderId` int(11) NOT NULL,
  `userId` int(11) NOT NULL,
  PRIMARY KEY (`orderId`,`userId`),
  KEY `FK_asMember2` (`userId`),
  CONSTRAINT `FK_asMember` FOREIGN KEY (`orderId`) REFERENCES `RoomOrder` (`orderId`),
  CONSTRAINT `FK_asMember2` FOREIGN KEY (`userId`) REFERENCES `User` (`userId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `asMember`
--

LOCK TABLES `asMember` WRITE;
/*!40000 ALTER TABLE `asMember` DISABLE KEYS */;
INSERT INTO `asMember` VALUES (1,1),(2,1),(1,2);
/*!40000 ALTER TABLE `asMember` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Temporary view structure for view `detailedorder`
--

DROP TABLE IF EXISTS `detailedorder`;
/*!50001 DROP VIEW IF EXISTS `detailedorder`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE VIEW `detailedorder` AS SELECT 
 1 AS `orderId`,
 1 AS `applicantId`,
 1 AS `roomId`,
 1 AS `memberNum`,
 1 AS `status`,
 1 AS `isPublic`,
 1 AS `orderPassword`,
 1 AS `inMemNum`,
 1 AS `score`,
 1 AS `startTime`,
 1 AS `endTime`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `showorders`
--

DROP TABLE IF EXISTS `showorders`;
/*!50001 DROP VIEW IF EXISTS `showorders`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE VIEW `showorders` AS SELECT 
 1 AS `orderId`,
 1 AS `memberNum`,
 1 AS `status`,
 1 AS `isPublic`,
 1 AS `orderPassword`,
 1 AS `score`,
 1 AS `min(startTime)`,
 1 AS `max(endTime)`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `usableslots`
--

DROP TABLE IF EXISTS `usableslots`;
/*!50001 DROP VIEW IF EXISTS `usableslots`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE VIEW `usableslots` AS SELECT 
 1 AS `libraryId`,
 1 AS `libraryName`,
 1 AS `roomId`,
 1 AS `roomName`,
 1 AS `startTime`,
 1 AS `endTime`,
 1 AS `available`*/;
SET character_set_client = @saved_cs_client;

--
-- Dumping events for database 'studyroom'
--

--
-- Dumping routines for database 'studyroom'
--
/*!50003 DROP PROCEDURE IF EXISTS `addSlots` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `addSlots`(iroomId int, istartTime datetime, iendTime datetime)
BEGIN
	insert into Slots(roomId,startTime,endTime,available) values(iroomId,istartTime,iendTime,1);
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `searchSlots` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `searchSlots`(libraryId int, thedate date, startTime datetime, endTime datetime)
begin 
	select * from usableSlots okSlots 
	where
	(libraryId is null or okSlots.libraryId=libraryId)
	and 
	(thedate is null or date_add(thedate, interval 1 day)>okSlots.endTime and thedate<okSlots.startTime)
	and 
	(startTime is null and endTime is null 
	or  startTime <= okSlots.startTime and endTime >= okSlots.endTime);
end ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `showManagerOrders` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `showManagerOrders`(state int)
BEGIN
	select orderId,applicantId,roomId,memberNum,inMemNum,status,isPublic,orderPassword,
    startTime,endTime
	from detailedOrder
    where status=state;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `showUserOrders` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `showUserOrders`(userId int)
BEGIN
	
	select orderId,detailedOrder.roomId,roomName,libraryId,libraryName,memberNum,inMemNum,status,isPublic,orderPassword,
    score,startTime,endTime
	from detailedOrder join 
	(select Room.roomId,roomName,Room.libraryId,libraryName 
	from Room join Library on Room.libraryId = Library.libraryId) as detailedRoom
	on detailedRoom.roomId=detailedOrder.roomId
	where applicantId=userId;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Final view structure for view `detailedorder`
--

/*!50001 DROP VIEW IF EXISTS `detailedorder`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8 */;
/*!50001 SET character_set_results     = utf8 */;
/*!50001 SET collation_connection      = utf8_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `detailedorder` AS select `total`.`orderId` AS `orderId`,`total`.`applicantId` AS `applicantId`,min(`total`.`roomId`) AS `roomId`,`total`.`memberNum` AS `memberNum`,`total`.`status` AS `status`,`total`.`isPublic` AS `isPublic`,`total`.`orderPassword` AS `orderPassword`,`total`.`inMemNum` AS `inMemNum`,`total`.`score` AS `score`,min(`total`.`startTime`) AS `startTime`,max(`total`.`endTime`) AS `endTime` from (select `rorder`.`orderId` AS `orderId`,`rorder`.`inMemNum` AS `inMemNum`,`rorder`.`applicantId` AS `applicantId`,`rorder`.`memberNum` AS `memberNum`,`rorder`.`status` AS `status`,`rorder`.`isPublic` AS `isPublic`,`rorder`.`orderPassword` AS `orderPassword`,`rorder`.`score` AS `score`,`rslot`.`startTime` AS `startTime`,`rslot`.`endTime` AS `endTime`,`rslot`.`roomId` AS `roomId` from (((select `studyroom`.`roomorder`.`orderId` AS `orderId`,`studyroom`.`roomorder`.`applicantId` AS `applicantId`,`studyroom`.`roomorder`.`memberNum` AS `memberNum`,`studyroom`.`roomorder`.`status` AS `status`,`studyroom`.`roomorder`.`orderPassword` AS `orderPassword`,`studyroom`.`roomorder`.`isPublic` AS `isPublic`,`studyroom`.`roomorder`.`score` AS `score`,count(`studyroom`.`asmember`.`userId`) AS `inMemNum` from (`studyroom`.`roomorder` join `studyroom`.`asmember` on((`studyroom`.`roomorder`.`orderId` = `studyroom`.`asmember`.`orderId`))) group by `studyroom`.`roomorder`.`orderId`)) `rorder` join `studyroom`.`slot` `rslot` on((`rslot`.`orderId` = `rorder`.`orderId`))) where 1) `total` where 1 group by `total`.`orderId` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `showorders`
--

/*!50001 DROP VIEW IF EXISTS `showorders`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8 */;
/*!50001 SET character_set_results     = utf8 */;
/*!50001 SET collation_connection      = utf8_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `showorders` AS select `total`.`orderId` AS `orderId`,`total`.`memberNum` AS `memberNum`,`total`.`status` AS `status`,`total`.`isPublic` AS `isPublic`,`total`.`orderPassword` AS `orderPassword`,`total`.`score` AS `score`,min(`total`.`startTime`) AS `min(startTime)`,max(`total`.`endTime`) AS `max(endTime)` from (select `rorder`.`orderId` AS `orderId`,`rorder`.`memberNum` AS `memberNum`,`rorder`.`status` AS `status`,`rorder`.`isPublic` AS `isPublic`,`rorder`.`orderPassword` AS `orderPassword`,`rorder`.`score` AS `score`,`rslot`.`startTime` AS `startTime`,`rslot`.`endTime` AS `endTime` from (`studyroom`.`roomorder` `rorder` join `studyroom`.`slot` `rslot` on((`rslot`.`orderId` = `rorder`.`orderId`))) where 1) `total` where 1 group by `total`.`orderId` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `usableslots`
--

/*!50001 DROP VIEW IF EXISTS `usableslots`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8 */;
/*!50001 SET character_set_results     = utf8 */;
/*!50001 SET collation_connection      = utf8_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `usableslots` AS select `detailedroom`.`libraryId` AS `libraryId`,`detailedroom`.`libraryName` AS `libraryName`,`detailedroom`.`roomId` AS `roomId`,`detailedroom`.`roomName` AS `roomName`,`usableslotsets`.`startTime` AS `startTime`,`usableslotsets`.`endTime` AS `endTime`,isnull(`usableslotsets`.`orderId`) AS `available` from (((select `studyroom`.`slot`.`roomId` AS `roomId`,`studyroom`.`slot`.`startTime` AS `startTime`,`studyroom`.`slot`.`endTime` AS `endTime`,`studyroom`.`slot`.`orderId` AS `orderId` from `studyroom`.`slot` where (`studyroom`.`slot`.`isUsable` = 1))) `usableSlotsets` join (select `studyroom`.`room`.`roomId` AS `roomId`,`studyroom`.`room`.`libraryId` AS `libraryId`,`studyroom`.`library`.`libraryName` AS `libraryName`,`studyroom`.`room`.`roomName` AS `roomName` from (`studyroom`.`room` join `studyroom`.`library` on((`studyroom`.`room`.`libraryId` = `studyroom`.`library`.`libraryId`))) where 1) `detailedRoom` on((`usableslotsets`.`roomId` = `detailedroom`.`roomId`))) where 1 */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2017-05-17 23:45:31

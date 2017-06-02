drop database if exists lvzheng_studyroom;
create database lvzheng_studyroom default collate utf8_bin;
use lvzheng_studyroom;

drop table if exists Library;

drop table if exists Room;

drop table if exists RoomOrder;

drop table if exists Slot;

drop table if exists User;

drop table if exists asMember;

/*==============================================================*/
/* Table: Library                                               */
/*==============================================================*/
create table Library
(
   libraryId            int not null auto_increment,
   libraryName          varchar(255) not null,
   address              varchar(255) not null,
   phone                varchar(255) not null,
   primary key (libraryId)
);

/*==============================================================*/
/* Table: Room                                                  */
/*==============================================================*/
create table Room
(
   roomId               int not null auto_increment,
   roomName             varchar(255) not null,
   libraryId            int not null,
   capacity             int not null,
   hasProjector         bool not null,
   primary key (roomId)
);

/*==============================================================*/
/* Table: RoomOrder                                             */
/*==============================================================*/
create table RoomOrder
(
   orderId              int not null auto_increment,
   reviewerId           int,
   scorerId             int,
   applicantId          int not null,

   roomId               int,
   startTime            datetime,
   endTime              datetime,

   createTime           timestamp not null default current_timestamp,
   memberNum            int not null,
   status               int not null,
   isPublic             bool not null,
   orderPassword        varchar(255),
   score                int,
   primary key (orderId)
);

/*==============================================================*/
/* Table: Slot                                                  */
/*==============================================================*/
create table Slot
(
   slotId               int not null auto_increment,
   roomId               int not null,
   orderId              int,
   slotDate             date not null,
   startTime            datetime not null,
   endTime              datetime not null,
   isUsable             bool not null,
   primary key (slotId)
);

/*==============================================================*/
/* Table: User                                                  */
/*==============================================================*/
create table User
(
   userId               int not null auto_increment,
   userScore            int not null,
   role                 int not null,
   username             varchar(255) not null,
   password             varchar(255) not null,
   primary key (userId),
   key AK_Identifier_2 (username)
);

/*==============================================================*/
/* Table: asMember                                              */
/*==============================================================*/
create table asMember
(
   orderId              int not null,
   userId               int not null,
   primary key (orderId, userId)
);

alter table Room add constraint FK_ownRoom foreign key (libraryId)
      references Library (libraryId) on delete restrict on update restrict;

alter table RoomOrder add constraint FK_applyUser foreign key (applicantId)
      references User (userId) on delete restrict on update restrict;

alter table RoomOrder add constraint FK_asReviewer foreign key (reviewerId)
      references User (userId) on delete restrict on update restrict;

alter table RoomOrder add constraint FK_asScorer foreign key (scorerId)
      references User (userId) on delete restrict on update restrict;

alter table Slot add constraint FK_OrderInSlot foreign key (orderId)
      references RoomOrder (orderId) on delete restrict on update restrict;

alter table Slot add constraint FK_SlotInRoom foreign key (roomId)
      references Room (roomId) on delete restrict on update restrict;

alter table asMember add constraint FK_asMember foreign key (orderId)
      references RoomOrder (orderId) on delete restrict on update restrict;

alter table asMember add constraint FK_asMember2 foreign key (userId)
      references User (userId) on delete restrict on update restrict;
      
-- index
ALTER TABLE `Slot` 
ADD INDEX `dateIndex` USING BTREE (`slotDate` ASC);


DELIMITER $$

-- Yang Liu

DROP FUNCTION IF EXISTS srCheckSlot$$
CREATE FUNCTION srCheckSlot(_slotId INT)
	RETURNS INT
    -- 1 if ok,
    -- -1 if slot is reserved,
    -- -2 if slot is unusable
	-- -3 if slot not found
BEGIN
	DECLARE retVal INT;
    DECLARE oldOrderId int;
    DECLARE oldIsUsable bool;

    -- put the slot info into variables
	SELECT orderId, isUsable
    INTO oldOrderId, oldIsUsable
	FROM Slot
	WHERE Slot.slotId = _slotId;

    -- check if we can find the slot with slotId
    IF oldIsUsable = null THEN RETURN -3;
    END IF;
	-- check if room is usable
    IF oldIsUsable = false THEN RETURN -2;
    END IF;
    -- check if the slot is not reserved
    IF oldOrderId IS NOT NULL THEN RETURN -1;
    END IF;

    -- now we could be sure that the slot could be reserved
    -- UPDATE Slot SET Slot.orderId = _orderId
    -- WHERE Slot.slotId = _slotId;
	RETURN 1;

END$$

DROP PROCEDURE IF EXISTS srCreateOrder$$
-- CAUTION: make sure this proceudre is executed within a transaction
CREATE PROCEDURE srCreateOrder(
	_applicantId INT,
    -- default status is '0'
    _memberNum int,
    _isPublic BOOL,
    _slotIdStr VARCHAR(1023),
    OUT _outOrderId INT
	-- orderId if succeed
	-- -1 if slot is reserved,
    -- -2 if slot is unusable,
    -- -3 if slot cannot be found,
    )
srCreateOrderCursor:
BEGIN
	DECLARE slotRetVal INT;
    DECLARE slotCount INT;
    DECLARE slotCursor INT;
    DECLARE tempSlotId INT;

	DECLARE orderStartTime DATETIME;
	DECLARE orderEndTime DATETIME;
	DECLARE orderRoomId INT;

    DECLARE slotsReservable BOOL;

    DECLARE newOrderId INT;
    DECLARE orderPwd INT;

	-- handler for general sqlexception error(commented)
--     DECLARE EXIT HANDLER FOR SQLEXCEPTION
-- 		BEGIN
-- 			SET _outOrderId = -4;
-- 			ROLLBACK;
-- 		END;

	DROP TEMPORARY TABLE IF EXISTS SlotList;
	CREATE TEMPORARY TABLE SlotList(
		slotId INT,
		roomId INT,
		startTime DATETIME,
		endTime DATETIME
	);

	-- parse _slotIdStr, store slotIds in SlotList
    INSERT INTO SlotList(slotId, roomId, startTime, endTime)
        SELECT Slot.slotId, Slot.roomId, Slot.startTime, Slot.endTime
        FROM Slot
        WHERE FIND_IN_SET(Slot.slotId, _slotIdStr);
    -- set slot count
    SELECT COUNT(*) FROM SlotList INTO slotCount;
	-- if we cannot find any slot in the slot array...
	IF slotCount = 0 THEN
		SET _outOrderId = -3;
		LEAVE srCreateOrderCursor;
	END IF;
	-- reset slot cursor
    SET slotCursor = 0;

    -- check if every slot is reservable
    SET slotsReservable = true;
    checkSlotLoop:
    WHILE slotCursor < slotCount DO
        -- get next tempSlotId in list
        SELECT SlotList.slotId INTO tempSlotId FROM SlotList
        ORDER BY SlotList.slotId LIMIT slotCursor, 1;
        -- check this slot
        SET slotRetVal = srCheckSlot(tempSlotId);
        -- if a slot is not reservable
        IF slotRetVal < 0 THEN
            SET slotsReservable = false;
            LEAVE checkSlotLoop;
        END IF;
        SET slotCursor = slotCursor + 1;
    END WHILE;

    -- if a slot is not reservable, set out parameter and leave procedure
    IF slotsReservable = false THEN
        SET _outOrderId = slotRetVal;
        LEAVE srCreateOrderCursor;
    END IF;

	-- we could confirm all slots are reservable now.
    -- prepare order:
	SET orderStartTime =
		(SELECT DISTINCT MIN(startTime) FROM SlotList);
	SET orderEndTime =
	 	(SELECT DISTINCT MAX(endTime) FROM SlotList);
	SET orderRoomId =
		(SELECT roomId FROM SlotList LIMIT 1);

    -- generate randomized 6-digit order password:
    -- [100000, 999999]
    -- SET orderPwd = FLOOR(RAND()*(999999 - 100000 + 1)) + 100000;

    -- for simplicity of testing, generate 0/1 password instead
    SET orderPwd = FLOOR(RAND()*2);

    -- create order (default status value is 0)
    -- and store its order id
    INSERT INTO
		RoomOrder(applicantId, memberNum, status, isPublic, orderPassword,
				  startTime, endTime, roomId)
        values(_applicantId, _memberNum, 0, _isPublic, orderPwd,
			   orderStartTime, orderEndTime, orderRoomId);
    SET newOrderId = LAST_INSERT_ID();

	-- reset slot cursor
    SET slotCursor = 0;
    -- iterate through the SlotList set again and modify slots
    WHILE slotCursor < slotCount DO
        -- get next tempSlotId in list
        SELECT SlotList.slotId
        INTO tempSlotId
        FROM SlotList
        ORDER BY SlotList.slotId
        LIMIT slotCursor, 1;
        -- try to modify(reserve) this slot
		UPDATE Slot SET Slot.orderId = newOrderId
		WHERE Slot.slotId = tempSlotId;

        SET slotCursor = slotCursor + 1;
    END WHILE;

	INSERT INTO asMember(orderId, userId) VALUES(newOrderId, _applicantId);
    SET _outOrderId = newOrderId;

END$$



-- Junyi Liu
CREATE
VIEW `detailedorder` AS
    SELECT
        `asMember`.`orderId` AS `orderId`,
        `RoomOrder`.`applicantId` AS `applicantId`,
        `RoomOrder`.`roomId` AS `roomId`,
        `RoomOrder`.`reviewerId` AS `reviewerId`,
        `RoomOrder`.`scorerId` AS `scorerId`,
        `RoomOrder`.`memberNum` AS `memberNum`,
        `RoomOrder`.`status` AS `status`,
        `RoomOrder`.`isPublic` AS `isPublic`,
        `RoomOrder`.`orderPassword` AS `orderPassword`,
        `RoomOrder`.`score` AS `score`,
        `RoomOrder`.`startTime` AS `startTime`,
        `RoomOrder`.`endTime` AS `endTime`,
        COUNT(`asMember`.`userId`) AS `inMemNum`
    FROM
        (`RoomOrder`
        JOIN `asMember` ON ((`RoomOrder`.`orderId` = `asMember`.`orderId`)))
    WHERE
        1
    GROUP BY `asMember`.`orderId`
$$


CREATE 
VIEW `usableslots` AS
    SELECT 
        `detailedRoom`.`libraryId` AS `libraryId`,
        `detailedRoom`.`libraryName` AS `libraryName`,
        `detailedRoom`.`roomId` AS `roomId`,
        `detailedRoom`.`roomName` AS `roomName`,
        `usableSlotsets`.`slotDate` AS `slotDate`,
        `usableSlotsets`.`startTime` AS `startTime`,
        `usableSlotsets`.`endTime` AS `endTime`,
        ISNULL(`usableSlotsets`.`orderId`) AS `available`
    FROM
        (((SELECT 
            `Slot`.`roomId` AS `roomId`,
                .`Slot`.`slotDate` AS `slotDate`,
                .`Slot`.`startTime` AS `startTime`,
                .`Slot`.`endTime` AS `endTime`,
                .`Slot`.`orderId` AS `orderId`
        FROM
            `Slot`
        WHERE
            (`Slot`.`isUsable` = 1))) `usableSlotsets`
        JOIN (SELECT 
            `Room`.`roomId` AS `roomId`,
                `Room`.`libraryId` AS `libraryId`,
                `Library`.`libraryName` AS `libraryName`,
                `Room`.`roomName` AS `roomName`
        FROM
            (`Room`
        JOIN `Library` ON ((`Room`.`libraryId` = `Library`.`libraryId`)))
        WHERE
            1) `detailedRoom` ON ((`usableSlotsets`.`roomId` = `detailedRoom`.`roomId`)))
    WHERE
        1
$$


CREATE PROCEDURE `addSlots`(iroomId int, istartTime datetime, iendTime datetime)
BEGIN
	insert into Slots(roomId,startTime,endTime,isUsable) values(iroomId,istartTime,iendTime,1);
END$$

CREATE PROCEDURE `searchSlots`(libraryId int, thedate date, startTime datetime, endTime datetime)
begin
	select * from usableSlots okSlots 
	where
	(libraryId is null or okSlots.libraryId=libraryId)
	and 
	(thedate is null or thedate=okSlots.slotDate)
	and 
	(startTime is null and endTime is null 
	or  startTime <= okSlots.startTime and endTime >= okSlots.endTime);
end$$

CREATE PROCEDURE `showManagerOrders`(state int)
BEGIN
	select orderId,applicantId,roomId,memberNum,inMemNum,status,isPublic,orderPassword,
    startTime,endTime
	from detailedOrder
    where status=state;
END$$

CREATE PROCEDURE `showMemberOrders`(userId int)
BEGIN
    select orderId,memOrder.roomId,applicantId,roomName,libraryId,libraryName,memberNum,inMemNum,status,isPublic,orderPassword,
    score,startTime,endTime
    from (select detailedOrder.orderId,roomId,applicantId,memberNum,inMemNum,status,isPublic,orderPassword,
    score,startTime,endTime
    from detailedOrder join asMember on detailedOrder.orderId=asMember.orderId where asMember.userId=userId) as memOrder
    join
    (select Room.roomId,roomName,Room.libraryId,libraryName
    from Room join Library on Room.libraryId = Library.libraryId) as detailedRoom
    on detailedRoom.roomId=memOrder.roomId
    where 1;
END$$


CREATE PROCEDURE `showApplicantOrders`(userId int)
BEGIN

    select orderId,detailedOrder.roomId,roomName,libraryId,libraryName,memberNum,inMemNum,status,isPublic,orderPassword,
    score,startTime,endTime
    from detailedOrder join
    (select Room.roomId,roomName,Room.libraryId,libraryName
    from Room join Library on Room.libraryId = Library.libraryId) as detailedRoom
    on detailedRoom.roomId=detailedOrder.roomId
    where applicantId=userId;

END$$

CREATE PROCEDURE `setOrderStatus` (inStatus int, orderId int)
BEGIN
update RoomOrder set status = inStatus where RoomOrder.orderId = orderId; 
if inStatus < 0 then
	update Slot slot set slot.orderId = null where slot.orderId= orderId;
    end if;
END$$

CREATE PROCEDURE `createADaySlots`(toDoDay date, inStartTime time, inEndTime time, gap int)
BEGIN
    declare ittime datetime;
    declare stoptime datetime;
    set ittime=cast(CONCAT(toDoday,' ',inStartTime) as datetime);
    set stoptime=cast(CONCAT(toDoday,' ',inEndTime) as datetime);

    create temporary table if not exists daySlot (
        startTime datetime,
        endTime datetime
    );
    truncate TABLE daySlot;

    while date_add(ittime, interval gap minute)<= stopTime do 
        insert into daySlot values (ittime,date_add(ittime, interval gap minute));
        set ittime=date_add(ittime, interval gap minute);
    end while;

    insert into Slot(roomId,slotDate,startTime,endTime,isUsable)
    select roomId, toDoDay, startTime, endTime,1
    from Room join daySlot;
END$$


CREATE PROCEDURE `naiveSlotRetire`(requestDate date)
BEGIN
    insert into oldSlot
    select * from Slot
    where Slot.slotDate=requestDate;
    delete from Slot
    where Slot.slotDate=requestDate;
END$$

-- Ye Wu

create Function setOrderScore (targetOrderId int, targetUserId int, judgeScore int) returns int
BEGIN
	declare setStatus int default 0;
    if(exists(select * from RoomOrder where RoomOrder.orderId = targetOrderId) && exists(select * from User where User.userId = targetUserId)) then
		update RoomOrder set RoomOrder.score = judgeScore where RoomOrder.orderId = targetOrderId;
        update RoomOrder set RoomOrder.scorerId = targetUserId where RoomOrder.orderId = targetOrderId;
        set setStatus = 1; #  Scucess
    else
		set setStatus = 0; #  Failure
	end if;
	return setStatus;
END$$


create Function getScore(targetUserId int) returns double
BEGIN
	declare targetScore double default 5;
    if(exists(select * from User where User.userId = targetUserId )) then
		select exp(avg(ln(score))) into targetScore
        from RoomOrder natural join asMember
        where asMember.userId = targetUserId;
        #set targetScore = finalScore;
    end if;
    return targetScore;
END$$

CREATE FUNCTION freeOrderSlots(_orderId INT) returns bool
BEGIN
	IF _orderId = null THEN
		RETURN false;
    END IF;
    
	UPDATE Slot set orderId = null where orderId = _orderId;
    RETURN true;
END $$

create Function setSlotUsable(targetSlotId int, slotUsableStatus tinyint) returns bool
BEGIN
	declare setSlotSuccess bool default 0;
    declare oldSlotOrderId INT;
    declare retVal BOOL;
    
    if(exists(select * from slot where slot.slotId = targetSlotId )) then
		update slot set slot.isUsable = slotUsableStatus where slot.slotId = targetSlotId;
        
        if slotUsableStatus = 0 then
			SET oldSlotOrderId = (select orderId from Slot where slotId=targetSlotId);
			update RoomOrder set status = -1 where orderId = oldSlotOrderId;
			SET retVal = freeOrderSlots(oldSlotOrderId);
            
        end if;
        
		set setSlotSuccess = 1; #  Scucess
    else
		set setSlotSuccess = 0; #  Failure
    end if;
    return setSlotSuccess;
END$$

create Function setOrderStatus(targetUserId int, targetOrderId int, targetOrderStatus int) returns bool
BEGIN
	declare setOrderSuccess bool default 0;
    declare retVal bool;
    
    if(exists(select * from RoomOrder where RoomOrder.orderId = targetOrderId) && exists(select * from User where User.userId = targetUserId)) then
        update RoomOrder set RoomOrder.reviewerId = targetUserId where RoomOrder.orderId = targetOrderId;
        update RoomOrder set RoomOrder.status = targetOrderStatus where RoomOrder.orderId = targetOrderId;
        
        IF targetOrderStatus < 0 THEN
			SET retVal = freeOrderSlots(targetOrderId);
        END IF;
        
        set setOrderSuccess = 1; #  Scucess
    else
		set setOrderSuccess = 0; #  Failure
    end if;
    return setOrderSuccess;
END$$



-- create Trigger cancelOrderOnSlotUnusable after update on Slot
-- for each row
-- begin
--     if not new.isUsable then
--         update RoomOrder set status = -1 where orderId = new.orderId;
--     end if;
-- end$$

-- create Trigger freeSlotsOnOrderCancel after update on RoomOrder
-- for each row
-- begin
--     if new.status < 0 then
--         update Slot set orderId = null where orderId = new.orderId;
--     end if;
-- end$$

-- Zheng Lv


CREATE FUNCTION LoginUser(username VARCHAR(255), password VARCHAR(255))
RETURNS INT
RETURN (SELECT IFNULL((SELECT userId
		FROM User
		WHERE User.username = username
		AND User.password = password
	), 0)
)$$

CREATE PROCEDURE BeMember(userId INT, orderId INT, orderPassword VARCHAR(255), OUT success INT)
proc:BEGIN
	DECLARE isDup INT DEFAULT 0;
	DECLARE pwdCorrect INT DEFAULT 0;
	SELECT
		COUNT(*)
	INTO isDup FROM
		asMember
	WHERE
		asMember.userId = userId
			AND asMember.orderId = orderId;
	IF isDup THEN
		SET success = 1;
		LEAVE proc;
	END IF;
	SELECT
		COUNT(*)
	INTO pwdCorrect FROM
		RoomOrder
	WHERE
		RoomOrder.orderId = orderId
			AND (RoomOrder.isPublic
			OR RoomOrder.orderPassword = orderPassword);
	IF NOT pwdCorrect THEN
		SET success = 0;
		LEAVE proc;
	END IF;
	INSERT INTO asMember (orderId, userId) VALUES (orderId, userId);
	SET success = 1;
END$$

CREATE FUNCTION EnterRoom(userId INT, roomId INT, currentTime DATETIME)
RETURNS INT
RETURN (SELECT COUNT(*) FROM Room
	NATURAL JOIN Slot
	NATURAL JOIN RoomOrder
	NATURAL JOIN asMember
	WHERE Room.roomId = roomId
	AND Slot.startTime <= currentTime AND Slot.endTime >= currentTime
	AND asMember.userId = userId
	AND RoomOrder.status = 1)
$$

DELIMITER ;

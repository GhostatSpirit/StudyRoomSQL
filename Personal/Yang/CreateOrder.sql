DELIMITER $$
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

END;
$$
DELIMITER ;

DELIMITER $$
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
    SET orderPwd = FLOOR(RAND()*(999999 - 100000 + 1)) + 100000;
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

END
$$
DELIMITER ;

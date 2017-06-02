-- Author: Yang Liu
-- Email: lykavin@hotmail.com

DELIMITER $$
-- DROP FUNCTION IF EXISTS srCheckSlot$$
-- CREATE FUNCTION srCheckSlot(_isUsable bool)
-- 	RETURNS INT
--     -- 1 if ok,
--     -- -1 if slot is reserved,
--     -- -2 if slot is unusable
-- 	-- -3 if slot not found
-- BEGIN
-- 	DECLARE retVal INT;
--
--     -- check if we can find the slot with slotId
--     IF _isUsable = null THEN RETURN -3;
--     END IF;
-- 	-- check if room is usable
--     IF _isUsable = false THEN RETURN -2;
--     END IF;
--     -- check if the slot is not reserved
--     IF _isUsable IS NOT NULL THEN RETURN -1;
--     END IF;
--
--     -- now we could be sure that the slot could be reserved
--     -- UPDATE Slot SET Slot.orderId = _orderId
--     -- WHERE Slot.slotId = _slotId;
-- 	RETURN 1;
--
-- END$$

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
    -- DECLARE slotCount INT;
    DECLARE slotCursor INT;

	DECLARE orderStartTime DATETIME;
	DECLARE orderEndTime DATETIME;
	DECLARE orderRoomId INT;

    DECLARE slotsReservable BOOL;

    DECLARE newOrderId INT;
    DECLARE orderPwd INT;

	DROP TEMPORARY TABLE IF EXISTS SlotList;

	CREATE TEMPORARY TABLE SlotList(
		slotId INT,
		roomId INT,
		startTime DATETIME,
		endTime DATETIME,
		isUsable BOOLEAN,
		orderId INT
	);

	INSERT INTO SlotList(slotId, roomId, startTime, endTime, isUsable, orderId)
		SELECT Slot.slotId, Slot.roomId, Slot.startTime,
		       Slot.endTime, Slot.isUsable, Slot.orderId
		FROM Slot
		WHERE FIND_IN_SET(Slot.slotId, _slotIdStr);

	IF NOT EXISTS (SELECT NULL FROM SlotList) THEN
		-- cannot parse _slotIdStr OR cannot find slotId in Slot
		SET _outOrderId = -3;
		LEAVE srCreateOrderCursor;
	END IF;

	IF EXISTS
		(SELECT NULL
		 FROM SlotList
		 WHERE SlotList.isUsable != true OR SlotList.orderId IS NOT NULL)
	THEN
		-- some slot is not
		SET _outOrderId = -1;
		LEAVE srCreateOrderCursor;
	END IF;


	-- we could confirm all slots are reservable now.
    -- prepare order:
	SET orderStartTime =
		(SELECT MIN(startTime) FROM SlotList LIMIT 1);
	SET orderEndTime =
	 	(SELECT MAX(endTime) FROM SlotList LIMIT 1);
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

    -- set orderId for corresponding slots in Slot TABLE
	UPDATE Slot SET Slot.orderId = newOrderId
	WHERE Slot.SlotId IN (SELECT SlotList.SlotId FROM SlotList);


	INSERT INTO asMember(orderId, userId) VALUES(newOrderId, _applicantId);
    SET _outOrderId = newOrderId;

END$$

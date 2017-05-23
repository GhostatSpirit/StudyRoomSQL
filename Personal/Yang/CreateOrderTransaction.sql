SET @tempUser = (SELECT userId FROM User WHERE userName = 'lykavin' LIMIT 0, 1);
SET @outOrderId = -999;

START TRANSACTION;
	CALL srCreateOrder(@tempUser, 4, true, '3,4,5,6', @outOrderId);
    COMMIT;

SELECT @outOrderId;
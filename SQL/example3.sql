use lvzheng_studyroom;
SET @tempUser = (SELECT userId FROM User WHERE userName = 'lykavin' LIMIT 0, 1);

SET @outOrderId0 = -999;
SET @outOrderId1 = -999;
SET @outOrderId2 = -999;

START TRANSACTION;
	CALL srCreateOrder(@tempUser, 4, true, '2,3', @outOrderId0);
    COMMIT;
    
START TRANSACTION;
	CALL srCreateOrder(@tempUser, 4, false, '6,7,8', @outOrderId1);
    COMMIT;

START TRANSACTION;
	CALL srCreateOrder(@tempUser, 4, false, '9,10', @outOrderId2);
    COMMIT;

START TRANSACTION;
	CALL srCreateOrder(@tempUser, 4, false, '1,2', @outOrderId3);
    COMMIT;
    


SELECT @outOrderId0, @outOrderId1, @outOrderId2, @outOrderId3;
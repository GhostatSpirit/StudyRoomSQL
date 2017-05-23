use lvzheng_studyroom;
start transaction;
delete from Slot;
delete from asMember;
delete from RoomOrder;
delete from User;
delete from Room;
delete from Library;

insert into User(userScore, role, username, password)
            values(100, 0, 'lykavin', '123456');
insert into User(userScore, role, username, password)
            values(100, 0, 'ghost', '123456');
insert into User(userScore, role, username, password)
            values(100, 0, 'fadeinblack', '123456');
insert into User(userScore, role, username, password)
            values(100, 0, 'kimi', '123456');
            
insert into Library(libraryName, address, phone)
            values('xintu', 'xxlu', '18621544542');
            
insert into Room(roomName, libraryId, capacity, hasProjector)
            values('101', 
			       (SELECT libraryId FROM Library WHERE libraryName = 'xintu'),
                   4, 
                   true
			);

insert into Room(roomName, libraryId, capacity, hasProjector)
            values('102', 
			       (SELECT libraryId FROM Library WHERE libraryName = 'xintu'),
                   4, 
                   true
			);

insert into Slot(roomId, startTime, endTime, isUsable)
			values((SELECT roomId FROM Room WHERE roomName = '101'),
			       '2017-05-17 15:00:00', '2017-05-17 15:30:00', true
            );

insert into Slot(roomId, startTime, endTime, isUsable)
			values((SELECT roomId FROM Room WHERE roomName = '101'),
			       '2017-05-17 15:30:00', '2017-05-17 16:00:00', true
            );

insert into Slot(roomId, startTime, endTime, isUsable)
			values((SELECT roomId FROM Room WHERE roomName = '101'),
			       '2017-05-17 16:00:00', '2017-05-17 16:30:00', true
            );
SET @tempSlotId0 = LAST_INSERT_ID();
            
insert into Slot(roomId, startTime, endTime, isUsable)
			values((SELECT roomId FROM Room WHERE roomName = '101'),
			       '2017-05-17 16:30:00', '2017-05-17 17:00:00', true
            );
SET @tempSlotId = LAST_INSERT_ID();
SET @tempUserId = (SELECT userId FROM User WHERE username = 'lykavin' LIMIT 1);


-- create slots for room 102
insert into Slot(roomId, startTime, endTime, isUsable)
			values((SELECT roomId FROM Room WHERE roomName = '102'),
			       '2017-05-17 15:00:00', '2017-05-17 15:30:00', true
            );

insert into Slot(roomId, startTime, endTime, isUsable)
			values((SELECT roomId FROM Room WHERE roomName = '102'),
			       '2017-05-17 15:30:00', '2017-05-17 16:00:00', true
            );

insert into Slot(roomId, startTime, endTime, isUsable)
			values((SELECT roomId FROM Room WHERE roomName = '102'),
			       '2017-05-17 16:00:00', '2017-05-17 16:30:00', false
            );
            
insert into Slot(roomId, startTime, endTime, isUsable)
			values((SELECT roomId FROM Room WHERE roomName = '102'),
			       '2017-05-17 16:30:00', '2017-05-17 17:00:00', true
            );


insert into RoomOrder(applicantId, memberNum, status, isPublic, orderPassword)
            values(
				@tempUserId,
                4, 
                0, 
                true, 
			    '123456'
			);
SET @tempOrderId0 = LAST_INSERT_ID();

insert into RoomOrder(applicantId, memberNum, status, isPublic, orderPassword)
            values(
				@tempUserId,
                6, 
                0, 
                false, 
			    '123456'
			);

SET @tempOrderId = LAST_INSERT_ID();

UPDATE Slot SET orderId = @tempOrderId WHERE slotId = @tempSlotId;
UPDATE RoomOrder SET roomId = (SELECT roomId FROM Slot WHERE slotId = @tempSlotId)
			WHERE orderId = @tempOrderId;
UPDATE RoomOrder SET startTime = (SELECT startTime FROM Slot WHERE slotId = @tempSlotId)
			WHERE orderId = @tempOrderId;
UPDATE RoomOrder SET endTime = (SELECT endTime FROM Slot WHERE slotId = @tempSlotId)
			WHERE orderId = @tempOrderId;

UPDATE Slot SET orderId = @tempOrderId0 WHERE slotId = @tempSlotId0;
UPDATE RoomOrder SET roomId = (SELECT roomId FROM Slot WHERE slotId = @tempSlotId0)
			WHERE orderId = @tempOrderId0;
UPDATE RoomOrder SET startTime = (SELECT startTime FROM Slot WHERE slotId = @tempSlotId0)
			WHERE orderId = @tempOrderId0;
UPDATE RoomOrder SET endTime = (SELECT endTime FROM Slot WHERE slotId = @tempSlotId0)
			WHERE orderId = @tempOrderId0;


INSERT INTO asMember(orderId, userId) VALUES (@tempOrderId, @tempUserId);
INSERT INTO asMember(orderId, userId) VALUES (@tempOrderId0, @tempUserId);

commit;

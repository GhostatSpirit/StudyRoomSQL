CREATE DEFINER=`root`@`localhost` PROCEDURE `addSlots`(iroomId int, istartTime datetime, iendTime datetime)
BEGIN
	insert into Slots(roomId,startTime,endTime,available) values(iroomId,istartTime,iendTime,1);
END

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
end

CREATE DEFINER=`root`@`localhost` PROCEDURE `showManagerOrders`(state int)
BEGIN
	select orderId,applicantId,roomId,memberNum,inMemNum,status,isPublic,orderPassword,
    startTime,endTime
	from detailedOrder
    where status=state;
END

CREATE DEFINER=`root`@`localhost` PROCEDURE `showUserOrders`(userId int)
BEGIN
	
	select orderId,detailedOrder.roomId,roomName,libraryId,libraryName,memberNum,inMemNum,status,isPublic,orderPassword,
    score,startTime,endTime
	from detailedOrder join 
	(select Room.roomId,roomName,Room.libraryId,libraryName 
	from Room join Library on Room.libraryId = Library.libraryId) as detailedRoom
	on detailedRoom.roomId=detailedOrder.roomId
	where applicantId=userId;

END
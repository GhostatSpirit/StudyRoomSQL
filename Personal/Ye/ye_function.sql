DELIMITER $$
 
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
DELIMITER ;

DELIMITER $$
create Function getScore(targetUserId int) returns int
BEGIN
    declare targetScore int default 0;
    if(exists(select * from User where User.userId = targetUserId )) then
        select exp(avg(ln(score))) into targetScore 
        from RoomOrder natural join asMember 
        where asMember.userId = targetUserId;
        #set targetScore = finalScore;
    end if;
    return targetScore;
END$$
DELIMITER ;

DELIMITER $$
create Function setSlotUsable(targetAdminId int, targetSlotId int, slotUsableStatus tinyint) returns bool
BEGIN
    declare setSlotSuccess bool default 0;
    if(exists(select * from slot where slot.slotId = targetSlotId )) then
        update slot set slot.isUsable = slotUsableStatus where slot.slotId = targetSlotId;
        set setSlotSuccess = 1; #  Scucess
    else
        set setSlotSuccess = 0; #  Failure
    end if;
    return setSlotSuccess;
END$$
DELIMITER ;

DELiMITER $$
create Function setOrderStatus(targetUserId int, targetOrderId int, targetOrderStatus int) returns bool
BEGIN
    declare setOrderSuccess bool default 0;
    if(exists(select * from RoomOrder where RoomOrder.orderId = targetOrderId) && exists(select * from User where User.userId = targetUserId)) then
        update RoomOrder set RoomOrder.reviewerId = targetUserId where RoomOrder.orderId = targetOrderId;
        update RoomOrder set RoomOrder.status = targetOrderStatus where RoomOrder.orderId = targetOrderId;
        set setOrderSuccess = 1; #  Scucess
    else
        set setOrderSuccess = 0; #  Failure
    end if;
    return setOrderSuccess; 
END$$ 
DELIMITER ;

DELiMITER $$
create Trigger cancelOrderOnSlotUnusable after update on Slot
for each row
begin
    if not new.isUsable then 
        update RoomOrder set status = -1 where orderId = new.orderId;
    end if;
end$$
DELIMITER ;

DELiMITER $$
create Trigger freeSlotsOnOrderCancel after update on RoomOrder
for each row
begin
    if  new.status < 0 then 
        update Slot set orderId = null where orderId = new.orderId;
    end if;
end$$
DELIMITER ;
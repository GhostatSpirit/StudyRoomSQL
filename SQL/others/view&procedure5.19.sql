CREATE
VIEW `detailedorder` AS
    SELECT
        `asmember`.`orderId` AS `orderId`,
        `roomorder`.`applicantId` AS `applicantId`,
        `roomorder`.`roomId` AS `roomId`,
        `roomorder`.`reviewerId` AS `reviewerId`,
        `roomorder`.`scorerId` AS `scorerId`,
        `roomorder`.`memberNum` AS `memberNum`,
        `roomorder`.`status` AS `status`,
        `roomorder`.`isPublic` AS `isPublic`,
        `roomorder`.`orderPassword` AS `orderPassword`,
        `roomorder`.`score` AS `score`,
        `roomorder`.`startTime` AS `startTime`,
        `roomorder`.`endTime` AS `endTime`,
        COUNT(`asmember`.`userId`) AS `inMemNum`
    FROM
        (`roomorder`
        JOIN `asmember` ON ((`roomorder`.`orderId` = `asmember`.`orderId`)))
    WHERE
        1
    GROUP BY `asmember`.`orderId`


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
END


CREATE PROCEDURE `showApplicantOrders`(userId int)
BEGIN

    select orderId,detailedOrder.roomId,roomName,libraryId,libraryName,memberNum,inMemNum,status,isPublic,orderPassword,
    score,startTime,endTime
    from detailedOrder join
    (select Room.roomId,roomName,Room.libraryId,libraryName
    from Room join Library on Room.libraryId = Library.libraryId) as detailedRoom
    on detailedRoom.roomId=detailedOrder.roomId
    where applicantId=userId;

END

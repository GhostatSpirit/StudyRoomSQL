CREATE 
    ALGORITHM = UNDEFINED 
    DEFINER = `root`@`localhost` 
    SQL SECURITY DEFINER
VIEW `detailedorder` AS
    SELECT 
        `total`.`orderId` AS `orderId`,
        `total`.`applicantId` AS `applicantId`,
        `total`.`reviewerId` AS `reviewerId`,
        `total`.`scorerId` AS `scorerId`,
        MIN(`total`.`roomId`) AS `roomId`,
        `total`.`memberNum` AS `memberNum`,
        `total`.`status` AS `status`,
        `total`.`isPublic` AS `isPublic`,
        `total`.`orderPassword` AS `orderPassword`,
        `total`.`inMemNum` AS `inMemNum`,
        `total`.`score` AS `score`,
        MIN(`total`.`startTime`) AS `startTime`,
        MAX(`total`.`endTime`) AS `endTime`
    FROM
        (SELECT 
            `rorder`.`orderId` AS `orderId`,
                `rorder`.`inMemNum` AS `inMemNum`,
                `rorder`.`applicantId` AS `applicantId`,
                `rorder`.`memberNum` AS `memberNum`,
                `rorder`.`status` AS `status`,
                `rorder`.`isPublic` AS `isPublic`,
                `rorder`.`orderPassword` AS `orderPassword`,
                `rorder`.`score` AS `score`,
                `rorder`.`reviewerId` AS `reviewerId`,
                `rorder`.`scorerId` AS `scorerId`,
                `rslot`.`startTime` AS `startTime`,
                `rslot`.`endTime` AS `endTime`,
                `rslot`.`roomId` AS `roomId`
        FROM
            (((SELECT 
            `studyroom`.`roomorder`.`orderId` AS `orderId`,
                `studyroom`.`roomorder`.`applicantId` AS `applicantId`,
                `studyroom`.`roomorder`.`memberNum` AS `memberNum`,
                `studyroom`.`roomorder`.`status` AS `status`,
                `studyroom`.`roomorder`.`orderPassword` AS `orderPassword`,
                `studyroom`.`roomorder`.`isPublic` AS `isPublic`,
                `studyroom`.`roomorder`.`score` AS `score`,
                `studyroom`.`roomorder`.`reviewerId` AS `reviewerId`,
                `studyroom`.`roomorder`.`scorerId` AS `scorerId`,
                COUNT(`studyroom`.`asmember`.`userId`) AS `inMemNum`
        FROM
            (`studyroom`.`roomorder`
        JOIN `studyroom`.`asmember` ON ((`studyroom`.`roomorder`.`orderId` = `studyroom`.`asmember`.`orderId`)))
        GROUP BY `studyroom`.`roomorder`.`orderId`)) `rorder`
        JOIN `studyroom`.`slot` `rslot` ON ((`rslot`.`orderId` = `rorder`.`orderId`)))
        WHERE
            1) `total`
    WHERE
        1
    GROUP BY `total`.`orderId`


CREATE 
    ALGORITHM = UNDEFINED 
    DEFINER = `root`@`localhost` 
    SQL SECURITY DEFINER
VIEW `usableslots` AS
    SELECT 
        `detailedroom`.`libraryId` AS `libraryId`,
        `detailedroom`.`libraryName` AS `libraryName`,
        `detailedroom`.`roomId` AS `roomId`,
        `detailedroom`.`roomName` AS `roomName`,
        `usableslotsets`.`startTime` AS `startTime`,
        `usableslotsets`.`endTime` AS `endTime`,
        ISNULL(`usableslotsets`.`orderId`) AS `available`
    FROM
        (((SELECT 
            `studyroom`.`slot`.`roomId` AS `roomId`,
                `studyroom`.`slot`.`startTime` AS `startTime`,
                `studyroom`.`slot`.`endTime` AS `endTime`,
                `studyroom`.`slot`.`orderId` AS `orderId`
        FROM
            `studyroom`.`slot`
        WHERE
            (`studyroom`.`slot`.`isUsable` = 1))) `usableSlotsets`
        JOIN (SELECT 
            `studyroom`.`room`.`roomId` AS `roomId`,
                `studyroom`.`room`.`libraryId` AS `libraryId`,
                `studyroom`.`library`.`libraryName` AS `libraryName`,
                `studyroom`.`room`.`roomName` AS `roomName`
        FROM
            (`studyroom`.`room`
        JOIN `studyroom`.`library` ON ((`studyroom`.`room`.`libraryId` = `studyroom`.`library`.`libraryId`)))
        WHERE
            1) `detailedRoom` ON ((`usableslotsets`.`roomId` = `detailedroom`.`roomId`)))
    WHERE
        1
/*==============================================================*/
/* DBMS name:      MySQL 5.0                                    */
/* Created on:     2017/5/16 20:50:27                           */
/*==============================================================*/


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
   timeStamp            timestamp not null,
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




DELIMITER $$
create Function setOrderScore (targetOrderId int, userId int, judgeScore int) returns int
BEGIN
	declare setStatus int default 0;
    if(exists(select * from RoomOrder where RoomOrder.orderId = targetOrderId)) then
		update RoomOrder set RommOrder.score = judgeScore 
		where RoomOrder.orderId = targetOrderId;
        set setStatus = 1;
    else set setStatus = 0;
	end if;
	return setStatus;
END$$

create Function modifyScore(targetUserId int) returns bool
BEGIN
	declare modifySucess bool default false;
    if(exists(select * from User where User.userId = targetUserId )) then
		select exp(avg(ln(score))) as finalScore from RoomOrder;
		update User set User.userScore =  finalScore
		where User.userId = targetUserId;
        set modifySucess = true;
	else set modifySucess = false;
    end if;
    return modifySucess;
END$$
DELIMITER ;

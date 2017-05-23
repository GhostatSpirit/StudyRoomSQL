set @t1 = false;
set @t2 = false;
set @t3 = false;
set @t4 = false;

CALL BeMember(3, 1, NULL, @t1);
CALL BeMember(3, 1, '123456', @t2);
CALL BeMember(2, 2, NULL, @t3);
CALL BeMember(2, 2, '123456', @t4);

select @t1, @t2, @t3, @t4;
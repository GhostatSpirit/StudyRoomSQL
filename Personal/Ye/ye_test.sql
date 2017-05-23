#       ( ReviererId, orderId, orderStatus )

select studyroom.setOrderStatus(4, 1, 1);	# Pass

select studyroom.setOrderStatus(4, 2, 0);	# Not Reviewed

select studyroom.setOrderStatus(4, 2, -1);	# Cancel

#		( orderId, scorerId, orderScore )

select studyroom.setOrderScore(1, 4, 1);	# Success

select studyroom.setOrderScore(3, 4, 1);	# Failure

#		( userId ) 

select getScore(1);		# Success

select getScore(5);		# Failure

#       ( adminId, slotId, usableStatus )

select setSlotUsable( 4, 1, 1 );			# Usable

select setSlotUsable( 4, 2, 0 );			# Unusable
from datetime import *
start=date(2017,1,1)
end = date(2018,1,1)
starttime=time(8, 00, 00)
endtime=time (22,00,00)
gap=30

while start<end:
	print "call createADaySlots(\""+str(start)+"\",\""+str(starttime)+"\",\""+str(endtime)+"\","+str(gap)+")"
	start=start+timedelta(days = 1)



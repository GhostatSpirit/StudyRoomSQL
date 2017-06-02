import random

print("START TRANSACTION;")

print("SET @ooid = 0;")
print("SET @suc = 0;")
ptn1 = "CALL srCreateOrder(%d, 8, false, '%s', @ooid);"
ptn2 = "SELECT setOrderStatus(%d, %d, 1);"
ptn3 = "CALL BeMember(%d, %d, %s, @suc);"

def randuser():
    return random.randint(1, 999)

i = 0
base = 0
for day in range(0, 365):
    for h in range(0, 28, 4):
        for room in range(1, 31):
            i += 1
            base += 4
            #base = (day * 28 * 30) + h * 28 + room
            s = "%d,%d,%d,%d" % (base, base + 1, base + 2, base + 3)
            print(ptn1 % (randuser(), s))
            print("SELECT 1;")
            print(ptn2 % (randuser(), i))
            for member in range(5):
                print(ptn3 % (randuser(), i, str(random.randint(0, 1))))

print("COMMIT;")

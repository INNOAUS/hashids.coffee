
# test for collisions with 3 integers

startAt = 0
endAt = 15

# this script will create hashes and check against each other to make sure there are no collisions

hashes = new hashids "this is my salt"

hashObj = {}
total = 0
hash = ""

for i in [startAt..endAt]
	for j in [startAt..endAt]
		for k in [startAt..endAt]
			
			hash = hashes.encrypt i, j, k
			console.log hash+" - "+i+", "+j+", "+k
			
			if hash in hashObj
				console.log "Collision for "+hash+": "+i+", "+j+", "+k+" and "+hashObj[hash]
				hashObj = {}
				break
			else
				hashObj[hash] = i+", "+j+", "+k
			
			total++
			
console.log "Ran through "+total+" hashes."

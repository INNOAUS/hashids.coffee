
# test for speed

numberOfIntsToEncryptAtOnce = 3
startAt = 0
endAt = 100

# this script will encrypt AND decrypt (when it decrypts it checks that hash is legit)

hashes = new hashids()

microtime = ->
	new Date().getTime() / 1000

total = 0
timeStart = microtime()
timeStop = 0

for i in [startAt..endAt]
	
	numbers = []
	for j in [0...numberOfIntsToEncryptAtOnce]
		numbers[j] = i
	
	hash = hashes.encrypt.apply hashes, numbers
	numbers = hashes.decrypt hash
	
	console.log hash+" - "+numbers
	total++
	
timeStop = microtime()
console.log "Total hashes created: "+total
console.log "Total time: "+(timeStop - timeStart)

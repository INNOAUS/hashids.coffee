
# creating class object with hash length of 8
hashids = new Hashids "this is my salt", 8

# encoding several numbers into one id (length of id is going to be at least 8)
id = hashids.encode 1337, 5

# decoding the same id
numbers = hashids.decode id

# numbers is always an array
console.log id, numbers

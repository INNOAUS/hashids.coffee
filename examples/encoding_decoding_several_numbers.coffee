
# creating class object
hashids = new Hashids "this is my salt"

# encoding several numbers into one id
id = hashids.encode 1337, 5, 77, 12345678

# decoding that hash
numbers = hashids.decode id

# numbers is always an array
console.log id, numbers

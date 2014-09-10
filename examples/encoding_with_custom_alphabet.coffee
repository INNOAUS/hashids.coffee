
# creating class object with custom alphabet
hashids = new Hashids "this is my salt", 0, "abcdefgh123456789"

# encoding several numbers into one id
id = hashids.encode 1, 2, 3, 4

# decoding that id
numbers = hashids.decode id

# numbers is always an array
console.log id, numbers

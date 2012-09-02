
# creating class object
hashes = new hashids "this is my salt"

# encrypting several numbers into one hash
hash = hashes.encrypt 1337, 5, 77, 12345678

# decrypting that hash
numbers = hashes.decrypt hash

# numbers is always an array
console.log hash, numbers

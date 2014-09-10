
# creating class object
hashids = new Hashids "this is my salt"

# encoding one number
id = hashids.encode 1337

# id is always a string
console.log id

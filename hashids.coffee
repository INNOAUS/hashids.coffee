
###
	hashids
	http://www.hashids.org/coffeescript/
	(c) 2012 Ivan Akimov
	
	https://github.com/ivanakimov/hashids.coffee
	hashids may be freely distributed under the MIT license.
###

class hashids
	
	constructor: (@salt = "", @minHashLength = 0, @alphabet = "xcS4F6h89aUbidefI7fjkyunopqrsgCYE5GHTCKLHMtARXz") ->
		
		@version = "0.1.2"
		@primes = [2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43]
		
		@seps = []
		@guards = []
		
		if alphabet
			@alphabet = ""
			for char in alphabet
				 @alphabet += char if @alphabet.indexOf(char) is -1
		
		throw "Alphabet must contain at least 4 unique characters." if @alphabet.length < 4
		
		for prime in @primes
			
			if @alphabet[prime - 1] isnt undefined
				ch = @alphabet[prime - 1]
				@seps.push ch
				@alphabet = @alphabet.replace(new RegExp(ch, "g"), " ")
			else
				break
			
		for index in [0, 4, 8, 12]
			
			if @seps[index] isnt undefined
				@guards.push @seps[index]
				@seps.splice index, 1
		
		@alphabet = @alphabet.replace /\s/g, ""
		@alphabet = @consistentShuffle @alphabet, @salt
		
	encrypt: ->
		
		ret = ""
		numbers = []
		
		for arg in arguments
			numbers.push arg
		
		if not numbers.length
			return ret
		
		for number in numbers
			return ret if typeof number isnt "number" or number < 0
		
		@encode numbers, @alphabet, @salt, @minHashLength
		
	decrypt: (hash) ->
		
		ret = []
		
		return ret if not hash.length or typeof hash isnt "string"
		@decode hash
		
	encode: (numbers, alphabet, salt, minHashLength) ->
		
		ret = ""
		seps = @consistentShuffle(@seps, numbers).split ""
		lotteryChar = ""
		
		for number, i in numbers
			
			if not i
				
				lotterySalt = numbers.join "-"
				for n in numbers
					lotterySalt += "-" + (n + 1) * 2
				
				lottery = @consistentShuffle alphabet, lotterySalt
				ret += lotteryChar = lottery[0]
				
				alphabet = lotteryChar + alphabet.replace(new RegExp(lotteryChar, "g"), "")
				
			alphabet = @consistentShuffle alphabet, (lotteryChar.charCodeAt(0) & 12345) + "" + salt
			ret += @hash number, alphabet
			
			if (i + 1) < numbers.length
				sepsIndex = (number + i) % seps.length
				ret += seps[sepsIndex]
			
		if ret.length < minHashLength
			
			firstIndex = 0
			for number, i in numbers
				firstIndex += (i + 1) * number
			
			guardIndex = firstIndex % @guards.length
			guard = @guards[guardIndex]
			
			ret = guard + ret
			if ret.length < minHashLength
				
				guardIndex = (guardIndex + ret.length) % @guards.length
				guard = @guards[guardIndex]
				
				ret += guard
				
		while ret.length < minHashLength
			
			padArray = [alphabet[1].charCodeAt(0), alphabet[0].charCodeAt(0)]
			padLeft = @encode padArray, alphabet, salt
			padRight = @encode padArray, alphabet, padArray.join ""
			
			ret = padLeft + ret + padRight
			excess = ret.length - minHashLength
			
			ret = ret.substr excess / 2, minHashLength if excess > 0
			alphabet = @consistentShuffle alphabet, salt + ret
			
		ret
		
	decode: (hash) ->
		
		ret = []
		
		if hash.length
			
			originalHash = hash
			alphabet = ""
			lotteryChar = ""
			
			for guard in @guards
				hash = hash.replace new RegExp(guard, "g"), " "
			
			hashSplit = hash.split " "
			
			i = 0
			i = 1 if hashSplit.length is 3 or hashSplit.length is 2
			
			hash = hashSplit[i]
			
			for sep in @seps
				hash = hash.replace new RegExp(sep, "g"), " "
			
			hashArray = hash.split " "
			for subHash, i in hashArray
				
				if subHash.length
					
					if not i
						lotteryChar = hash[0]
						subHash = subHash.substr 1
						alphabet = lotteryChar + @alphabet.replace lotteryChar, ""
					
					if alphabet.length and lotteryChar.length
						alphabet = @consistentShuffle alphabet, (lotteryChar.charCodeAt(0) & 12345) + "" + @salt
						ret.push @unhash subHash, alphabet
					
			if @encrypt.apply(@, ret) isnt originalHash
				ret = []
		
		ret
		
	consistentShuffle: (alphabet, salt) ->
		
		ret = ""
		
		alphabet = alphabet.join "" if typeof alphabet is "object"
		salt = salt.join "" if typeof salt is "object"
		
		if alphabet.length
			
			alphabetArray = alphabet.split ""
			saltArray = salt.split ""
			sortingArray = []
			
			saltArray.push "" if not saltArray.length
			
			for saltChar in saltArray
				sortingArray.push saltChar.charCodeAt(0) or 0
			
			for int, i in sortingArray
				
				add = true
				
				k = i
				while k isnt sortingArray.length + i - 1
					
					nextIndex = (k + 1) % sortingArray.length
					
					if add
						sortingArray[i] += sortingArray[nextIndex] + (k * i)
					else
						sortingArray[i] -= sortingArray[nextIndex]
					
					add = not add
					k++
					
				sortingArray[i] = Math.abs sortingArray[i]
				
			i = 0
			while alphabetArray.length
				
				alphabetSize = alphabetArray.length
				pos = sortingArray[i]
				
				pos %= alphabetSize if pos >= alphabetSize
				
				ret += alphabetArray[pos]
				alphabetArray.splice pos, 1
				
				i = ++i % sortingArray.length
			
		ret
				
	hash: (number, alphabet) ->
		
		hash = ""
		alphabetLength = alphabet.length
		
		while true
			hash = alphabet[number % alphabetLength] + hash
			number = parseInt number / alphabetLength
			break if not number
		
		hash
		
	unhash: (hash, alphabet) ->
		
		number = 0
		
		for char, i in hash
			pos = alphabet.indexOf char
			number += pos * Math.pow alphabet.length, hash.length - i - 1
		
		number
	
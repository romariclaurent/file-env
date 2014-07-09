fs = require("fs")

splitMultilineString = (lines) ->
	content = undefined
	return []  if typeof lines isnt "string"
	lines = lines.trim().split("\n")
	# remove any empty lines
	lines.filter (line) -> line.trim().length
		


getKeyAndValueFromLine = (line) ->
	key_value_array = line.match(/^\s*([\w\.\-]+)\s*=\s*(.*)?\s*$/)
	return unless key_value_array
	
	key = key_value_array[1]
	value = key_value_array[2]
	value = ""  if typeof value is "undefined"
	value = value.replace(/\\n/g, "\n")  if value.charAt(0) is "\"" and value.charAt(value.length - 1) is "\""
	value = value.replace(/(^['"]|['"]$)/g, "") # replace first and last quotes only
	
	return [key, value]
	

setEnv = (env) ->
	process.env[key] = process.env[key] or value for key, value of env
		
parseEnv = (data) ->
	
	payload = {}
	
	lines = splitMultilineString(data.toString())
	
	keys_and_values = lines.map(getKeyAndValueFromLine).filter(Array.isArray)
	
	keys_and_values.forEach (pair) ->
		key = pair[0]
		value = pair[1]
		payload[key] = value.trim()
		return		

	payload


module.exports = (currentDir) ->
	
	filepath = currentDir + "/.env"
	# look in parent folder if not found
	
	filepath = currentDir + "/../" + ".env" unless fs.existsSync(filepath)
	
	return unless fs.existsSync(filepath)

	console.log "loading environment variables from" + filepath

	try
		data = fs.readFileSync(filepath)				
	catch e
		return false

	setEnv parseEnv(data)
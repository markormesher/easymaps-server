express = require('express')
bodyParser = require('body-parser')
rfr = require('rfr')
pJson = rfr('./package.json')
c = rfr('./helpers/constants')

# server config
app = express()
app.use(bodyParser.urlencoded({extended: false}))

# squash favicon requests
app.use('/favicon.ico', (req, res) -> res.end())

# TODO: real routes
app.use('*', (req, res) ->
	res.json(
		message: 'Hello World'
		version: pJson.version
	)
)

# 404 error handler
app.use((req, res, next) ->
	err = new Error('Not Found')
	err.status = 404
	next(err)
)

# generic error handler
app.use((error, req, res, next) ->
	res.status(error.status || 500)
	res.json(error)
)

app.listen(c.PORT)
console.log("#{pJson.name} is listening on port #{c.PORT}")
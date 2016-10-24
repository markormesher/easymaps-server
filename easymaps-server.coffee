express = require('express')
rfr = require('rfr')
path = require('path')
flash = require('express-flash')
session = require('express-session')
bodyParser = require('body-parser')
cookieParser = require('cookie-parser')
passport = require('passport')
pJson = rfr('./package.json')
c = rfr('./helpers/constants')

# server config
app = express()
app.set('views', path.join(__dirname, 'views'));
app.set('view engine', 'pug');
app.use(flash())
app.use(bodyParser.urlencoded({ extended: true }))
app.use(cookieParser())
app.use(session({
	secret: 'g'
	resave: false
	saveUninitialized: false
}))

# auth config
rfr('./helpers/passport-config')(passport)
app.use(passport.initialize())
app.use(passport.session())

# routes
app.use('/', rfr('./controllers/_root'))
app.use('/auth', rfr('./controllers/auth'))
app.use('/labellings', rfr('./controllers/labellings'))
app.use('/scan-logs', rfr('./controllers/scan-logs'))

# squash favicon requests
app.use('/favicon.ico', (req, res) -> res.end())

# 404 error handler
app.use((req, res, next) ->
	err = new Error('Not Found')
	err.status = 404
	next(err)
)

# generic error handler
app.use((error, req, res, next) ->
	console.log(error)
	res.status(error.status || 500)
	res.json(error)
)

app.listen(c.PORT)
console.log("#{pJson.name} is listening on port #{c.PORT}")
LocalPassportStrategy = require('passport-local').Strategy
crypto = require('crypto')

sha256 = (data) -> crypto.createHash('sha256').update(data).digest('hex')

users = {
	'mark': {
		password: '97c10efe01d5c9c88704a12d361d8429b3a6aa2412290a0773109d5d2d603d5e'
		name: 'Mark Ormesher'
	}
}

module.exports = (passport) ->
	passport.serializeUser((user, done) -> done(null, JSON.stringify(user)))

	passport.deserializeUser((user, done) -> done(null, JSON.parse(user)))

	passport.use(new LocalPassportStrategy({ passReqToCallback: true }, (req, username, password, done) ->
			if (users[username] && users[username].password == sha256(password))
				return done(null, users[username])

			req.flash('error', 'bad-username-or-password')
			return done(null, false)
		)
	)
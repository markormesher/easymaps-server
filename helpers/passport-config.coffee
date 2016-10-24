LocalPassportStrategy = require('passport-local').Strategy

module.exports = (passport) ->
	passport.serializeUser((user, done) -> done(null, JSON.stringify(user)))

	passport.deserializeUser((user, done) -> done(null, JSON.parse(user)))

	passport.use(new LocalPassportStrategy(
		{ passReqToCallback: true },
		(req, username, password, done) ->
			if (username == 'mark' && password == 'pass')
				return done(null, { name: 'Mark Ormesher' })
			else
				req.flash('error', 'bad-username-or-password')
				return done(null, false)
		)
	)
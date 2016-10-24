router = require('express').Router()
passport = require('passport')

router.get('/', (req, res) -> res.redirect('/auth/login'))

router.get('/login', (req, res) ->
	res.render('auth/login', {
		meta: {
			title: 'Login'
			icon: 'fa-key'
		}
		errors: req.flash('error')
	})
)

router.post('/login', passport.authenticate('local', {
	successRedirect: '/'
	failureRedirect: '/auth/login'
	failureFlash: true
}))

module.exports = router
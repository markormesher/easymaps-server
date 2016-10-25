router = require('express').Router()
passport = require('passport')

router.get('/', (req, res) -> res.redirect('/auth/login'))

router.get('/login', (req, res) ->
	res.render('auth/login', {
		meta: {
			page: 'login'
			title: 'Login'
			icon: 'fa-key'
		}
		errors: req.flash('error')
		info: req.flash('info')
	})
)

router.post('/login', passport.authenticate('local', {
	successRedirect: '/'
	failureRedirect: '/auth/login'
}))

router.get('/logout', (req, res) ->
	req.logout()
	req.flash('info', 'logged-out')
	res.redirect('/auth/login')
)

module.exports = router
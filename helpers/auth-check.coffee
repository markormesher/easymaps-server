funcs = {
	checkOnly: (req, res, next)->
		if (req.user)
			res.locals.user = req.user
		next()

	checkAndRefuse: (req, res, next)->
		funcs.checkOnly(res, res, next)
		if (!req.user)
			req.flash('error', 'login-required')
			res.redirect('/auth/login')
}

module.exports = funcs
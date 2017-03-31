router = require('express').Router()
rfr = require('rfr')
authCheck = rfr('./helpers/auth-check')
c = rfr('./helpers/constants')

router.get('/', authCheck.checkAndRefuse, (req, res) ->
	fs = require('fs')
	fs.readFile(c['WITHDRAWAL_FILE'], 'utf8', (err, data) ->
		if (err)
			withdrawnIds = []
		else
			withdrawnIds = data.split('\n').filter((x) -> x.length > 0)

		res.render('withdrawal/index', {
			meta: {
				title: 'Withdrawal'
				icon: 'fa-trash-o'
				page: 'withdrawal'
			}
			users: withdrawnIds
		})
	)
)

router.post('/register', (req, res) ->
	id = req.body.userId
	fs = require('fs')
	fs.appendFile(c['WITHDRAWAL_FILE'], "\n#{id}", (err) ->
		res.status(if (err) then 400 else 200)
		res.end()
	)
)

module.exports = router

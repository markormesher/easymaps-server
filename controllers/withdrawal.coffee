router = require('express').Router()
multer = require('multer')
fs = require('fs')
rfr = require('rfr')
authCheck = rfr('./helpers/auth-check')

PATH = 'uploads/withdrawals.txt'

router.get('/', authCheck.checkAndRefuse, (req, res) ->
	fs.readFile(PATH, 'utf8', (err, data) ->
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
	fs.appendFile(PATH, "\n#{id}", (err) ->
		res.status(if (err) then 400 else 200)
		res.end()
	)
)

module.exports = router

router = require('express').Router()
rfr = require('rfr')
data = rfr('./uploads/leader-board-data.json')

router.get('/', (req, res) ->
	delete data.users['9ebbfd45-01f3-4535-a1fa-d54469f64463']
	res.render('scanning-stats/index', {
		meta: {
			title: 'Scanning Stats'
			icon: 'fa-trophy'
			page: 'scanning-stats'
		}
		updated: data.updated
		users: data.users
	})
)
module.exports = router
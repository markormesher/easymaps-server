router = require('express').Router()
rfr = require('rfr')
data = rfr('./uploads/leader-board-data.json')

router.get('/', (req, res) ->
	res.render('scanning-stats/index', {
		meta: {
			title: 'Scanning Stats'
			icon: 'fa-trophy'
			page: 'scanning-stats'
		}
		updated: data['updated']
		users: data['users']
	})
)
module.exports = router

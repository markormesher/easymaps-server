router = require('express').Router()
crypto = require('crypto')
rfr = require('rfr')
secrets = rfr('./secrets.json')

sha256 = (data) -> crypto.createHash('sha256').update(data).digest('hex')

router.post('/', (req, res) ->
	id = req.body.id
	secret = req.body.secret

	winners = require('../helpers/winners')

	if (Object.keys(winners).length == 0)
		res.send('TOO SOON')

	else if (!winners[id])
		res.send('NOPE')

	else if (winners[id].secret != secret)
		res.send('NICE TRY')

	else
		res.send(winners[id].prize)

	res.end()
)

module.exports = router

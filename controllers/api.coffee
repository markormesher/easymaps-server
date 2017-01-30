router = require('express').Router()
fs = require('fs')
rfr = require('rfr')
pJson = rfr('./package.json')

getLatest = (path, prefix, callback) ->
	latestTimestamp = -1
	latestFile = null
	fs.readdir(path, (err, files) ->
		if (err) then return next(err)
		filesToConsider = files.filter((x) -> x.substr(0, prefix.length) == prefix)
		for f in filesToConsider
			[network, timestamp] = f.replace('.txt', '').split('-')
			if (timestamp > latestTimestamp)
				latestTimestamp = timestamp
				latestFile = f

		callback(latestTimestamp, latestFile)
	)

router.get('/', (req, res) ->
	res.json({
		version: pJson.version
	})
)

router.get('/data-packs/:network/stats', (req, res) ->
	network = req.params['network']
	getLatest('uploads/data-packs', network, (latestTimestamp) ->
		if (latestTimestamp > 0)
			res.json({
				network: network
				latestVersion: parseInt(latestTimestamp)
			})
		else
			res.status(404)
			res.json({
				error: 'No data packs for network'
			})
	)
)

router.get('/labellings/:network/stats', (req, res) ->
	network = req.params['network']
	getLatest('uploads/labellings', network, (latestTimestamp) ->
		if (latestTimestamp > 0)
			res.json({
				network: network
				latestVersion: parseInt(latestTimestamp)
			})
		else
			res.status(404)
			res.json({
				error: 'No labellings for network'
			})
	)
)

router.get('/data-packs/:network/latest', (req, res) ->
	network = req.params['network']
	getLatest('uploads/data-packs', network, (latestTimestamp, latestFile) ->
		if (latestFile)
			fs.createReadStream('uploads/data-packs/' + latestFile).pipe(res)
		else
			res.status(404)
			res.json({
				error: 'No data packs for network'
			})
	)
)

router.get('/labellings/:network/latest', (req, res) ->
	network = req.params['network']
	getLatest('uploads/labellings', network, (latestTimestamp, latestFile) ->
		if (latestFile)
			fs.createReadStream('uploads/labellings/' + latestFile).pipe(res)
		else
			res.status(404)
			res.json({
				error: 'No labellings for network'
			})
	)
)

module.exports = router

router = require('express').Router()
rfr = require('rfr')
pJson = rfr('./package.json')
constants = rfr('./helpers/constants')

getLatest = (path, prefix, callback) ->
	latestTimestamp = -1
	latestFile = null
	fs = require('fs')
	fs.readdir(path, (err, files) ->
		if (err) then return next(err)
		filesToConsider = files.filter((x) -> x.substr(0, prefix.length) == prefix)
		for f in filesToConsider
			[network, timestamp] = f.replace('.txt', '').replace('.json', '').split('-')
			if (timestamp > latestTimestamp)
				latestTimestamp = timestamp
				latestFile = f

		callback(latestTimestamp, latestFile)
	)

router.get('/', (req, res) ->
	res.json({
		version: pJson['version']
	})
)

router.get('/data-packs/:network/stats', (req, res) ->
	network = req.params['network']
	getLatest(constants['DATA_PACK_PATH'], network, (latestTimestamp) ->
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
	getLatest(constants['LABELLING_PATH'], network, (latestTimestamp) ->
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
	getLatest(constants['DATA_PACK_PATH'], network, (latestTimestamp, latestFile) ->
		if (latestFile)
			fs = require('fs')
			fs.createReadStream(constants['DATA_PACK_PATH'] + '/' + latestFile).pipe(res)
		else
			res.status(404)
			res.json({
				error: 'No data packs for network'
			})
	)
)

router.get('/labellings/:network/latest', (req, res) ->
	network = req.params['network']
	getLatest(constants['LABELLING_PATH'], network, (latestTimestamp, latestFile) ->
		if (latestFile)
			fs = require('fs')
			fs.createReadStream(constants['LABELLING_PATH'] + '/' + latestFile).pipe(res)
		else
			res.status(404)
			res.json({
				error: 'No labellings for network'
			})
	)
)

module.exports = router

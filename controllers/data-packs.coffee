router = require('express').Router()
multer = require('multer')
fs = require('fs')
zipper = require('node-zip')
rfr = require('rfr')
authCheck = rfr('./helpers/auth-check')

PATH = 'uploads/data-packs'

uploader = multer({
	storage: multer.diskStorage({
		destination: PATH + '/'
		filename: (req, file, cb) ->
			req.uploadErrors = []
			if (file.mimetype != 'text/plain')
				req.uploadErrors.push('MIME type must be text/plain')

			if (!req.body['network'])
				req.uploadErrors.push('No network specified')

			if (req.uploadErrors.length)
				cb(Error(req.uploadErrors.join(', ')))
				return

			network = req.body['network']
			cb(null, "#{network}-#{(new Date()).getTime()}.txt")
	})
})

router.get('/', authCheck.checkAndRefuse, (req, res, next) ->
	fs.readdir(PATH, (err, files) ->
		if (err) then return next(err)

		# versions (grouped by network)
		output = {}
		for f in files
			[network, timestamp] = f.replace('.txt', '').split('-')

			if (!(network of output))
				output[network] = { files: 0, latest: -1 }

			output[network].files++
			if (output[network].latest < timestamp)
				output[network].latest = timestamp

		res.render('data-packs/index', {
			meta: {
				title: 'Data Packs'
				icon: 'fa-tags'
				page: 'data-packs'
			}
			files: output
		})
	)
)

router.get('/download/:network', authCheck.checkAndRefuse, (req, res, next) ->
	network = req.params['network']
	if (!network)
		next(Error('No network specified'))
		return

	fileToSend = null
	maxTimestamp = -1

	# get list of files, filtered by network prefix, and pick the latest
	fs.readdir(PATH, (err, files) ->
		if (err) then return next(err)
		filesToConsider = files.filter((x) -> x.substr(0, network.length) == network)
		for f in filesToConsider
			[network, timestamp] = f.replace('.txt', '').split('-')
			if (timestamp > maxTimestamp)
				maxTimestamp = timestamp
				fileToSend = f

		done(fileToSend)
	)

	# send zip file to client
	done = (file) ->
		res.writeHead(200, {
			'Content-disposition': "attachment; filename=#{network}-#{maxTimestamp}.txt",
			'Content-type': 'text/plain'
		})
		fs.createReadStream(PATH + '/' + file).pipe(res)
)

router.get('/download-all/:network', authCheck.checkAndRefuse, (req, res, next) ->
	network = req.params['network']
	if (!network)
		next(Error('No network specified'))
		return

	zip = zipper()
	filesToZip = []

	# get list of files, filtered by network prefix
	fs.readdir(PATH, (err, files) ->
		if (err) then return next(err)
		filesToZip = files.filter((x) -> x.substr(0, network.length) == network)
		addFile(0)
	)

	# read file i asynchronously and add to zip collection
	addFile = (i) ->
		if (i == filesToZip.length)
			done()
		else
			fs.readFile("#{PATH}/#{filesToZip[i]}", (err, data) ->
				if (err) then return next(err)
				zip.file(filesToZip[i], data)
				addFile(i + 1)
			)

	# send zip file to client
	done = () ->
		res.setHeader('Content-disposition', "attachment; filename=#{network}-data-packs.zip")
		res.setHeader('Content-type', 'application/zip')
		res.end(Buffer(zip.generate({ base64: false, compression: 'DEFLATE' }), 'binary'))
)

router.get('/upload', authCheck.checkAndRefuse, (req, res) ->
	res.render('data-packs/upload', {
		meta: {
			title: 'Upload Data Packs'
			icon: 'fa-tags'
			page: 'data-packs'
		}
	})
)

router.post('/upload', authCheck.checkAndRefuse, (req, res) ->
	uploader.single('file')(req, res, (err) ->
		if (err)
			res.status(400)
			res.json(req.uploadErrors)
		else
			res.redirect('/data-packs')
	)
)

module.exports = router

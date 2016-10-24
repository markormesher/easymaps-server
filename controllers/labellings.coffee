router = require('express').Router()
multer = require('multer')
fs = require('fs')
zipper = require('node-zip')
rfr = require('rfr')
c = rfr('./helpers/constants')

PATH = 'uploads/labellings'

uploader = multer({
	storage: multer.diskStorage({
		destination: PATH
		filename: (req, file, cb) ->
			req.uploadErrors = []
			if (file.mimetype != 'text/plain')
				req.uploadErrors.push('MIME type must be text/plain')

			if (!req.body['network'])
				req.uploadErrors.push('No network specified')

			if (req.uploadErrors.length)
				cb(Error(req.uploadErrors.join(', ')))
				return

			# callback with new filename
			network = req.body['network']
			cb(null, "#{network}-#{Date().now}.txt")
	})
})

router.get('/', (req, res, next) ->
	fs.readdir(PATH, (err, files) ->
		if (err) then return next(err)

		# versions (both grouped by network)
		output = {}
		for f in files
			[network, timestamp] = f.replace('.txt', '').split('-')

			if (!(network of output))
				output[network] = {files: 0, latest: -1}

			output[network].files++
			if (output[network].latest < timestamp)
				output[network].latest = timestamp

		res.render('labellings/index', {
			meta: {
				title: 'Network Labellings'
				icon: 'fa-tags'
				page: 'labellings'
			}
			files: output
		})
	)
)

router.get('/download/:network', (req, res, next) ->
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
		console.log(file)
		res.writeHead(200, {
			'Content-disposition': "attachment; filename=#{network}-#{maxTimestamp}.txt",
			'Content-type': 'text/plain'
		})
		fs.createReadStream(PATH + '/' + file).pipe(res)
)

router.get('/download-all/:network', (req, res, next) ->
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
		res.setHeader('Content-disposition', "attachment; filename=#{network}-labellings.zip")
		res.setHeader('Content-type', 'application/zip')
		res.end(Buffer(zip.generate({base64: false, compression: 'DEFLATE'}), 'binary'))
)

router.post('/upload', (req, res) ->
	uploader.single('file')(req, res, (err) ->
		if (err)
			res.status(400)
			res.json(req.uploadErrors)
		else
			res.status(200)
			res.end()
	)
)

module.exports = router
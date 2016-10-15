router = require('express').Router()
multer = require('multer')
fs = require('fs')
zipper = require('node-zip')
rfr = require('rfr')
c = rfr('./helpers/constants')

uploader = multer({
	storage: multer.diskStorage({
		destination: 'uploads/'
		filename: (req, file, cb) ->
			req.uploadErrors = []
			if (file.mimetype != 'text/plain')
				req.uploadErrors.push('MIME type must be text/plain')

			if (!c.LOG_FILE_NAME_FORMAT.test(file.originalname))
				req.uploadErrors.push('File name does not match expected format')

			if (!req.body['network'])
				req.uploadErrors.push('No network specified')

			if (!req.body['userId'])
				req.uploadErrors.push('No user ID specified')

			if (req.uploadErrors.length)
				cb(Error(req.uploadErrors.join(', ')))
				return

			timestamp = file.originalname.replace('.txt', '')
			network = req.body['network']
			userId = req.body['userId']
			if (!c.USER_ID_FORMAT.test(userId)) then userId = 'unknown'

			# callback with new filename
			cb(null, "#{network}-#{timestamp}-#{userId}.txt")
	})
})

router.get('/', (req, res, next) ->
	fs.readdir('uploads', (err, files) ->
		if (err) then return next(err)

		# count files and collect unique users (both grouped by network)
		output = {}
		for f in files
			[network, timestamp, userId...] = f.replace('.txt', '').split('-')
			userId = userId.join('-')

			if (!(network of output))
				output[network] = {files: 0, users: []}

			output[network].files++
			if (output[network].users.indexOf(userId) == -1)
				output[network].users.push(userId)

		# reduce unique users list to count only
		for network, data of output
			output[network].users = data.users.length

		res.render('scan-logs/index', {
			meta: {
				title: 'Scan Logs'
				page: 'scan-logs'
			}
			files: output
		})
	)
)

router.get('/download-network/:network', (req, res, next) ->
	network = req.params['network']
	if (!network)
		next(Error('No network specified'))
		return

	zip = zipper()
	filesToZip = []

	# get list of files, filtered by network prefix
	fs.readdir('uploads', (err, files) ->
		if (err) then return next(err)
		filesToZip = files.filter((x) -> x.substr(0, network.length) == network)
		addFile(0)
	)

	# read file i asynchronously and add to zip collection
	addFile = (i) ->
		if (i == filesToZip.length)
			done()
		else
			fs.readFile("uploads/#{filesToZip[i]}", (err, data) ->
				if (err) then return next(err)
				zip.file(filesToZip[i], data)
				addFile(i + 1)
			)

	# send zip file to client
	done = () ->
		res.setHeader('Content-disposition', "attachment; filename=#{network}.zip")
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
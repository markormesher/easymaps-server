router = require('express').Router()
multer = require('multer')
fs = require('fs')
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

			cb(null, "#{network}-#{timestamp}-#{userId}.txt")
	})
})

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

router.get('/', (req, res, next) ->
	fs.readdir('uploads', (err, files) ->
		if (err) then return next(err)

		output = {}
		for f in files
			[network, timestamp, user...] = f.replace('.txt', '').split('-')
			user = user.join('-')

			if (!(network of output)) then output[network] = []
			output[network].push(f)

		res.render('scan-logs/index', {
			meta: {
				title: 'Scan Logs'
				page: 'scan-logs'
			}
			files: output
		})
	)
)

module.exports = router
rfr = require('rfr')
server = rfr('./easymaps-server.coffee')
constants = rfr('./helpers/constants')

chai = require('chai')
chai.use(require('chai-http'))
expect = chai.expect

describe('Withdrawal controller', () ->

	originalReadFile = {}
	originalAppendFile = {}

	beforeEach(() ->
		fs = require('fs')
		originalReadFile = fs.readFile
		originalAppendFile = fs.appendFile
	)

	afterEach(() ->
		fs = require('fs')
		fs.readFile = originalReadFile
		fs.appendFile = originalAppendFile
	)

	describe('GET /withdrawal', () ->

		it('Should allow unauthorised requests', (done) ->
			chai.request(server)
				.get('/withdrawal')
				.redirects(0)
				.end((err, res) ->
					expect(err).to.be.null
					expect(res.status).to.equal(200)
					done()
				)
			return
		)

		it('Should list withdrawn IDs', (done) ->
			require('fs').readFile = (name, format, cb) -> cb(null, 'test-id-1\ntest-id-2\ntest-id-3')

			chai.request(server)
				.get('/withdrawal')
				.end((err, res) ->
					expect(err).to.be.null
					expect(res.text).to.contain('<code>test-id-1</code>')
					expect(res.text).to.contain('<code>test-id-2</code>')
					expect(res.text).to.contain('<code>test-id-3</code>')
					done()
			)
			return
		)
	)

	describe('POST /withdrawal/register', () ->

		it('Should append ID', (done) ->
			appended = ''
			require('fs').appendFile = (name, content, cb) ->
				appended = content
				cb(null)

			chai.request(server)
				.post('/withdrawal/register')
				.set('content-type', 'application/x-www-form-urlencoded')
				.send({ userId: 'test-id' })
				.end((err) ->
					expect(err).to.be.null
					expect(appended).to.equal('\ntest-id')
					done()
			)
			return
		)
	)

)


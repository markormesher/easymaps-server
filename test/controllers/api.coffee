rfr = require('rfr')
server = rfr('./easymaps-server.coffee')

chai = require('chai')
chai.use(require('chai-http'))
expect = chai.expect
helpers = rfr('./helpers/test-helpers')

describe('API controller', () ->

	originalReaddir = {}
	originalCreateReadStream = {}

	beforeEach(() ->
		fs = require('fs')
		originalReaddir = fs.readdir
		originalCreateReadStream = fs.createReadStream

		fs.readdir = (path, cb) ->
			cb(null, [
				'london-01.txt'
				'london-02.txt'
				'london-03.txt'
				'london-04.txt'
			])
	)

	afterEach(() ->
		fs = require('fs')
		fs.readdir = originalReaddir
		fs.createReadStream = originalCreateReadStream
	)

	describe('GET /api', () ->

		it('Should allow unauthorised requests', (done) ->
			chai.request(server)
				.get('/api')
				.redirects(0)
				.end((err, res) ->
					expect(res.status).to.equal(200)
					done()
				)
			return
		)
	)

	describe('GET /api/data-packs/:network:/stats', () ->

		it('Should fail for invalid network', (done) ->
			chai.request(server)
				.get('/api/data-packs/not-a-real-network/stats')
				.redirects(0)
				.end((err, res) ->
					expect(res.status).to.equal(404)
					done()
			)
			return
		)

		it('Should succeed for valid network', (done) ->
			chai.request(server)
				.get('/api/data-packs/london/stats')
				.redirects(0)
				.end((err, res) ->
					expect(res.status).to.equal(200)
					jsonRes = JSON.parse(res.text)
					expect(jsonRes.latestVersion).to.equal(4)
					done()
			)
			return
		)
	)

	describe('GET /api/data-packs/:network:/latest', () ->

		it('Should fail for invalid network', (done) ->
			chai.request(server)
				.get('/api/data-packs/not-a-real-network/latest')
				.redirects(0)
				.end((err, res) ->
					expect(res.status).to.equal(404)
					done()
			)
			return
		)

		it('Should succeed for valid network', (done) ->
			Readable = require('stream').Readable
			stream = new Readable
			stream.push('test content')
			stream.push(null)
			require('fs').createReadStream = () -> stream

			chai.request(server)
				.get('/api/data-packs/london/latest')
				.redirects(0)
				.end((err, res) ->
					expect(res.status).to.equal(200)
					expect(res.text).to.equal('test content')
					done()
			)
			return
		)
	)

	describe('GET /api/labellings/:network:/stats', () ->

		it('Should fail for invalid network', (done) ->
			chai.request(server)
				.get('/api/labellings/not-a-real-network/stats')
				.redirects(0)
				.end((err, res) ->
					expect(res.status).to.equal(404)
					done()
				)
			return
		)

		it('Should succeed for valid network', (done) ->
			chai.request(server)
				.get('/api/labellings/london/stats')
				.redirects(0)
				.end((err, res) ->
					expect(res.status).to.equal(200)
					jsonRes = JSON.parse(res.text)
					expect(jsonRes.latestVersion).to.equal(4)
					done()
				)
			return
		)
	)

	describe('GET /api/labellings/:network:/latest', () ->

		it('Should fail for invalid network', (done) ->
			chai.request(server)
				.get('/api/labellings/not-a-real-network/latest')
				.redirects(0)
				.end((err, res) ->
					expect(res.status).to.equal(404)
					done()
			)
			return
		)

		it('Should succeed for valid network', (done) ->
			Readable = require('stream').Readable
			stream = new Readable
			stream.push('test content')
			stream.push(null)
			require('fs').createReadStream = () -> stream

			chai.request(server)
				.get('/api/labellings/london/latest')
				.redirects(0)
				.end((err, res) ->
					expect(res.status).to.equal(200)
					expect(res.text).to.equal('test content')
					done()
			)
			return
		)
	)

)

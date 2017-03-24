rfr = require('rfr')
server = rfr('./easymaps-server.coffee')

chai = require('chai')
chai.use(require('chai-http'))
expect = chai.expect

winners = {
	empty: {}
	valid: {
		'valid-id': {
			secret: 'valid-secret'
			prize: 'prize-code'
		}
	}
}

describe('Winners controller', () ->

	describe('POST /winners', () ->

		originalWinners = {}

		beforeEach(() ->
			require('../../helpers/winners')
			originalWinners = require.cache[require.resolve('../../helpers/winners')]
		)

		afterEach(() ->
			require.cache[require.resolve('../../helpers/winners')] = originalWinners
		)

		it('Should allow unauthorised requests', (done) ->
			chai.request(server)
				.post('/winners')
				.redirects(0)
				.end((err, res) ->
					expect(res.status).to.equal(200)
					done()
				)
			return
		)

		it('Should return prize for valid claim', (done) ->
			require.cache[require.resolve('../../helpers/winners')].exports = winners.valid
			chai.request(server)
				.post('/winners')
				.set('content-type', 'application/x-www-form-urlencoded')
				.send({ id: 'valid-id', secret: 'valid-secret' })
				.end((err, res) ->
					expect(res.text).to.equal('prize-code')
					done()
			)
			return
		)

		it('Should return TOO SOON for empty winner array', (done) ->
			require.cache[require.resolve('../../helpers/winners')].exports = winners.empty
			chai.request(server)
				.post('/winners')
				.set('content-type', 'application/x-www-form-urlencoded')
				.send({ id: 'valid-id', secret: 'valid-secret' })
				.end((err, res) ->
					expect(res.text).to.equal('TOO SOON')
					done()
				)
			return
		)

		it('Should return NOPE for non-winning ID', (done) ->
			require.cache[require.resolve('../../helpers/winners')].exports = winners.valid
			chai.request(server)
				.post('/winners')
				.set('content-type', 'application/x-www-form-urlencoded')
				.send({ id: 'idvalid-id', secret: 'valid-secret' })
				.end((err, res) ->
					expect(res.text).to.equal('NOPE')
					done()
			)
			return
		)

		it('Should return NICE TRY for invalid secret', (done) ->
			require.cache[require.resolve('../../helpers/winners')].exports = winners.valid
			chai.request(server)
				.post('/winners')
				.set('content-type', 'application/x-www-form-urlencoded')
				.send({ id: 'valid-id', secret: 'invalid-secret' })
				.end((err, res) ->
					expect(res.text).to.equal('NICE TRY')
					done()
			)
			return
		)
	)
)

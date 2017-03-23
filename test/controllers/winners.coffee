rfr = require('rfr')
server = rfr('./easymaps-server.coffee')

chai = require('chai')
chai.use(require('chai-http'))
expect = chai.expect

describe('Winners controller', () ->

	describe('POST /winners', () ->

		originalWinners = {}

		beforeEach(() ->
			require('../../helpers/winners')
			originalWinners = require._cache[require.resolve('../../helpers/winners')]
		)

		afterEach(() ->
			require._cache[require.resolve('../../helpers/winners')] = originalWinners
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

		it('Should return NOT YET for empty winner array', (done) ->
			require._cache[require.resolve('../../helpers/winners')] = {}
			chai.request(server)
				.post('/winners')
				.send({ id: '1', secret: '2' })
				.redirects(0)
				.end((err, res) ->
					expect(res.text).to.equal('TOO SOON')
					done()
				)
			return
		)

		it('Should return NICE TRY for invalid secret', (done) ->
			require._cache[require.resolve('../../helpers/winners')] = {
				'valid-id': {
					secret: 'valid-secret'
					prize: 'TEST_PRIZE_1'
				}
			}
			chai.request(server)
				.post('/winners')
				.send({ id: 'valid-id', secret: 'invalid-secret' })
				.redirects(0)
				.end((err, res) ->
					expect(res.text).to.equal('NICE TRY')
					done()
				)
			return
		)
	)
)

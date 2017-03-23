rfr = require('rfr')
server = rfr('./easymaps-server.coffee')

chai = require('chai')
chai.use(require('chai-http'))
expect = chai.expect

describe('Withdrawal controller', () ->

	describe('GET /withdrawal', () ->

		it('Should allow unauthorised requests', (done) ->
			chai.request(server)
				.get('/withdrawal')
				.redirects(0)
				.end((err, res) ->
					expect(res.status).to.equal(200)
					done()
				)
			return
		)
	)

)

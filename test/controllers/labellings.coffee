rfr = require('rfr')
server = rfr('./easymaps-server.coffee')

chai = require('chai')
chai.use(require('chai-http'))
expect = chai.expect
helpers = rfr('./helpers/test-helpers')

describe('Labellings controller', () ->

	beforeEach(() -> helpers.logout(server))

	describe('GET /labellings', () ->
		it('Should not allow unauthorised requests', (done) ->
			chai.request(server)
				.get('/labellings')
				.redirects(0)
				.end((err, res) ->
					expect(res.status).to.equal(302)
					expect(res.headers).to.have.property('location')
					expect(res.headers['location']).to.equal('/auth/login')
					done()
				)
			return
		)

		it('Should allow authorised requests', (done) ->
			helpers.login(server)
			chai.request(server)
				.get('/labellings')
				.redirects(0)
				.end((err, res) ->
					expect(res.status).to.equal(200)
					done()
				)
			return
		)
	)

)

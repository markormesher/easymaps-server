rfr = require('rfr')
server = rfr('./easymaps-server')

chai = require('chai')
chaiHttp = require('chai-http')
chai.use(chaiHttp)
chai.should()

describe('/scan-logs', () ->

	describe('GET /', () ->
		chai
			.use(server)
			.get('/')
			.end((err, res) ->
				should.be.null(err)
			)
	)
)

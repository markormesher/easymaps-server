require('chai').should()

describe('Sample Tests', () ->
	it('Should pass (sync)', () ->
		(2 + 3).should.equal(5)
	)

	it('Should pass (async)', (done) ->
		setTimeout(
			() ->
				(2 + 3).should.equal(5)
				done()
			10
		)
	)
)

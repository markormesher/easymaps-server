rfr = require('rfr')
secrets = rfr('./secrets.json')

module.exports = {

	'9ebbfd45-01f3-4535-a1fa-d54469f64463': {
		secret: sha256('9ebbfd45-01f3-4535-a1fa-d54469f64463' + secrets['winner_salt'])
		prize: 'prize-code'
	},
	'23ef028e-1ac7-411e-8aba-6279f06012f4': {
		secret: sha256('23ef028e-1ac7-411e-8aba-6279f06012f4 ' + secrets['winner_salt'])
		prize: 'prize-code'
	},
	'5b0c8e53-c8b4-4606-8b1c-8402afee99f9': {
		secret: sha256('5b0c8e53-c8b4-4606-8b1c-8402afee99f9' + secrets['winner_salt'])
		prize: 'prize-code'
	}

}


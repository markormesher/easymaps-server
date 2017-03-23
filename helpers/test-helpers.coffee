module.exports = {
	login: (server) -> server.request.user = { name: 'Test user' }
	logout: (server) -> server.request.user = null
}

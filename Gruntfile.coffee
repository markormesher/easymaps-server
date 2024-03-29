module.exports = (grunt) ->
	grunt.loadNpmTasks('grunt-ssh')

	grunt.initConfig

		pkg: grunt.file.readJSON('package.json')

		sshconfig:
			main:
				host: 'chuck'
				username: 'deploy'
				agent: process.env.SSH_AUTH_SOCK # use active local SSH keys
				agentForward: true

		sshexec:
			deploy:
				command: [
					'cd /var/node/easymaps.markormesher.co.uk'
					'mkdir -p uploads/scan-logs'
					'mkdir -p uploads/labellings'
					'mkdir -p uploads/data-packs'
					'git pull origin master'
					'npm i'
					'pm2 stop --silent easymaps-server'
					'pm2 start --silent process.chuck.json'
					'sleep 3'
					'pm2 show easymaps-server'
				].join(' && ')
				options:
					config: 'main'

			restart:
				command: [
					'cd /var/node/easymaps.markormesher.co.uk'
					'pm2 stop --silent easymaps-server'
					'pm2 start --silent process.chuck.json'
					'sleep 3'
					'pm2 show easymaps-server'
				].join(' && ')
				options:
					config: 'main'

			status:
				command: 'pm2 show easymaps-server'
				options:
					config: 'main'

	# task aliases
	grunt.registerTask('deploy', ['sshexec:deploy'])
	grunt.registerTask('restart', ['sshexec:restart'])
	grunt.registerTask('status', ['sshexec:status'])

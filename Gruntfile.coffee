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
					'cd /var/node/prjserver.markormesher.co.uk'
					'git pull origin master'
					'npm i'
					'pm2 stop --silent prj-server'
					'pm2 start --silent prj-server'
					'sleep 3'
					'pm2 show prj-server'
				].join(' && ')
				options:
					config: 'main'

			status:
				command: 'pm2 show prj-server'
				options:
					config: 'main'

	# task aliases
	grunt.registerTask('deploy', ['sshexec:deploy'])
	grunt.registerTask('status', ['sshexec:status'])
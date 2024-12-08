pipeline {
    agent any

    stages {
        stage('Clone Repository') {
            steps {
                // Cloning the repository
                git url: 'https://github.com/dcalixto/friendly_id.git', branch: 'main'
            }
        }

        stage('Install Dependencies') {
            steps {
                // Installing dependencies
                sh 'shards install'
            }
        }

        stage('Run Tests') {
            steps {
                // Running tests
                sh 'crystal spec'
            }
        }

        stage('Lint Code') {
            steps {
                // Linting code
                sh 'crystal tool format --check'
            }
        }
    }

    post {
        always {
            // Archiving results or logs if needed
            archiveArtifacts artifacts: '**/log/*', allowEmptyArchive: true
        }
        success {
            echo 'Build succeeded!'
        }
        failure {
            echo 'Build failed!'
        }
    }
}

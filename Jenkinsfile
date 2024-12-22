pipeline {
    agent any
    
    stages {
        stage('Install Dependencies') {
            steps {
                sh '''
                  apt-get update
                  apt-get install -y libsqlite3-dev
                  apt-get install -y curl gnupg apt-transport-https
                  curl -fsSL https://crystal-lang.org/install.sh | bash
                  apt-get install -y crystal
                  crystal --version
                  shards --version || echo "Shards is already bundled with Crystal."
                '''
              
            }
        }
        
        stage('Build') {
            steps {
                sh 'shards install'
            }
        }
        
        stage('Test') {
            steps {
                sh 'crystal spec'
            }
        }
    }
}
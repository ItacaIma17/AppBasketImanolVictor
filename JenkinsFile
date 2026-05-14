pipeline {
    agent any

    stages {
        stage('📦 Clonar repositorio') {
            steps {
                echo 'Clonando repositorio desde GitHub...'
                checkout scm
                echo 'Repositorio clonado correctamente'
            }
        }

        stage('📁 Verificar estructura') {
            steps {
                echo 'Archivos en el repositorio:'
                sh 'ls -la'
            }
        }

        stage('🌿 Verificar rama actual') {
            steps {
                echo 'Rama actual:'
                sh 'git branch'
            }
        }

        stage('📊 Información del commit') {
            steps {
                echo 'Último commit:'
                sh 'git log -1 --oneline'
            }
        }
    }

    post {
        success {
            echo '🎉 Pipeline completado con ÉXITO!'
            echo '✅ Jenkins ha clonado correctamente el repositorio'
        }
        failure {
            echo '❌ Pipeline falló. Revisa los logs para identificar el error.'
        }
    }
}
def ROOT_PATH = "REPLACE ME"

def URL_DOWNLOAD
def MODEL_TYPE
def MODEL_VER_NAME
def MODEL_VER_ID
def DOWNLOAD_PATH

pipeline {
    agent {
        node {
            label 'REPLACE ME'
        }
    }

    options {
        disableResume()
        throttleJobProperty categories: [], limitOneJobWithMatchingParams: false, maxConcurrentPerNode: 2, maxConcurrentTotal: 2, paramsToUseForLimit: '', throttleEnabled: true, throttleOption: 'project'
    }

    parameters {
        string 'MODEL_ID'
        activeChoiceHtml choiceType: 'ET_ORDERED_LIST', name: 'Model_Version_List', omitValueField: false, randomName: 'choice-parameter-2178091673551144', referencedParameters: 'MODEL_ID', script: groovyScript(fallbackScript: [classpath: [], oldScript: '', sandbox: false, script: ''], script: [classpath: [], oldScript: '', sandbox: true, script: '''
            def response = new URL("https://civitai.com/api/v1/models/"+MODEL_ID).getText()
            def json = new groovy.json.JsonSlurper().parseText(response)
            def modelVersions = json.modelVersions
            def names = []
            modelVersions.each { version ->
                version.files.each { file ->
                    names.add(file.name+" ["+file.id+"] ("+file.scannedAt+")")
                }
            }
            return names''']
        )
        reactiveChoice choiceType: 'PT_SINGLE_SELECT', filterLength: 1, filterable: false, name: 'Model_Version', randomName: 'choice-parameter-2178341260990159', referencedParameters: 'MODEL_ID', script: groovyScript(fallbackScript: [classpath: [], oldScript: '', sandbox: false, script: ''], script: [classpath: [], oldScript: '', sandbox: true, script: '''
            def response = new URL("https://civitai.com/api/v1/models/"+MODEL_ID).getText()
            def json = new groovy.json.JsonSlurper().parseText(response)
            def modelVersions = json.modelVersions
            def names = []
            modelVersions.each { version ->
                version.files.each { file ->
                    names.add(file.name)
                }
            }
            return names''']
        )
        activeChoiceHtml choiceType: 'ET_UNORDERED_LIST', name: 'Model Information', omitValueField: false, randomName: 'choice-parameter-2178091673551144', referencedParameters: 'MODEL_ID', script: groovyScript(fallbackScript: [classpath: [], oldScript: '', sandbox: false, script: ''], script: [classpath: [], oldScript: '', sandbox: true, script: '''
            def response = new URL("https://civitai.com/api/v1/models/"+MODEL_ID).getText()
            def json = new groovy.json.JsonSlurper().parseText(response)
            def names = []
            names.add("Model Name: "+json.name)
            names.add("Model Type: "+json.type)
            names.add("Is Model NSFW: "+json.nsfw)
            names.add("Model (Base Model): "+json.modelVersions.baseModel)
            names.add("Model Created At: "+json.modelVersions.createdAt)
            names.add("Model Updated At: "+json.modelVersions.updatedAt)
            return names''']
        )
        activeChoiceHtml choiceType: 'ET_FORMATTED_HTML', name: 'Model Description', omitValueField: false, randomName: 'choice-parameter-2180408145256099', referencedParameters: 'MODEL_ID', script: groovyScript(fallbackScript: [classpath: [], oldScript: '', sandbox: false, script: ''], script: [classpath: [], oldScript: '', sandbox: true, script: '''
            def response = new URL("https://civitai.com/api/v1/models/"+MODEL_ID).getText()
            def json = new groovy.json.JsonSlurper().parseText(response)
            return json.description''']
        )
    }

    stages {
        stage('Pre-Check') {
            steps {
                script {
                    echo "Checking MODLE_ID env"
                    if (env.MODEL_ID == null || env.MODEL_ID.isEmpty()) {
                        addShortText background: 'red', borderColor: 'red', color: 'white', link: '', text: "[ENV Error] MODLE_ID is not valid, could be a reporting null or empty!"
                        error("[ENV Error] MODLE_ID is not valid, could be a reporting null or empty!")
                    }
                    echo "Checking Modle_Version env"
                    if (env.Model_Version == null || env.Model_Version.isEmpty()) {
                        addShortText background: 'red', borderColor: 'red', color: 'white', link: '', text: "[ENV Error] Modle_Version is not valid, could be a reporting null or empty!"
                        error("[ENV Error] Modle_Version is not valid, could be a reporting null or empty!")
                    }
                    echo "Pre-Check Done!"
                    MODEL_VER_NAME = env.Model_Version
                }
            }
        }
        stage('API Requests') {
            steps {
                script {
                    def JSON_RESPONSE = new URL("https://civitai.com/api/v1/models/"+env.MODEL_ID).getText()
                    def JSON = new groovy.json.JsonSlurper().parseText(JSON_RESPONSE)
                    MODEL_TYPE = JSON.type
                    def mv = JSON.modelVersions
                    def modelVersions = JSON.modelVersions
                    modelVersions.each { version ->
                        version.files.each { file ->
                            if (file.name==MODEL_VER_NAME) {
                                MODEL_VER_ID = file.id
                                URL_DOWNLOAD = file.downloadUrl
                            }
                        }
                    }
                }
            }
        }
        stage('Post API Chcek') {
            steps {
                script {
                    echo "MODEL_VER_ID: "+MODEL_VER_ID
                    echo "MODEL_DOWNLOAD_URL: "+URL_DOWNLOAD 
                    echo "MODEL_TYPE: "+MODEL_TYPE 
                    echo "FILE NAME: "+MODEL_VER_NAME
                    def validType = false;
                    if (MODEL_TYPE.equalsIgnoreCase("checkpoint")) {
                        DOWNLOAD_PATH = ROOT_PATH+"Stable-diffusion"
                        validType = true
                    }
                    if (MODEL_TYPE.equalsIgnoreCase("lora")) {
                        DOWNLOAD_PATH = ROOT_PATH+"Lora"
                        validType = true
                    }
                    if (MODEL_TYPE.equalsIgnoreCase("vae")) {
                        DOWNLOAD_PATH = ROOT_PATH+"VAE"
                        validType = true
                    }
                    if (MODEL_TYPE.equalsIgnoreCase("LyCORIS")) {
                        DOWNLOAD_PATH = ROOT_PATH+"LyCORIS"
                        validType = true
                    }
                    if (MODEL_TYPE.equalsIgnoreCase("ControlNet")) {
                        DOWNLOAD_PATH = ROOT_PATH+"ControlNet"
                        validType = true
                    }
                    if (MODEL_TYPE.equalsIgnoreCase("LDSR")) {
                        DOWNLOAD_PATH = ROOT_PATH+"LDSR"
                        validType = true
                    }

                    if (!validType) {
                        addShortText background: 'red', borderColor: 'red', color: 'white', link: '', text: "[Model Type Error] Unsupported Model type!"
                        error("[Model Type Error] Unsupported Model type was given! MODEL_TYPE '"+MODEL_TYPE+"' is not supported!")
                    }

                    echo "Download Path Set To: "+DOWNLOAD_PATH
                }
            }
        }
        stage('File Check') {
            steps {
                script {
                    def TARGET_FILE = DOWNLOAD_PATH+"/"+MODEL_VER_NAME
                    echo "Checking if '"+TARGET_FILE+"' file exist..."
                    if (fileExists(TARGET_FILE)) {
                        addShortText background: 'red', borderColor: 'red', color: 'white', link: '', text: "[File Error] File Already Exist!"
                        error("[File Error] File Already Exist! Please either rename it or delete")
                    }
                    echo "Ready to download the file!"
                }
            }
        }
        stage('Download') {
            steps {
                script {
                    dir (DOWNLOAD_PATH) {
                        sh 'wget '+URL_DOWNLOAD+' --content-disposition'
                    }
                }
            }
            post {
                failure {
                    script {
                        addShortText background: 'red', borderColor: 'red', color: 'white', link: '', text: "Download Failure! "+"MODEL ID: "+env.MODEL_ID+ " Model Name: "+MODEL_VER_NAME+" Model Version ID: "+MODEL_VER_ID+" Model Type: "+MODEL_TYPE
                    }
                }
                success {
                    script {
                        addShortText background: 'yellow', borderColor: 'yellow', color: 'black', link: '', text: "MODEL ID: "+env.MODEL_ID+ " Model Name: "+MODEL_VER_NAME+" Model Version ID: "+MODEL_VER_ID+" Model Type: "+MODEL_TYPE
                    }
                }
            }
        }
    }
}
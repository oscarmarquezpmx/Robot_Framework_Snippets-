Create WebDriver in Grid With Chrome Options   
    ${count}    Get length   ${TEST_TAGS} 
    IF     ${count}!=0
        ${DATE}                 Get Current Date    result_format=%m%d%a:%H:%M
        Set Global Variable    ${VIDEO NAME}    ${TEST_TAGS}[0]_${DATE}.mp4  #adds the test id and date to the name of the video to make easier to find it
        ${selenoid_options}    Create Dictionary
        ...    enableVideo=${True}
        ...    enableVNC=${True}
        ...    name=${TEST_TAGS}[0] ${DATE}
        ...    videoName=${VIDEO NAME} 
        ...    sessionTimeout=5m
    ELSE
         ${selenoid_options}    Create Dictionary
        ...    enableVideo=${False}
        ...    enableVNC=${False}
        ...    sessionTimeout=5m
    END
    ${chrome_options}=  Evaluate  sys.modules['selenium.webdriver'].ChromeOptions()  sys, selenium.webdriver
    ${experimental_options}    Create List    enable-automation    
    ${prefs}  Create Dictionary  download.default_directory=${EXECDIR}    safebrowsing.enabled=${True}    download.directory_upgrade=${True}    download.prompt_for_download=${FALSE}     plugins.always_open_pdf_externally=${TRUE}     #  plugins.plugins_disabled=${disabled}
    ${prefs}  Create Dictionary       plugins.always_open_pdf_externally=${TRUE}      download.default_directory=${EXECDIR}  #plugins.plugins_disabled=${disabled}
    Call Method   ${chrome_options}  add_argument    --no-sandbox
    Call Method   ${chrome_options}  add_argument    --disable-dev-shm-usage
    Call Method   ${chrome_options}  add_argument     force-device-scale-factor\=.90
    Call Method    ${chrome_options}    add_experimental_option    excludeSwitches    ${experimental_options} 
    Call Method    ${chrome_options}    add_experimental_option    useAutomationExtension    ${False}
    Call Method   ${chrome_options}     add_experimental_option  prefs  ${prefs}
    Call Method   ${chrome_options}  set_capability    selenoid:options    ${selenoid_options}
    SeleniumLibrary.Open Browser    browser=chrome    remote_url=${GRID_URL}     options=${chrome_options} #GRID URL ids the selenoid address
    Maximize Browser Window
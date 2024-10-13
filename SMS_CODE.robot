Get and input phone verification code option 
    [Arguments]    ${phoneno}        ${BROWSER}
    ${smsURL}=     Set Variable    https://receive-smss.com/sms/${phoneno}/
    IF    $BROWSER=="Edge"
        Create WebDriver With Edge Options    
        BuiltIn.Log To Console    Opening Chrome
    END
    IF    $BROWSER=="Grid Chrome"
        Create WebDriver in Grid With Chrome No Record
        BuiltIn.Log To Console    Opening Chrome
    END
    SeleniumLibrary.Go to    ${smsURL}
    Sleep   4
    ${present}    Run Keyword And Return Status
    ...    Element Should Be Visible
    ...    css=body > div.fc-consent-root > div.fc-dialog-container > div.fc-dialog.fc-choice-dialog > div.fc-footer-buttons-container > div.fc-footer-buttons > button.fc-button.fc-cta-consent.fc-primary-button > p
    IF    ${present}
        Sleep    4s
        SeleniumLibrary.Click Element     css=body > div.fc-consent-root > div.fc-dialog-container > div.fc-dialog.fc-choice-dialog > div.fc-footer-buttons-container > div.fc-footer-buttons > button.fc-button.fc-cta-consent.fc-primary-button > p
    END
    ${element_1}    SeleniumLibrary.Get Text   xpath=//div[contains(@class, 'list-view')]/div[1]/div[1]
    ${element_2}    SeleniumLibrary.Get Text   xpath=//div[contains(@class, 'list-view')]/div[1]/div[3]
    ${contains1}=    Run Keyword And Return Status    Should Contain    ${element_1}    DELFI
    ${contains2}=    Run Keyword And Return Status    Should Contain    ${element_2}    second
    #Capture Page Screenshot
    IF    ${contains1} == False or ${contains2} == False
        FOR  ${loop}  IN RANGE  3
            Sleep    20
            SeleniumLibrary.Reload Page
            FOR  ${loopIndex}  IN RANGE  1    10
                ${element_1}    SeleniumLibrary.Get Text   xpath=//div[contains(@class, 'list-view')]/div[${loopIndex}]/div[1]
                ${element_2}    SeleniumLibrary.Get Text   xpath=//div[contains(@class, 'list-view')]/div[${loopIndex}]/div[3]
                ${contains1}=    Run Keyword And Return Status    Should Contain    ${element_1}    DELFI
                ${contains2}=    Run Keyword And Return Status    Should Contain    ${element_2}    second
                Exit For Loop If  ${contains1} and ${contains2}
                Log  "WAITING SMS"         
            END
            Exit For Loop If  ${contains1} and ${contains2}    
        END
    END
    IF    ${contains1} == False or ${contains2} == False  
            #Capture Page Screenshot
            BuiltIn.Log To Console    SMS FAILED
            SeleniumLibrary.Close All Browsers
            Fatal Error
            SeleniumLibrary.Switch Browser    1
            SeleniumLibrary.Go To    ${URL}
    ELSE
        ${text}    SeleniumLibrary.Get Text    ((//div[1]/div/div[2]/div/div/span[.//text()[contains(., 'DELFI')]])[1])
        ${codeFree}    Get Substring    ${text}    22    28
        #Capture Page Screenshot
        BuiltIn.Log To Console    Leaving SMS Page
        SeleniumLibrary.Close Browser
        Log To Console    ${codeFree}
        SeleniumLibrary.Switch Browser    1
        SeleniumLibrary.Wait Until Page Contains Element    //input[@id="verificationCode"]
        SeleniumLibrary.Input Text   //input[@id="verificationCode"]    ${codeFree}
        SeleniumLibrary.Wait Until Page Contains Element    //button[@id="verifyCode"]
        SeleniumLibrary.Click Element    //button[@id="verifyCode"]
    END
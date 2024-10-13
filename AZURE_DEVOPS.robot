*** Settings ***
Library     String
Library     DateTime
Library     RequestsLibrary
Library     JSONLibrary
Library     Collections
Library     OperatingSystem
Library     SeleniumLibrary   
Library    ../Resources/PyFunctions.py
Variables  ../Resources/credentials.py
Library	   Screenshot	../../Screenshots
Library    Process     
Library    OperatingSystem

Resource    CommonKeywords.robot

*** Variables ***
${DEV_OPS_URL}       https://dev.azure.com/some_company/some_project/
${user}    some@email.com

*** Keywords ***
API Setup
    ${local start date}    Get Current Date
    Set Global Variable    ${start date}   ${local start date}

#Update the status in azure devops and removes the video record in selenoid
Update Test Status
    [Arguments]    ${TestID}
    Log To Console    \nTest is Ending -> ${TestID}
    ${end date} =	Get Current Date
    ${elapsed time}    Subtract Date From Date     ${end date}    ${start date}
    Log To Console    ------> Elapsed Time: ${elapsed time}s <----------
    Run Keyword And Warn On Failure   SeleniumLibrary.Capture Page Screenshot
    ${devops_token}=    Get Refresh Token
    ${TestDetails}=    Get Test Points    ${TestID}    ${devops_token}
    Update Test    ${TestDetails}    ${TestID}     ${devops_token}
    Sleep    5
    TRY
        IF    '${TEST STATUS}'=='PASS' and $BROWSER=='Grid Chrome'
            Run       curl --request "DELETE" http://192.168.1.250:8080/video/${VIDEO NAME}
        END 
    EXCEPT 
        Log To Console    Could not delete the Video
    END
    Run Keyword And Warn On Failure    Close All Browsers

Get Refresh Token
    RequestsLibrary.Create Session    DEVOPS    https://app.vssps.visualstudio.com/     verify=${True}
    ${data}=     Create Dictionary    grant_type=refresh_token 
    ...    client_assertion_type=yourdetails
    ...    redirect_uri=https://oauth.pstmn.io/v1/browser-callback
    ...    client_assertion=${client_secret}
    ...    assertion=${refresh_token}
    ${headers}=   Create Dictionary    Content-Type=application/x-www-form-urlencoded
    ${resp}=    RequestsLibrary.POST On Session    DEVOPS    /oauth2/token   data=${data}    headers=${headers}
    ${devops_token}=    evaluate    $resp.json().get("access_token")
    [Return]     ${devops_token}

Get Test Points
    [Arguments]    ${TestID}    ${devops_token}
    RequestsLibrary.Create Session    AzureSession    ${DEV_OPS_URL}   
    &{headers}=    Create Dictionary
    ...    Authorization=Bearer ${devops_token}
    ...    content-type=application/json
    ${resp}=    GET On Session  AzureSession
    ...    ${DEV_OPS_URL}_apis/test/Plans/1234567/Suites/9876554/points?api-version\=7.0&testCaseId\=${TestID}&$top\=1
    ...    headers=${headers}  
    ${values}=      Evaluate      json.loads($resp.content)
    ${lastResultID}=    evaluate    ${values['value'][0]['lastResult']['id']} 
    ${lastTestRun}=    evaluate    ${values['value'][0]['lastTestRun']['id']} 
    [Return]     ${lastResultID}    ${lastTestRun}

Update Test
    [Arguments]    ${TestDetails}    ${TestID}    ${devops_token}
    ${auth}=  Create List  ${user}  ${devops_token}
    RequestsLibrary.Create Session    UpdateSession    ${DEV_OPS_URL}  auth=${auth}   verify=True
    ${headers}=    Create Dictionary
    ...    content-type=application/json
    ${body}=    Catenate    [{"id":${TestDetails}[0],"state":"Completed","comment":"Automated Test Run","outcome":"${TEST_STATUS}ED"}]
    ${jsonBody}=    JSONLibrary.Convert String to JSON    ${body}
    ${resp}=    RequestsLibrary.PATCH On Session
    ...    UpdateSession
    ...    ${DEV_OPS_URL}_apis/test/runs/${TestDetails}[1]/results?api-version\=7.0
    ...    json=${jsonBody}
    ...    headers=${headers}


Get Azure Token
    ${azureURL}=    BuiltIn.Set Variable    https://login.microsoftonline.com/1234567890
    RequestsLibrary.Create Session    OA2    ${azureURL}    verify=${True}
    ${data}=     Create Dictionary    grant_type=client_credentials   client_Id=yourid   Client_Secret=yoursecret    resource=https://youresource
    ${headers}=   Create Dictionary    Content-Type=application/x-www-form-urlencoded    Cookie=cookie
    ${resp}=    RequestsLibrary.POST On Session    OA2    /oauth2/token   data=${data}    headers=${headers}
    ${approverAccessToken}=    evaluate    $resp.json().get("access_token")
    [Return]     ${approverAccessToken}
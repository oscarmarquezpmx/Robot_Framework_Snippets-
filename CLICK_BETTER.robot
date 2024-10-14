*** Settings ***
Library    SeleniumLibrary    timeout=35  
Library    String

click
    [Arguments]    ${element}
    ${EXIT}    Set Variable    $False
    ${nameStarts} =	Get Substring	${element}		0    3    
    ${element}=     String.Replace String    ${element}    "    '    
    waitForElementPresent    ${element}
    IF   $nameStarts=='id\='
        ${elementScroll}=    Get Substring	${element}    3
        runScript    document.getElementById('${elementScroll}').scrollIntoView(true);
    ELSE
        IF   $nameStarts=='lin'
            BuiltIn.Log To Console    Click on link ${element}
        ELSE
            IF   $nameStarts=='xpa'
              ${elementScroll}=   Remove String     ${element}    xpath\=
              runScript   window.document.evaluate("${elementScroll}", document, null, XPathResult.FIRST_ORDERED_NODE_TYPE, null).singleNodeValue.scrollIntoView(true);
              Sleep    3
              runScript   window.document.evaluate("${elementScroll}", document, null, XPathResult.FIRST_ORDERED_NODE_TYPE, null).singleNodeValue.click();
              ${EXIT}     Set Variable    True
            END
        END
    END
    IF    ${EXIT}==$False
        Wait Until Element Is Enabled    ${element}    timeout=10s
        Sleep    3
        Click Element  ${element}
        Capture Page Screenshot
    END    

click up
    [Arguments]    ${element}    ${pixels up}
    ${nameStarts} =	Get Substring	${element}		0    3    
    ${element}=     String.Replace String    ${element}    "    '    
    waitForElementPresent    ${element}
    IF   $nameStarts=='id\='
        ${elementScroll}=    Get Substring	${element}    3
        runScript    document.getElementById('${elementScroll}').scrollIntoView(true);
    ELSE
        IF   $nameStarts=='lin'
            BuiltIn.Log To Console    Click on link ${element}
        ELSE
            IF   $nameStarts=='xpa'
              ${elementScroll}=   Remove String     ${element}    xpath\=
              runScript   window.document.evaluate("${elementScroll}", document, null, XPathResult.FIRST_ORDERED_NODE_TYPE, null).singleNodeValue.scrollIntoView(true);
               Sleep    1
              runScript   window.scrollBy(0, -${pixels up});
              Sleep    3
            END
        END
    END
    Sleep    3
    Click Element  ${element}
    Capture Page Screenshot 
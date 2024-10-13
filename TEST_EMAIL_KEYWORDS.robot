
*** Settings ***
Library  MailClientLibrary  MailServerAddress=127.0.0.1  ImapPorts=[1143,1143]   SmtpPorts=[1025,1025]
Variables    ../Resources/email_credentials.py
Library    String


*** Keywords ***
Validate Last 10 Emails And Delete Match
    [Arguments]     ${sender}  ${receiver}  ${subject}  @{text to test}
    Sleep    10
    Append To List     ${text to test}    ${sender}  ${receiver}  ${subject} 
    ${result}    Set Variable    ${False}
    Log To Console    Text to test ----> '@{text to test}'
    FOR    ${time}    IN RANGE    1    6    
            FOR    ${email counter}    IN RANGE    1    10
                Set IMAP Username And Password    ${user_email}      ${password_email}    # Receiver's mailbox credentials
                ${MIME}    Open Imap Mail By Index   ${email counter}  useSsl=${False}
                IF   $MIME != $False
                    ${MIME}=    PyFunctions.Remove Returns    ${MIME}   
                    ${MIME}=    Replace String    ${MIME}    =    ${EMPTY} 
                    FOR    ${text}    IN   @{text to test}
                            ${result}=    Run Keyword and Return Status    Should Contain  ${MIME}    ${text}
                            IF    ${result} == ${False}
                                Log To Console    Missing text --${text}-- in the email
                                Log To Console    Discarding email ${email counter}
                                Exit For Loop
                            END
                    END
                ELSE
                    Log To Console    No email at position ${email counter}   
                    Exit For Loop 
                END
                IF    ${result} == ${True}
                    ${MIME}    Delete Imap Mail By Index   ${email counter}   useSsl=${False}   # required in case email is coming once or more wont match same email 
                    Log To Console    Email found at position ${email counter}
                    Exit For Loop
                ELSE
                    Log To Console    Checking Next Email
                END
            END
        IF    ${result} == ${True}
            Log To Console    Email Was Found
            Exit For Loop
        ELSE
            Log To Console    Email could not be found
        END
        Sleep    10    
    END
    RETURN    ${result}

Clear Current Emails
    Set IMAP Username And Password    ${user_email}      ${password_email}     # Receiver's mailbox cridentials
     ${MIME}    Delete Imap Mail By Index   1  useSsl=${False}
    WHILE    ${MIME} != ${False}
            ${MIME}    Delete Imap Mail By Index   1  useSsl=${False}
    END



    
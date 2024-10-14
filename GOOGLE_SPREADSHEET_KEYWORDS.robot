*** Settings ***
Documentation       An example robot that reads and writes data
...                 into a Google Sheet document.

Library    RPA.Cloud.Google
Library    DateTime
Library    Collections
Library    ../Resources/PyFunctions.py

*** Variables ***
${SHEET_ID}         someid

*** Keywords ***
Add values to the Google Sheet 
   [Arguments]     ${email}     ${userType}    ${orderNumber}     ${product}    ${country}    ${profile}    ${quote}    ${contractStatus}    ${orderStatus}
   BuiltIn.Log To Console    Adding values to the Google Sheet
   Init Sheets    ${CURDIR}/AUTH.json
   ${SHEET_RANGE}   BuiltIn.Set Variable     Orders_Created!A1:J1
   ${DATE}         Get Current Date    result_format=%Y-%m-%d %H:%M:%S.%f
   ${orderNumber}=    Set Variable    '${orderNumber}
   ${email}=    PyFunctions.Remove Returns    ${email}
   Log To Console     ${orderNumber}
   Log To Console     ${DATE}
   Log To Console     ${profile}
   ${values}=    Evaluate    [["${email}","${userType}","${orderNumber}", "${product}", "${country}","${profile}","${quote}","${contractStatus}","${orderStatus}","","${DATE}"]]
   Insert Sheet Values
   ...    ${SHEET_ID}
   ...    ${SHEET_RANGE}
   ...    ${values}
   ...    ROWS

Update User Values
   [Arguments]    ${ROW}    ${values} 
   Init Sheets    ${CURDIR}/AUTH.json
   @{ITEMS}=  Create List
   Collections.Append To List  ${ITEMS}    ${values}
   ${SHEET_RANGE}=    Set Variable    Users!E${ROW}    #:F${row}
   ${result}=  Update Sheet Values  ${SHEET_ID}  ${SHEET_RANGE}    ${ITEMS}    ROWS
   ${DATE}         Get Current Date    result_format=%Y-%m-%d %H:%M:%S.%f
   @{VALUE}=  Create List   
   Collections.Append To List  ${VALUE}    ${DATE}
   ${UPDATE VALUE}  Evaluate   [${VALUE}]
   ${SHEET_RANGE}=    Set Variable    Users!O${ROW}   #:O${ROW}
   ${result}=  RPA.Cloud.Google.Update Sheet Values  ${SHEET_ID}  ${SHEET_RANGE}    ${UPDATE VALUE}    ROWS   
    
Read user values
   [Arguments]    ${ROW}     ${SHEET}
   Init Sheets    ${CURDIR}/AUTH.json
   ${SHEET_ROW}=    Set Variable    ${SHEET}!B${ROW}:M${ROW}   
   ${spreadsheet_content}=    Get Sheet Values    ${SHEET_ID}   ${SHEET_ROW}
   IF    "values" in ${spreadsheet_content}
      Log Many    ${spreadsheet_content["values"]}
   END
   RETURN  ${spreadsheet_content["values"]}

Read Product Values
   [Arguments]    ${ROW}     ${SHEET}
   Init Sheets    ${CURDIR}/AUTH.json
   ${SHEET_ROW}=    Set Variable    ${SHEET}!A${ROW}:G${ROW}   
   ${spreadsheet_content}=    Get Sheet Values    ${SHEET_ID}   ${SHEET_ROW}
   ${values}   Set Variable    ${spreadsheet_content["values"]}
   ${values}    Set Variable    ${values[0]}
   IF    "values" in ${spreadsheet_content}
      Log Many    ${spreadsheet_content["values"]}
   END
   RETURN  ${values}


Read Row For Verification
   [Arguments]    ${ROW}
   Init Sheets    ${CURDIR}/AUTH.json
   ${SHEET_ROW}=    Set Variable    Users!A${ROW}:B${ROW}   
   ${spreadsheet_content}=    Get Sheet Values  ${SHEET_ID}   ${SHEET_ROW}
   IF    "values" in ${spreadsheet_content}
      Log Many    ${spreadsheet_content["values"]}
   END
   RETURN  ${spreadsheet_content["values"]}    

Read Order Row For Verification
   [Arguments]    ${ROW}
   Init Sheets    ${CURDIR}/AUTH.json
   ${SHEET_ROW}=    Set Variable    Orders_Created!A${row}:C${row}   
   ${spreadsheet_content}=    Get Sheet Values  ${SHEET_ID}   ${SHEET_ROW}
   IF    "values" in ${spreadsheet_content}
      Log Many    ${spreadsheet_content["values"]}
   END
   RETURN  ${spreadsheet_content["values"]}   

Update User Status
   [Arguments]    ${ROW}        ${value} 
   Init Sheets    ${CURDIR}/AUTH.json
   ${DATE}         Get Current Date    result_format=%Y-%m-%d %H:%M:%S.%f
   @{values}=    Create List     ${value}    ${DATE}    
   ${value}  Evaluate   [${values}]
   ${SHEET_RANGE}=    Set Variable    Users!N${ROW}  
   ${result}=  RPA.Cloud.Google.Update Sheet Values  ${SHEET_ID}  ${SHEET_RANGE}    ${value}    ROWS   

Update Order Status
   [Arguments]    ${ROW}   ${value}        
   ${DATE}         Get Current Date    result_format=%Y-%m-%d %H:%M:%S.%f
   Append To List     ${value}    ${DATE}
   ${value}  Evaluate   [${value}]
   Init Sheets    ${CURDIR}/AUTH.json
   ${SHEET_RANGE}=    Set Variable    Orders_Created!G${ROW}:K${ROW}
   ${result}=  RPA.Cloud.Google.Update Sheet Values  ${SHEET_ID}  ${SHEET_RANGE}    ${value}    ROWS

Get Random Phone    
   [Arguments]    ${ROW}
   Init Sheets    ${CURDIR}/AUTH.json
   ${SHEET_ROW}=    Set Variable    Users!D${ROW}:D${ROW}   
   ${spreadsheet_content}=    Get Sheet Values  ${SHEET_ID}   ${SHEET_ROW}
   IF    "values" in ${spreadsheet_content}
      Log Many    ${spreadsheet_content["values"]}
      ELSE
      RETURN   ${EMPTY}
   END
   ${value}=    set variable  ${spreadsheet_content["values"][0][0]}   
   RETURN  '${value}'
    

*** Settings ***
Library     String
Library     DateTime
Library     RequestsLibrary


*** Variables ***
${API_URL}                https://yoursite.com
${API_GATEWAY}            https://your_api_gateway
${DOW_JONES_API}          https://djrc.api.test.dowjones.com

*** Keywords ***
Post My App API Basic Token
    RequestsLibrary.Create Session    OA2    ${API_URL}     verify=True
    &{params}=    Create Dictionary
    ...    grant_type=client_credentials
    ...    client_id=the_id
    ...    client_secret=the_secret
    ...    scope=extended
    &{headers}=    Create Dictionary    Content-Type=application/json
    ${resp}=    POST On Session
    ...    OA2
    ...    ${API_URL}/authorizationserver/oauth/token
    ...    params=${params}
    ...    headers=${headers}
    ${accessToken}=    evaluate    $resp.json().get("access_token")
    Log to Console    ${resp.json()['access_token']}
    RETURN    ${accessToken}

Post My App API Approver Token
    RequestsLibrary.Create Session    OA2    ${API_URL}     verify=True
    &{params}=    Create Dictionary
    ...    grant_type=client_credentials
    ...    client_id=someid
    ...    client_secret=mysecret
    ...    scope=extended
    &{headers}=    Create Dictionary    Content-Type=application/json
    ${resp}=    POST On Session
    ...    OA2
    ...    ${API_URL}/authorizationserver/oauth/token
    ...    params=${params}
    ...    headers=${headers}
    ${approverAccessToken}=    evaluate    $resp.json().get("access_token")
    Log to Console    ${resp.json()['access_token']}
    RETURN    ${approverAccessToken}


Post My App API Admin Token
    RequestsLibrary.Create Session    OA2    ${API_URL}    verify=True
    &{params}=    Create Dictionary
    ...    grant_type=client_credentials
    ...    client_id=myid
    ...    client_secret=adminsecret
    ...    scope=extended
    &{headers}=    Create Dictionary    Content-Type=application/json
    ${resp}=    POST On Session
    ...    OA2
    ...    ${API_URL}/authorizationserver/oauth/token
    ...    params=${params}
    ...    headers=${headers}
    ${approverAccessToken}=    evaluate    $resp.json().get("access_token")
    Log to Console    ${resp.json()['access_token']}
    RETURN    ${approverAccessToken}

Post Other App Token
    RequestsLibrary.Create Session    OA2    ${API_URL}     verify=True
    &{params}=    Create Dictionary
    ...    grant_type=client_credentials
    ...    client_id=testclient
    ...    client_secret=mysecret
    ...    scope=extended
    &{headers}=    Create Dictionary    Content-Type=application/json
    ${resp}=    POST On Session
    ...    OA2
    ...    ${API_URL}/authorizationserver/oauth/token
    ...    params=${params}
    ...    headers=${headers}
    ${accessToken}=    evaluate    $resp.json().get("access_token")
    Log to Console    ${resp.json()['access_token']}
    RETURN    ${accessToken}

Post Create Cart
    [Arguments]    ${email}   ${token}    ${responseStatus}
    RequestsLibrary.Create Session   Create Cart    ${API_URL}     verify=True
    &{headers}=    Create Dictionary
    ...    Content-Type=application/json
    ...    Authorization=Bearer ${token}
    ...    Cookie=somecookie=value;
    ${resp}=    POST On Session
    ...    Create Cart
    ...    ${API_URL}/rest/v2/some_company/users/${email}/carts
    ...    headers=${headers}    expected_status=${responseStatus}

Get Current Cart Code
    [Arguments]    ${email}    ${token}
    RequestsLibrary.Create Session    Cart    ${API_URL}     verify=True
    ${headers}=    Create Dictionary
    ...    content-type=application/json
    ...    Authorization=Bearer ${token}
    ...    Cookie=somecookie=value; ROUTE=someroute
    ${resp}=    GET On Session
    ...    Cart
    ...    ${API_URL}/rest/v2/some_company/users/${email}/carts/current
    ...    headers=${headers}
    ${currCart}=    evaluate    $resp.json().get("code")
    RETURN    ${currCart}

Post eLearning Course to Cart
    [Arguments]    ${email}    ${currCart}    ${token}    ${basePrice}    ${courseQuantity}    ${courseCode}    ${courseTitle}
    RequestsLibrary.Create Session    Cart    ${API_URL}     verify=True
    ${body}=    Catenate    {"product":{"code":"${courseCode}"},
    ...    "quantity":${courseQuantity},"course":{"title":"${courseTitle}",
    ...    "classExpiry": "02/01/2023",
    ...    "classTCEmails":["some@email.com","someone@some_company.com"],
    ...    "basePrice": ${basePrice}.00,
    ...    "courseId":"SOMEID",
    ...    "eLearning":"true" }}
    ${jsonBody}=    JSONLibrary.Convert String to JSON    ${body}
    &{headers}=    Create Dictionary
    ...    Content-Type=application/json
    ...    Authorization=Bearer ${token}
    ...    Cookie=somecookie=value; ROUTE=someroute
    ${resp}=    POST On Session
    ...    Cart
    ...    ${API_URL}/rest/v2/some_company/users/${email}/carts/${currCart}/entries
    ...    json=${jsonBody}
    ...    headers=${headers}
    Should Be Equal As Strings    ${resp.status_code}    200


Patch eLearning Course Cart
    [Arguments]    ${email}    ${currCart}    ${token}    ${courseQuantity}   
    RequestsLibrary.Create Session    Cart    ${API_URL}     verify=True
    ${body}=    Catenate    {"quantity":${courseQuantity}}
    ${jsonBody}=    JSONLibrary.Convert String to JSON    ${body}
    &{headers}=    Create Dictionary
    ...    Content-Type=application/json
    ...    Authorization=Bearer ${token}
    ...    Cookie=somecookie=value; ROUTE=someroute
    ${resp}=    PATCH On Session
    ...    Cart
    ...    ${API_URL}/rest/v2/some_company/users/${email}/carts/${currCart}/entries/0
    ...    json=${jsonBody}
    ...    headers=${headers}
    Should Be Equal As Strings    ${resp.status_code}    200    

Post Update Product1 Order
    [Arguments]    ${order}     ${token}    ${randomDay}
    RequestsLibrary.Create Session    Update    ${API_URL}     verify=True
    ${body}=    Catenate    {"updateOrderNumber": "${order}","updatedAttributes":{
    ...    "lineItems":[
    ...    {    "pluginOrderLineItemId": "0",
    ...    "pluginLicense": {
    ...    	"maintenanceEndDate": "2023-12-${randomDay}T00:00:00+0000"
    ...    } } ] } }
    ${jsonBody}=    JSONLibrary.Convert String to JSON    ${body}
    &{headers}=    Create Dictionary
    ...    Content-Type=application/json
    ...    Authorization=Bearer ${token}
    ${resp}=    POST On Session
    ...    Update
    ...    ${API_URL}/some_companyproductwebservices/Product1Data/v1/UpdateProduct3Order
    ...    json=${jsonBody}
    ...    headers=${headers}
    Should Be Equal As Strings    ${resp.status_code}    200   

Post Update Product1 License 
    [Arguments]    ${order}     ${email}    ${token}    ${randomDay}    ${randomLicense}
    RequestsLibrary.Create Session    Update    ${API_URL}     verify=True
    ${body}=    Catenate    {"updateOrderNumber": "${order}","updatedAttributes":{
    ...  		"Product3Email": "commercetest-110922-Product3full@mailinator.com",
    ...         "licenseFile":"${randomLicense}"    }  }
    ${jsonBody}=    JSONLibrary.Convert String to JSON    ${body}
    &{headers}=    Create Dictionary
    ...    Content-Type=application/json
    ...    Authorization=Bearer ${token}
    ${resp}=    POST On Session
    ...    Update
    ...    ${API_URL}/some_companyproductwebservices/Product1Data/v1/UpdateProduct3Order
    ...    json=${jsonBody}
    ...    headers=${headers}
    Should Be Equal As Strings    ${resp.status_code}    200   

Post Get Product1 Order Details
    [Arguments]    ${order}     ${token}
    RequestsLibrary.Create Session    Get    ${API_URL}     verify=True
    ${body}=    Catenate    {
    ...    "Product3OrderSearchQuery": {
    ...    "orderSearch": {
    ...    "combineSearchAttributes": "AND",
    ...    "searchAttributes": {
    ...    "orderNumber": [
    ...    {   "term": "${order} "   }
    ...    ] } },
    ...    "retrieveAttributes": [
    ...    {
    ...    "retrievalAttribute": "*"
    ...    } ] } }
    ${jsonBody}=    JSONLibrary.Convert String to JSON    ${body}
    &{headers}=    Create Dictionary
    ...    Content-Type=application/json
    ...    Authorization=Bearer ${token}
    ${resp}=    RequestsLibrary.GET On Session
    ...    Get
    ...    ${API_URL}/some_companyproductwebservices/Product1Data/v1/SearchProduct3Orders
    ...    json=${jsonBody}
    ...    headers=${headers}
    Should Be Equal As Strings    ${resp.status_code}    200     
    RETURN    ${resp} 

Post eLearning Course to Cart Missing Parameter
    [Arguments]    ${email}    ${currCart}    ${token}    ${basePrice}    ${courseQuantity}    ${courseCode}    ${courseTitle}
    RequestsLibrary.Create Session    Cart    ${API_URL}     verify=True
    ${body}=    Catenate    {"product":{
    ...    "title":"${courseTitle}",
    ...    "code":"${courseCode}"},
    ...    "quantity":${courseQuantity},
    ...    "course":{"title":"${courseTitle}",
    ...    "classTCEmails":["some@email.com","someone@some_company.com"],
    ...    "basePrice": ${basePrice}.00,
    ...    "eLearning":"true" }}
    ${jsonBody}=    JSONLibrary.Convert String to JSON    ${body}
    &{headers}=    Create Dictionary
    ...    Content-Type=application/json
    ...    Authorization=Bearer ${token}
    ...    Cookie=somecookie=value; ROUTE=someroute
    ${resp}=    POST On Session
    ...    Cart
    ...    ${API_URL}/rest/v2/some_company/users/${email}/carts/${currCart}/entries
    ...    json=${jsonBody}
    ...    headers=${headers}    expected_status=400
    RETURN    ${resp}


Post Classroom Course to Cart
    [Arguments]    ${email}    ${currCart}    ${token}    ${basePrice}    ${courseQuantity}    ${courseCode}    ${courseTitle}  ${classExpiry}   ${startDate}  ${endDate}
    RequestsLibrary.Create Session    Cart    ${API_URL}     verify=True
    ${body}=    Catenate    {"product":{"code":"${courseCode}"},
    ...    "quantity":${courseQuantity},"course":{
    ...    "classExpiry": "${classExpiry}",
    ...    "startDate":"${startDate}",
    ...    "endDate":"${endDate}",
    ...    "classCountry":"US",
    ...    "location":"Classroom",
    ...    "title":"${courseTitle}",
    ...    "classTCEmails":["some@email.com","someone@some_company.com"],
    ...    "basePrice": ${basePrice}.00,
    ...    "courseId":"SOMEID",
    ...    "classId":"someclass",    
    ...    "eLearning":"false" }}
    ${jsonBody}=    JSONLibrary.Convert String to JSON    ${body}
    &{headers}=    Create Dictionary
    ...    Content-Type=application/json
    ...    Authorization=Bearer ${token}
    ...    Cookie=somecookie=value; ROUTE=someroute
    ${resp}=    POST On Session
    ...    Cart
    ...    ${API_URL}/rest/v2/some_company/users/${email}/carts/${currCart}/entries
    ...    json=${jsonBody}
    ...    headers=${headers}    
    Should Be Equal As Strings    ${resp.status_code}    200    


Post Classroom Course to Cart Missing Parameter
    [Arguments]    ${email}    ${currCart}    ${token}    ${basePrice}    ${courseQuantity}    ${courseCode}    ${courseTitle}  ${classExpiry}   ${startDate}  ${endDate}
    RequestsLibrary.Create Session    Cart    ${API_URL}     verify=True
    ${body}=    Catenate    {"product":{"code":"${courseCode}"},
    ...    "quantity":${courseQuantity},"course":{
    ...    "startDate":"${startDate}",
    ...    "endDate":"${endDate}",
    ...    "classCountry":"US",
    ...    "location":"Classroom",
    ...    "title":"${courseTitle}",
    ...    "classTCEmails":["some@email.com","someone@some_company.com"],
    ...    "basePrice": ${basePrice}.00,
    ...    "courseId":"SOMEID",
    ...    "classId":"someID",    
    ...    "eLearning":"false" }}
    ${jsonBody}=    JSONLibrary.Convert String to JSON    ${body}
    &{headers}=    Create Dictionary
    ...    Content-Type=application/json
    ...    Authorization=Bearer ${token}
    ...    Cookie=somecookie=value; ROUTE=someroute
    ${resp}=    POST On Session
    ...    Cart
    ...    ${API_URL}/rest/v2/some_company/users/${email}/carts/${currCart}/entries
    ...    json=${jsonBody}
    ...    headers=${headers}    expected_status=400
    RETURN    ${resp}



Post Approve or Reject The Order
    [Arguments]    ${decision}    ${email}    ${approverEmail}    ${orderNo}    ${token}     ${responseStatus}
    RequestsLibrary.Create Session    Desicion    ${API_URL}     verify=True
    ${body}=    Catenate    {
    ...    "decision": "${decision}",
    ...    "quoteAccountManager": "${approverEmail}",
    ...    "businessManagerEmail": "${approverEmail}"    }
    ${jsonBody}=    JSONLibrary.Convert String to JSON    ${body}
    BuiltIn.Log To Console    ${jsonBody}
    &{headers}=    Create Dictionary
    ...    Content-Type=application/json
    ...    Authorization=Bearer ${token}
    ...    Cookie=somecookie=value; ROUTE=someroute
    ${resp}=    POST On Session
    ...    Desicion
    ...    ${API_URL}/rest/v2/some_company/users/${email}/orderapprovals/${orderNo}/decision
    ...    json=${jsonBody}
    ...    headers=${headers}    expected_status=${responseStatus}
    RETURN    ${resp}

Approve My App Order Without Business Manager Email
    [Arguments]    ${decision}    ${email}    ${approverEmail}    ${orderNo}    ${token}    ${responseStatus}    
    RequestsLibrary.Create Session    Reject    ${API_URL}     verify=True
    ${body}=    Catenate    {
    ...    "decision": "${decision}",
    ...    "quoteAccountManager": "${approverEmail}"  }
    ${jsonBody}=    JSONLibrary.Convert String to JSON    ${body}
    BuiltIn.Log To Console    ${jsonBody}
    &{headers}=    Create Dictionary
    ...    Content-Type=application/json
    ...    Authorization=Bearer ${token}
    ...    Cookie=somecookie=value; ROUTE=someroute
    ${resp}=    POST On Session
    ...    Reject
    ...    ${API_URL}/rest/v2/some_company/users/${email}/orderapprovals/${orderNo}/decision
    ...    json=${jsonBody}
    ...    headers=${headers}    expected_status=${responseStatus}
    RETURN    ${resp}    

Post Upload Payment Document
    [Arguments]    ${email}    ${orderNo}    ${token}
    Sleep    3
    &{file}=    Create Dictionary    file   ${CURDIR}/PDF.pdf
    RequestsLibrary.Create Session    Cart    ${API_URL}     verify=True
    ${headers}=    Create Dictionary
    ...    Authorization=Bearer ${token}
    ...    Cookie=ROUTE=someroute
    ...    Content-Type=multipart/form-data boundary  
    ${resp}=    POST On Session
    ...    Cart
    ...    ${API_URL}/rest/v2/some_company/users/${email}/orderapprovals/${orderNo}/uploadPurchaseOrder
    ...    headers=${headers}   files=&{file}    headers=&{headers}
    Should Be Equal As Strings    ${resp.status_code}    200



Post Register B2B Customer
    [Arguments]    ${token}    ${email}    ${FirstName}    ${LastName}    ${Country}    ${Company}    ${responseStatus}      
    RequestsLibrary.Create Session    Register User    ${API_URL}    verify=True
    ${body}=    Catenate  {"email": "${email}",
    ...    "firstName": "${FirstName}",
    ...    "lastName": "${LastName}",
    ...    "origin": "My App",
    ...    "country": "${Country}",
    ...     "companyName":"${Company}" }
    ${jsonBody}=    JSONLibrary.Convert String to JSON    ${body}
    &{headers}=    Create Dictionary
    ...    Content-Type=application/json
    ...    Authorization=Bearer ${token}
    ...    Cookie=somecookie=value; ROUTE=someroute
    ${resp}=     POST On Session    Register User    
    ...    ${API_URL}/rest/v2/some_company/users/Anonymous/orgCustomers
    ...    json=${jsonBody}
    ...    headers=${headers}    expected_status=${responseStatus}
    RETURN    ${resp}

Get B2B Customer    
    [Arguments]    ${token}    ${email}    ${responseStatus}    
    RequestsLibrary.Create Session    Get Customer    ${API_URL}    verify=True
    ${headers}=    Create Dictionary
    ...    content-type=application/json
    ...    Authorization=Bearer ${token}
    ...    Cookie=somecookie=value; ROUTE=someroute
    ${resp}=    GET On Session
    ...    Get Customer
    ...    ${API_URL}/rest/v2/some_company/orgUsers/${email}
    ...    headers=${headers}
    RETURN    ${resp}

Get Order Details
    [Arguments]    ${token}   ${order}    ${responseStatus}
    RequestsLibrary.Create Session    Cart    ${API_URL}    verify=True
    ${headers}=    Create Dictionary
    ...    content-type=application/json
    ...    Authorization=Bearer ${token}
    ...    Cookie=somecookie=value; ROUTE=someroute
    ${resp}=    GET On Session
    ...    Cart
    ...    ${API_URL}/rest/v2/some_company/orders/${order}
    ...    headers=${headers}    expected_status=${responseStatus}
    RETURN    ${resp}    

Get Order Details My App
    [Arguments]    ${token}    ${fromDate}    ${toDate}     ${eLearning}    ${courseId}    ${responseStatus}
    RequestsLibrary.Create Session    Order    ${API_URL}    verify=True
    ${headers}=    Create Dictionary
    ...    content-type=application/json
    ...    Authorization=Bearer ${token}
    &{params}=    Create Dictionary
    ...    createdFrom=${fromDate} 
    ...    createdTo=${toDate}
    ...    courseId=${courseId}
    ...    eLearning=${eLearning}
    ${resp}=    GET On Session
    ...    Order
    ...    ${API_URL}/rest/v2/some_company/My App/orders/
    ...    params=${params}
    ...    headers=${headers}    expected_status=${responseStatus}
    RETURN    ${resp}        
        
    
Approve or Reject the My App Order     
    [Arguments]   ${decision}  ${email}  ${approverEmail}  ${OrderNo}  ${courseCode}  ${token}  ${waitStatus}  ${expectedStatus}  ${message}   ${responseStatus}    
    FOR  ${loop}  IN RANGE  12
        Sleep    10
        ${resp}=    Get Order Details    ${token}   ${OrderNo}    200
        BuiltIn.Log To Console    loop checking order status '${loop}'
        ${orderStatus}=    evaluate    $resp.json().get("status")
        Exit For Loop IF    '${orderStatus}'=='${waitStatus}'        
    END
    IF  '${orderStatus}'=='${waitStatus}'   
        ${approverToken}=    Post My App API Approver Token
        ${message}=    Post Approve or Reject The Order    ${decision}    ${email}    ${approverEmail}    ${OrderNo}    ${approverToken}     ${responseStatus}
    ELSE   
        Fatal Error    '${message}' Failed
    END
    FOR  ${loop}  IN RANGE  12
        Sleep    10
        ${resp}=    Get Order Details    ${token}   ${OrderNo}    200
        BuiltIn.Log To Console    loop checking order status    '${loop}'
        ${orderStatus}=    evaluate    $resp.json().get("status")
        Exit For Loop If  '${orderStatus}'=='${expectedStatus}'
    END
    IF    '${orderStatus}'=='${expectedStatus}'
        BuiltIn.Log To Console    "Order " '${message}' '${OrderNo}'
    ELSE   
        Run Keyword and Continue On Failure    BuiltIn.Should Be Equal As Strings     ${orderStatus}     ${expectedStatus}
        BuiltIn.Log To Console    "Order " '${message}' '${OrderNo}'

    END
    RETURN    ${message}

Get Cart Response
    [Arguments]    ${email}    ${token}
    RequestsLibrary.Create Session    Cart    ${API_URL}    verify=True
    ${headers}=    Create Dictionary
    ...    content-type=application/json
    ...    Authorization=Bearer ${token}
    ...    Cookie=somecookie=value; ROUTE=someroute
    ${resp}=    GET On Session
    ...    Cart
    ...    ${API_URL}/rest/v2/some_company/users/${email}/carts/current
    ...    headers=${headers}
    [Return]    ${resp}

Get All Carts Response
    [Arguments]    ${email}    ${token}
    RequestsLibrary.Create Session    Cart    ${API_URL}    verify=True
    ${headers}=    Create Dictionary
    ...    content-type=application/json
    ...    Authorization=Bearer ${token}
    ...    Cookie=somecookie=value; ROUTE=someroute
    ${resp}=    GET On Session
    ...    Cart
    ...    ${API_URL}/rest/v2/some_company/users/${email}/carts
    ...    headers=${headers}
    [Return]    ${resp}    

Delete Item From Cart
    [Arguments]    ${email}    ${token}    ${cart}    ${entry}    ${responseStatus}
    RequestsLibrary.Create Session    Cart    ${API_URL}    verify=True
    ${headers}=    Create Dictionary
    ...    content-type=application/json
    ...    Authorization=Bearer ${token}
    ...    Cookie=somecookie=value; ROUTE=someroute
    ${resp}=    RequestsLibrary.DELETE On Session
    ...    Cart
    ...    ${API_URL}/rest/v2/some_company/users/${email}/carts/${cart}/entries/${entry}
    ...    headers=${headers}    expected_status=${responseStatus}
    [Return]    ${resp}

Delete Cart
    [Arguments]    ${email}    ${token}    ${cart}    ${responseStatus}
    RequestsLibrary.Create Session    Cart    ${API_URL}    verify=True
    ${headers}=    Create Dictionary
    ...    content-type=application/json
    ...    Authorization=Bearer ${token}
    ...    Cookie=somecookie=value; ROUTE=someroute
    ${resp}=    RequestsLibrary.DELETE On Session
    ...    Cart
    ...    ${API_URL}/rest/v2/some_company/users/${email}/carts/${cart}
    ...    headers=${headers}    expected_status=${responseStatus}
    [Return]    ${resp}    


Get Order Details Full
    [Arguments]    ${email}    ${OrderNo}   ${token}
    ${email}=        String.Strip String    ${email}
    ${OrderNo}=        String.Strip String    ${OrderNo}
    ${token}=        String.Strip String    ${token}
    RequestsLibrary.Create Session    Cart    ${API_URL}     verify=True
    ${headers}=    Create Dictionary
    ...    content-type=application/json
    ...    Authorization=Bearer ${token}
    ...    Cookie=somecookie
    ${resp}=    GET On Session
    ...    Cart
    ...    ${API_URL}/rest/v2/some_company/orgUsers/${email}/orgUnits/orders/${OrderNo}?fields\=contractId,contractStatus,cartType,status
    ...    headers=${headers}
    [Return]    ${resp}

Get Auth Token
    ${Auth_URL}    BuiltIn.Set Variable    https://some_company-ds.com
    RequestsLibrary.Create Session    Auth    ${Auth_URL}     verify=True
    ${body}=    Catenate    {
    ...    "client_id": "someid",
    ...    "client_secret": "somesecret",
    ...    "scope": "somescope",
    ...    "grant_type" : "client_credentials"}
    ${jsonBody}=    JSONLibrary.Convert String to JSON    ${body}
    &{headers}=    Create Dictionary    
    ...    Content-Type=application/json
    ...    Authorization=Basic someauth
    ${resp}=    POST On Session
    ...    Auth
    ...    ${Auth_URL}/v2/token
    ...    headers=${headers}
    ...    json=${jsonBody}
    ${Auth_TOKEN}=    evaluate    $resp.json().get("access_token")
    Log to Console    ${resp.json()['access_token']}
    RETURN    ${Auth_TOKEN}

 Get Product2 Portal Reaction
    [Arguments]     ${Auth_Token}    ${email}    ${responseStatus}
    ${Product2_URL}=    Set Variable    https://some_company.com
    RequestsLibrary.Create Session    Product2    ${Product2_URL}
    &{params}=    Create Dictionary
    ...    appCode=Product2-portal
    &{headers}=    Create Dictionary   
    ...    Authorization=Bearer ${Auth_Token}
    ...    Content-Type=application/json
    ...    appkey=somekey
    ${resp}=    RequestsLibrary.GET On Session
    ...    Product2 
    ...    ${Product2_URL}/ccm/userTerms/v2/users/${email}/reaction
    ...    params=${params}
    ...    headers=${headers}     expected_status=${responseStatus}
    RETURN    ${resp}

Get Search Orders
    [Arguments]    ${token}    ${order type}
    RequestsLibrary.Create Session    Get Orders   ${API_URL}     verify=True
    &{headers}=    Create Dictionary
    ...    Content-Type=application/json
    ...    Authorization=Bearer ${token}
    &{params}=    Create Dictionary
    ...    maxDate=06-06-2024 11:40:00
    ...    type=${order type}
    ...    minDate=04-06-2024 11:10:00
    ${resp}=    GET On Session
    ...    Get Orders
    ...    ${API_URL}/some_companyproductwebservices/searchOrders
    ...    params=${params}
    ...    headers=${headers}
    Should Be Equal As Strings    ${resp.status_code}    200
    RETURN    ${resp}

Get Search Customers
    [Arguments]    ${token}
    RequestsLibrary.Create Session    Get Orders   ${API_URL}     verify=True
    &{headers}=    Create Dictionary
    ...    Content-Type=application/json
    ...    Authorization=Bearer ${token}
    &{params}=    Create Dictionary
    ...    maxDate=06-06-2024 11:40:00
    ...    minDate=04-06-2024 11:10:00
    ${resp}=    GET On Session
    ...    Get Orders
    ...    ${API_URL}/some_companyproductwebservices/searchCustomers
    ...    params=${params}
    ...    headers=${headers}
    Should Be Equal As Strings    ${resp.status_code}    200
    RETURN    ${resp}    

Get Address Dr Verification
    [Arguments]    ${azureToken}    ${city}    ${state}    ${country}    ${postal-code}    ${line1}   ${expected_status}
    RequestsLibrary.Create Session   Get Address   ${API_GATEWAY}     verify=True
    &{headers}=    Create Dictionary
    ...    Content-Type=application/json
    ...    Authorization=Bearer ${azureToken}
    ...    x-apikey=somekey
    &{params}=    Create Dictionary
    ...    city=${city}
    ...    state=${state}
    ...    country=${country}
    ...    postal-code=${postal-code}
    ...    line1=${line1}
    ${resp}=    GET On Session
    ...    Get Address
    ...    ${API_GATEWAY}/validate-data/address-cleanser/cleanse
    ...    params=${params}
    ...    headers=${headers}
    Should Be Equal As Strings    ${resp.status_code}    ${expected_status}
    RETURN    ${resp}
    
Get Dow Jones Status
     [Arguments]    ${content-set}    ${search-type}    ${first-name}    ${surname}    ${expected_status}
    RequestsLibrary.Create Session   Get DJ Status   ${DOW_JONES_API}     verify=True
    &{headers}=    Create Dictionary
    ...    Accept=application/json
    ...    Authorization=Basic someauth
    &{params}=    Create Dictionary
    ...    content-set=${content-set}
    ...    search-type=${search-type}
    ...    first-name=${first-name}
    ...    surname= ${surname}
    ${resp}=    GET On Session
    ...    Get DJ Status
    ...    ${DOW_JONES_API}/v1/search/person-name
    ...    params=${params}
    ...    headers=${headers}
    Should Be Equal As Strings    ${resp.status_code}    ${expected_status}
    RETURN    ${resp}


TC (API) Schema Validation
    ${resp}=    Get All Carts Response    ${email}    ${token}
    ${message}=    Evaluate   str($resp.content, encoding='utf-8')
    BuiltIn.Log To Console    ${message}
    ${schema}    Get Binary File    ./SLB/TestCases/schemas/cartAllSchema.json
    ${schema}    evaluate    json.loads('''${schema}''')    json
    ${instance}    evaluate    json.loads('''${resp.content}''')    json
    validate    instance=${instance}    schema=${schema}   
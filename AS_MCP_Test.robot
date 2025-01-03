*** Settings ***
Library    RequestsLibrary
Library    Collections
Library    BuiltIn

*** Variables ***
${BASE_URL}            https://192.168.254.92
${PAIR_ENDPOINT}       /api/mcp/v1/pair
${TABLE_INFO}          /api/mcp/v1/table-info
${TABLE_CONFIG}        /api/mcp/v1/table-config
${TABLE_MODE}          /api/mcp/v1/table-mode
${TARGET_POSITION}     /api/mcp/v1/target-position
${HEADERS}             {"Authorization": "Bearer 123e4567e89b12d3a456426614174000", "Content-Type": "application/json"}
${TIMEOUT}             30
${pair_data}           {"authToken": "Token", "sensorData": [{"theta": 10, "phi": 180, "rho": 0}]}
${Table_Config_BODY}   {"powerLimit": "100", "vInit": "10", "vMax": "90", "acceleration": "10", "thetaMin": "5", "thetaMax": "15", "phiHysterisis": "3"}

*** Test Cases ***
Run Full API Test Suite
    [Documentation]    This test suite runs the full API flow:
    ...                Pair -> Table Info -> Table Config -> Table Mode -> Target Position
    
    Test Pair API
    Test Table Info API
    Test Table Config API
    Test Table Mode API
    Test Target Position API
*** Keywords ***
Test Pair API
    [Documentation]    This test verifies the pairing endpoint.
     Create Session    api_session    ${BASE_URL}    headers=${headers}    verify=False
    ${response}=    PUT On Session    api_session    ${PAIR_ENDPOINT}    json=${pair_data}
    Log    ${response.status_code}
    Log    ${response.text}
    Should Be Equal As Numbers    ${response.status_code}    200

Test Table Info API
    [Documentation]    This test retrieves the table info details.
    Create Session    mysession    ${BASE_URL}    headers=${HEADERS}    verify=False    timeout=${TIMEOUT}
    ${response}=    Get Request    mysession    ${TABLE_INFO}
    Should Be Equal As Numbers    ${response.status_code}    200
    Should Contain    ${response.json()}    "swVersion"
    Log    Table Info: ${response.json()}

Test Table Config API
    [Documentation]    This test updates the table configuration.
    Create Session  api  ${BASE_URL}  timeout=${TIMEOUT}  headers=${HEADERS}  verify=False
    ${response}=  Put Request  api  ${TABLE_CONFIG}  json=${Table_Config_BODY}
    Log  Status Code: ${response.status_code}
    Log  Response Body: ${response.text}
    # Should Be Equal As Numbers  ${response.status_code}  200
    Should Contain  ${response.text}  "status"

Test Table Mode API
    [Documentation]    This test sets the table mode.
    Create Session    mysession    ${BASE_URL}    headers=${HEADERS}    verify=False    timeout=${TIMEOUT}
    ${payload}=    Create Dictionary    mode=Auto
    ${response}=    Put Request    mysession    ${TABLE_MODE}    json=${payload}
    # Should Be Equal As Numbers    ${response.status_code}    200
    Log    Table Mode set to Auto: ${response.text}

Test Target Position API
    [Documentation]    This test sets the target position.
    Create Session    mysession    ${BASE_URL}    headers=${HEADERS}    verify=False    timeout=${TIMEOUT}
    ${payload}=    Create Dictionary    Angle=[{'Theta': '15', 'Phi': '180', 'R': '10'}]
    ${response}=    Put Request    mysession    ${TARGET_POSITION}    json=${payload}
    # Should Be Equal As Numbers    ${response.status_code}    200
    Log    Target Position set: ${response.text}

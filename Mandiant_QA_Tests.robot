*** Settings ***
Documentation	Mandiant QA Test
Library			RequestsLibrary
Library 		Collections
Library  		JSONLibrary

Test Template    Connect And validate Countries GraphQL API

Suite Setup    Create Session  requestSession  https://countries.trevorblades.com	verify=true	disable_warnings=1

*** Test Cases ***                INPUT         EXPECTED
Valid Country - IN					IN			{"data": {"country": {"name": "India","capital": "New Delhi","currency": "INR"}}}
Valid County LowerCase - br			br			{"data": {"country": null}}
Invalid Country - WW				WW    		{"data": {"country": null}}
	


*** Keywords ***
Connect And validate Countries GraphQL API
	[Arguments]    ${input}	${expected}
    
	# Arrange
    ${expected_json}=    Convert String to JSON	${expected}
	${expected_country_data}=	 Get value from JSON    ${expected_json}    $.data.country
	&{input_json}=	Create dictionary   query= { country (code: \"${input}\") { name capital currency }}
    
	# Act
	${resp}=    POST On Session    requestSession	/	json=${input_json}
	${string_resp}=    Convert To String    ${resp.content}
	${actual_json}=    Convert String to JSON	${string_resp}
	${actual_country_data}=	 Get value from JSON    ${actual_json}    $.data.country
	Log		${actual_country_data}
	Log		${expected_country_data}
	
	# Assert
    Status Should Be                 200  ${resp}
	Should Be Equal	${expected_country_data}	${actual_country_data}
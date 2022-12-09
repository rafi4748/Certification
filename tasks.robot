*** Settings ***
Documentation       Enter weekly sales into the RobotSpareBin Industries Intranet.

Library    RPA.Browser.Selenium    auto_close=${FALSE}
Library    RPA.Excel.Files
Library    RPA.HTTP
Library    RPA.Tables
Library    RPA.RobotLogListener
Library    RPA.Archive
Library    RPA.PDF
Library    RPA.Email.ImapSmtp
Library    RPA.FileSystem




*** Variables ***
${URL}=    https://robotsparebinindustries.com/#/robot-order
${status}     0


*** Tasks ***
Order robots from RobotSpareBin Industries Inc
    Download an Excel file, open it, and close it
    Open the robot order website
    Get Orders
    
    

*** Keywords ***
Download an Excel file, open it, and close it
    Download    https://robotsparebinindustries.com/orders.csv            overwrite=True
    Sleep    5
    Close All Browsers

*** Keywords ***
Open the robot order website
    Open Available Browser     ${URL}
    Sleep    5
    Click Button    OK
Get Orders
    ${order_table}    Read table from CSV    orders.csv    header=True
    FOR    ${order_row}    IN    @{order_table}
        WHILE    True
            ${status}    Set Variable    True
            TRY
                Select From List By Index    head    ${order_row}[Head]
                Select Radio Button    body    ${order_row}[Body]
                Input Text    xpath=//input[@placeholder="Enter the part number for the legs"]    ${order_row}[Legs]
                Input Text    address    ${order_row}[Address]
                Click Button    Order
                Wait Until Element Is Visible    order-another    5s
                ${status}    Set Variable    False
                Log    ${status}
            EXCEPT
                Close Browser
                Open Available Browser    ${URL}
                 Click Button    OK
            END

            IF    "${status}" == "False"                BREAK
        END

        ${receipt_html}    Get Element Attribute    id:receipt    outerHTML
        Html To Pdf    ${receipt_html}    ReceiptPdf${/}${order_row}[Order number].pdf    overwrite=True
        Screenshot    id:receipt    Screenshot${/}${order_row}[Order number].png
        ${imgfile}    Create List    Screenshot${/}${order_row}[Order number].png
        Add Files To Pdf
        ...    ${imgfile}
        ...    ReceiptPdf${/}${order_row}[Order number].pdf    append=True
        Click Button    order-another
        Click Button    OK
        Wait Until Page Contains Element    head    10s
    END

    Archive Folder With Zip    ReceiptPdf       ReceiptPdf.zip
    Close All Browsers




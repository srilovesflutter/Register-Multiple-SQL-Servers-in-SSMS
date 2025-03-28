# Generate .regsrvr File for SSMS Registered Servers

## Overview

This PowerShell script, `Generate.ps1`, generates a `.regsrvr` file for SQL Server Management Studio (SSMS) Registered Servers. It takes a server group name and a list of server names as input and outputs an XML file that conforms to the SSMS registered server XML format. This file can then be imported into SSMS to quickly register multiple SQL Server instances.

## Features

- **Group Name Input:** Specify a group name to organize your registered servers.
- **Server List Input:** Accepts multiple server names entered as a comma-separated string or on separate lines.
- **XML Generation:** Automatically builds the XML structure needed for SSMS using the provided inputs.
- **Output File:** Creates a file named `<GroupName>.regsrvr` in the current directory.

## Prerequisites

- PowerShell (version 3.0 or later)
- Basic familiarity with running PowerShell scripts
- SQL Server Management Studio (SSMS) for importing the generated file

## Script Details

### Parameters

- **GroupName**  
  The name of the server group. This value will appear in the generated XML and is used to create the output filename.

- **Servers**  
  A list of server names. The script accepts server names separated by commas or new lines.  
  **Example formats:**
  - Comma-separated:  
    `Test1\Instance1, Test2\Instance2, Test3\Instance3`
  - Multi-line using a here-string:

    ```powershell
    @"
    Test1\Instance1
    Test2\Instance2
    Test3\Instance3
    "@
    ```

### How the Script Works

1. **Input Processing:**  
   The script splits the server list using a regular expression that handles commas and newline characters. It then trims extra whitespace and creates an array of server names.

2. **XML Block Generation:**  
   Two sections of XML are dynamically generated:
   - **Server Reference Block:** Inserts each server into the group’s XML section.
   - **Server Document Block:** Creates a `<document>` entry for each server with its connection details.

3. **XML Template Integration:**  
   The generated XML blocks are inserted into a pre-defined XML template that follows the SSMS Registered Servers schema.

4. **Output File Creation:**  
   The complete XML is written to a file named `<GroupName>.regsrvr` (e.g., `TestGroup.regsrvr`).

## Usage

### Command Line Usage

Run the script with the required parameters. For example:

```powershell
.\Generate.ps1 -GroupName "TestGroup" -Servers "Test1\Instance1, Test2\Instance2, Test3\Instance3"

.\Generate.ps1 -GroupName "TestGroup" -Servers @"
Test1\Instance1
Test2\Instance2
Test3\Instance3
"@


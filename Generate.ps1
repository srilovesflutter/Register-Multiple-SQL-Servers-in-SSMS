<#
.SYNOPSIS
    Generates a .regsrvr file for SSMS Registered Servers from a group name and list of servers.

.DESCRIPTION
    This script takes two parameters:
      - GroupName: The name of the server group.
      - Servers: A list of server names separated by commas or new lines.
    It then creates a file named GroupName.regsrvr with the appropriate XML format. 
    The XML contains a group section and then repeating blocks for each registered server.

.EXAMPLE
    .\Generate.ps1 -GroupName "TestGroup" -Servers "Test1\Instance1, Test2\Instance2, Test3\Instance3"

.NOTES
    Modify the XML template as needed.
#>

param (
    [Parameter(Mandatory = $true, HelpMessage = "Enter the group name.")]
    [string]$GroupName,

    [Parameter(Mandatory = $true, HelpMessage = "Enter the server names (comma or newline separated).")]
    [string]$Servers
)

# Split the server names by comma or newline and trim any whitespace
$serverList = $Servers -split '[,\r\n]+' | ForEach-Object { $_.Trim() } | Where-Object { $_ -ne "" }

# Build the repeating server reference block for the group XML
$serverReferences = ""
foreach ($server in $serverList) {
    $serverReferences += @"
                          <sfc:Reference sml:ref="true">
                            <sml:Uri>/RegisteredServersStore/ServerGroup/DatabaseEngineServerGroup/ServerGroup/$GroupName/RegisteredServer/$server</sml:Uri>
                          </sfc:Reference>
"@
}

# Build the repeating server document block for each server
$serverDocuments = ""
foreach ($server in $serverList) {
    $serverDocuments += @"
                <document>
                  <docinfo>
                    <aliases>
                      <alias>/RegisteredServersStore/ServerGroup/DatabaseEngineServerGroup/ServerGroup/$GroupName/RegisteredServer/$server</alias>
                    </aliases>
                    <sfc:version DomainVersion="1" />
                  </docinfo>
                  <data>
                    <RegisteredServers:RegisteredServer xmlns:RegisteredServers="http://schemas.microsoft.com/sqlserver/RegisteredServers/2007/08" xmlns:sfc="http://schemas.microsoft.com/sqlserver/sfc/serialization/2007/08" xmlns:sml="http://schemas.serviceml.org/sml/2007/02" xmlns:xs="http://www.w3.org/2001/XMLSchema">
                      <RegisteredServers:Parent>
                        <sfc:Reference sml:ref="true">
                          <sml:Uri>/RegisteredServersStore/ServerGroup/DatabaseEngineServerGroup/ServerGroup/$GroupName</sml:Uri>
                        </sfc:Reference>
                      </RegisteredServers:Parent>
                      <RegisteredServers:Name type="string">$server</RegisteredServers:Name>
                      <RegisteredServers:Description type="string" />
                      <RegisteredServers:ServerName type="string">$server</RegisteredServers:ServerName>
                      <RegisteredServers:UseCustomConnectionColor type="boolean">false</RegisteredServers:UseCustomConnectionColor>
                      <RegisteredServers:CustomConnectionColorArgb type="int">-986896</RegisteredServers:CustomConnectionColorArgb>
                      <RegisteredServers:ServerType type="ServerType">DatabaseEngine</RegisteredServers:ServerType>
                      <RegisteredServers:ConnectionStringWithEncryptedPassword type="string">data source=$server;integrated security=True;pooling=False;multiple active result sets=False;connect timeout=30;encrypt=True;trust server certificate=False;packet size=4096;command timeout=0</RegisteredServers:ConnectionStringWithEncryptedPassword>
                      <RegisteredServers:CredentialPersistenceType type="CredentialPersistenceType">None</RegisteredServers:CredentialPersistenceType>
                      <RegisteredServers:OtherParams type="string" />
                      <RegisteredServers:AuthenticationType type="int">0</RegisteredServers:AuthenticationType>
                      <RegisteredServers:ActiveDirectoryTenant type="string" />
                    </RegisteredServers:RegisteredServer>
                  </data>
                </document>
"@
}

# XML template with placeholders for GroupName, ServerReferences, and ServerDocuments.
$xmlTemplate = @"
<?xml version="1.0"?>
<model xmlns="http://schemas.serviceml.org/smlif/2007/02">
  <identity>
    <name>urn:uuid:96fe1236-abf6-4a57-b54d-e9baab394fd1</name>
    <baseURI>http://documentcollection/</baseURI>
  </identity>
  <xs:bufferSchema xmlns:xs="http://www.w3.org/2001/XMLSchema">
    <definitions xmlns:sfc="http://schemas.microsoft.com/sqlserver/sfc/serialization/2007/08">
      <document>
        <docinfo>
          <aliases>
            <alias>/system/schema/RegisteredServers</alias>
          </aliases>
          <sfc:version DomainVersion="1" />
        </docinfo>
        <data>
          <xs:schema targetNamespace="http://schemas.microsoft.com/sqlserver/RegisteredServers/2007/08" xmlns:sfc="http://schemas.microsoft.com/sqlserver/sfc/serialization/2007/08" xmlns:sml="http://schemas.serviceml.org/sml/2007/02" xmlns:xs="http://www.w3.org/2001/XMLSchema" elementFormDefault="qualified">
            <xs:element name="ServerGroup">
              <xs:complexType>
                <xs:sequence>
                  <xs:any namespace="http://schemas.microsoft.com/sqlserver/RegisteredServers/2007/08" processContents="skip" minOccurs="0" maxOccurs="unbounded" />
                </xs:sequence>
              </xs:complexType>
            </xs:element>
            <xs:element name="RegisteredServer">
              <xs:complexType>
                <xs:sequence>
                  <xs:any namespace="http://schemas.microsoft.com/sqlserver/RegisteredServers/2007/08" processContents="skip" minOccurs="0" maxOccurs="unbounded" />
                </xs:sequence>
              </xs:complexType>
            </xs:element>
            <RegisteredServers:bufferData xmlns:RegisteredServers="http://schemas.microsoft.com/sqlserver/RegisteredServers/2007/08">
              <instances xmlns:sfc="http://schemas.microsoft.com/sqlserver/sfc/serialization/2007/08">
                <document>
                  <docinfo>
                    <aliases>
                      <alias>/RegisteredServersStore/ServerGroup/DatabaseEngineServerGroup/ServerGroup/$GroupName</alias>
                    </aliases>
                    <sfc:version DomainVersion="1" />
                  </docinfo>
                  <data>
                    <RegisteredServers:ServerGroup xmlns:RegisteredServers="http://schemas.microsoft.com/sqlserver/RegisteredServers/2007/08" xmlns:sfc="http://schemas.microsoft.com/sqlserver/sfc/serialization/2007/08" xmlns:sml="http://schemas.serviceml.org/sml/2007/02" xmlns:xs="http://www.w3.org/2001/XMLSchema">
                      <RegisteredServers:RegisteredServers>
                        <sfc:Collection>
$serverReferences
                        </sfc:Collection>
                      </RegisteredServers:RegisteredServers>
                      <RegisteredServers:Parent>
                        <sfc:Reference sml:ref="true">
                          <sml:Uri>/RegisteredServersStore/ServerGroup/DatabaseEngineServerGroup</sml:Uri>
                        </sfc:Reference>
                      </RegisteredServers:Parent>
                      <RegisteredServers:Name type="string">$GroupName</RegisteredServers:Name>
                      <RegisteredServers:Description type="string" />
                      <RegisteredServers:ServerType type="ServerType">DatabaseEngine</RegisteredServers:ServerType>
                    </RegisteredServers:ServerGroup>
                  </data>
                </document>
$serverDocuments
              </instances>
            </RegisteredServers:bufferData>
          </xs:schema>
        </data>
      </document>
    </definitions>
  </xs:bufferSchema>
</model>
"@

# Define the output filename (GroupName.regsrvr)
$outputFile = "$GroupName.regsrvr"

# Write the generated XML to the output file
$xmlTemplate | Out-File -FilePath $outputFile -Encoding UTF8

Write-Host "File '$outputFile' has been generated with group '$GroupName' and servers:" -ForegroundColor Green
$serverList | ForEach-Object { Write-Host " - $_" }

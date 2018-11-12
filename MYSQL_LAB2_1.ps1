#### variables

$arrNamesDBs = @()
$HumanResources = "False"
$InternetSales = "False"

##################################################

Try
 {
    $SqlServer = "192.168.1.1";
    $SqlLogin = "Sa";
    $SqlPassw = Read-Host "Enter PASSWORD"
    $SqlConnection = New-Object System.Data.SqlClient.SqlConnection
    $SqlConnection.ConnectionString = "Server=$SqlServer; User ID=$SqlLogin; Password=$SqlPassw;"
    $SqlConnection.Open()
 }
Catch [system.exception]
 {
    Write-Host "caught a system exception (open connection)" -ForegroundColor White -BackgroundColor Red 
 }

$SqlCmd = $SqlConnection.CreateCommand()
$SqlCmd.CommandText = "EXEC sp_Databases;"
$objReader = $SqlCmd.ExecuteReader()
while ($objReader.read()) {
  $arrNamesDBs += $objReader.GetValue(0)
}

$objReader.close()

Write-Host $arrNamesDBs

foreach($i in $arrNamesDBs) {

    If($i -like "HumanResources") {
    
        $HumanResources = "True"

    } elseif ($i -like "InternetSales") {

        $InternetSales = "True"

    }

}
####################################################################################

function Set-CrTable {
Param($nameOfTable)

if ($nameOfTable -like "InternetSales") {

Write-Host "Create DB - 'InternetSales'" -ForegroundColor White -BackgroundColor DarkGreen

$SqlCmd.CommandText = @'
CREATE DATABASE InternetSales
ON PRIMARY
  ( NAME='InternetSales',
    FILENAME=
       "F:\Data\InternetSales.mdf",
    SIZE=5MB,
    FILEGROWTH=1MB),
FILEGROUP SalesData
  ( NAME = 'InternetSales_data1',
    FILENAME =
       'F:\Data\InternetSales_data1.ndf',
    SIZE = 100MB,
    FILEGROWTH=10MB),
  ( NAME = 'InternetSales_data2',
    FILENAME =
       'F:\AdditionalData\InternetSales_data2.ndf',
    SIZE = 100MB,
    FILEGROWTH=10MB)
LOG ON
  ( NAME='InternetSales_log',
    FILENAME =
       'F:\Logs\InternetSales_log.ldf',
    SIZE=2MB,
    FILEGROWTH=10%);

ALTER DATABASE InternetSales 
  MODIFY FILEGROUP SalesData DEFAULT;

'@

$objReader = $SqlCmd.ExecuteReader()
$objReader.close()

} else {

Write-Host "Create DB - 'HumanResources'" -ForegroundColor White -BackgroundColor DarkGreen

$SqlCmd.CommandText = @'
CREATE DATABASE HumanResources
ON PRIMARY
  ( NAME='HumanResources',
    FILENAME=
       'F:\Data\HumanResources.mdf',
    SIZE=50MB,
    FILEGROWTH=5MB)
LOG ON
  ( NAME='HumanResources_log',
    FILENAME =
       'F:\Logs\HumanResources_log.ldf',
    SIZE=5MB,
    FILEGROWTH=1MB);
'@

$objReader = $SqlCmd.ExecuteReader()
$objReader.close()

}

}

####################################################################################

Try {

    If($InternetSales -like "True") {

    Write-Host "Such name DB 'InternetSales' already exist. DROP DB - 'InternetSales'" -ForegroundColor White -BackgroundColor Magenta

    $SqlCmd.CommandText = "DROP DATABASE InternetSales;"
    $objReader = $SqlCmd.ExecuteReader()
    $objReader.close()
    Set-CrTable -nameOfTable "InternetSales"


    } else {

    Set-CrTable -nameOfTable "InternetSales"

    }

} 
Catch [system.exception] {
    
    Write-Host "caught a system exception (DROP/CREATE InternetSales)" -ForegroundColor White -BackgroundColor Red
    $SqlConnection.close()

}

############################################################################

Try {

    If($HumanResources -like "True") {

    Write-Host "Such name DB 'InternetSales' already exist. DROP DB - 'HumanResources'" -ForegroundColor White -BackgroundColor Magenta
    $SqlCmd.CommandText = "DROP DATABASE HumanResources; "
    $objReader = $SqlCmd.ExecuteReader()
    $objReader.close()
    Set-CrTable -nameOfTable "HumanResources"

    } else {

    Set-CrTable -nameOfTable "HumanResources"

    }
}
Catch [system.exception] {
    
    Write-Host "caught a system exception (DROP/CREATE HumanResources)" -ForegroundColor White -BackgroundColor Red
    $SqlConnection.close()
}

$SqlConnection.close()

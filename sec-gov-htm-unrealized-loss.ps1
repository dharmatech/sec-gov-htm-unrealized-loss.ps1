
$username = Get-Content ~\Dropbox\api-keys\username # replace with your name or company name
$email    = Get-Content ~\Dropbox\api-keys\email    # replace with your email

$headers = @{ 'User-Agent' = ('{0} {1}' -f $username, $email) }

$cik_table = @{ 
    PACW = 'CIK0001102112' 
    FRC  = 'CIK0001132979'
    WAL  = 'CIK0001212545'
    SCHW = 'CIK0000316709'
    SIVB = 'CIK0000719739'
    # SBNY = 'CIK0001288784'
    
}

# $cik = $cik_table.WAL

$cik = $cik_table.SIVB

# $result_submissions = Invoke-RestMethod ('https://data.sec.gov/submissions/{0}.json' -f $cik) -Headers $headers

# $result = Invoke-RestMethod ('https://data.sec.gov/api/xbrl/companyfacts/{0}.json' -f $cik) -Headers $headers

$result = Invoke-RestMethod ('https://data.sec.gov/api/xbrl/companyconcept/{0}/us-gaap/HeldToMaturitySecuritiesAccumulatedUnrecognizedHoldingLoss.json' -f $cik) -Headers $headers

# SIVB
# $result_json = $result.Replace('USD/Right', 'USD/Right1') | ConvertFrom-Json
# $result = $result_json

# SCHW
# $result_json = $result.Replace('Segment', "Segment1").Replace('State', 'State1') | ConvertFrom-Json
# $result = $result_json

# $result.facts.'us-gaap'.HeldToMaturitySecuritiesAccumulatedUnrecognizedHoldingLoss.units.USD | ft

$result.units.USD | ft

$json = @{
    chart = @{
        type = 'bar'
        data = @{
            labels = $result.units.USD.ForEach({ $_.end })
            datasets = @(
                @{ label = 'HTM unrealized loss'; data = $result.units.USD.ForEach({ $_.val }); }
            )
        }
        options = @{
            title = @{ display = $true; text = $result.entityName }
            scales = @{ }
        }
    }
} | ConvertTo-Json -Depth 100

$result_chart = Invoke-RestMethod -Method Post -Uri 'https://quickchart.io/chart/create' -Body $json -ContentType 'application/json'

# Start-Process $result.url

$id = ([System.Uri] $result_chart.url).Segments[-1]

Start-Process ('https://quickchart.io/chart-maker/view/{0}' -f $id)

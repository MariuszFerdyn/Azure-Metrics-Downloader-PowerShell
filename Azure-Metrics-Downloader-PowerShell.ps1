# Connect to Azure (if not already connected)
#Connect-AzAccount
# Import necessary modules
#Import-Module Az.Monitor

Write-Host "Starting...."
$resourceId = "/subscriptions/xxx/resourceGroups/xxx/providers/Microsoft.Network/applicationGateways/xxx"
$startTime = Get-Date "2024-10-23 13:00:00"
$endTime = Get-Date "2024-10-23 17:00:00"


# Get all possible metrics for the resource
$metricDefinitions = Get-AzMetricDefinition -ResourceId $resourceId
$allmetrics = $metricDefinitions.Name.Value

# Initialize an array
$all = @()

# Query metrics


foreach ($metric in $allmetrics) {
 $results = Get-AzMetric -ResourceId $resourceId -MetricName $metric -StartTime $startTime -EndTime $endTime -Aggregation Total
  foreach ($metric in $results) {
      foreach ($element in $metric.TimeSeries) {
          foreach ($metricValue in $element.Data) {
              $timestamp = $metricValue.TimeStamp.ToString("yyyy-MM-dd HH:mm")
              $average = $metricValue.Average
              $maximumn = $metricValue.Maximum
              $total = $metricValue.Total
              $count = $metricValue.Count
              #Write-Host("$timestamp,$average,$maximumn,$total,$count")
              $all += [PSCustomObject]@{
                  Metric = $metric.Name.Value
                  TimeStamp = $timestamp
                  Average = $average
                  Maximum = $maximumn
                  Total = $total
                  Count = $count}
          }
      }
  }
}
# Print the result
$all | Out-GridView

# Export the result to CSV
$resourceName = Split-Path -Path $resourceId -Leaf
$csvPath = "$resourceName.csv"
$all | Export-Csv -Path $csvPath -NoTypeInformation -Encoding utf8

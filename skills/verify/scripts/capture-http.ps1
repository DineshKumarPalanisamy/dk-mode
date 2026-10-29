<#
Local HTTP capture endpoint for verification. Stands in for a remote service
(for example a payment gateway or a vendor API) so a caller's real request can be inspected.

Records per request: method, path, query parameter NAMES (values redacted),
header names, the value of selected headers redacted to 4 chars, and body length.
Never records the body or any secret value.

Usage:
  pwsh -File .claude/skills/verify/scripts/capture-http.ps1 -Port 7399 -OutFile .dk/artifacts/<id>/verify/capture.jsonl [-MaxRequests 1] [-TimeoutSeconds 120] [-StatusCode 200] [-ResponseBody '{"token":"fake"}']
Point the caller's base URL at http://localhost:<Port>/ and run it.
#>
param(
    [int]$Port = 7399,
    [Parameter(Mandatory)] [string]$OutFile,
    [int]$MaxRequests = 1,
    [int]$TimeoutSeconds = 120,
    [int]$StatusCode = 200,
    [string]$ResponseBody = '{}'
)

$ErrorActionPreference = 'Stop'
$redactHeaders = @('x-functions-key', 'authorization', 'ocp-apim-subscription-key', 'x-api-key')

function Redact([string]$value) {
    if ([string]::IsNullOrEmpty($value)) { return '' }
    if ($value.Length -le 4) { return '****' }
    return $value.Substring(0, 4) + '...'
}

New-Item -ItemType Directory -Force -Path (Split-Path -Parent $OutFile) | Out-Null
$listener = [System.Net.HttpListener]::new()
$listener.Prefixes.Add("http://localhost:$Port/")
$listener.Start()
Write-Host "capture listening on http://localhost:$Port/ (pid $PID)"

$deadline = (Get-Date).AddSeconds($TimeoutSeconds)
$count = 0
try {
    while ($count -lt $MaxRequests -and (Get-Date) -lt $deadline) {
        $pending = $listener.GetContextAsync()
        while (-not $pending.Wait(500)) {
            if ((Get-Date) -ge $deadline) { break }
        }
        if (-not $pending.IsCompleted) { break }
        $ctx = $pending.Result
        $req = $ctx.Request

        $queryNames = @()
        foreach ($k in $req.QueryString.AllKeys) { $queryNames += $k }
        $headers = [ordered]@{}
        foreach ($h in $req.Headers.AllKeys) {
            $headers[$h] = if ($redactHeaders -contains $h.ToLowerInvariant()) { Redact $req.Headers[$h] } else { '(present)' }
        }
        $reader = [System.IO.StreamReader]::new($req.InputStream)
        $bodyLength = $reader.ReadToEnd().Length

        $record = [ordered]@{
            time         = (Get-Date).ToString('o')
            method       = $req.HttpMethod
            path         = $req.Url.AbsolutePath
            queryNames   = $queryNames
            hasQuery     = [bool]$req.Url.Query
            headers      = $headers
            bodyLength   = $bodyLength
        }
        ($record | ConvertTo-Json -Compress -Depth 4) | Add-Content -Path $OutFile -Encoding utf8

        $bytes = [System.Text.Encoding]::UTF8.GetBytes($ResponseBody)
        $ctx.Response.StatusCode = $StatusCode
        $ctx.Response.ContentType = 'application/json'
        $ctx.Response.OutputStream.Write($bytes, 0, $bytes.Length)
        $ctx.Response.Close()
        $count++
    }
}
finally {
    $listener.Stop()
    Write-Host "capture stopped after $count request(s); records in $OutFile"
}

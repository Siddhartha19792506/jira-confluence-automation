param(
    [string]$RequestJson
)

$ErrorActionPreference = "Stop"

function Send-JsonRpcResponse {
    param(
        [Parameter(Mandatory = $true)]
        [object]$Payload
    )

    $json = $Payload | ConvertTo-Json -Depth 20 -Compress
    Write-Output $json
}

$toolSchema = @{
    type = "object"
    properties = @{
        message = @{
            type = "string"
            description = "Text to echo back"
        }
    }
    required = @("message")
}

$timeToolSchema = @{
    type = "object"
    properties = @{}
}

function Process-RequestLine {
    param(
        [Parameter(Mandatory = $true)]
        [string]$line
    )

    if ([string]::IsNullOrWhiteSpace($line)) {
        return
    }

    try {
        $request = $line | ConvertFrom-Json
    }
    catch {
        return
    }

    if (-not ($request.PSObject.Properties.Name -contains "method")) {
        return
    }

    $method = [string]$request.method
    $idExists = $request.PSObject.Properties.Name -contains "id"
    $id = if ($idExists) { $request.id } else { $null }

    switch ($method) {
        "initialize" {
            if ($idExists) {
                Send-JsonRpcResponse -Payload @{
                    jsonrpc = "2.0"
                    id = $id
                    result = @{
                        protocolVersion = "2024-11-05"
                        capabilities = @{
                            tools = @{}
                        }
                        serverInfo = @{
                            name = "echo-windows"
                            version = "1.0.0"
                        }
                    }
                }
            }
        }
        "notifications/initialized" {
        }
        "ping" {
            if ($idExists) {
                Send-JsonRpcResponse -Payload @{
                    jsonrpc = "2.0"
                    id = $id
                    result = @{}
                }
            }
        }
        "tools/list" {
            if ($idExists) {
                Send-JsonRpcResponse -Payload @{
                    jsonrpc = "2.0"
                    id = $id
                    result = @{
                        tools = @(
                            @{
                                name = "echo"
                                description = "Echoes a provided message"
                                inputSchema = $toolSchema
                            },
                            @{
                                name = "time"
                                description = "Returns current local date and time"
                                inputSchema = $timeToolSchema
                            }
                        )
                    }
                }
            }
        }
        "tools/call" {
            if ($idExists) {
                $toolName = [string]$request.params.name
                if ($toolName -eq "echo") {
                    $message = [string]$request.params.arguments.message
                    Send-JsonRpcResponse -Payload @{
                        jsonrpc = "2.0"
                        id = $id
                        result = @{
                            content = @(
                                @{
                                    type = "text"
                                    text = $message
                                }
                            )
                        }
                    }
                }
                elseif ($toolName -eq "time") {
                    $now = Get-Date -Format "yyyy-MM-dd HH:mm:ss zzz"
                    Send-JsonRpcResponse -Payload @{
                        jsonrpc = "2.0"
                        id = $id
                        result = @{
                            content = @(
                                @{
                                    type = "text"
                                    text = $now
                                }
                            )
                        }
                    }
                }
                else {
                    Send-JsonRpcResponse -Payload @{
                        jsonrpc = "2.0"
                        id = $id
                        error = @{
                            code = -32601
                            message = "Tool not found: $toolName"
                        }
                    }
                }
            }
        }
        default {
            if ($idExists) {
                Send-JsonRpcResponse -Payload @{
                    jsonrpc = "2.0"
                    id = $id
                    error = @{
                        code = -32601
                        message = "Method not found: $method"
                    }
                }
            }
        }
    }
}

if ($MyInvocation.ExpectingInput) {
    foreach ($line in $input) {
        Process-RequestLine -line ([string]$line)
    }
    exit 0
}

if (-not [string]::IsNullOrWhiteSpace($RequestJson)) {
    Process-RequestLine -line $RequestJson
    exit 0
}

while ($true) {
    $line = [Console]::In.ReadLine()
    if ($null -eq $line) {
        break
    }

    Process-RequestLine -line $line
}

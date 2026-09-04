# Module 10 Completion Report

## Instruction Files

    Directory: 
    C:\Users\SiddharthaKumarSriva\Documents\Test\Vibecoding\instructions


Mode                 LastWriteTime         Length Name                         
----                 -------------         ------ ----                         
-a----        04-09-2026     13:59            489 create-status-report.agent.md
-a----        04-09-2026     14:21            807 fetch-jira-issue-data.agent.m
                                                  d                            
-a----        04-09-2026     14:21            781 generate-jql-reporting-querie
                                                  s.agent.md                   
-a----        04-09-2026     14:21           1047 main.agent.md                
-a----        04-09-2026     14:21            649 process-sprint-summary-table.
                                                  agent.md                     
-a----        04-09-2026     14:21            765 update-confluence-project-sta
                                                  tus.agent.md                 

## main.agent.md Contents
- Instructions Catalog
- ./instructions/create-status-report.agent.md - Generate weekly status reports in constrained markdown format.
	+ Keywords: status report, weekly report, accomplishments, blockers, next week
- ./instructions/fetch-jira-issue-data.agent.md - Fetch Jira issues and normalize output for reporting workflows.
	+ Keywords: jira api, fetch issues, normalize issue data, pagination, blockers
- ./instructions/update-confluence-project-status.agent.md - Update Confluence project status pages using processed Jira data.
	+ Keywords: confluence update, project status page, page version, idempotent update
- ./instructions/generate-jql-reporting-queries.agent.md - Generate reusable JQL queries for common project reporting needs.
	+ Keywords: jql, reporting query, sprint progress, open blockers, completed issues
- ./instructions/process-sprint-summary-table.agent.md - Process sprint data into summary tables and completion metrics.
	+ Keywords: sprint summary, status table, assignee totals, priority totals, metrics

## Sample Instruction
- File: instructions/fetch-jira-issue-data.agent.md
- Contents:
- Read Jira base URL, auth token, project key, and date window from environment variables.
- Validate required inputs before sending API requests.
- Build JQL for project and date filters with pagination support.
- Call Jira search API and iterate pages until all matching issues are collected.
- Normalize issue fields into a stable schema: key, summary, status, assignee, priority, sprint, updated, blocker flag.
- Handle rate limits with retry and exponential backoff.
- Handle auth and network failures with explicit error messages and non-zero exit behavior.
- Produce deterministic output in JSON and a human-readable markdown summary.
- Sort output by status and priority for consistent downstream reporting.
- Save raw response snapshots and normalized output separately for traceability.

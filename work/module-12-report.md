# Module 12 Completion Report

## Instruction File
- Filename: instructions/Jira_Confluence_acces.agent.md

- Use this instruction when the user needs to verify Jira and Confluence service-account access scopes before integration work.
- Use this instruction for setup checks tied to backlog item: confirm Jira and Confluence access scopes.
- Run the tool from project root: python tools/Jira_Confluence_acces.py --jira-url <url> --confluence-url <url> --token <token>.
- Include --email <email> when using Atlassian Basic auth.
- Include --project-key <key> to validate Jira project access.
- Include --space-key <key> to validate Confluence space access.
- If values are already configured, allow env var fallback: JIRA_BASE_URL, CONFLUENCE_BASE_URL, ATLASSIAN_EMAIL, ATLASSIAN_API_TOKEN, JIRA_PROJECT_KEY, CONFLUENCE_SPACE_KEY.
- Treat PASS for Jira auth, Jira permissions, and Confluence auth as minimum success criteria.
- Report each check line exactly as PASS or FAIL with details from tool output.
- Return summary as passed checks over total checks and clearly state overall status.
- On failures, include the failing scope and the next corrective action needed.

## Script File
- Filename: tools/Jira_Confluence_acces.py
- Language: Python

import argparse
import base64
import json
import os
import sys
from dataclasses import dataclass
from typing import Dict, Optional, Tuple
from urllib.error import HTTPError, URLError
from urllib.request import Request, urlopen


@dataclass
class CheckResult:
    name: str
    ok: bool
    details: str


def build_auth_header(email: Optional[str], token: str) -> str:
    if email:
        raw = f"{email}:{token}".encode("utf-8")
        encoded = base64.b64encode(raw).decode("ascii")
        return f"Basic {encoded}"
    return f"Bearer {token}"


def http_get_json(url: str, auth_header: str, timeout: int = 20) -> Tuple[int, Dict]:
    req = Request(url)
    req.add_header("Authorization", auth_header)
    req.add_header("Accept", "application/json")

    with urlopen(req, timeout=timeout) as response:
        status = response.getcode()
        body = response.read().decode("utf-8")
        return status, json.loads(body) if body else {}


def safe_get_json(url: str, auth_header: str) -> Tuple[bool, str, Optional[Dict]]:
    try:
        status, data = http_get_json(url, auth_header)
        return True, f"HTTP {status}", data
    except HTTPError as exc:
        body = exc.read().decode("utf-8", errors="replace")
        return False, f"HTTP {exc.code}: {body[:200]}", None
    except URLError as exc:
        return False, f"Network error: {exc.reason}", None
    except Exception as exc:
        return False, f"Unexpected error: {exc}", None


def normalize_base_url(url: str) -> str:
    return url.rstrip("/")


def check_jira_access(base_url: str, auth_header: str, project_key: Optional[str]) -> Dict[str, CheckResult]:
    checks: Dict[str, CheckResult] = {}

    ok, details, _ = safe_get_json(f"{base_url}/rest/api/3/myself", auth_header)
    checks["jira_auth"] = CheckResult("Jira auth", ok, details)

    ok, details, data = safe_get_json(f"{base_url}/rest/api/3/mypermissions", auth_header)
    if ok and data and "permissions" in data:
        perms = data.get("permissions", {})
        browse = bool(perms.get("BROWSE_PROJECTS", {}).get("havePermission"))
        search = bool(perms.get("SEARCH_ISSUES", {}).get("havePermission"))
        checks["jira_browse_projects"] = CheckResult(
            "Jira permission: BROWSE_PROJECTS",
            browse,
            "havePermission=true" if browse else "havePermission=false",
        )
        checks["jira_search_issues"] = CheckResult(
            "Jira permission: SEARCH_ISSUES",
            search,
            "havePermission=true" if search else "havePermission=false",
        )
    else:
        checks["jira_permissions"] = CheckResult("Jira permissions endpoint", False, details)

    if project_key:
        ok, details, _ = safe_get_json(f"{base_url}/rest/api/3/project/{project_key}", auth_header)
        checks["jira_project_access"] = CheckResult(
            f"Jira project access ({project_key})",
            ok,
            details,
        )

    return checks


def check_confluence_access(base_url: str, auth_header: str, space_key: Optional[str]) -> Dict[str, CheckResult]:
    checks: Dict[str, CheckResult] = {}

    ok, details, _ = safe_get_json(f"{base_url}/wiki/rest/api/user/current", auth_header)
    checks["confluence_auth"] = CheckResult("Confluence auth", ok, details)

    if space_key:
        ok, details, _ = safe_get_json(f"{base_url}/wiki/rest/api/space/{space_key}", auth_header)
        checks["confluence_space_access"] = CheckResult(
            f"Confluence space access ({space_key})",
            ok,
            details,
        )

    return checks


def print_results(jira_checks: Dict[str, CheckResult], confluence_checks: Dict[str, CheckResult]) -> int:
    all_checks = list(jira_checks.values()) + list(confluence_checks.values())

    print("Service Account Access Check")
    print("=" * 28)
    for result in all_checks:
        status = "PASS" if result.ok else "FAIL"
        print(f"[{status}] {result.name} - {result.details}")

    passed = sum(1 for item in all_checks if item.ok)
    total = len(all_checks)
    print(f"\nSummary: {passed}/{total} checks passed")

    return 0 if passed == total else 1


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Confirm Jira and Confluence access scopes for a service account."
    )
    parser.add_argument("--jira-url", default=os.getenv("JIRA_BASE_URL"), help="Jira base URL")
    parser.add_argument(
        "--confluence-url",
        default=os.getenv("CONFLUENCE_BASE_URL"),
        help="Confluence base URL",
    )
    parser.add_argument("--email", default=os.getenv("ATLASSIAN_EMAIL"), help="Account email")
    parser.add_argument(
        "--token",
        default=os.getenv("ATLASSIAN_API_TOKEN"),
        help="Atlassian API token",
    )
    parser.add_argument("--project-key", default=os.getenv("JIRA_PROJECT_KEY"), help="Jira project key")
    parser.add_argument("--space-key", default=os.getenv("CONFLUENCE_SPACE_KEY"), help="Confluence space key")
    return parser.parse_args()


def validate_args(args: argparse.Namespace) -> Optional[str]:
    if not args.jira_url:
        return "Missing Jira URL. Use --jira-url or set JIRA_BASE_URL."
    if not args.confluence_url:
        return "Missing Confluence URL. Use --confluence-url or set CONFLUENCE_BASE_URL."
    if not args.token:
        return "Missing token. Use --token or set ATLASSIAN_API_TOKEN."
    return None


def main() -> int:
    args = parse_args()
    error = validate_args(args)
    if error:
        print(error)
        return 2

    auth_header = build_auth_header(args.email, args.token)
    jira_url = normalize_base_url(args.jira_url)
    confluence_url = normalize_base_url(args.confluence_url)

    jira_checks = check_jira_access(jira_url, auth_header, args.project_key)
    confluence_checks = check_confluence_access(confluence_url, auth_header, args.space_key)

    return print_results(jira_checks, confluence_checks)


if __name__ == "__main__":
    sys.exit(main())

## Script Execution Output
usage: Jira_Confluence_acces.py [-h] [--jira-url JIRA_URL]
                                [--confluence-url CONFLUENCE_URL]
                                [--email EMAIL] [--token TOKEN]
                                [--project-key PROJECT_KEY]
                                [--space-key SPACE_KEY]

Confirm Jira and Confluence access scopes for a service account.

options:
  -h, --help            show this help message and exit
  --jira-url JIRA_URL   Jira base URL
  --confluence-url CONFLUENCE_URL
                        Confluence base URL
  --email EMAIL         Account email
  --token TOKEN         Atlassian API token
  --project-key PROJECT_KEY
                        Jira project key
  --space-key SPACE_KEY
                        Confluence space key

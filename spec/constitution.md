# SpecKit Constitution

## 1. Purpose
This constitution defines how specification-driven development is performed for the Jira/Confluence automation project. It establishes mandatory rules, quality gates, and delivery phases so every change is traceable from requirement to implementation to validation.

## 2. Project Context

### 2.1 Project Overview
Build and maintain a Jira/Confluence automation platform that:
- Collects and normalizes Jira issue and sprint data.
- Produces status/reporting artifacts.
- Updates Confluence project status pages safely and idempotently.
- Exposes a web UI and backend APIs for operators.

### 2.2 Technology Baseline
- Frontend: React 18 with Vite.
- Backend: Node.js with Express.
- Database: PostgreSQL 15.
- Local runtime: Docker and Docker Compose.

## 3. Guiding Principles

### 3.1 Spec First
No implementation work starts until a written feature spec exists and is reviewed.

### 3.2 Single Source of Truth
Specs are the canonical definition of expected behavior. Code, tests, and documentation must align with approved specs.

### 3.3 Traceability
Every implementation task, pull request, and test must reference a spec item or acceptance criterion.

### 3.4 Small, Verifiable Increments
Work is delivered in small slices that can be validated independently.

### 3.5 Security and Reliability by Default
Integrations with Jira and Confluence must protect credentials, enforce least privilege, and handle transient failures with retries and clear errors.

## 4. Required Spec Structure
Each feature spec must include the sections below.

### 4.1 Problem and Outcome
- Problem statement.
- Desired business outcome.
- Success metrics.

### 4.2 Functional Requirements
- User or system behaviors in clear bullet points.
- API contracts (request/response shape, status codes).
- Data transformation rules for Jira and Confluence payloads.

### 4.3 Technical Requirements
- Frontend constraints (React component boundaries, state strategy).
- Backend constraints (Express route structure, service boundaries).
- Database constraints (schema changes, migrations, indexes).
- Docker requirements (services, networking, env var contracts).

### 4.4 Scope
- In scope items.
- Out of scope items.

### 4.5 Acceptance Criteria
- Objective pass/fail statements.
- Testable expected behavior.
- Failure-path expectations.

## 5. Spec-Driven Development Phases

### Phase 1: Discovery
- Gather stakeholder intent and operational constraints.
- Identify assumptions, risks, and dependencies.
- Define measurable outcomes.
- Exit gate: discovery notes reviewed; open questions tracked.

### Phase 2: Specification
- Produce full feature spec using Section 4 template.
- Define edge cases, error handling, and non-functional constraints.
- Exit gate: spec approved by engineering owner before coding.

### Phase 3: Design and Planning
- Break spec into implementation tasks for frontend, backend, and database.
- Define migration plan and rollback strategy if schema changes exist.
- Exit gate: task list mapped one-to-one with acceptance criteria.

### Phase 4: Implementation
- Implement tasks incrementally.
- Keep API and schema updates backward-safe where possible.
- Exit gate: all planned tasks complete and code references spec IDs.

### Phase 5: Verification
- Run automated tests and manual scenario checks.
- Validate acceptance criteria directly against observed behavior.
- Exit gate: all acceptance criteria pass or exceptions are documented and approved.

### Phase 6: Release and Review
- Deploy via approved workflow.
- Validate post-deployment health and key metrics.
- Record lessons learned for future specs.
- Exit gate: release checklist complete and report published.

## 6. Engineering Standards

### 6.1 Frontend (React 18 + Vite)
- Components should be focused and composable.
- Network calls must be isolated from presentation logic.
- Error and loading states are mandatory for API-backed views.

### 6.2 Backend (Node.js + Express)
- Route handlers delegate business logic to service modules.
- Input validation is required for all external request boundaries.
- External API clients (Jira/Confluence) must include timeout and retry behavior.

### 6.3 Database (PostgreSQL 15)
- All schema updates must use versioned migrations.
- Indexes are required for high-cardinality filtering fields used in reports.
- Destructive migrations require backup and rollback documentation.

### 6.4 Dockerized Development
- Local environment must start with a single documented compose command.
- Services must expose health checks.
- Required environment variables must be documented in example env files.

## 7. Testing and Quality Gates
- Unit tests for core business logic.
- Integration tests for Jira/Confluence API interactions (with mocks or sandbox endpoints).
- API contract checks for backend endpoints.
- Frontend tests for critical user flows.
- Lint and format checks must pass before merge.

Minimum merge gate:
- Spec linked in PR.
- Acceptance criteria checklist completed.
- Tests and static checks pass.
- Reviewer sign-off received.

## 8. Documentation and Reporting Rules
- Every completed feature must update relevant operational docs.
- Module/report outputs must include exact command evidence when required.
- Any deviation from spec must be recorded with rationale and approval.

## 9. Change Control
- Changes to this constitution require:
  - Proposed diff.
  - Reason for change.
  - Approval by project maintainer.
- Version this document using semantic increments:
  - Patch: editorial clarifications.
  - Minor: additive process changes.
  - Major: breaking governance changes.

## 10. Initial Adoption Checklist
- Create spec templates aligned to Section 4.
- Add PR template fields for spec link and acceptance criteria mapping.
- Add CI checks for lint, test, and migration validation.
- Document local Docker startup for frontend, backend, and PostgreSQL 15.

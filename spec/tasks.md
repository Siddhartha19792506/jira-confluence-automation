# Task Breakdown

## Metadata
- Plan ID: PLAN-JCA-001
- Spec ID: SPEC-JCA-001
- Date: 2026-09-04
- Status: Draft

## Phase 1: Backend Setup (Database, API Skeleton)

### TASK-JCA-01: Backend service bootstrap
- Description: Initialize Node.js + Express backend project structure with environment loading and app startup.
- Dependencies: None.
- Deliverables:
  - Backend directory structure.
  - App entrypoint and server bootstrap.
  - Base configuration loader.
- Acceptance Criteria:
  - Backend starts locally without runtime errors.
  - Startup fails with clear message when required env vars are missing.

### TASK-JCA-02: PostgreSQL 15 container and connection wiring
- Description: Configure PostgreSQL service through Docker and wire backend DB connection.
- Dependencies: TASK-JCA-01.
- Deliverables:
  - Docker Compose service definition for PostgreSQL 15.
  - Backend DB client configuration.
- Acceptance Criteria:
  - PostgreSQL service starts successfully.
  - Backend establishes DB connection on startup.
  - Backend fails fast with explicit error if DB is unavailable.

### TASK-JCA-03: Migration baseline
- Description: Add migration system and create initial schema for workflow run metadata.
- Dependencies: TASK-JCA-02.
- Deliverables:
  - Migration tooling configuration.
  - Initial migration script.
- Acceptance Criteria:
  - Migrations apply cleanly on empty database.
  - Required tables and indexes for run metadata exist.

### TASK-JCA-04: API skeleton and cross-cutting middleware
- Description: Implement API skeleton routes, request validation layer, and centralized error handler.
- Dependencies: TASK-JCA-01.
- Deliverables:
  - `GET /api/health`
  - Placeholder routes for Jira fetch, summary generation, Confluence update.
  - Validation and error middleware.
- Acceptance Criteria:
  - `GET /api/health` returns HTTP 200 with `{ "status": "ok" }`.
  - Invalid request payloads return structured 4xx responses.
  - Unexpected errors return structured 5xx responses without secrets.

## Phase 2: Frontend Setup (UI Skeleton, Routing)

### TASK-JCA-05: React 18 + Vite app skeleton
- Description: Initialize frontend project with base app shell.
- Dependencies: None.
- Deliverables:
  - Frontend project scaffold.
  - Shared app layout and navigation structure.
- Acceptance Criteria:
  - Frontend dev server starts without errors.
  - Base shell renders in browser.

### TASK-JCA-06: Routing setup
- Description: Add and wire routes for dashboard, workflow run page, and history page.
- Dependencies: TASK-JCA-05.
- Deliverables:
  - Route definitions for `/`, `/run`, `/history`.
- Acceptance Criteria:
  - All three routes render successfully.
  - Route navigation works without full page reload.

### TASK-JCA-07: Frontend API service layer
- Description: Implement API client abstraction with typed request/response contracts.
- Dependencies: TASK-JCA-06, TASK-JCA-04.
- Deliverables:
  - API service module.
  - Request helpers and error parsing.
- Acceptance Criteria:
  - UI can call backend health endpoint through service layer.
  - API errors are normalized for UI rendering.

### TASK-JCA-08: UI state components
- Description: Implement reusable loading, empty, success, and error states for API-driven screens.
- Dependencies: TASK-JCA-07.
- Deliverables:
  - State components and integration in `/run` and `/history`.
- Acceptance Criteria:
  - Loading state appears during requests.
  - Error state appears on failed requests.
  - Success state appears on completed workflow.

## Phase 3: Feature Implementation (One Feature at a Time)

### TASK-JCA-09: Feature 1 - Jira fetch endpoint
- Description: Implement `POST /api/jira/fetch` with validation, Jira client call, retry/timeout behavior, and normalized response.
- Dependencies: TASK-JCA-04.
- Deliverables:
  - Jira fetch route and service.
  - Normalization mapper.
- Acceptance Criteria:
  - Valid request returns normalized issue/sprint data.
  - Invalid request returns validation error.
  - Retry/timeout policy is applied for transient failures.

### TASK-JCA-10: Feature 2 - Sprint summary endpoint
- Description: Implement `POST /api/reports/sprint-summary` to generate summary artifacts from normalized Jira data.
- Dependencies: TASK-JCA-09.
- Deliverables:
  - Summary generation service.
  - Summary endpoint route.
- Acceptance Criteria:
  - Endpoint returns structured summary payload.
  - Summary output is deterministic for identical input payloads.

### TASK-JCA-11: Feature 3 - Confluence update endpoint
- Description: Implement `POST /api/confluence/update-status` with idempotency and version result tracking.
- Dependencies: TASK-JCA-10.
- Deliverables:
  - Confluence update service and route.
  - Idempotency-key handling.
- Acceptance Criteria:
  - Repeated request with same idempotency key does not duplicate updates.
  - Response includes `updated` and `version` fields.

### TASK-JCA-12: Workflow metadata persistence
- Description: Persist run metadata and execution outcomes for each workflow stage.
- Dependencies: TASK-JCA-03, TASK-JCA-09, TASK-JCA-10, TASK-JCA-11.
- Deliverables:
  - DB writes for run start/end, status, and errors.
  - History query support for frontend.
- Acceptance Criteria:
  - Each workflow run creates a persisted metadata record.
  - Failure cases persist error summary without secrets.

## Phase 4: Integration and Testing

### TASK-JCA-13: Backend unit and integration tests
- Description: Add tests for health, Jira fetch, summary generation, Confluence update, and DB persistence.
- Dependencies: TASK-JCA-09, TASK-JCA-10, TASK-JCA-11, TASK-JCA-12.
- Deliverables:
  - Unit test suite for service modules.
  - Integration test suite for API endpoints.
- Acceptance Criteria:
  - Tests pass for success and failure paths.
  - Input validation and structured errors are verified.

### TASK-JCA-14: Frontend integration tests
- Description: Add tests for route rendering and API state handling.
- Dependencies: TASK-JCA-06, TASK-JCA-08.
- Deliverables:
  - Route tests.
  - Loading/error/success state tests.
- Acceptance Criteria:
  - `/`, `/run`, `/history` route tests pass.
  - UI state transitions are verified for API calls.

### TASK-JCA-15: End-to-end workflow test
- Description: Validate end-to-end workflow path from Jira fetch through Confluence status update.
- Dependencies: TASK-JCA-13, TASK-JCA-14.
- Deliverables:
  - E2E test scenario and execution evidence.
- Acceptance Criteria:
  - Full workflow executes without manual data editing.
  - Output and persisted run metadata are consistent.

### TASK-JCA-16: Traceability and delivery closure
- Description: Finalize traceability mapping, acceptance checklist, and commit hygiene.
- Dependencies: TASK-JCA-15.
- Deliverables:
  - Updated traceability matrix with concrete references.
  - Acceptance criteria checklist marked complete.
- Acceptance Criteria:
  - AC-1 through AC-10 are explicitly mapped to tests/evidence.
  - Commits reference `SPEC-JCA-001`.

## Acceptance Criteria Coverage Map
- AC-1: TASK-JCA-01, TASK-JCA-02, TASK-JCA-04
- AC-2: TASK-JCA-04
- AC-3: TASK-JCA-06
- AC-4: TASK-JCA-09
- AC-5: TASK-JCA-10
- AC-6: TASK-JCA-11
- AC-7: TASK-JCA-12
- AC-8: TASK-JCA-13, TASK-JCA-15
- AC-9: TASK-JCA-08, TASK-JCA-14
- AC-10: TASK-JCA-16

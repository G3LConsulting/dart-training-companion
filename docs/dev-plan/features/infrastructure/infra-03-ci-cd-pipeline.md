# INFRA-03 — CI/CD Pipeline

| Metadata | Value |
|----------|-------|
| Feature | Infrastructure |
| Phase | MVP |
| Status | 🔲 Not started |
| Agent | DevOps Lead |
| Output | .github/workflows/build-deploy.yml GitHub Actions workflow |
| Notes | Automates build, test, Docker image creation, and deployment |

## Context

Set up GitHub Actions workflow with self-hosted runner for build, test, Docker image build, and deploy. This automates the full CI/CD pipeline from code push to production deployment.

**Implements:** TA §12 (CI/CD Pipeline)

## Acceptance Criteria

- [ ] Push to main triggers the workflow
- [ ] Workflow builds .NET solution with dotnet build
- [ ] Workflow builds Angular app with ng build
- [ ] Workflow runs dotnet test for all test projects
- [ ] Workflow builds Docker images for API and Web
- [ ] Workflow deploys via docker compose up -d on self-hosted runner
- [ ] Secrets (DB password, JWT key, SMTP creds) injected from GitHub Actions secrets
- [ ] Workflow runs only on main branch (no builds on feature branches unless explicitly triggered)
- [ ] Failure notifications sent (Slack, email, or GitHub status)
- [ ] Artifacts (build logs, test results) retained for debugging

## Tasks

| Task ID | Title | Status | Layer |
|---------|-------|--------|-------|
| [INFRA-03-T01](infra-03-ci-cd-pipeline/infra-03-t01-github-actions-workflow.md) | GitHub Actions workflow file | 🔲 | Infra |

## Dependencies

- [INFRA-01](infra-01-solution-scaffolding.md) — Solution and test projects must exist
- [INFRA-02](infra-02-docker-compose-local-dev.md) — Docker and docker-compose configuration must exist

## Shared References

- [Architecture](../../shared/architecture.md)
- [Technical Approach §12](../../shared/technical-approach.md#section-12-cicd-pipeline)

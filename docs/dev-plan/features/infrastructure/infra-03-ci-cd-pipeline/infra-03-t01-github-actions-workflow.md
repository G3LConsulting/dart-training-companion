# INFRA-03-T01 — GitHub Actions Workflow File

| Metadata | Value |
|----------|-------|
| Story | [INFRA-03](../infra-03-ci-cd-pipeline.md) — CI/CD Pipeline |
| Layer | Infra |
| Status | 🔲 Not started |
| Agent | DevOps Lead |

## What to Build

Create .github/workflows/build-deploy.yml with build, test, Docker build, and deploy steps for self-hosted runner. The workflow triggers on push to main, runs unit and integration tests, builds Docker images, and deploys to the self-hosted runner environment.

## Files to Create or Modify

| File Path | Purpose | Type |
|-----------|---------|------|
| .github/workflows/build-deploy.yml | GitHub Actions CI/CD workflow | Create |

## Definition of Done

- [ ] Workflow file is valid YAML (can be validated by GitHub)
- [ ] Workflow is triggered on push to main branch
- [ ] Build stage: dotnet build DartsCompanion.sln completes
- [ ] Test stage: dotnet test runs all test projects and reports results
- [ ] Angular build stage: npm ci && ng build --configuration production completes
- [ ] Docker build stage: docker build -t api:latest and docker build -t web:latest complete
- [ ] Deploy stage: docker compose up -d applies on self-hosted runner
- [ ] Secrets injected: DB_PASSWORD, JWT_SECRET, SMTP_PASSWORD from GitHub Actions secrets
- [ ] Workflow logs available in GitHub Actions UI
- [ ] Test results reported as job summary
- [ ] Failures cause workflow to fail and notify (via status check)
- [ ] Artifacts (logs, test reports) uploaded for debugging

## Implementation Notes

1. **Workflow Trigger**:
   ```yaml
   on:
     push:
       branches:
         - main
     pull_request:
       branches:
         - main
   ```

2. **Jobs Structure**:
   - **build-backend**: dotnet build + test
   - **build-frontend**: npm install + ng build
   - **build-docker**: docker build for API and Web (depends on backend/frontend)
   - **deploy**: docker compose up (depends on build-docker, runs on self-hosted runner)

3. **Self-Hosted Runner Setup**:
   - Runner must have: dotnet SDK 10.0, Node.js 21+, Docker, docker-compose, nginx (for reverse proxy)
   - Runner registers with label: `self-hosted`
   - Workflow specifies: `runs-on: [self-hosted]`
   - Runner must have access to deploy directory and docker socket

4. **Backend Build Job**:
   ```yaml
   - name: Restore dependencies
     run: dotnet restore
   - name: Build
     run: dotnet build --configuration Release --no-restore
   - name: Run unit tests
     run: dotnet test tests/DartsCompanion.UnitTests --configuration Release --no-build
   - name: Run integration tests
     run: dotnet test tests/DartsCompanion.IntegrationTests --configuration Release --no-build
   ```

5. **Frontend Build Job**:
   ```yaml
   - name: Install dependencies
     run: npm ci
   - name: Build
     run: npm run build -- --configuration production
   ```

6. **Docker Build Job**:
   - Build API image: `docker build -t dartscompanion.api:${{ github.sha }} src/DartsCompanion.Api`
   - Build Web image: `docker build -t dartscompanion.web:${{ github.sha }} src/DartsCompanion.Web`
   - Tag with latest: `docker tag dartscompanion.api:${{ github.sha }} dartscompanion.api:latest`
   - Save images or push to registry if using one

7. **Deploy Job** (self-hosted runner):
   ```yaml
   - name: Set environment variables
     env:
       DB_PASSWORD: ${{ secrets.DB_PASSWORD }}
       JWT_SECRET: ${{ secrets.JWT_SECRET }}
     run: echo "DB_PASSWORD=$DB_PASSWORD" >> .env
   - name: Deploy
     run: docker compose up -d --build
   - name: Health check
     run: |
       for i in {1..30}; do
         curl http://localhost:8080/health && exit 0 || sleep 2
       done
       exit 1
   ```

8. **Secrets Configuration**:
   - Navigate to GitHub repo Settings → Secrets and Variables → Actions
   - Add: DB_PASSWORD, JWT_SECRET, SMTP_PASSWORD
   - Refer in workflow as: `${{ secrets.SECRET_NAME }}`
   - Keep .env file out of git; generate dynamically in deploy job

9. **Test Reporting**:
   - Use `dotnet test --logger "trx;LogFileName=test-results.trx"`
   - Upload TRX reports as artifacts
   - GitHub Actions automatically parses and reports results

10. **Notifications**:
    - GitHub commit status check automatically fails if job fails
    - Can add Slack notification:
      ```yaml
      - name: Notify Slack on failure
        if: failure()
        uses: slackapi/slack-github-action@v1
        with:
          webhook-url: ${{ secrets.SLACK_WEBHOOK }}
      ```

11. **Artifact Retention**:
    ```yaml
    - name: Upload test results
      if: always()
      uses: actions/upload-artifact@v3
      with:
        name: test-results
        path: '**/test-results.trx'
        retention-days: 30
    ```

12. **Conditional Steps**:
    - Deploy only after successful tests and docker build
    - Use `needs: [build-backend, build-frontend, build-docker]`
    - Failure in any step stops subsequent steps

## References

- [Architecture](../../../shared/architecture.md)
- [Technical Approach §12](../../../shared/technical-approach.md#section-12-cicd-pipeline)

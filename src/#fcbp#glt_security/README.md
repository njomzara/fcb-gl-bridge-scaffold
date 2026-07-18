# /FCBP/GLT_SECURITY - Audit and Security Package

This package owns audit persistence/query, security context, support access checks, redaction, configuration audit, and authorization cache support.

## Runtime Pattern

- Runtime layers build audit/security events with safe metadata.
- Audit repository persists `/FCBP/GLT_AUD` records.
- Audit query exposes filtered support and governance views.
- Security context resolves actor, scope, support session, and redaction profile.
- Redaction removes or masks sensitive values before support display.
- Support access validates whether a user/session can inspect transfer evidence.

## Interfaces

- `/FCBP/IF_GLT_SEC_TYPES`
  - Security, audit, support, and redaction DTOs/constants.

- `/FCBP/IF_GLT_SECURITY_CONTEXT`
  - Contract for resolving actor/security context.

- `/FCBP/IF_GLT_SUPPORT_ACCESS`
  - Contract for support-session and transfer-scope access checks.

- `/FCBP/IF_GLT_REDACTION`
  - Contract for redacting sensitive text, fields, and evidence values.

- `/FCBP/IF_GLT_AUDIT_REPO`
  - Persistence contract for audit events.

- `/FCBP/IF_GLT_AUDIT_QUERY`
  - Query contract for audit evidence.

- `/FCBP/IF_GLT_AUDIT_EVENT_FACTORY`
  - Contract for creating normalized audit events.

- `/FCBP/IF_GLT_CONFIG_AUDIT`
  - Contract for configuration audit events.

## Classes

- `/FCBP/CX_GLT_AUDIT`
  - Audit/security-specific exception.

- `/FCBP/CL_GLT_SECURITY_CONTEXT`
  - Resolves actor and security context for runtime/support operations.

- `/FCBP/CL_GLT_SUPPORT_ACCESS`
  - Checks support access to transfer and evidence data.

- `/FCBP/CL_GLT_REDACTION`
  - Applies redaction profile rules to operator/support-safe outputs.

- `/FCBP/CL_GLT_AUDIT_REPO`
  - Productive repository scaffold over `/FCBP/GLT_AUD`.

- `/FCBP/CL_GLT_AUDIT_QUERY`
  - Reads and filters audit evidence for support/governance use.

- `/FCBP/CL_GLT_AUDIT_EVENT_FACTORY`
  - Creates normalized audit events with transfer, package, outbox, target, and config references.

- `/FCBP/CL_GLT_CONFIG_AUDIT`
  - Writes audit records for configuration changes and lifecycle transitions.

- `/FCBP/CL_GLT_AUTHZ_CACHE`
  - Authorization cache scaffold for repeated checks in a run.

## ABAP Package Artifact

- `package.devc.xml`
  - abapGit package object for `/FCBP/GLT_SECURITY`.

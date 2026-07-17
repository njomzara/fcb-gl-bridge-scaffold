# codex_scaffold - /FCBP/ GL Transfer Framework scaffold

Generated from:

- `DTS/GL_Bridge_Transfer_Core_Layer_Technical_Specification.md`
- `DTS/GL_Bridge_Source_Handoff_Layer_Technical_Specification.md`
- `DTS/GL_Bridge_Monitoring_and_Status_Layer_Technical_Specification.md`
- `DTS/GL_Bridge_Audit_and_Security_Layer_Technical_Specification.md`
- `DTS/GL_Bridge_Configuration_Layer_Technical_Specification.md`
- `DTS/GL_Bridge_Adapter_Layer_Technical_Specification.md`
- `DTS/GL_Bridge_Aggregation_and_Split_Layer_Technical_Specification.md`
- `DTS/GL_Bridge_Validation_Layer_Technical_Specification.md`
- `DTS/GL_Bridge_Mapping_Layer_Technical_Specification.md`
- `DTS/GL_Bridge_Source_Reading_Layer_Technical_Specification.md`
- `DTS/GL_Bridge_Package_Builder_Layer_Technical_Specification.md`
- `DTS/GL_Bridge_Target_Routing_and_Policy_Resolution_Layer_Technical_Specification.md`
- `DTS/GL_Bridge_Job_Layer_Technical_Specification.md`
- `DTS/GL_Bridge_Outbox_Execution_Layer_Technical_Specification.md`
- `docs/GL_BRIDGE_ARCHITECTURE.md`

This scaffold is intentionally separate from `claude_scaffold`. The older scaffold uses
`ZGLTR_*` POC naming; this one follows the transfer-core specification's target
namespace and object model:

- Package: `/FCBP/GL_TRANSFER_CORE`
- Core namespace: `/FCBP/GLT`
- Primary root table: `/FCBP/GLT_HDR`
- Public entry point: `/FCBP/IF_GLT_TRANSFER_API`
- Runtime coordinator: `/FCBP/CL_GLT_ORCHESTRATOR`

## Layout

The scaffold uses abapGit `FULL` folder logic. Package names are represented by
their escaped filesystem form, for example `/FCBP/GLT_CORE` is stored as
`src/#fcbp#glt_core/`. Each package folder includes a `package.devc.xml`
metadata artefact; the package name itself is derived from the folder path by
abapGit.

| Folder | ABAP package | Purpose |
| --- | --- | --- |
| `src/` | `/FCBP/GL_TRANSFER_CORE` | Root package metadata. |
| `src/#fcbp#glt_handoff/` | `/FCBP/GLT_HANDOFF` | Source Handoff receiver, registration, routing, validation, and factory shells. |
| `src/#fcbp#glt_core/` | `/FCBP/GLT_CORE` | Shared types, exceptions, contracts, and service-class shells. |
| `src/#fcbp#glt_source_reading/` | `/FCBP/GLT_SOURCE_READING` | Source Reading contracts, source-type router, reconciliation/document/mock delegates, released-source repository seam, normalizer, hasher, and source-read exception. |
| `src/#fcbp#glt_package_builder/` | `/FCBP/GLT_PACKAGE_BUILDER` | Package Builder orchestration contracts for package preparation/rebuild, package id generation, publication lock ownership, status/audit/message handoff, and graph consistency checks. |
| `src/#fcbp#glt_target_rtg_policy/` | `/FCBP/GLT_TARGET_RTG_POLICY` | Target Routing and Policy Resolution runtime hardening services: routing bucket derivation, effective-context hashing, request-local context cache, and route audit helper. |
| `src/#fcbp#glt_config/` | `/FCBP/GLT_CONFIG` | Configuration Layer target-profile, policy, health, hash, policy-context, validation, migration, and admin-service seams. |
| `src/#fcbp#glt_aggr_split/` | `/FCBP/GLT_AGGR_SPLIT` | Aggregation and Split Layer package builder, deterministic signature grouping, trace construction, split, balance-check, repository, and config-health seams. |
| `src/#fcbp#glt_validation/` | `/FCBP/GLT_VALIDATION` | Validation Layer request-gate extension seams, package-level validator, rule evaluator, finding/result services, evidence reader, repository, and validation-profile health checks. |
| `src/#fcbp#glt_mapping/` | `/FCBP/GLT_MAPPING` | Mapping Layer target-normalization contracts, package/journal mapper, deterministic resolver, field decision helper, event builder, repository, exception, and mapping-rule health checks. |
| `src/#fcbp#glt_monitor/` | `/FCBP/GLT_MONITOR` | Monitoring and Status services for messages, references, rollups, queries, and guarded operator actions. |
| `src/#fcbp#glt_security/` | `/FCBP/GLT_SECURITY` | Audit and Security services for context, authorization support, audit writing/querying, redaction, support access, and config audit. |
| `src/#fcbp#glt_job/` | `/FCBP/GLT_JOB` | Job Layer typed runtime context, runner contracts, job-run recorder, authorization guard, source selector seam, outbox-backed runner, and batch handoff runner. |
| `src/#fcbp#glt_outbox_exec/` | `/FCBP/GLT_OUTBOX_EXEC` | Outbox Execution dispatcher, owner-only outbox repository seam, work-handler contract/registry, fail-closed handler shells, outcome classifier, and stale-lock recovery seam. |
| `src/#fcbp#glt_test/` | `/FCBP/GLT_TEST` | In-memory happy-path test harness with seeded source/config tables, shared fixture repository, mock target adapter, dispatch handler, runner, and assertions. |
| `src/#fcbp#glt_test_cockpit/` | `/FCBP/GLT_TEST_COCKPIT` | Fiori elements/RAP test cockpit scaffold with persisted run snapshots, kickoff action seams, object-page evidence sections, and mock target document TreeTable hierarchy. |
| `src/#fcbp#glt_dcl/` | `/FCBP/GLT_DCL` | CDS access-control stubs for transfer, audit, support, security, and configuration read models. |
| `src/#fcbp#glt_db/` | `/FCBP/GLT_DB` | Table stubs for transfer root, lines, status, errors/messages, attempts, outbox, idempotency, retry, target references, audit, jobs, target profiles, policy families, policy context, configuration health, optional source-read diagnostics (`GLT_SRCRUN`), package evidence (`GLT_PKG`, `GLT_DOC`, `GLT_LIN`, `GLT_SRC`), validation evidence (`GLT_VALRUN`, `GLT_VALFND`), and mapping evidence (`GLT_MAPEV`). |
| `src/#fcbp#glt_adapter/` | `/FCBP/GLT_ADAPTER` | Adapter Layer contracts, capability matrix, normalizer, payload/client seams, evidence builder, mock/test adapters, and target-family adapter stubs. |
| `src/#fcbp#glt_ops/` | `/FCBP/GLT_OPS` | Operational shells for dispatch, retry, status query, polling, adapter health, reconciliation, support queries, route simulation, policy-context consistency, package preparation, package rebuild, package consistency checks, source-read probing, package validation, and package mapping. |
| `src/#fcbp#glt_cds/` | `/FCBP/GLT_CDS` | CDS interface and consumption view stubs for monitor, exceptions, timeline, queue, handoff, source-read diagnostics, reconciliation, audit/security, target profiles, policy families, policy context/trace, configuration health, adapter attempts, target references, unknown confirmation, adapter health, package details, aggregation trace, split results, rebuild comparison, validation runs/findings, and mapping events/findings. |
| `src/#fcbp#glt_rap/` | `/FCBP/GLT_RAP` | RAP behavior/service stubs for monitor, controlled operator actions, audit/security services, target-profile maintenance, policy administration, configuration health, source-read diagnostics, adapter operations, package evidence read services, validation evidence services, and mapping evidence services. |

## Scaffold Rules Captured

- Transfer Core owns transfer state, idempotency, retry/reprocess scheduling, logging, and audit evidence.
- Transfer Core does not create, recalculate, or mutate upstream FCBP accounting.
- External status remains small: `RECEIVED`, `FAILED`, `POSTED`.
- Detailed status is persisted in `STATUS_CODE`.
- `UNKNOWN_CONFIRMATION` schedules status query first; it is never treated as direct retry permission.
- Posted transfers are terminal except for linked reversal evidence.
- Adapter implementations consume contracts and return normalized results; they must not directly update GLT persistence.
- Source Handoff is an atomic registration boundary: reserve `/FCBP/GLT_REG` before creating the transfer root, and never use lookup-then-insert duplicate prevention.
- Source Handoff always queues asynchronous `DISPATCH` work in `/FCBP/GLT_OUTBOX`; it must not call package builders, mappers, validators, or target adapters.
- Source Reading is the read-only boundary over released FCBP source evidence and returns deterministic `/FCBP/IF_GLT_PKG_TYPES=>TT_SOURCE_GL_LINE` data to package preparation.
- Source Reading validates request/source stability, authorization, identity, non-empty line sets, and source/line hashes, but it must not write package, status, audit, outbox, source trace, or upstream source persistence.
- Source-type-specific reading is isolated behind `/FCBP/IF_GLT_SRC_TYPE_READER`; reconciliation-key, document, and mock delegates are registered through `/FCBP/CL_GLT_SOURCE_READER`.
- Productive source access is hidden behind `/FCBP/IF_GLT_SRC_REPO` and `/FCBP/CL_GLT_SRC_REPO_FCBP`; the default repository fails closed until released FCBP projections/APIs are bound.
- Optional `/FCBP/GLT_SRCRUN` diagnostics are caller-owned. They are for monitoring/support evidence and are not written by the read-only source reader.
- Target Routing and Policy Resolution is the runtime resolver boundary over maintained configuration: Source Handoff asks for a route context, and Package Builder/downstream services consume a resolved effective context or persisted policy context.
- `/FCBP/IF_GLT_ROUTING_BUCKET` centralizes routing-bucket derivation so Source Handoff registration and diagnostics use one canonical bucket format.
- `/FCBP/IF_GLT_CONFIG_PROVIDER->RESOLVE_EFFECTIVE_CONTEXT` remains the runtime policy resolver and must fail closed for missing, inactive, expired, unhealthy, ambiguous, unsupported, or inconsistent target/policy configuration.
- Policy context evidence in `/FCBP/GLT_POLCTX` is immutable runtime proof. It now uses UUID-style id generation in the scaffold instead of date/time ids.
- Route simulation and policy-context consistency jobs are diagnostic only; normal retry of prepared/submitted packages must reuse existing policy context rather than silently re-resolving current configuration.
- Package Builder has two roles: `/FCBP/IF_GLT_PACKAGE_BUILDER` remains the deterministic, side-effect-free graph builder; `/FCBP/IF_GLT_PACKAGE_PREPARER` owns transfer-context preparation/rebuild orchestration.
- Package Preparer coordinates Source Reading, package id creation, graph build, graph consistency checks, repository persistence, current-package publication, and status/message/audit handoff through injected seams.
- Package graph persistence remains owned by `/FCBP/IF_GLT_PACKAGE_REPO`; `/FCBP/CL_GLT_PACKAGE_REPO` still fails closed until it is bound to `/FCBP/GLT_PKG`, `/FCBP/GLT_DOC`, `/FCBP/GLT_LIN`, and `/FCBP/GLT_SRC`.
- Package Builder must not call adapters, construct target-specific payloads, schedule retry/poll work, read unreleased FCBP source tables, or directly own Validation/Mapping outcomes.
- Rebuilds create successor package evidence and publish only after source read, graph build, consistency, and persistence succeed; predecessor package content remains immutable.
- Monitoring and Status owns the cockpit read model, append-only timeline drilldown, and guarded actions for retry/rebuild/cancel/query.
- Monitor actions enqueue controlled outbox work and write audit evidence; they must not call adapters or package builders directly.
- Target confirmation writes `/FCBP/GLT_REF` evidence before a transfer is marked `POSTED`.
- `UNKNOWN_CONFIRMATION` permits `queryStatus` or poll work only; direct retry/reprocess actions are rejected.
- Audit and Security is a governance layer: it authorizes, redacts, and records evidence, but does not create transfer roots, build packages, call adapters, or own lifecycle transitions.
- Authorization checks fail closed until IAM/business-role scope is implemented for tenant, company code, target profile, action, support, audit, config, and worker contexts.
- Audit evidence is append-only in `/FCBP/GLT_AUD`; accepted business mutations write audit in the caller's LUW and audit writer services do not issue uncontrolled commits.
- Support access requires explicit ticket, reason, scoped context, authorization, redaction, and audit evidence.
- Subscriber-facing audit/security CDS views use `@AccessControl.authorizationCheck: #CHECK` and have DCL baseline stubs.
- Configuration owns target profiles and runtime policy families: retry, aggregation, split, validation, mapping, throttling, and confirmation.
- Runtime layers consume a resolved target profile and effective policy context; they must fail closed on missing, inactive, expired, unhealthy, ambiguous, unsupported, or inconsistent configuration.
- Configuration changes affect future resolution only. Historical packages remain explainable through immutable `/FCBP/GLT_POLCTX` policy-context evidence.
- Activation is a governed action with validation, health checks, authorization, and audit evidence; active flags alone are not sufficient.
- Configuration change/activation/deactivation paths call audit hooks and preserve old/new hashes instead of raw configuration payloads where possible.
- Direct table maintenance is not the target UX for productive configuration; RAP maintenance services are the scaffolded control plane.
- Adapter Layer owns target communication, payload envelope, destination/client usage, response parsing, connection validation, and normalized target outcome semantics.
- Adapter Layer must not schedule retry/poll work, change transfer lifecycle state, write status rows directly, select target profiles, or rebuild/remap accounting payload.
- Timeout, dropped connection, parser failure, or middleware uncertainty after a possible send returns `UNKNOWN_CONFIRMATION`; unknown confirmation is never marked retryable.
- Target references in `/FCBP/GLT_REF` are required before `POSTED` classification when the route requires posting proof; duplicate target confirmations must be handled idempotently by owning evidence/reference services.
- Adapter attempt evidence in `/FCBP/GLT_ATT` stores request/response hashes and approved raw references, not credentials, tokens, or full raw payloads by default.
- Adapter factory selection is driven by configured adapter type and fails closed for unsupported types; mock selection is restricted to explicit mock/POC profiles.
- Productive S/4 Public, S/4 Private, Integration Suite, and on-premise adapters are scaffolded but blocked until released API, destination, status-query, idempotency, and capability matrix decisions are finalized.
- Aggregation and Split owns package shaping only: deterministic aggregation, source traceability, split-document construction, balance checks, package evidence hashes, and rebuild comparison support.
- Aggregation and Split consumes resolved configuration and immutable policy-context evidence; it must not select target profiles, mutate upstream accounting, call adapters, or advance transfer lifecycle state directly.
- Source trace rows in `/FCBP/GLT_SRC` are first-class audit evidence and must preserve source identity, source hash, contribution amount/ratio, company code, and the canonical line/outdoc assignment.
- Prepared packages are immutable. Current-package publication and supersession belong to repository/LUW orchestration, not to the pure package builder.
- Split output is blocked when balance checks fail for the configured document/company/currency/ledger scope.
- Package detail, aggregation trace, split result, and rebuild-comparison CDS surfaces are subscriber-facing read models and must remain protected by DCL.
- Validation is the pre-submit gate after package preparation and before Mapping/Adapter execution.
- Request-level validation remains on `/FCBP/IF_GLT_VALIDATOR`; package-level validation is added through `/FCBP/IF_GLT_PKG_VALIDATOR`.
- Validation consumes transfer, package, policy-context, target-profile, validation-rule, target-reference, and attempt evidence; it must not build packages, map payloads, call adapters, schedule retries, or mutate upstream accounting.
- Validation findings are operator-safe, deterministic, and persisted as run/finding evidence in `/FCBP/GLT_VALRUN` and `/FCBP/GLT_VALFND`.
- Mapping may start only when the validation run for the current package/policy context is `PASSED` or governance has produced explicit `WAIVED` evidence.
- Unsupported validation expressions, missing validation profiles, unknown categories, and missing hashes fail closed through validation-profile health checks.
- Mapping runs after Validation and before Adapter payload construction. It translates target-relevant canonical journal values and records one append-only mapping event per significant decision.
- Mapping must not validate package safety, build protocol payloads, call adapters, schedule retry/poll work, confirm target postings, or hide accounting transformation in Adapter code.
- Explicit mapping decisions are required for map, derive, clear, truncate, reject, and pass-through behavior. Unsafe missing/ambiguous/unsupported mappings fail closed and block Adapter submission.
- Mapping evidence in `/FCBP/GLT_MAPEV` preserves package, outdoc, line, field, source/target value hashes or safe displays, mapping policy/version/hash, rule id/version, decision type, and result status.
- Retry must reuse prior mapping evidence for the same submitted package; rebuild/remap must create new evidence and retain historical mapping events.
- Mapping rule health checks block unknown fields, unsupported decision types, missing hashes, missing active rule sets, and non-explicit pass-through.
- Job Layer is the scheduler-facing boundary. It builds typed job context, checks worker authorization, starts `/FCBP/GLT_JOBRUN`, delegates to outbox execution, source handoff, or layer-specific services, and finalizes run counters/status.
- Outbox selection, claiming, handler lookup, adapter execution, package building, validation, mapping, status classification, and retry scheduling remain outside Job Layer. Job wrappers wake or scope those services and record aggregate evidence only.
- Batch source handoff jobs call `/FCBP/IF_GLT_SOURCE_SELECTOR` for candidates and `/FCBP/IF_GLT_HANDOFF_RECEIVER` for registration; the selector does not create transfers and the job does not write GLT business tables directly.
- Job-run final statuses use the Job Layer vocabulary: `SUCCESS`, `PARTIAL`, `NO_WORK`, `DRY_RUN`, `FAILED`, and `CANCELLED`, with `RUNNING` inserted at start.
- Outbox Execution owns due-work selection, atomic claim, work-type handler routing, owner-only complete/fail/release/supersede, follow-up work enqueueing, and stale-lock recovery.
- Outbox Execution does not repeat Source Handoff registration and does not let individual jobs implement competing claim loops.
- `UNKNOWN_CONFIRMATION` outcomes schedule status-query/poll work before any retry; no blind resubmit is allowed for ambiguous target outcomes.
- Work handlers fail closed until bound to Package Builder, Validation, Mapping, Adapter, Status, Message, Audit, and policy services.
- Test fixtures live in `/FCBP/GLT_TEST` and run against the public layer contracts: seeded Source Handoff creates the transfer/outbox work, Outbox Execution claims it, and a test DISPATCH handler invokes Package Builder, Validation, Mapping, and a mock target adapter.
- Test cockpit artifacts live in `/FCBP/GLT_TEST_COCKPIT`; they wrap the test harness for UI-triggered runs and persist UI-safe run evidence snapshots rather than exposing the in-memory fixture store directly.

## Activation Notes

The files are ABAP Cloud-shaped scaffolds. Tenant-specific work remains before activation:

- Confirm `/FCBP/` namespace availability and package hierarchy.
- Replace indicative built-in types with approved data elements/domains where required.
- Verify released ABAP Cloud APIs for UUID/hash generation, application logging, jobs, locks, and communication destinations.
- Keep slash-namespaced filenames and package folders in abapGit `#fcbp#...` form unless the target repository tooling requires a different namespace escape.
- Flesh out repository methods against the activated table definitions and the target tenant's released SQL/RAP patterns.
- Bind package persistence/publication to the activated `/FCBP/GLT_PKG`, `/FCBP/GLT_DOC`, `/FCBP/GLT_LIN`, and `/FCBP/GLT_SRC` tables and the transfer LUW owner.
- Bind Source Reading repositories to released reconciliation-key and posting-document FCBP projections/APIs, then replace compact scaffold hashes with the tenant-approved SHA/canonical hash service.
- Decide whether source-read run diagnostics in `/FCBP/GLT_SRCRUN` are required; if yes, keep writes in Transfer Core/package-preparation orchestration, not in `/FCBP/CL_GLT_SOURCE_READER`.
- Bind Target Routing and Policy Resolution to a productive `/FCBP/CL_GLT_CONFIG_REPO` implementation for `/FCBP/CC_GLTGT`, policy-family tables, and `/FCBP/GLT_POLCTX`.
- Replace scaffold compact hashes in `/FCBP/CL_GLT_EFFECTIVE_CTX_HASH` and `/FCBP/CL_GLT_ROUTING_BUCKET` with approved canonical serialization/hash rules once the platform hash service is selected.
- Bind `/FCBP/CL_GLT_PACKAGE_PREPARER` to the final Transfer Core work handler, effective-context resolver, message/status/audit services, and the package repository implementation.
- Implement `/FCBP/CL_GLT_PACKAGE_REPO` persistence/publication so graph rows are inserted atomically and one current package per transfer is enforced.
- Bind validation run/finding persistence to `/FCBP/GLT_VALRUN` and `/FCBP/GLT_VALFND`, and decide whether validation pass/fail is derived from latest run evidence or also stamped onto package/transfer headers.
- Bind mapping evidence persistence to `/FCBP/GLT_MAPEV`, finalize mapped-journal handoff to Adapter payload builders, and decide whether explicit `MAPPED` / `MAPPING_FAILED` statuses should be added to the Transfer Core status vocabulary.
- Bind `/FCBP/IF_GLT_OUTBOX_DISPATCHER` to the future Outbox Execution implementation so dispatch/retry/poll/status-query jobs do not duplicate claim loops.
- Bind `/FCBP/IF_GLT_SOURCE_SELECTOR` to released FCBP source discovery APIs for batch handoff and keep Source Handoff as the only transfer-registration boundary.
- Implement `/FCBP/IF_GLT_MONITOR_REPO->UPDATE_JOBRUN` against `/FCBP/GLT_JOBRUN` as a partial finalization update for status, counters, message, and finish timestamp.
- Wire ABAP Cloud Application Job catalog/template artefacts to the runner contracts once the target tenant's released Application Job runtime interfaces are confirmed.
- Implement `/FCBP/CL_GLT_OUTBOX_REPO` with conditional update semantics for `OPEN/FREE -> IN_PROCESS/LOCKED`, lock expiry, owner-only finalization, deterministic due-work selection, and stale-lock recovery.
- Wire `/FCBP/CL_GLT_WH_DISPATCH`, retry, poll, status-query, rebuild, and reprocess handlers to their downstream services only through injected contracts; do not let handlers update `/FCBP/GLT_OUTBOX` directly.
- Run `/FCBP/CL_GLT_TST_RUNNER->RUN_HAPPY_PATH` after activation to exercise the scaffolded happy path against seeded in-memory doubles before binding productive repositories.
- Implement `/FCBP/BP_GLT_TC_RUN` actions against `/FCBP/CL_GLT_TC_APP_SERVICE`, then persist run snapshots into `/FCBP/GLT_TCRUN`, `/FCBP/GLT_TCSD`, `/FCBP/GLT_TCITM`, `/FCBP/GLT_TCWRK`, `/FCBP/GLT_TCTIME`, `/FCBP/GLT_TCCAN`, and `/FCBP/GLT_TCTGT`.
- Validate generated OData V4 hierarchy metadata for `/FCBP/H_GLT_TC_TGTNODE`; adjust the UI5 manifest `hierarchyQualifier` for the mock target document TreeTable if ADT emits a tenant-specific qualifier.
- Move or generate `app/test-cockpit` into the target UI5/BSP deployment format once the ABAP service binding path is known.

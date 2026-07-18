# /FCBP/GLT_DB - Database Artifact Package

This package owns transparent table scaffolds for transfer state, package evidence, configuration, validation, mapping, adapter attempts, outbox execution, audit, source reading, and the test/runtime support model.

## Configuration Tables

- `/FCBP/CC_GLAGGR`
  - Aggregation policy header.

- `/FCBP/CC_GLAGGRF`
  - Aggregation policy field definitions.

- `/FCBP/CC_GLCONF`
  - Confirmation policy configuration.

- `/FCBP/CC_GLMAP`
  - Mapping rule configuration.

- `/FCBP/CC_GLRETRY`
  - Retry policy configuration.

- `/FCBP/CC_GLSPLIT`
  - Split policy configuration.

- `/FCBP/CC_GLTGT`
  - Target profile configuration.

- `/FCBP/CC_GLTHROT`
  - Throttle policy configuration.

- `/FCBP/CC_GLVAL`
  - Validation rule configuration.

- `/FCBP/GLT_CFG`
  - Transfer type/global bridge configuration.

- `/FCBP/GLT_ROUTE`
  - Route resolution evidence/configuration.

- `/FCBP/GLT_POLCTX`
  - Persisted policy-context evidence for a package/run.

- `/FCBP/GLT_CFGHLTH`
  - Configuration health findings.

## Transfer Core Tables

- `/FCBP/GLT_HDR`
  - Transfer header/root state.

- `/FCBP/GLT_ITEM`
  - Transfer item rows.

- `/FCBP/GLT_STAT`
  - Transfer status history.

- `/FCBP/GLT_ERR`
  - Normalized error records.

- `/FCBP/GLT_MSG`
  - Operator/support messages.

- `/FCBP/GLT_REF`
  - Target reference records.

- `/FCBP/GLT_IDEMP`
  - Idempotency reservations and completion state.

- `/FCBP/GLT_LOGREF`
  - Application log references.

- `/FCBP/GLT_REG`
  - Source registration/deduplication state.

## Package Evidence Tables

- `/FCBP/GLT_PKG`
  - Package header/current package evidence.

- `/FCBP/GLT_DOC`
  - Outbound document rows.

- `/FCBP/GLT_LIN`
  - Canonical package lines.

- `/FCBP/GLT_SRC`
  - Source trace rows.

## Runtime Evidence Tables

- `/FCBP/GLT_OUTBOX`
  - Due work queue for dispatch, retry, rebuild, poll, and status query; operator reprocess resolves to one of those concrete work types.

- `/FCBP/GLT_RETRY`
  - Retry/status-query schedule records.

- `/FCBP/GLT_ATT`
  - Adapter attempt evidence.

- `/FCBP/GLT_JOBRUN`
  - Job run lifecycle and counters.

- `/FCBP/GLT_MAPEV`
  - Mapping evidence/events.

- `/FCBP/GLT_VALRUN`
  - Validation run records.

- `/FCBP/GLT_VALFND`
  - Validation findings.

- `/FCBP/GLT_SRRUN`
  - Source read run evidence.

## Audit Tables

- `/FCBP/GLT_AUD`
  - Audit event evidence.

## ABAP Package Artifact

- `package.devc.xml`
  - abapGit package object for `/FCBP/GLT_DB`.

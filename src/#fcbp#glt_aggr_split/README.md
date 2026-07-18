# /FCBP/GLT_AGGR_SPLIT - Aggregation and Split Package

This package owns canonical line aggregation, split decisioning, balance checks, and source-trace generation before Package Builder persists durable package evidence.

## Runtime Pattern

- Source Reading provides source GL lines.
- Aggregation groups source lines into canonical lines according to active aggregation policy.
- Split logic divides canonical lines into outbound documents according to split policy.
- Balance checks verify each outbound document before package graph creation.
- Source trace links every canonical line back to contributing source rows.

## Interfaces

- `/FCBP/IF_GLT_AGGR_TYPES`
  - Shared aggregation, split, balance, and package-build result DTOs.

- `/FCBP/IF_GLT_AGGREGATOR`
  - Contract for source-line aggregation into canonical lines.

- `/FCBP/IF_GLT_AGGR_SIGNATURE`
  - Contract for aggregation signature and hash generation.

- `/FCBP/IF_GLT_AGSP_CONFIG_CHECK`
  - Contract for aggregation/split configuration sanity checks.

- `/FCBP/IF_GLT_BALANCE_CHECK`
  - Contract for document-level and policy-scope balance evaluation.

- `/FCBP/IF_GLT_PACKAGE_BUILDER`
  - Contract for assembling a package graph from source lines, policies, and build context.

- `/FCBP/IF_GLT_SOURCE_TRACE_BUILDER`
  - Contract for canonical-line to source-row trace creation.

- `/FCBP/IF_GLT_SPLITTER`
  - Contract for splitting canonical lines into outbound documents.

- `/FCBP/IF_GLT_SPLIT_KEY_BUILDER`
  - Contract for deriving split keys and split-key hashes.

## Classes

- `/FCBP/CX_GLT_PREPARATION`
  - Preparation-specific exception for aggregation, split, trace, and balance failures.

- `/FCBP/CL_GLT_AGGREGATOR`
  - Aggregates source GL lines into canonical package lines.

- `/FCBP/CL_GLT_AGGR_SIGNATURE`
  - Builds deterministic aggregation signatures and hashes.

- `/FCBP/CL_GLT_AGSP_CONFIG_CHECK`
  - Checks required aggregation and split policies before package preparation.

- `/FCBP/CL_GLT_BALANCE_CHECK`
  - Calculates debit/credit totals, differences, and balance status.

- `/FCBP/CL_GLT_PACKAGE_BUILDER`
  - Coordinates aggregation, split, trace, balance, and package graph assembly.

- `/FCBP/CL_GLT_SOURCE_TRACE_BUILDER`
  - Builds source trace evidence for each canonical line.

- `/FCBP/CL_GLT_SPLITTER`
  - Produces outbound document rows according to split policy.

- `/FCBP/CL_GLT_SPLIT_KEY_BUILDER`
  - Builds split keys from company code, currency, posting date, document type, ledger, and policy scope.

## ABAP Package Artifact

- `package.devc.xml`
  - abapGit package object for `/FCBP/GLT_AGGR_SPLIT`.

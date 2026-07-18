# /FCBP/GLT_PACKAGE_BUILDER - Package Builder Package

This package owns durable package evidence creation, package graph persistence, current-package publication, package locking, consistency checks, and package status reporting.

## Runtime Pattern

- Package Preparer reads transfer and source lines, reuses the current package for unchanged dispatch evidence, resolves build context when a new graph is needed, and calls Aggregation/Split package builder.
- Package Repository persists `/FCBP/GLT_PKG`, `/FCBP/GLT_DOC`, `/FCBP/GLT_LIN`, and `/FCBP/GLT_SRC`.
- Package Repository publishes and reads one current package for a transfer, and owns syncing `/FCBP/GLT_HDR-CURRENT_PACKAGE_ID`.
- Package publication requires the transfer/package lock owner and validates the expected current/predecessor package before changing current flags.
- Package Consistency checks persisted graph shape, counts, balance, orphan lines, and trace coverage.
- Rebuild creates a successor package using the current package as predecessor evidence.

## Interfaces

- `/FCBP/IF_GLT_PKG_PREP_TYPES`
  - Package preparation constants and diagnostic rule ids.

- `/FCBP/IF_GLT_PACKAGE_PREPARER`
  - Transfer-context entry point for dispatch package preparation and rebuild.

- `/FCBP/IF_GLT_PACKAGE_REPO`
  - Persistence contract for package graph persistence, current-package lookup/publication, package read, and consistency check.

- `/FCBP/IF_GLT_PACKAGE_LOCK`
  - Lock contract for package preparation/publication coordination.

- `/FCBP/IF_GLT_PACKAGE_ID_FACTORY`
  - Package, document, line, and trace id generation contract.

- `/FCBP/IF_GLT_PACKAGE_STATUS`
  - Package status/reporting contract.

## Classes

- `/FCBP/CL_GLT_PACKAGE_PREPARER`
  - Coordinates source reading, current package reuse, aggregation/split, package graph persistence, consistency check, and publication.
  - Supports `PREPARE_FOR_DISPATCH` and `REBUILD_PACKAGE`.
  - For `PREPARE_FOR_DISPATCH`, reuses the current package when source hash and package-shaping policy evidence still match.
  - Blocks dispatch with `PKG_REUSE_MISMATCH` when a current package exists but source or package-shaping policy evidence changed; rebuild is the successor-package path.

- `/FCBP/CL_GLT_PACKAGE_REPO`
  - Productive repository scaffold over package evidence tables.
  - Inserts full package graphs and reconstructs package graphs for validation/mapping/retry/dispatch reuse.
  - Reads the latest current package by `/FCBP/GLT_PKG-CURRENT_FLAG` when the transfer root has no current package pointer.
  - Publishes current package evidence under lock, supersedes predecessor packages, and updates transfer root `CURRENT_PACKAGE_ID`.

- `/FCBP/CL_GLT_PACKAGE_LOCK`
  - Transfer-header backed package lock for preparation and publication windows.
  - Claims `/FCBP/GLT_HDR-LOCK_OWNER/LOCK_UNTIL` using a deterministic package lock owner.

- `/FCBP/CL_GLT_PACKAGE_ID_FACTORY`
  - Generates package, outdoc, line, and trace identifiers.

- `/FCBP/CL_GLT_PACKAGE_CONSISTENCY`
  - Checks persisted graph consistency for missing docs, missing lines, missing trace, count mismatches, unbalanced documents, and orphan rows.

- `/FCBP/CL_GLT_PACKAGE_STATUS`
  - Reads package status and evidence summary for monitoring/support use.

## ABAP Package Artifact

- `package.devc.xml`
  - abapGit package object for `/FCBP/GLT_PACKAGE_BUILDER`.

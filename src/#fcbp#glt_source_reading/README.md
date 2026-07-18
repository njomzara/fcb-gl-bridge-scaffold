# /FCBP/GLT_SOURCE_READING - Source Reading Package

This package owns reading and normalizing source GL data into canonical source lines consumed by Package Builder.

## Runtime Pattern

- Package Preparer requests source lines for a transfer.
- Source Reader chooses a source-type reader by transfer source type.
- Source repository reads source-specific mock or productive source tables.
- Normalizer shapes source fields into canonical source GL lines.
- Hasher creates stable source and line hashes for evidence and rebuild comparison.

## Interfaces

- `/FCBP/IF_GLT_SRC_TYPES`
  - Source Reading DTOs and constants for source query, source rows, read runs, and diagnostics.

- `/FCBP/IF_GLT_SOURCE_READER`
  - Top-level source reader contract used by Package Builder.

- `/FCBP/IF_GLT_SRC_TYPE_READER`
  - Source-type specific reader contract.

- `/FCBP/IF_GLT_SRC_REPO`
  - Repository contract for source read persistence and source-specific table access.

## Classes

- `/FCBP/CX_GLT_SOURCE_READ`
  - Source Reading exception for missing source data, unsupported source type, and source repository errors.

- `/FCBP/CL_GLT_SOURCE_READER`
  - Facade that dispatches to the correct source-type reader and returns canonical source lines.

- `/FCBP/CL_GLT_SRC_REPO_FCBP`
  - Productive source repository scaffold for FCBP source tables and read-run evidence.

- `/FCBP/CL_GLT_SRC_READ_RECON`
  - Source-type reader for reconciliation-key based source selection.

- `/FCBP/CL_GLT_SRC_READ_DOC`
  - Source-type reader for document based source selection.

- `/FCBP/CL_GLT_SRC_READ_MOCK`
  - Mock source reader for happy-path and scaffold tests.

- `/FCBP/CL_GLT_SRC_NORMALIZER`
  - Normalizes raw source rows into `/FCBP/IF_GLT_PKG_TYPES=>TY_SOURCE_GL_LINE`.

- `/FCBP/CL_GLT_SRC_HASHER`
  - Creates source hash and line hash values for traceability and rebuild comparison.

## ABAP Package Artifact

- `package.devc.xml`
  - abapGit package object for `/FCBP/GLT_SOURCE_READING`.

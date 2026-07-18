# /FCBP/GLT_MAPPING - Mapping Package

This package owns target-field mapping after package validation and before adapter submission.

## Runtime Pattern

- Work handlers call Mapper with package id, validation run, policy context, and effective mapping rules.
- Mapper reads package graph and mapping rules.
- Resolver chooses rule matches and target values.
- Field mapper applies derivation, truncation, pass-through, and validation-safe transformations.
- Event builder persists mapping evidence for support and audit.
- Mapping health checks verify rule availability and consistency.

## Interfaces

- `/FCBP/IF_GLT_MAP_TYPES`
  - Mapping DTOs and constants for contexts, rules, mapped journal, events, results, and health.

- `/FCBP/IF_GLT_MAPPER`
  - Main package mapping contract.

- `/FCBP/IF_GLT_MAP_RESOLVER`
  - Contract for resolving mapping rules and target values.

- `/FCBP/IF_GLT_MAP_REPO`
  - Persistence contract for mapping rules and mapping evidence.

- `/FCBP/IF_GLT_MAP_HEALTH`
  - Mapping health/reporting contract.

## Classes

- `/FCBP/CX_GLT_MAPPING`
  - Mapping-specific exception for missing rules, invalid derivation, or incompatible package data.

- `/FCBP/CL_GLT_MAPPER`
  - Main mapping facade.
  - Reads package evidence, applies mapping rules, builds mapped journal, and persists mapping evidence.

- `/FCBP/CL_GLT_MAP_RESOLVER`
  - Resolves the applicable mapping rule for each source/target field.

- `/FCBP/CL_GLT_MAP_FIELD`
  - Applies field-level mapping transformations.

- `/FCBP/CL_GLT_MAP_EVENT_BUILDER`
  - Builds mapping event/evidence rows.

- `/FCBP/CL_GLT_MAP_REPO`
  - Productive repository scaffold for mapping rules and `/FCBP/GLT_MAPEV`.

- `/FCBP/CL_GLT_MAP_HEALTH`
  - Mapping policy health check scaffold.

## ABAP Package Artifact

- `package.devc.xml`
  - abapGit package object for `/FCBP/GLT_MAPPING`.

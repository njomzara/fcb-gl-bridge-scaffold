# /FCBP/GLT_RAP - RAP Service Package

This package owns RAP service definitions, service bindings, behavior definitions, and behavior provider scaffolds for GL Bridge UI/API exposure.

## Service Definitions and Bindings

- `/FCBP/UI_GLT_TRANSFER`
  - Transfer monitor service definition and binding.

- `/FCBP/UI_GLT_PACKAGE`
  - Package evidence service definition and binding.

- `/FCBP/UI_GLT_VALIDATION`
  - Validation service definition and binding.

- `/FCBP/UI_GLT_MAPPING`
  - Mapping service definition and binding.

- `/FCBP/UI_GLT_ADAPTER`
  - Adapter attempt/health service definition and binding.

- `/FCBP/UI_GLT_CONFIG`
  - Configuration administration service definition and binding.

- `/FCBP/UI_GLT_CONFIG_HEALTH`
  - Configuration health service definition and binding.

- `/FCBP/UI_GLT_AUDIT`
  - Audit log service definition and binding.

- `/FCBP/UI_GLT_SECURITY_ADMIN`
  - Security/support administration service definition and binding.

- `/FCBP/UI_GLT_SOURCE_READING`
  - Source reading service definition and binding.

## Behavior Definitions

- `/FCBP/R_GLT_TRANSFER`
  - RAP behavior shell for transfer monitor actions.

- `/FCBP/R_GLT_TARGET_PROFILE`
  - RAP behavior shell for target profile administration.

- `/FCBP/R_GLT_POLICY_ADMIN`
  - RAP behavior shell for policy administration.

- `/FCBP/R_GLT_HANDOFF`
  - RAP behavior shell for handoff-facing operations.

## Behavior Provider Classes

- `/FCBP/BP_GLT_TRANSFER`
  - Behavior implementation scaffold for transfer actions.

- `/FCBP/BP_GLT_TARGET_PROFILE`
  - Behavior implementation scaffold for target profile actions.

- `/FCBP/BP_GLT_POLICY_ADMIN`
  - Behavior implementation scaffold for policy administration actions.

- `/FCBP/BP_GLT_HANDOFF`
  - Behavior implementation scaffold for handoff actions.

## ABAP Package Artifact

- `package.devc.xml`
  - abapGit package object for `/FCBP/GLT_RAP`.

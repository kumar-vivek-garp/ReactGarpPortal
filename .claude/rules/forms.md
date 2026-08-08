---
paths:
  - "**/uiBundles/**/components/**/*form*.ts"
  - "**/uiBundles/**/components/**/*form*.tsx"
  - "**/uiBundles/**/pages/**/*.ts"
  - "**/uiBundles/**/pages/**/*.tsx"
---

# Forms (react-hook-form)

- Use **react-hook-form** (`useForm`, `register` / `Controller`, `handleSubmit`) for interactive forms. Do not add TanStack Form.
- Validate **before** submit: `required` and domain rules (e.g. email `pattern`) via `register` options or a resolver.
- Use `noValidate` on `<form>` so native browser popups do not fight RHF.
- Show field errors **inline** under the control (`errors.field.message`, `role="alert"`, `aria-invalid`).
- Wire submit to domain `api/*` via hooks (`mutateAsync`). API failures go through QueryClient / Sonner unless `meta.silent`.
- Do not duplicate the same API error as both toast and a form-level list unless product explicitly wants both.

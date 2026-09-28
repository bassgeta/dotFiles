# Frontend (React, Tailwind, React Query)

## Layout

- `pages/`: thin route shells
- `features/`: domain UI, plus that domain's hooks and API calls
- `components/`: shared, domain-free UI
- `utils/`, never `lib/` (shadcn dumps into `lib/`; move things out)
- Hooks reused across the app go in `hooks/`; component-specific hooks live in the component folder

## Components

Every component gets a folder:

```
ComponentName/
├── index.tsx     # component + its props interface
├── types.ts      # shared / non-props types only
├── helpers.ts    # non-trivial logic
└── blocks/       # subcomponents used only here, same structure
```

- Props are a named `interface` in `index.tsx`, destructured in the signature
- Single responsibility. Before extracting a hook, ask whether a subcomponent should own that job
- Inline logic until it hurts; extract a custom hook only when needed
- Small, but not pointlessly small (no single-div components)
- Early return for loading, error and empty states, ideally by narrowing a discriminated union. No render-prop components
- Conditional JSX uses `cond ? <X /> : null`, never `&&` (the `0 &&` gotcha)
- Named exports preferred. If the codebase uses defaults, follow the codebase

## Markup and styling

- Flat, semantic HTML. No wrapper `div`s that exist only for styling; if a wrapper seems needed, question the component structure
- Tailwind; variants via `cva`, class merging via `cn()`
- Use design tokens. Arbitrary values (`w-[137px]`) are usually design drift; snap to the nearest token
- shadcn `components/ui` is owned code: edit it freely
- Accessibility: rely on Radix defaults, nothing heavy-handed

## State and data

1. `useState`: the default
2. React Query: server state. Always wrapped in a custom hook, never raw `useQuery` in components
3. Context: simple global state
4. Zustand: complex global state. Copying server data into a store is fine, especially for derived data

- As few effects as possible (https://react.dev/learn/you-might-not-need-an-effect). No derived state or fetching in effects
- Avoid `useMemo`/`useCallback`, `useCallback` especially, because once one is added the memoization has to spread to everything it touches
- Forms: react-hook-form with a Zod resolver
- Wallet/tx UX: follow the existing patterns

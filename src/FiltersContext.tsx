import React, { createContext, useContext, useMemo, useState } from 'react';
import { activities, applyFilters, emptyFilters, FilterState } from './data';

type Ctx = {
  applied: FilterState;
  setApplied: (f: FilterState) => void;
  results: typeof activities;
};

const FiltersCtx = createContext<Ctx | null>(null);

/** Filters chosen on the Filters screen and applied to the List and Map screens. */
export function FiltersProvider({ children }: { children: React.ReactNode }) {
  const [applied, setApplied] = useState<FilterState>(emptyFilters);
  const results = useMemo(() => applyFilters(activities, applied), [applied]);
  return <FiltersCtx.Provider value={{ applied, setApplied, results }}>{children}</FiltersCtx.Provider>;
}

export function useFilters() {
  const ctx = useContext(FiltersCtx);
  if (!ctx) throw new Error('useFilters must be used inside FiltersProvider');
  return ctx;
}

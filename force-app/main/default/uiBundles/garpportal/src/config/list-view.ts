export const LIST_VIEWS = ["grid", "list"] as const

/** Grid (card) or list (row) layout for a collection page. */
export type ListView = (typeof LIST_VIEWS)[number]

/** Pages that offer a layout toggle. One remembered choice per page. */
export type ListViewScope = "programs" | "study-materials"

/** localStorage key for remembered layout choices. */
export const LIST_VIEW_STORAGE_KEY = "garp-portal:list-view"

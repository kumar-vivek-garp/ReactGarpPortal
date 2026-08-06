/**
 * Response shape for the V2 event-registration screen load.
 *
 * The ONLY thing worth aggregating is the onload data — so this wrapper carries
 * the full registration screen payload AND the initial fee calculation together,
 * letting garpEventRegModernFullV2 render on a single call. The individual write
 * actions (verify, recalc, submit, pay, rollback) stay as small, direct methods
 * on GARP_EventRegV2_Controller — they don't need a wrapper.
 */
public class GARP_EventRegV2_Wrapper {

    /** The single onload payload: full registration screen + initial fees. */
    public class Screen {
        /** Full event-registration screen payload (event, products, membership, locations…). */
        public Object registration;
        /** Initial fee calculation for the freshly-loaded form (null when the load errored). */
        public Object fees;
    }
}
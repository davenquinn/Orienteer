import { Attitude } from "./types";
import { PostgrestFilterBuilder } from "@supabase/postgrest-js";

export type AttitudeFilterData = {
  tags: any[];
  classes: any[];
};

type AttitudeRow = {
  id: number;
  strike: number;
  dip: number;
  rake: number;
  class: string;
  tags: string[];
};

type FilterArg = PostgrestFilterBuilder<AttitudeResult[]>;
export type AttitudeFilter = (pg: FilterArg) => FilterArg;

export function constructFilter(
  data: AttitudeFilterData | null
): AttitudeFilter {
  if (data == null) return (q) => q;
  return (q) => {
    const { tags = [], classes = [] } = data;
    if (tags.length > 0) {
      q = q.contains(
        "tags",
        tags.map((d) => d.name)
      );
    }
    if (classes.length > 0) {
      q = q.in_(
        "class",
        classes.map((d) => d.id)
      );
    }
    return q;
  };
}

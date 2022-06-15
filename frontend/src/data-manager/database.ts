import {
  PostgrestClient,
  PostgrestFilterBuilder,
} from "@supabase/postgrest-js";
import { useState, useEffect } from "react";
import { ORIENTEER_API_BASE } from "../config";

const POSTGREST_URL = ORIENTEER_API_BASE + "/models";
const pg = new PostgrestClient(POSTGREST_URL);

type FilterFunc<T = any> = (
  pg: PostgrestFilterBuilder<T>
) => PostgrestFilterBuilder<T>;

function usePostgrestSelect<T = any>(
  source: string,
  query: string = "*",
  filter: FilterFunc<T> = (pg) => pg
): { data: T[]; error: Error | null; loading: boolean } {
  const [data, setData] = useState<any[]>([]);
  const [error, setError] = useState<any>(null);
  const [loading, setLoading] = useState<boolean>(false);

  useEffect(() => {
    setLoading(true);
    filter(pg.from(source).select(query))
      .then((res) => {
        setData(res.data);
        setLoading(false);
      })
      .catch((err) => {
        setError(err);
        setLoading(false);
      });
  }, [source, query]);

  return { data, error, loading };
}

export default pg;
export { usePostgrestSelect };

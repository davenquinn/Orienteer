import { PostgrestClient } from "@supabase/postgrest-js";
const POSTGREST_URL = process.env.ORIENTEER_API_BASE + "/models";
const pg = new PostgrestClient(POSTGREST_URL);

export default pg;

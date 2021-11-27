import { resolve, join } from "path";
const PGPromise = require("pg-promise");
const { readFileSync } = require("fs");
import { queryResult, PGPromise } from "pg-promise";

const opts = {
  noWarnings: true
};

const pgp = PGPromise(opts);

class QuickBackend {
  db: PGPromise.IDatabase<any>;
  constructor(pg_conn, opts={log: true}) {
    this.db = pgp(pg_conn, opts);
  }

  async runQuery(
    key: string,
    params: any = null,
    resultMask: queryResult = queryResult.any
  ) {
    let fn = key;
    if (!key.endsWith(".sql")) {
      fn = resolve(join(__dirname, "..", "sql", key + ".sql"));
    }
    try {
      return await this.db.query(storedProcedure(fn), params, resultMask);
    } catch (err) {
      console.error(err);
      throw new Error(`Query ${fn} failed to run`);
    }
  }

}

const backend = new QuickBackend(process.env.DATABASE_URL);

// Create database connection
const { helpers } = pgp;

const queryFiles: { [k: string]: string } = {};

const storedProcedure = function(fileName: string) {
  // Don't hit the filesystem repeatedly
  // in a session
  const fn = resolve(fileName);
  if (queryFiles[fn] == null) {
    queryFiles[fn] = readFileSync(fn, "UTF-8");
  }
  return queryFiles[fn];
};

export { queryResult as ResultMask };
export { storedProcedure, helpers, pgp, QuickBackend, backend };

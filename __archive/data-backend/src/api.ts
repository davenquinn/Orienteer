import express from "express";
import morgan from "morgan";
import { sync as glob } from "glob";
import { join, resolve } from "path";
import { ResultMask, runBackendQuery } from "./database";
import cors from "cors";

const baseDir = resolve(__dirname, "..", "sql");

interface Params {
  [key: string]: any;
}
interface ExtParams extends Params {
  __qrm?: string | number;
}

function normalizeResultMask(
  __qrm: string | number | undefined
): ResultMask | undefined {
  const num = parseInt(`${__qrm}`);
  if (Number.isNaN(num)) return undefined;
  return num;
}

type APIHandler = (params: Params) => Promise<any>;

function apiRoute(handler: APIHandler) {
  return async (req: any, res: any, next: any) => {
    try {
      const queryResult = await handler(req);
      res.json(queryResult);
    } catch (err) {
      next(err);
    }
  };
}

function buildQueryFileRoutes(app: any) {
  let helpRoutes: string[] = [];
  for (const fn of glob(join(baseDir, "**/*.sql"))) {
    const newFn = fn.replace(baseDir, "").slice(0, -4);
    helpRoutes.push(newFn);

    const handler = async (req: any) => {
      let { __qrm, __argsArray, ...rest }: ExtParams = req.query;
      let newParams = rest;
      if (__argsArray != null) {
        newParams = JSON.parse(__argsArray);
      }
      return await runBackendQuery(
        newFn,
        newParams,
        normalizeResultMask(__qrm)
      );
    };

    app.get(newFn, apiRoute(handler));
  }
  return helpRoutes;
}

async function createServer() {
  const app = express().disable("x-powered-by");
  if (process.env.NODE_ENV !== "production") {
    app.use(morgan("dev"));
  }
  app.use(cors());
  app.use(express.json());
  let helpRoutes = buildQueryFileRoutes(app);
  // create help route
  app.get("/", (req: any, res: any) => {
    helpRoutes.sort();
    res.json({
      v: 1,
      description: "The data service for Naukluft Nappe Complex mapping",
      routes: helpRoutes
    });
  });

  return app;
}

export { createServer };

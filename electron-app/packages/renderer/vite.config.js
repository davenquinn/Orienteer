/* eslint-env node */

import { chrome } from "../../electron-vendors.config.json";
import { join, resolve } from "path";
import { builtinModules } from "module";
import react from "@vitejs/plugin-react";
import { viteCommonjs } from "@originjs/vite-plugin-commonjs";
import createExternal from "vite-plugin-external";

const PACKAGE_ROOT = __dirname;

/**
 * @type {import('vite').UserConfig}
 * @see https://vitejs.dev/config/
 */
const config = {
  mode: process.env.MODE,
  root: PACKAGE_ROOT,
  resolve: {
    alias: {
      "/@/": join(PACKAGE_ROOT, "src") + "/",
      "gis-core": resolve(join(PACKAGE_ROOT, "../../../packages/gis-core")),
    },
  },
  plugins: [react(), viteCommonjs({})],
  base: "",
  server: {
    fs: {
      strict: true,
    },
  },
  optimizeDeps: {
    exclude: ["pg", "pg-native", "pg-promise", "@blueprintjs/core"],
  },
  build: {
    sourcemap: true,
    target: `chrome${chrome}`,
    outDir: "dist",
    assetsDir: ".",
    rollupOptions: {
      external: [...builtinModules, "pg-native"],
    },
    emptyOutDir: true,
    brotliSize: false,
  },
};

export default config;

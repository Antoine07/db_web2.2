import { spawn } from "node:child_process";
import path from "node:path";
import { fileURLToPath } from "node:url";

const pnpmCommand = process.platform === "win32" ? "pnpm.cmd" : "pnpm";
const projectRoot = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..");
let isShuttingDown = false;
let apiProcess;
let clientProcess;

function shutdown(signal) {
  if (isShuttingDown) return;
  isShuttingDown = true;
  apiProcess?.kill(signal);
  clientProcess?.kill(signal);
}

function runDev(relativeWorkspacePath) {
  const child = spawn(pnpmCommand, ["-C", relativeWorkspacePath, "dev"], {
    cwd: projectRoot,
    stdio: "inherit",
    env: process.env
  });
  child.on("exit", (code, signal) => {
    if (isShuttingDown) return;
    if (signal) {
      shutdown(signal);
      return;
    }
    process.exitCode = code ?? 0;
    shutdown("SIGTERM");
  });
  return child;
}

apiProcess = runDev("api");
clientProcess = runDev("client");

process.on("SIGINT", () => shutdown("SIGINT"));
process.on("SIGTERM", () => shutdown("SIGTERM"));


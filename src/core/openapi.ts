import bunyan from "bunyan";
import fs from "fs";
import yaml from "js-yaml";

const logger = bunyan.createLogger({ name: "openapi" });
export const getNormalizePathsForMetrics = (
  prefix: string
): [string, string][] => {
  try {
    const doc: any = yaml.load(
      fs.readFileSync(__dirname + "/../../openapi.yml", "utf8")
    );
    return Object.keys(doc.paths)
      .filter((path) => /{.*}/.test(path))
      .map((path) => prefix + path)
      .map((path) => ["^" + path.replace(/\{\w+\}/g, "\\w+") + "$", path]);
  } catch (err) {
    logger.error(err);
    process.abort();
  }
};

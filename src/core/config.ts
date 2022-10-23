import Config from "../models/Config";

const config = new Config();
if (config.applicationSecret === undefined) {
  throw new Error("Missing application secret (set APPLICATION_SECRET");
}
export default config;

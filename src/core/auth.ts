import bunyan from "bunyan";
import { getFlatByApiKey } from "../repositories/flats";
import { getUserByApiKey } from "../repositories/users";
import config from "./config";

const logger = bunyan.createLogger({ name: "episodes" });

export const authPresent = (apiKey: string) => {
  const result = apiKey !== undefined;
  logger.debug({ result, apiKey }, "authPresent");
  return result;
};

export const isUser = async (apiKey: string) => {
  const result = (await getUserByApiKey(apiKey)) !== null;
  logger.debug({ result, apiKey }, "isUser");
  return result;
};

export const isAdmin = (apiKey: string) => {
  const result = apiKey === config.adminApiKey;
  logger.debug({ result, apiKey }, "isAdmin");
  return result;
};

export const isFlatAdmin = async (apiKey: string) => {
  const result = (await getFlatByApiKey(apiKey)) !== null;
  logger.debug({ result, apiKey }, "isFlatAdmin");
  return result;
};

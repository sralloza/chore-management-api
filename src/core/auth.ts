import bunyan from "bunyan";
import { getFlatByApiKey } from "../repositories/flats";
import { getUserByApiKey } from "../repositories/users";
import config from "./config";

const logger = bunyan.createLogger({ name: "episodes" });

export const authPresent = (apiKey: string) => {
  const result = apiKey !== undefined;
  logger.info({ result, apiKey }, "authPresent");
  return result;
};

export const isUser = async (apiKey: string) => {
  const result = (await getUserByApiKey(apiKey)) !== null;
  logger.info({ result, apiKey }, "isUser");
  return result;
};

export const isAdmin = (apiKey: string) => {
  const result = apiKey === config.adminApiKey;
  logger.info({ result, apiKey }, "isAdmin");
  return result;
};

export const isFlatAdmin = async (apiKey: string) => {
  const result = (await getFlatByApiKey(apiKey)) !== null;
  logger.info({ result, apiKey }, "isFlatAdmin");
  return result;
};

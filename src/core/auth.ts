import { getFlatByApiKey } from "../repositories/flats";
import { getUserByApiKey } from "../repositories/users";

export const authRequired = (apiKey: string) => {
  return apiKey !== undefined;
};

export const isUser = (apiKey: string) => {
  return getUserByApiKey(apiKey) !== undefined;
};

export const isAdmin = (apiKey: string) => {
  return apiKey === process.env.ADMIN_API_KEY;
};

export const isFlatAdmin = (apiKey: string) => {
  return getFlatByApiKey(apiKey) !== undefined;
};

import { randomUUID } from "crypto";
import jwt, { Secret } from "jsonwebtoken";
import config from "../core/config";

export const genJWT = (expiresIn: number | string) => {
  const token = jwt.sign({ sub: randomUUID() }, config.applicationSecret, {
    expiresIn,
  });

  return token;
};

export const verifyJWT = (token: string) => {
  try {
    jwt.verify(token, config.applicationSecret);
    return true;
  } catch (e) {
    return false;
  }
};

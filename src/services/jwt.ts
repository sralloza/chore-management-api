import { randomUUID } from "crypto";
import jwt, { Secret } from "jsonwebtoken";

const SECRET_KEY: Secret = process.env.APPLICATION_SECRET || "secret";

export const genJWT = (expiresIn: number | string) => {
  const token = jwt.sign({ sub: randomUUID() }, SECRET_KEY, {
    expiresIn,
  });

  return token;
};

export const verifyJWT = (token: string) => {
  try {
    jwt.verify(token, SECRET_KEY);
    return true;
  } catch (e) {
    return false;
  }
}

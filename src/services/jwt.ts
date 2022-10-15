import { randomUUID } from "crypto";
import jwt, { Secret } from "jsonwebtoken";

const SECRET_KEY: Secret = "secret";

export const genJWT = (expiresIn: number | string) => {
  const token = jwt.sign({ sub: randomUUID() }, SECRET_KEY, {
    expiresIn,
  });

  return token;
};

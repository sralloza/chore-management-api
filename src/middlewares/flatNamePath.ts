import { NextFunction, Request, Response } from "express";
import { getFlatByApiKey } from "../repositories/flats";
import { isAdmin } from "../core/auth";

const flatNamePathResolver = async (
  req: Request,
  res: Response,
  next: NextFunction
) => {
  const flatNamePath = req.params.flatName;
  const apiKey = req.get("x-token");
  const isAdminResult = isAdmin(apiKey);

  if (flatNamePath === "me") {
    if (isAdminResult) {
      return res
        .status(400)
        .json({ message: "Can't use the me keyword with the admin API key" });
    }
    req.params.flatName = (await getFlatByApiKey(apiKey)).name;
  }

  next();
};

export default flatNamePathResolver;

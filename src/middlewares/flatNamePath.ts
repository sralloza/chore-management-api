import bunyan from "bunyan";
import { NextFunction, Request, Response } from "express";
import { isAdmin } from "../core/auth";
import flatsRepo from "../repositories/flats";

const logger = bunyan.createLogger({ name: "flatNamePathMiddleware" });

const flatNamePathResolver = async (
  req: Request,
  res: Response,
  next: NextFunction
) => {
  const flatNamePath = req.params.flatName;
  const apiKey = req.get("x-token");
  const isAdminResult = isAdmin(apiKey);

  if (flatNamePath === "me") {
    // "me" keyword can't be used by the admin
    if (isAdminResult) {
      return res
        .status(400)
        .json({ message: "Can't use the me keyword with the admin API key" });
    }
    req.params.flatName = (await flatsRepo.getFlatByApiKey(apiKey)).name;
  } else if (!isAdminResult) {
    // Check if the flat admin is trying to access a flat that is not his
    const flat = await flatsRepo.getFlatByApiKey(apiKey);
    if (flat?.name !== flatNamePath) {
      return res.status(403).json({
        message: "You don't have permission to access this flat's data",
      });
    }
  }

  next();
};

export default flatNamePathResolver;

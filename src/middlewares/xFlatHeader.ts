import bunyan from "bunyan";
import { NextFunction, Request, Response } from "express";
import { isAdmin } from "../core/auth";
import flatsRepo from "../repositories/flats";
import { flat404 } from "./flats";

const logger = bunyan.createLogger({ name: "authMiddleware" });

// Note: must be used with admin or flat admin access only
const parseXFlatHeader = async (
  req: Request,
  res: Response,
  next: NextFunction
) => {
  const xFlatHeader = req.get("x-flat") as string;
  const headerDefined = xFlatHeader !== undefined;
  const isAdminResult = isAdmin(req.get("x-token"));

  if (headerDefined && !isAdminResult) {
    return res.status(400).json({
      message: "Can't use the x-flat header without the admin API key",
    });
  }
  if (!headerDefined && isAdminResult) {
    return res
      .status(400)
      .json({ message: "Must use the x-flat header with the admin API key" });
  }

  // If the header is defined, we need to check if the flat exists
  // Otherwise, we can just skip the check
  logger.info({ info: { xFlatHeader, headerDefined, isAdminResult } });
  if (headerDefined) {
    req.params.flatName = xFlatHeader;
    return flat404(req, res, next);
  } else {
    if (req.params.flatName === undefined) {
      req.params.flatName = (
        await flatsRepo.getFlatByApiKey(req.get("x-token"))
      )?.name;
    }
  }
  logger.info({ info: { flatName: req.params.flatName } });

  next();
};

export default parseXFlatHeader;

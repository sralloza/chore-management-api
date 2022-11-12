import { NextFunction, Request, Response } from "express";
import {
  XFLAT_HEADER_REQUIRED,
  XFLAT_HEADER_WITHOUT_ADMIN_KEY,
} from "../core/constants";
import { isAdmin } from "../core/auth";
import flatsRepo from "../repositories/flats";
import { flat404 } from "./flats";

// Note: must be used with admin or flat admin access only
const parseXFlatHeader = async (
  req: Request,
  res: Response,
  next: NextFunction
) => {
  const xFlatHeader = req.get("X-Flat") as string;
  const headerDefined = xFlatHeader !== undefined;
  const isAdminResult = isAdmin(req.get("X-Token"));

  if (headerDefined && !isAdminResult) {
    return res.status(400).json(XFLAT_HEADER_WITHOUT_ADMIN_KEY);
  }
  if (!headerDefined && isAdminResult) {
    return res.status(400).json(XFLAT_HEADER_REQUIRED);
  }

  // If the header is defined, we need to check if the flat exists
  // Otherwise, we can just skip the check
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

  next();
};

export default parseXFlatHeader;

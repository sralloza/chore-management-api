import bunyan from "bunyan";
import express from "express";
import { INTERNAL } from "../core/constants";
import { flatAuth, userAuth } from "../middlewares/auth";
import { choreType404, choreType409 } from "../middlewares/choreTypes";
import parseXFlatHeader from "../middlewares/xFlatHeader";
import choreTypesRepo from "../repositories/choreTypes";
import validate from "../validators";
import { choreTypeCreateValidator } from "../validators/choreType";

const logger = bunyan.createLogger({ name: "choreTypesController" });
const router = express.Router();

router.post(
  "",
  flatAuth,
  parseXFlatHeader,
  validate(choreTypeCreateValidator),
  choreType409,
  async (req, res) => {
    try {
      const choreType = await choreTypesRepo.createChoreType(
        req.body,
        req.params.flatName
      );
      res.status(200).json(choreType);
    } catch (err) {
      logger.error(err);
      res.status(500).json(INTERNAL);
    }
  }
);

router.get("", flatAuth, parseXFlatHeader, async (req, res) => {
  const choreTypes = await choreTypesRepo.listChoreTypes(req.params.flatName);
  res.status(200).json(choreTypes);
});

router.get(
  "/:choreTypeId",
  userAuth,
  parseXFlatHeader,
  choreType404,
  async (req, res) => {
    res.status(200).json(req.choreType);
  }
);

export default router;

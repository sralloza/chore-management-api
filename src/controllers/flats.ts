import express from "express";
import { DateTime } from "luxon";
import { adminAuth, flatAuth } from "../middlewares/auth";
import flatNamePathResolver from "../middlewares/flatNamePath";
import { flat404, flat409, verifyCreateCode403 } from "../middlewares/flats";
import flatsRepo from "../repositories/flats";
import { genJWT } from "../services/jwt";
import redisClient from "../services/redis";
import validate from "../validators";
import {
  flatCreateValidator,
  flatSettingsUpdateValidator,
} from "../validators/flat";

const router = express.Router();

router.post("/create-code", adminAuth, (req, res) => {
  const expiresAt = DateTime.now().plus({ minutes: 5 });
  const code = genJWT("5m");
  res.status(200).json({ code, expires_at: expiresAt });
});

router.post(
  "",
  validate(flatCreateValidator),
  verifyCreateCode403,
  flat409,
  async (req, res) => {
    const flat = await flatsRepo.addFlat(req.body);
    await redisClient.set(req.body.create_code, req.body.name, 5);
    return res.status(200).json(flat);
  }
);

router.get("", adminAuth, async (req, res) => {
  const flats = await flatsRepo.getFlats();
  res.status(200).json(flats);
});

router.get("/:flatName", adminAuth, flat404, async (req, res) => {
  res.status(200).json(req.flat);
});

router.delete("/:flatName", adminAuth, flat404, async (req, res) => {
  await flatsRepo.deleteFlat(req.params.flatName);
  res.status(204).send();
});

router.patch(
  "/:flatName/settings",
  flatAuth,
  flatNamePathResolver,
  validate(flatSettingsUpdateValidator),
  flat404,
  async (req, res) => {
    const flat = await flatsRepo.updateFlatSettings(
      req.body,
      req.params.flatName
    );
    res.status(200).json(flat.settings);
  }
);

export default router;

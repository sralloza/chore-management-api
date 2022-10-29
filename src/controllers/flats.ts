import express from "express";
import { validationResult } from "express-validator";
import { DateTime } from "luxon";
import flatNamePathResolver from "../middlewares/flatNamePath";
import { INTERNAL } from "../core/constants";
import { adminAuth, flatAuth } from "../middlewares/auth";
import {
  addFlat,
  deleteFlat,
  getFlatByName,
  getFlats,
  updateFlatSettings,
} from "../repositories/flats";
import { genJWT, verifyJWT } from "../services/jwt";
import redisClient from "../services/redis";
import validate from "../validators";
import {
  flatCreateValidator,
  flatSettingsUpdateValidator,
} from "../validators/flat";

const router = express();

router.post("/create-code", adminAuth, (req, res) => {
  const expiresAt = DateTime.now().plus({ minutes: 5 });
  const code = genJWT("5m");
  res.status(200).json({ code, expires_at: expiresAt });
});

router.post("", validate(flatCreateValidator), async (req, res) => {
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    return res.status(422).json({ errors: errors.array() });
  }

  if (!verifyJWT(req.body.create_code)) {
    return res.status(403).json({ message: "Invalid create code" });
  }

  const savedCreateCode = await redisClient.get(req.body.create_code);
  if (savedCreateCode) {
    return res.status(403).json({ message: "Invalid create code" });
  }

  const existingFlat = await getFlatByName(req.body.name);
  if (existingFlat) {
    return res.status(409).json({ message: "Flat already exists" });
  }

  try {
    const flat = await addFlat(req.body);
    await redisClient.set(req.body.create_code, req.body.name, 5);
    res.status(200).json(flat);
  } catch (e) {
    return res.status(500).json(INTERNAL);
  }
});

router.get("", adminAuth, async (req, res) => {
  const flats = await getFlats();
  res.status(200).json(flats);
});

router.get("/:flatName", adminAuth, async (req, res) => {
  const flat = await getFlatByName(req.params.flatName);
  if (!flat) {
    return res
      .status(404)
      .json({ message: "Flat not found: " + req.params.flatName });
  }
  res.status(200).json(flat);
});

router.delete("/:flatName", adminAuth, async (req, res) => {
  const existingFlat = await getFlatByName(req.params.flatName);
  if (!existingFlat) {
    return res
      .status(404)
      .json({ message: "Flat not found: " + req.params.flatName });
  }
  await deleteFlat(req.params.flatName);
  res.status(204).send();
});

router.patch(
  "/:flatName/settings",
  flatAuth,
  flatNamePathResolver,
  validate(flatSettingsUpdateValidator),
  async (req, res) => {
    const existingFlat = await getFlatByName(req.params.flatName);
    if (!existingFlat) {
      return res
        .status(404)
        .json({ message: "Flat not found: " + req.params.flatName });
    }
    const flat = await updateFlatSettings(req.body, req.params.flatName);
    res.status(200).json(flat.settings);
  }
);

export default router;

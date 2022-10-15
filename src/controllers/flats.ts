import express from "express";
import { DateTime } from "luxon";
import { adminAuth, flatAuth } from "../middlewares/auth";
import { addFlat, deleteFlat, getFlatByName } from "../repositories/flats";
import { genJWT } from "../services/jwt";

const router = express();

router.post("/create-code", adminAuth, (req, res) => {
  const expiresAt = DateTime.now().plus({ minutes: 5 });
  const code = genJWT("5m");
  res.status(200).json({ code, expires_at: expiresAt });
});

router.post("", async (req, res) => {
  const existingFlat = await getFlatByName(req.body.name);
  if (existingFlat) {
    return res.status(409).json({ message: "Flat already exists" });
  }

  const flat = await addFlat(req.body);
  res.status(200).json(flat);
});

router.get("/:name", flatAuth, async (req, res) => {
  const flat = await getFlatByName(req.params.name);
  if (!flat) {
    return res
      .status(404)
      .json({ message: "Flat not found: " + req.params.name });
  }
  res.status(200).json(flat);
});

router.delete("/:name", async (req, res) => {
  const existingFlat = await getFlatByName(req.params.name);
  if (!existingFlat) {
    return res
      .status(404)
      .json({ message: "Flat not found: " + req.params.name });
  }
  await deleteFlat(req.params.name);
  res.status(204).send();
});

export default router;

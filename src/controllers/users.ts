import express from "express";
import { INTERNAL } from "../core/constants";
import { addUser, getUserByApiKey } from "../repositories/users";

const router = express();

router.post("", async (req, res) => {
  const existingFlat = await getUserByApiKey(req.body.username);
  if (existingFlat) {
    return res
      .status(409)
      .json({ message: "User already exists: " + req.body.username });
  }

  try {
    const flat = await addUser(req.body, "flat-name");
    res.status(200).json(flat);
  } catch (e) {
    console.error(e);
    return res.status(500).json(INTERNAL);
  }
});

export default router;

import express from "express";
import weekIdUtils from "../core/weekId";
const router = express();

router.get("/current", (req, res) => {
  res.status(200).json({ week_id: weekIdUtils.getCurrentWeekId() });
});
router.get("/next", (req, res) => {
  res.status(200).json({ week_id: weekIdUtils.getNextWeekId() });
});
router.get("/last", (req, res) => {
  res.status(200).json({ week_id: weekIdUtils.getLastWeekId() });
});

export default router;

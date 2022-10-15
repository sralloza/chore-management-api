import express from "express";
import flats from "./flats";
import weekId from "./weekId";

const router = express();
router.use("/flats", flats);
router.use("/week-id", weekId);

export default router;

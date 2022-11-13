import express from "express";
import choreTypes from "./choreTypes";
import flats from "./flats";
import tickets from "./tickets";
import users from "./users";
import weekId from "./weekId";

const router = express.Router();

router.use("/chore-types", choreTypes);
router.use("/flats", flats);
router.use("/tickets", tickets);
router.use("/users", users);
router.use("/week-id", weekId);

export default router;

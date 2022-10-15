import express from "express";

const router = express();

router.get("/:name", (req, res) => {
  res.status(200).json({ message: "Hello " + req.params.name });
});

export default router;

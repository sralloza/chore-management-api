import { body } from "express-validator";

const choreTypeIdPattern = /^[a-z-]+$/;

export const choreTypeCreateValidator = [
  body("id")
    .exists({ checkNull: true })
    .withMessage("body.id is required")
    .bail()
    .isLength({ min: 1, max: 25 })
    .withMessage("body.id must be between 1 and 25 characters long")
    .bail()
    .trim()
    .custom((value) => {
      if (!choreTypeIdPattern.test(value)) {
        return Promise.reject();
      }
      return true;
    })
    .withMessage("body.id does not match the pattern '^[a-z-]+$'"),
  body("name")
    .exists({ checkNull: true })
    .withMessage("body.name is required")
    .bail()
    .trim()
    .isLength({ min: 1, max: 50 })
    .withMessage("body.name must be between 1 and 50 characters long")
    .bail(),
  body("description")
    .exists({ checkNull: true })
    .withMessage("body.description is required")
    .bail()
    .trim()
    .isLength({ min: 1, max: 255 })
    .withMessage("body.description must be between 1 and 255 characters long")
    .bail(),
];

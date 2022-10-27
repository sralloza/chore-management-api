import { body } from "express-validator";

const flatNamePattern = /^[a-z-]+$/;
const flatValidator = [
  body("name")
    .exists({ checkFalsy: false, checkNull: true })
    .withMessage("body.name is required")
    .not()
    .isEmpty({ ignore_whitespace: true })
    .withMessage("body.name can't be empty")
    .custom((value) => {
      if (!flatNamePattern.test(value)) {
        return Promise.reject();
      }
      return true;
    })
    .withMessage("body.name does not match the pattern '^[a-z-]+$'"),
  body("create_code")
    .exists({checkNull: true})
    .withMessage("body.create_code is required")
    .bail()
    .isJWT()
    .withMessage("body.create_code is not a valid JWT"),
];

export default flatValidator;

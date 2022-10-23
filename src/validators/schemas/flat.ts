import { Schema } from "express-validator";

const flatNamePattern = /^[a-z-]+$/;
const schema: Schema = {
  create_code: {
    in: ["body"],
    isString: true,
  },
  name: {
    in: ["body"],
    isString: true,
    isEmpty: {
      options: {
        ignore_whitespace: true,
      },
    },
    custom: {
      options: (value) => {
        if (!flatNamePattern.test(value)) {
          return Promise.reject("Invalid flat name");
        }
        return true;
      },
    },
  },
};

export default schema;

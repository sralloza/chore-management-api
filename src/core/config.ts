import Config from "../models/Config";

const validateRequiredVar = (
  variable: any,
  explanation: string,
  envVar: string
) => {
  if (variable === undefined) {
    throw new Error(
      `Missing ${explanation} (set $${envVar} environment variable)`
    );
  }
};

const config = new Config();
validateRequiredVar(
  config.applicationSecret,
  "application secret",
  "APPLICATION_SECRET"
);
validateRequiredVar(config.adminApiKey, "admin API key", "ADMIN_API_KEY");

export default config;

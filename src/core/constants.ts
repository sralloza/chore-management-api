// GENERICS
export const INTERNAL = { message: "Internal server error" };

// AUTH
export const MISSING_API_KEY = { message: "Missing API key" };
export const ADMIN_ACCESS_REQUIRED = { message: "Admin access required" };
export const FLAT_ADMIN_ACCESS_REQUIRED = {
  message: "Flat administration access required",
};
export const USER_ACCESS_REQUIRED = { message: "User access required" };
export const ADMIN_KEY_ME = {
  message: "Can't use the special keyword me with the admin API key",
};
export const FLAT_ADMIN_KEY_ME = {
  message:
    "Can't use the special keyword me with a flat administration API key",
};

// GENERICS
const notFound = (name: string, id: string) => ({
  message: `${name} not found: ${id}`,
});
const alreadyExists = (name: string) => ({
  message: `${name} already exists`,
});

// FLATS
export const FLAT_ALREADY_EXISTS = alreadyExists("Flat");
export const FLAT_NOT_FOUND = (id: string) => {
  return notFound("Flat", id);
};
export const FORBIDDEN_FLAT_DATA = {
  message: "You don't have permission to access this flat's data",
};
export const INVALID_CREATE_CODE = { message: "Invalid create code" };

// CHORE TYPES
export const CHORE_TYPE_ALREADY_EXISTS = alreadyExists("Chore type");
export const CHORE_TYPE_NOT_FOUND = (id: string) => {
  return notFound("Chore type", id);
};

// USERS
export const USER_ALREADY_EXISTS = alreadyExists("User");
export const USER_NOT_FOUND = (id: string) => {
  return notFound("User", id);
};
export const FORBIDDEN_USER_DATA = {
  message: "You don't have permission to access this user's data",
};

// X-FLAT HEADER
export const XFLAT_HEADER_WITHOUT_ADMIN_KEY = {
  message: "Can't use the X-Flat header without the admin API key",
};
export const XFLAT_HEADER_REQUIRED = {
  message: "Must use the X-Flat header with the admin API key",
};

import { randomUUID } from "crypto";
import dataSource from "../core/datasource";
import FlatDB from "../models/db/FlatDB";

const repo = dataSource.getRepository(FlatDB);

const splitString = (str: string) =>
  str
    .split(",")
    .map((s) => s.trim())
    .filter((s) => s.length > 0)
    .map((s) => Number.parseInt(s, 10));

const buildFlat = (flat: FlatDB): Flat => {
  if (flat === null) return null;
  return {
    name: flat.name,
    settings: {
      assignment_order: splitString(flat.assignmentOrder),
      rotation_sign: flat.rotationSign as RotationSign,
    },
    api_key: flat.apiKey,
  };
};

export const getFlats = async () => {
  const flats = await repo.find();
  return flats.map(buildFlat);
};

export const getFlatByName = async (name: string): Promise<Flat> => {
  const flat = await repo.findOne({ where: { name } });
  return buildFlat(flat);
};

export const getFlatByApiKey = async (apiKey: string): Promise<Flat> => {
  const flat = await repo.findOne({ where: { apiKey } });
  console.log({ flat });
  return buildFlat(flat);
};

export const addFlat = async (flat: FlatCreate): Promise<Flat> => {
  const newFlat = repo.create({
    name: flat.name,
    assignmentOrder: "",
    rotationSign: "positive",
    apiKey: randomUUID(),
  });
  await repo.save(newFlat);
  return buildFlat(newFlat);
};

export const deleteFlat = async (name: string): Promise<void> => {
  await repo.delete({ name });
  return;
};

export const updateFlatSettings = async (
  settingsUpdate: SettingsUpdate,
  flatName: string
): Promise<Flat> => {
  const flat = await repo.findOne({ where: { name: flatName } });
  if (flat === null) return null;
  if (settingsUpdate.rotation_sign !== undefined)
    flat.rotationSign = settingsUpdate.rotation_sign;

  if (settingsUpdate.assignment_order !== undefined)
    flat.assignmentOrder = settingsUpdate.assignment_order.join(",");

  await repo.save(flat);
  return buildFlat(flat);
};

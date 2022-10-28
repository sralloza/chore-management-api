import { randomUUID } from "crypto";
import dataSource from "../core/datasource";
import FlatDB from "../models/FlatDB";

const repo = dataSource.getRepository(FlatDB);
const buildFlat = (flat: FlatDB): Flat => {
  if (flat === null) return null;
  return {
    name: flat.name,
    settings: {
      assignment_order: [],
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

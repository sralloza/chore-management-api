import dataSource from "../core/datasource";
import ChoreTypeDB from "../models/db/ChoreTypeDB";

const repo = dataSource.getRepository(ChoreTypeDB);
const mapper = (choreType: ChoreTypeDB): ChoreType => {
  if (choreType === null) return null;
  return {
    id: choreType.id,
    name: choreType.name,
    description: choreType.description,
  };
};

const choreTypesRepo = {
  listChoreTypes: async (flatName: string): Promise<ChoreType[]> => {
    const choreTypes = await repo.find({ where: { flatName } });
    return choreTypes
      .map(mapper)
      .sort((a, b) => a.name.toLowerCase().localeCompare(b.name.toLowerCase()));
  },

  getChoreTypeByName: async (name: string): Promise<ChoreType> => {
    const choreType = await repo.findOne({ where: { name } });
    return mapper(choreType);
  },

  getChoreTypeById: async (
    id: string,
    flatName: string
  ): Promise<ChoreType> => {
    const choreType = await repo.findOne({ where: { id, flatName } });
    return mapper(choreType);
  },

  createChoreType: async (
    choreType: ChoreTypeCreate,
    flatName: string
  ): Promise<ChoreType> => {
    const data = { ...choreType, flatName };
    const newChoreType = repo.create(data);
    await repo.save(newChoreType);
    return mapper(newChoreType);
  },

  deleteChoreTypeById: async (id: string, flatName: string): Promise<void> => {
    await repo.delete({ id, flatName });
    return;
  },
};
export default choreTypesRepo;

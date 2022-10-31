import { Column, Entity, PrimaryColumn } from "typeorm";

@Entity({ name: "flats" })
class FlatDB {
  @PrimaryColumn("varchar", { length: 20 })
  name: string;
  @Column("varchar", { length: 2048 })
  assignmentOrder: string;
  @Column("varchar", { length: 15 })
  rotationSign: string;
  @Column("varchar", { length: 36, unique: true })
  apiKey: string;
}

export default FlatDB;

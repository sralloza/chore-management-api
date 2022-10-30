import { Column, Entity, PrimaryGeneratedColumn } from "typeorm";

@Entity({ name: "choreTypes" })
class UserDB {
  @PrimaryGeneratedColumn("increment")
  realId: bigint;
  @Column("varchar", { length: 25 })
  id: string;
  @Column("varchar", { length: 50 })
  name: string;
  @Column("varchar", { length: 255 })
  description: string;
  @Column("varchar", { length: 20 })
  flatName: string;
}

export default UserDB;

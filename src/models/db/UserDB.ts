import { Column, Entity, PrimaryColumn } from "typeorm";

@Entity({ name: "users" })
class UserDB {
  @PrimaryColumn("bigint")
  id: bigint;
  @Column("varchar", { length: 50 })
  username: string;
  @Column("varchar", { length: 36 })
  apiKey: string;
  @Column("varchar", { length: 20 })
  flatName: string;
}

export default UserDB;

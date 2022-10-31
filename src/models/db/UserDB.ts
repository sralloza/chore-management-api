import { Column, Entity, PrimaryGeneratedColumn } from "typeorm";

@Entity({ name: "users" })
class UserDB {
  @PrimaryGeneratedColumn("uuid")
  realId: string;
  @Column("varchar", { length: 40 })
  id: string;
  @Column("varchar", { length: 50 })
  username: string;
  @Column("varchar", { length: 36, unique: true })
  apiKey: string;
  @Column("varchar", { length: 20 })
  flatName: string;
}

export default UserDB;

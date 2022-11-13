const { MigrationInterface, QueryRunner } = require("typeorm");

module.exports = class start1668296402816 {
    name = 'start1668296402816'

    async up(queryRunner) {
        await queryRunner.query(`CREATE TABLE \`tickets\` (\`id\` int NOT NULL AUTO_INCREMENT, \`chore_type_id\` varchar(25) NOT NULL, \`user_id\` varchar(40) NOT NULL, \`tickets\` int NOT NULL, \`flatName\` varchar(20) NOT NULL, PRIMARY KEY (\`id\`)) ENGINE=InnoDB`);
        await queryRunner.query(`CREATE TABLE \`choreTypes\` (\`realId\` varchar(36) NOT NULL, \`id\` varchar(25) NOT NULL, \`name\` varchar(50) NOT NULL, \`description\` varchar(255) NOT NULL, \`flatName\` varchar(20) NOT NULL, PRIMARY KEY (\`realId\`)) ENGINE=InnoDB`);
        await queryRunner.query(`CREATE TABLE \`flats\` (\`name\` varchar(20) NOT NULL, \`assignmentOrder\` varchar(2048) NOT NULL, \`rotationSign\` varchar(15) NOT NULL, \`apiKey\` varchar(36) NOT NULL, UNIQUE INDEX \`IDX_381c6b3c2bf8a43eff521acd32\` (\`apiKey\`), PRIMARY KEY (\`name\`)) ENGINE=InnoDB`);
        await queryRunner.query(`CREATE TABLE \`users\` (\`realId\` varchar(36) NOT NULL, \`id\` varchar(40) NOT NULL, \`username\` varchar(50) NOT NULL, \`apiKey\` varchar(36) NOT NULL, \`flatName\` varchar(20) NOT NULL, UNIQUE INDEX \`IDX_c654b438e89f6e1fbd2828b5d3\` (\`apiKey\`), PRIMARY KEY (\`realId\`)) ENGINE=InnoDB`);
    }

    async down(queryRunner) {
        await queryRunner.query(`DROP INDEX \`IDX_c654b438e89f6e1fbd2828b5d3\` ON \`users\``);
        await queryRunner.query(`DROP TABLE \`users\``);
        await queryRunner.query(`DROP INDEX \`IDX_381c6b3c2bf8a43eff521acd32\` ON \`flats\``);
        await queryRunner.query(`DROP TABLE \`flats\``);
        await queryRunner.query(`DROP TABLE \`choreTypes\``);
        await queryRunner.query(`DROP TABLE \`tickets\``);
    }
}

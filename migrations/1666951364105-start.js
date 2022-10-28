const { MigrationInterface, QueryRunner } = require("typeorm");

module.exports = class start1666951364105 {
    name = 'start1666951364105'

    async up(queryRunner) {
        await queryRunner.query(`CREATE TABLE \`flats\` (\`name\` varchar(20) NOT NULL, \`assignmentOrder\` varchar(2048) NOT NULL, \`rotationSign\` varchar(15) NOT NULL, \`apiKey\` varchar(36) NOT NULL, PRIMARY KEY (\`name\`)) ENGINE=InnoDB`);
        await queryRunner.query(`CREATE TABLE \`users\` (\`id\` bigint NOT NULL, \`username\` varchar(50) NOT NULL, \`apiKey\` varchar(36) NOT NULL, \`flatName\` varchar(20) NOT NULL, PRIMARY KEY (\`id\`)) ENGINE=InnoDB`);
    }

    async down(queryRunner) {
        await queryRunner.query(`DROP TABLE \`users\``);
        await queryRunner.query(`DROP TABLE \`flats\``);
    }
}

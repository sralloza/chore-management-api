const { MigrationInterface, QueryRunner } = require("typeorm");

module.exports = class start1667212940381 {
    name = 'start1667212940381'

    async up(queryRunner) {
        await queryRunner.query(`CREATE TABLE \`choreTypes\` (\`realId\` varchar(36) NOT NULL, \`id\` varchar(25) NOT NULL, \`name\` varchar(50) NOT NULL, \`description\` varchar(255) NOT NULL, \`flatName\` varchar(20) NOT NULL, PRIMARY KEY (\`realId\`)) ENGINE=InnoDB`);
        await queryRunner.query(`CREATE TABLE \`users\` (\`realId\` varchar(36) NOT NULL, \`id\` varchar(40) NOT NULL, \`username\` varchar(50) NOT NULL, \`apiKey\` varchar(36) NOT NULL, \`flatName\` varchar(20) NOT NULL, PRIMARY KEY (\`realId\`)) ENGINE=InnoDB`);
        await queryRunner.query(`CREATE TABLE \`flats\` (\`name\` varchar(20) NOT NULL, \`assignmentOrder\` varchar(2048) NOT NULL, \`rotationSign\` varchar(15) NOT NULL, \`apiKey\` varchar(36) NOT NULL, PRIMARY KEY (\`name\`)) ENGINE=InnoDB`);
    }

    async down(queryRunner) {
        await queryRunner.query(`DROP TABLE \`flats\``);
        await queryRunner.query(`DROP TABLE \`users\``);
        await queryRunner.query(`DROP TABLE \`choreTypes\``);
    }
}

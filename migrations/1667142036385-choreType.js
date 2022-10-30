const { MigrationInterface, QueryRunner } = require("typeorm");

module.exports = class choreType1667142036385 {
    name = 'choreType1667142036385'

    async up(queryRunner) {
        await queryRunner.query(`CREATE TABLE \`choreTypes\` (\`realId\` int NOT NULL AUTO_INCREMENT, \`id\` varchar(25) NOT NULL, \`name\` varchar(50) NOT NULL, \`description\` varchar(255) NOT NULL, \`flatName\` varchar(20) NOT NULL, PRIMARY KEY (\`realId\`)) ENGINE=InnoDB`);
    }

    async down(queryRunner) {
        await queryRunner.query(`DROP TABLE \`choreTypes\``);
    }
}

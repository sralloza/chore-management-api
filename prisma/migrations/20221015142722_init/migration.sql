-- CreateTable
CREATE TABLE `Flat` (
    `name` VARCHAR(191) NOT NULL,
    `assignmentOrder` VARCHAR(2048) NOT NULL,
    `rotationSign` VARCHAR(15) NOT NULL,
    `apiKey` VARCHAR(36) NOT NULL,

    PRIMARY KEY (`name`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `User` (
    `id` BIGINT NOT NULL,
    `username` VARCHAR(50) NOT NULL,
    `apiKey` VARCHAR(36) NOT NULL,
    `flatName` VARCHAR(191) NOT NULL,

    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

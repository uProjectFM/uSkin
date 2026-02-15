-- ============================
-- uSkin Permissions Migration
-- Adds a 'perms' JSON column to the ESX users table
-- Run this once on your database before restarting the server
-- ============================

ALTER TABLE `users` ADD COLUMN `perms` LONGTEXT NULL DEFAULT NULL AFTER `metadata`;

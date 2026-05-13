const { sequelize } = require('../../config/db');

const setupTestDB = async () => {
  try {
    await sequelize.query('SET FOREIGN_KEY_CHECKS = 0');
    
    const [tables] = await sequelize.query("SHOW TABLES");
    const dbName = sequelize.config.database;
    for (const tableObj of tables) {
      const tableName = tableObj[`Tables_in_${dbName}`];
      await sequelize.query(`DROP TABLE IF EXISTS \`${tableName}\``);
    }
    
    await sequelize.sync({ force: true });
    await sequelize.query('SET FOREIGN_KEY_CHECKS = 1');
  } catch (error) {
    console.error('Error during test DB setup:', error);
    throw error;
  }
};

const closeTestDB = async () => {
  await sequelize.close();
};

module.exports = { setupTestDB, closeTestDB };

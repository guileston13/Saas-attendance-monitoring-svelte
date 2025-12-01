import { executeQuery } from './src/services/database.js';

async function migrate() {
    try {
        console.log('Adding per-day schedule columns...');
        await executeQuery(`
            ALTER TABLE section_subjects
            ADD COLUMN MondayStart TIME DEFAULT NULL,
            ADD COLUMN MondayEnd TIME DEFAULT NULL,
            ADD COLUMN TuesdayStart TIME DEFAULT NULL,
            ADD COLUMN TuesdayEnd TIME DEFAULT NULL,
            ADD COLUMN WednesdayStart TIME DEFAULT NULL,
            ADD COLUMN WednesdayEnd TIME DEFAULT NULL,
            ADD COLUMN ThursdayStart TIME DEFAULT NULL,
            ADD COLUMN ThursdayEnd TIME DEFAULT NULL,
            ADD COLUMN FridayStart TIME DEFAULT NULL,
            ADD COLUMN FridayEnd TIME DEFAULT NULL;
        `);
        console.log('Migration successful!');
    } catch (error) {
        if (error.code === 'ER_DUP_FIELDNAME') {
            console.log('Columns already exist.');
        } else {
            console.error('Migration failed:', error);
        }
    }
    process.exit(0);
}

migrate();

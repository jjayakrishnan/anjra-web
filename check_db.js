const { createClient } = require('@supabase/supabase-js');
require('dotenv').config();

const supabase = createClient(process.env.SUPABASE_URL, process.env.SUPABASE_KEY);

async function checkDB() {
    console.log("Checking transactions table...");
    const { data, error } = await supabase.from('transactions').select('*');
    if (error) {
        console.error("Error:", error);
    } else {
        console.log("Transactions found:", data.length);
        console.log(data.slice(0, 3)); // show first 3
    }
}

checkDB();

require('dotenv').config();
const { createClient } = require('@supabase/supabase-js');

const supabaseUrl = process.env.SUPABASE_URL;
const supabaseKey = process.env.SUPABASE_KEY;
const supabase = createClient(supabaseUrl, supabaseKey);

async function check() {
    console.log("Logging in as Lakshan...");
    const { data: authData, error: authError } = await supabase.auth.signInWithPassword({
        email: 'kid1_440795aa-e321-480e-b6ad-e16f94fbbc6c@anjra.app', // wait, lakshan's email is unknown. Let's find it.
    });
}
check();

const { createClient } = require('@supabase/supabase-js');
require('dotenv').config();

const supabase = createClient(process.env.SUPABASE_URL, process.env.SUPABASE_KEY);

async function checkUser() {
    console.log("Checking all profiles...");
    const { data: profileData, error: profileError } = await supabase
        .from('profiles')
        .select('*');

    if (profileError) {
        console.error("Profile Error:", profileError);
    } else {
        console.log("Profiles found:", profileData.length);
        console.dir(profileData.slice(0, 5), { depth: null });
    }
}

checkUser();

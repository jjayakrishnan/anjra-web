const { createClient } = require('@supabase/supabase-js');
require('dotenv').config();

const supabase = createClient(process.env.SUPABASE_URL, process.env.SUPABASE_KEY);

async function fixProfile() {
    try {
        console.log("Logging in as balakiruba@gmail.com...");
        const { data: authData, error: authError } = await supabase.auth.signInWithPassword({
            email: 'balakiruba@gmail.com',
            password: '123456'
        });

        if (authError) {
            console.error("Auth Error:", authError.message);
            return;
        }

        const user = authData.user;
        console.log("Logged in! User ID:", user.id);

        console.log("Checking if profile exists...");
        const { data: profile } = await supabase.from('profiles').select('*').eq('id', user.id).single();

        if (profile) {
            console.log("Profile already exists:", profile);
        } else {
            console.log("Creating default parent profile...");
            const { data: newProfile, error: insertError } = await supabase.from('profiles').insert([
                {
                    id: user.id,
                    username: 'balakiruba',
                    full_name: 'Bala Kiruba',
                    is_parent: true,
                    balance: 1000
                }
            ]).select();

            if (insertError) {
                console.error("Insert Error:", insertError);
            } else {
                console.log("Profile created successfully:", newProfile);
            }
        }
    } catch (e) {
        console.error("Unexpected error:", e);
    }
}

fixProfile();

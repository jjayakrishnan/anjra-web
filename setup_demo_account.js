require('dotenv').config();
const { createClient } = require('@supabase/supabase-js');

const supabaseUrl = process.env.SUPABASE_URL;
const supabaseKey = process.env.SUPABASE_SERVICE_ROLE_KEY;

if (!supabaseUrl || !supabaseKey) {
    console.error("Missing SUPABASE_URL or SUPABASE_SERVICE_ROLE_KEY in .env");
    process.exit(1);
}

const supabase = createClient(supabaseUrl, supabaseKey);

async function createReviewerAccount() {
    const email = 'evergreenjk@gmail.com';
    const password = 'test1234';

    console.log('Creating/Updating Reviewer Demo Account...');

    // Create user in Auth
    const { data: authData, error: authError } = await supabase.auth.admin.createUser({
        email: email,
        password: password,
        email_confirm: true,
        user_metadata: { full_name: 'App Store Reviewer' }
    });

    if (authError && authError.message !== 'User already registered') {
        console.error('Error creating auth user:', authError);
        return;
    }

    let userId;
    if (authData?.user) {
        userId = authData.user.id;
        console.log(`Created new auth user with ID: ${userId}`);
    } else {
        // If user already exists, find their ID
        const { data: users, error: findError } = await supabase.auth.admin.listUsers();
        if (findError) {
            console.error('Error fetching users:', findError);
            return;
        }
        const existingUser = users.users.find(u => u.email === email);
        if (existingUser) {
            userId = existingUser.id;
            // Ensure password is correct and email is confirmed
            await supabase.auth.admin.updateUserById(userId, { password: password, email_confirm: true });
            console.log(`Updated existing auth user with ID: ${userId}`);
        } else {
            console.error('Could not find existing user ID');
            return;
        }
    }

    // Ensure generic profile exists
    const { error: profileError } = await supabase
        .from('profiles')
        .upsert({
            id: userId,
            email: email,
            full_name: 'App Store Reviewer',
            is_parent: true,
            balance: 5000.0,
            created_at: new Date().toISOString(),
        }, { onConflict: 'id' });

    if (profileError) {
        console.error('Error upserting profile:', profileError);
        return;
    }

    // Create dummy kids for the reviewer
    console.log('Creating 3 dummy kids for reviewer...');
    const kids = ['Test Kid 1', 'Test Kid 2', 'Test Kid 3'];
    for (let i = 0; i < kids.length; i++) {
        const kidName = kids[i];
        const kidEmail = `demo.kid${i}@reviewer.com`;

        // Kid Auth
        const { data: kidAuth, error: kidAuthError } = await supabase.auth.admin.createUser({
            email: kidEmail,
            password: 'password123',
            email_confirm: true,
            user_metadata: { full_name: kidName }
        });

        if (kidAuthError && kidAuthError.message !== 'User already registered') {
            console.error(`Error creating kid auth ${kidName}:`, kidAuthError);
            continue;
        }

        let kidId;
        if (kidAuth?.user) {
            kidId = kidAuth.user.id;
        } else {
            const { data: allUsers } = await supabase.auth.admin.listUsers();
            kidId = allUsers.users.find(u => u.email === kidEmail)?.id;
        }

        if (kidId) {
            // Kid Profile
            await supabase.from('profiles').upsert({
                id: kidId,
                email: kidEmail,
                full_name: kidName,
                is_parent: false,
                parent_id: userId,
                balance: 0.0,
                created_at: new Date().toISOString(),
            }, { onConflict: 'id' });
        }
    }

    console.log('Successfully configured App Store Reviewer demo database state!');
}

createReviewerAccount();

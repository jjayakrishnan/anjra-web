const { createClient } = require('@supabase/supabase-js');
const supabase = createClient('https://fvwhrnsdwpqcajjqwqul.supabase.co', 'sb_publishable_qi2CHpTGKz4iH3T3PIviSg_u-CRtn4O');

async function check() {
    const { data, error } = await supabase.from('profiles').select('*').eq('username', 'nandhana');
    console.log('Nandhana query result:\\n', JSON.stringify(data, null, 2));
}
check();

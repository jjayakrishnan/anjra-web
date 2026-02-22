const { createClient } = require('@supabase/supabase-js');
const { v4: uuidv4 } = require('uuid');
const supabase = createClient('https://fvwhrnsdwpqcajjqwqul.supabase.co', 'sb_publishable_qi2CHpTGKz4iH3T3PIviSg_u-CRtn4O');

async function check() {
    const { data, error } = await supabase.from('profiles').insert({
        id: uuidv4(),
        full_name: 'Nandhana',
        username: 'nandhana',
        pin: '2020',
        is_parent: false,
        parent_id: '09683214-9914-4ea5-be40-734ff4ed8496',
        balance: 0.0,
    });
    console.log('Insert Nandhana result:\\n', JSON.stringify(data, null, 2));
    console.log('Error:\\n', error);
}
check();

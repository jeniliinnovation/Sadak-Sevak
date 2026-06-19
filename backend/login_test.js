const axios = require('axios');
(async ()=>{
  try{
    const res = await axios.post('http://localhost:5000/api/auth/login', { email: 'rajesh.contractor@builder.in', password: 'contract123' });
    console.log('status', res.status, res.data);
  }catch(err){
    if(err.response) console.log('status', err.response.status, err.response.data);
    else console.error(err.message);
  }
})();
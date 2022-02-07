function run () {
  var file = process.argv[2];
  process.argv.splice(1,1);
  console.log("Ready to run", file, "with argv = [" + process.argv.toString() + "]");
  // The script doesn't need to know it was started by init.js
  process.argv.splice(1,1);
  require(process.cwd() + "/" + file);
}

function load_bls_wasm() {
  var _bls = require('./blst.js');
  return _bls().then(function (BLS12381) { global._BLS12381 = BLS12381 }).catch(e => console.log(e))
}

load_bls_wasm().then(run);

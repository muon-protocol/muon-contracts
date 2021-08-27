const {roundBN} = require('./utils');

const expectThrow = (text) => async (promise) => {
  try {
    await promise;
  } catch (error) {
    assert(error.message.search(text) >= 0, "Expected throw, got '" + error + "' instead")
    return
  }
  assert.fail('Expected throw not received')
}

const eventArgsMatched = (args, matches) => {
  let keys = Object.keys(matches)
  for(let i=0 ; i<keys.length ; i++){
    let currentKey = keys[i];
    if(args[currentKey] === undefined)
      return false;
    let tmp = args[currentKey];
    if(web3.utils.isBN(tmp))
      tmp = `${tmp}`
    if(tmp != matches[currentKey])
      return false;
  }
  return true;
}

const eventEmitted = (result, eventName, detector) => {
  for(let item of result.logs){
    if(!!item.event && item.event === eventName){
      if(detector === undefined)
        return;
      if(typeof detector === 'function' && detector(item.args))
        return;
      if(typeof detector === 'object' && eventArgsMatched(item.args, detector))
        return;
    }
  }
  assert(false, `event ${eventName} expected but not happened.`)
}

const eventNotEmitted = (result, eventName, detector) => {
  for(let item of result.logs){
    if(!!item.event && item.event === eventName){
      if(detector === undefined)
        assert(false, `event ${eventName} not expected but happened.`)
      if(typeof detector === 'function' && detector(item.args))
        assert(false, `event ${eventName} not expected but happened.`)
      if(typeof detector === 'object' && eventArgsMatched(item.args, detector))
        assert(false, `event ${eventName}(${JSON.stringify(detector)}) not expected but happened.`)
    }
  }
}

const fail = (msg) => (error) => assert(false, error ?`${msg}, but got error: ${error.message}` : msg);

const expectError = async (promise, msgSearch) => {
    try {
        await promise;
        fail('expected to fail')();
    } catch (error) {
        assert(error.message.indexOf(msgSearch) >= 0 || error.message.indexOf('invalid opcode') >= 0,
            `Expected ${msgSearch}, but got: ${error.message}`);
    }
}

const expectRevert = async (promise) => {
    return expectError(promise, 'revert');
}

module.exports =  {
  expectOutOfGas: expectThrow('out of gas'),
  expectRevert: expectThrow('revert'),
  expectInvalidJump: expectThrow('invalid JUMP'),
  eventEmitted,
  eventNotEmitted,
  error: expectError,
  revert: expectRevert,
}
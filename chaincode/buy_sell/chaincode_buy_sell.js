'use strict';

const shim = require('fabric-shim');
const util = require('util');

const Chaincode = class {

    async Init(stub) {
        console.log('========= Chaincode Initialised =========');
        let ret = stub.getFunctionAndParameters();
        let args = ret.params;
        console.log("args[0]:" + args[0]);
        console.log("args[1]:" + args[1]);

        await stub.putState(args[0], Buffer.from(args[1]));
        return shim.success();
    }

    async Invoke(stub) {
        console.log('========= Chaincode Invoked =========');
        const args = stub.getFunctionAndParameters();
        console.info(args);
        console.log('args.params[0]:' + args.params[0]);
        let method = this[args.fcn];
        if (!method) {
            console.log('no method of name:' + method + ' found');
            return shim.success()
        } else {
            try {
                console.log("Running method...");
                // Run method
                let payload = await method(stub, args.params);
                console.log("payload:", payload);
                console.log("type of payload:", typeof payload);
                return shim.success(payload); 
            } catch (err) {
                console.log("ERROR", err);
                return shim.error("Error - unable to get response from method");
            }
        }
    }

    async getBalance(stub, args) {
        console.log('========= getBalance Function =========');
        console.log('args[0]:',args[0]);

        let value = await stub.getState(args[0]);
        if (value.toString() && value.toString() !== null) {
            console.log('value:', value.toString());
            return value;
        } else {
            return shim.error("Error - productBatch doesn't exist or is null");
        }
    }

    async updateBalance(stub, args) {
        console.log('========= updateBalance Function =========');
        console.log("args[0]:" + args[0]);
        // args[0] looks like
        // {
        //     "key": "xBalance",
        //     "value": "20"
        // }
        await stub.putState(JSON.parse(args[0]).key, Buffer.from(JSON.parse(args[0]).value));
    }

    async delete(stub,args) {
        console.log('========= Delete Function =========');
    }
};

shim.start(new Chaincode());
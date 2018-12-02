
// variables required for starting server
const express = require('express');
const bodyParser = require('body-parser');
const request = require('request');
var session = require('express-session');
const app = express()

// importing other node js functions
// var cmd=require('node-cmd');
// var sys = require('sys')
// var exec = require('child_process').exec;


// importing fabric clients
var Fabric_Client = require('fabric-client');
var Fabric_CA_Client = require('fabric-ca-client');
var path = require('path');
var util = require('util');
var os = require('os');



// instantiating fabric client and creating variables
var fabric_client = new Fabric_Client();
var fabric_ca_client = null;
var admin_user = null;
var member_user = null;
var store_path = path.join(__dirname, 'hfc-key-store');
console.log(' Store path:'+store_path);
var adminName;
var pass;


// setting engine and using static files

app.use(express.static('public'));
app.use(bodyParser.urlencoded({ extended: true }));
app.set('view engine', 'ejs')

var uchannel = fabric_client.newChannel('user');
var upeer = fabric_client.newPeer('grpc://localhost:7051');
uchannel.addPeer(upeer);
var uorder = fabric_client.newOrderer('grpc://localhost:7050')
uchannel.addOrderer(uorder);


var lchannel = fabric_client.newChannel('lands');
var lpeer = fabric_client.newPeer('grpc://localhost:7051');
lchannel.addPeer(lpeer);
var lorder = fabric_client.newOrderer('grpc://localhost:7050')
lchannel.addOrderer(lorder);

var tchannel = fabric_client.newChannel('transfer');
var tpeer = fabric_client.newPeer('grpc://localhost:7051');
tchannel.addPeer(tpeer);
var torder = fabric_client.newOrderer('grpc://localhost:7050')
tchannel.addOrderer(torder);





app.use(session({
  secret: 'hyperledgerfabric',
  cookie: {},
  saveUninitialized: false,
  resave: false

}));




app.get('/logout', function (req, res) {

 req.session.destroy(function(){
  res.redirect('/userlogin');
});

})




app.get('/', function (req, res) {

  res.redirect('/enrolladmin');
  
})






app.get('/createtransferreq', function (req, res) {

  if(!(req.session.username)) {
    res.redirect('/userlogin');
  } else if(!(req.session.usertype == "0")) {
    res.send("ACCESS DENIED");
  }

  var tx_id = null;
// create the key value store as defined in the fabric-client/config/default.json 'key-value-store' setting
Fabric_Client.newDefaultKeyValueStore({ path: store_path
}).then((state_store) => {
  // assign the store to the fabric client
  fabric_client.setStateStore(state_store);
  var crypto_suite = Fabric_Client.newCryptoSuite();
  // use the same location for the state store (where the users' certificate are kept)
  // and the crypto store (where the users' keys are kept)
  var crypto_store = Fabric_Client.newCryptoKeyStore({path: store_path});
  crypto_suite.setCryptoKeyStore(crypto_store);
  fabric_client.setCryptoSuite(crypto_suite);

  // get the enrolled user from persistence, this user will sign all requests
  return fabric_client.getUserContext('admin', true);
}).then((user_from_store) => {
  if (user_from_store && user_from_store.isEnrolled()) {
    console.log('Successfully loaded user1 from persistence');
    member_user = user_from_store;
  } else {
    throw new Error('Failed to get user1.... run registerUser.js');
  }

  // queryCar chaincode function - requires 1 argument, ex: args: ['CAR4'],
  // queryAllCars chaincode function - requires no arguments , ex: args: [''],
  const request = {
    //targets : --- letting this default to the peers assigned to the channel
    chaincodeId: 'myland',
    fcn: 'queryAllLands',
    args: ['']
  };

  // send the query proposal to the peer
  return lchannel.queryByChaincode(request);
}).then((query_responses) => {
  console.log("Query has completed, checking results");
  // query_responses could have more than one  results if there multiple peers were used as targets
  if (query_responses && query_responses.length == 1) {
    if (query_responses[0] instanceof Error) {
      console.error("error from query = ", query_responses[0]);
    } else {
      console.log("Response is ", query_responses[0].toString());
      var result = query_responses[0];
      var str = String.fromCharCode.apply(String, result);
      var obj = JSON.parse(str);
      
      
    // console.log(ex[1].record["abc"])
    console.log("start from here")
    
    // console.log(obj[0]["Key"])
    var dataToSend = {result: obj, message: "null", uname: req.session.uname, cnic: req.session.cnic, username: req.session.username, usertype: req.session.usertype};
    res.render('createtransferreq', dataToSend);

  }
} else {
  console.log("No payloads were returned from query");
}
}).catch((err) => {
  console.error('Failed to query successfully :: ' + err);
  res.send("FAILED TO FETCH KEYS");
});
  //end

})






app.post('/createtransferreq',function(req, res) {

  var property = req.body.property;

  var cnic = req.body.cnic;
  var tcnic = req.body.tcnic;

  var dataForAdm = [];
  dataForAdm[0] = cnic;
  dataForAdm[1] = tcnic;
  dataForAdm[2] = tcnic;
  dataForAdm[3] = "0";




  console.log('Store path:'+store_path);
  var tx_id = null;

// create the key value store as defined in the fabric-client/config/default.json 'key-value-store' setting
Fabric_Client.newDefaultKeyValueStore({ path: store_path
}).then((state_store) => {
  // assign the store to the fabric client
  fabric_client.setStateStore(state_store);
  var crypto_suite = Fabric_Client.newCryptoSuite();
  // use the same location for the state store (where the users' certificate are kept)
  // and the crypto store (where the users' keys are kept)
  var crypto_store = Fabric_Client.newCryptoKeyStore({path: store_path});
  crypto_suite.setCryptoKeyStore(crypto_store);
  fabric_client.setCryptoSuite(crypto_suite);

  // get the enrolled user from persistence, this user will sign all requests
  return fabric_client.getUserContext('admin', true);
}).then((user_from_store) => {
  if (user_from_store && user_from_store.isEnrolled()) {
    console.log('Successfully loaded user1 from persistence');
    member_user = user_from_store;
  } else {
    throw new Error('Failed to get user1.... run registerUser.js');
  }

  // get a transaction id object based on the current user assigned to fabric client
  tx_id = fabric_client.newTransactionID();
  console.log("Assigning transaction_id: ", tx_id._transaction_id);

  // createCar chaincode function - requires 5 args, ex: args: ['CAR12', 'Honda', 'Accord', 'Black', 'Tom'],
  // changeCarOwner chaincode function - requires 2 args , ex: args: ['CAR10', 'Dave'],
  // must send the proposal to endorsing peers
  var request = {
    //targets: let default to the peer assigned to the client
    chaincodeId: 'myt',
    fcn: 'createTransfer',
    args: dataForAdm,
    chainId: '',
    txId: tx_id
  };

  // send the transaction proposal to the peers
  return tchannel.sendTransactionProposal(request);
}).then((results) => {
  var proposalResponses = results[0];
  var proposal = results[1];
  let isProposalGood = false;
  if (proposalResponses && proposalResponses[0].response &&
    proposalResponses[0].response.status === 200) {
    isProposalGood = true;
  console.log('Transaction proposal was good');
} else {
  console.error('Transaction proposal was bad');
}
if (isProposalGood) {
  console.log(util.format(
    'Successfully sent Proposal and received ProposalResponse: Status - %s, message - "%s"',
    proposalResponses[0].response.status, proposalResponses[0].response.message));

    // build up the request for the orderer to have the transaction committed
    var request = {
      proposalResponses: proposalResponses,
      proposal: proposal
    };

    // set the transaction listener and set a timeout of 30 sec
    // if the transaction did not get committed within the timeout period,
    // report a TIMEOUT status
    var transaction_id_string = tx_id.getTransactionID(); //Get the transaction ID string to be used by the event processing
    var promises = [];

    var sendPromise = tchannel.sendTransaction(request);
    promises.push(sendPromise); //we want the send transaction first, so that we know where to check status

    // get an eventhub once the fabric client has a user assigned. The user
    // is required bacause the event registration must be signed
    let event_hub = fabric_client.newEventHub();
    event_hub.setPeerAddr('grpc://localhost:7053');

    // using resolve the promise so that result status may be processed
    // under the then clause rather than having the catch clause process
    // the status
    let txPromise = new Promise((resolve, reject) => {
      let handle = setTimeout(() => {
        event_hub.disconnect();
        resolve({event_status : 'TIMEOUT'}); //we could use reject(new Error('Trnasaction did not complete within 30 seconds'));
      }, 3000);
      event_hub.connect();
      event_hub.registerTxEvent(transaction_id_string, (tx, code) => {
        // this is the callback for transaction event status
        // first some clean up of event listener
        clearTimeout(handle);
        event_hub.unregisterTxEvent(transaction_id_string);
        event_hub.disconnect();

        // now let the application know what happened
        var return_status = {event_status : code, tx_id : transaction_id_string};
        if (code !== 'VALID') {
          console.error('The transaction was invalid, code = ' + code);
          resolve(return_status); // we could use reject(new Error('Problem with the tranaction, event status ::'+code));
        } else {
          console.log('The transaction has been committed on peer ' + event_hub._ep._endpoint.addr);
          resolve(return_status);
        }
      }, (err) => {
        //this is the callback if something goes wrong with the event registration or processing
        reject(new Error('There was a problem with the eventhub ::'+err));
      });
    });
    promises.push(txPromise);

    return Promise.all(promises);
  } else {
    console.error('Failed to send Proposal or receive valid response. Response null or status is not 200. exiting...');
    throw new Error('Failed to send Proposal or receive valid response. Response null or status is not 200. exiting...');
  }
}).then((results) => {
  console.log('Send transaction promise and event listener promise have completed');
  // check the results in the order the promises were added to the promise all list
  if (results && results[0] && results[0].status === 'SUCCESS') {
    console.log('Successfully sent transaction to the orderer.');
  } else {
    console.error('Failed to order the transaction. Error code: ' + results[0].status);
  }

  if(results && results[1] && results[1].event_status === 'VALID') {
    console.log('Successfully committed the change to the ledger by the peer');
    res.send("Submitted");
    
  } else {
    console.log('Transaction failed to be committed to the ledger due to ::'+results[1].event_status);
  }
}).catch((err) => {
  console.error('Failed to invoke successfully :: ' + err);
  
  res.send("Failed");

});

})













app.get('/dashboard', function (req, res) {

  if(req.session.username) {
    res.render('dashboard',{uname: req.session.uname, cnic: req.session.cnic, username: req.session.username, usertype: req.session.usertype})
  } else {
    res.render('admin',{loginmsg: "0"});
  }
  
})




app.get('/userlogin', function (req, res) {

  if(req.session.username) {
    res.render('dashboard',{uname: req.session.uname, cnic: req.session.cnic, username: req.session.username, usertype: req.session.usertype})
  } else {
    res.render('admin',{loginmsg: "0"});
  }
  
})




app.post('/userlogin', function(req, res) {

  cuser = req.body.username.trim();
  cpass = req.body.password.trim();


  var tx_id = null;

// create the key value store as defined in the fabric-client/config/default.json 'key-value-store' setting
Fabric_Client.newDefaultKeyValueStore({ path: store_path
}).then((state_store) => {
  // assign the store to the fabric client
  fabric_client.setStateStore(state_store);
  var crypto_suite = Fabric_Client.newCryptoSuite();
  // use the same location for the state store (where the users' certificate are kept)
  // and the crypto store (where the users' keys are kept)
  var crypto_store = Fabric_Client.newCryptoKeyStore({path: store_path});
  crypto_suite.setCryptoKeyStore(crypto_store);
  fabric_client.setCryptoSuite(crypto_suite);

  // get the enrolled user from persistence, this user will sign all requests
  return fabric_client.getUserContext('admin', true);
}).then((user_from_store) => {
  if (user_from_store && user_from_store.isEnrolled()) {
    console.log('Successfully loaded user1 from persistence');
    member_user = user_from_store;
  } else {
    throw new Error('Failed to get user1.... run registerUser.js');
  }

  // queryCar chaincode function - requires 1 argument, ex: args: ['CAR4'],
  // queryAllCars chaincode function - requires no arguments , ex: args: [''],
  const request = {
    //targets : --- letting this default to the peers assigned to the channel
    chaincodeId: 'mycc',
    fcn: 'queryAllUsers',
    args: ['']
  };

  // send the query proposal to the peer
  return uchannel.queryByChaincode(request);
}).then((query_responses) => {
  console.log("Query has completed, checking results");
  // query_responses could have more than one  results if there multiple peers were used as targets
  if (query_responses && query_responses.length == 1) {
    if (query_responses[0] instanceof Error) {
      console.error("error from query = ", query_responses[0]);
    } else {
      console.log("Response is ", query_responses[0].toString());
      var result = query_responses[0];
      var str = String.fromCharCode.apply(String, result);
      var obj = JSON.parse(str);
      
    // console.log(ex[1].record["abc"])
    console.log("Users Fetch validating credentials "+obj.length)
    var errmsg = "";
    breakme: {
     for(i=0;i<obj.length;i++) {
      if(cuser == obj[i].Record.username) {
        if(cpass == obj[i].Record.password) {
          
              req.session.uname = obj[i].Record.name;
              req.session.username = obj[i].Record.username;
              req.session.usertype = obj[i].Record.usertype;
              req.session.cnic = obj[i].Record.cnic;
              
              res.render('dashboard',{uname: req.session.uname, cnic: req.session.cnic, username: req.session.username, usertype: req.session.usertype})
              break breakme;
           

        } else {
          console.log("this is incorrect pass");
          errmsg = "1";
        }

      } else {
        console.log("this is incorrect user");
        errmsg = "1";
      }

    }
    res.render('admin',{loginmsg: errmsg})
  }






}
} else {
  console.log("No payloads were returned from query");
}
}).catch((err) => {
  console.error('Failed to query successfully :: ' + err);
});



});






app.get('/enrolladmin', function(req, res) {
  var admins = "admin";
  var adminspw = "adminpw";
  var tem = ''
  if (admins === 'admin') {
    Fabric_Client.newDefaultKeyValueStore({ path: store_path
    }).then((state_store) => {
    // assign the store to the fabric client
    fabric_client.setStateStore(state_store);
    var crypto_suite = Fabric_Client.newCryptoSuite();
    // use the same location for the state store (where the users' certificate are kept)
    // and the crypto store (where the users' keys are kept)
    var crypto_store = Fabric_Client.newCryptoKeyStore({path: store_path});
    crypto_suite.setCryptoKeyStore(crypto_store);
    fabric_client.setCryptoSuite(crypto_suite);
    var	tlsOptions = {
    	trustedRoots: [],
    	verify: false
    };
    // be sure to change the http to https when the CA is running TLS enabled
    fabric_ca_client = new Fabric_CA_Client('http://localhost:7054', tlsOptions , 'ca.example.com', crypto_suite);

    // first check to see if the admin is already enrolled
    return fabric_client.getUserContext(admins, true);
  }).then((user_from_store) => {
    if (user_from_store && user_from_store.isEnrolled()) {
      console.log('Successfully loaded admin from persistence');

      admin_user = user_from_store;
      return null;
    } else {
        // need to enroll it with CA server
        return fabric_ca_client.enroll({
          enrollmentID: admins,
          enrollmentSecret: adminspw
        }).then((enrollment) => {
          console.log('Successfully enrolled admin user "admin"');

          return fabric_client.createUser(
            {username: admins,
              mspid: 'CIVICMSP',
              cryptoContent: { privateKeyPEM: enrollment.key.toBytes(), signedCertPEM: enrollment.certificate }
            });
        }).then((user) => {
          admin_user = user;
          return fabric_client.setUserContext(admin_user);
        }).catch((err) => {
          console.error('Failed to enroll and persist admin. Error: ' + err.stack ? err.stack : err);

          throw new Error('Failed to enroll admin');
        });
      }
    }).then(() => {
      console.log('Assigned the admin user to the fabric client ::' + admin_user.toString());

    }).catch((err) => {
      console.error('Failed to enroll admin: ' + err);
    }); 

    res.redirect("/userlogin");
  }
  else {
    console.log('Admin Enroll Error');
    res.redirect("/userlogin");
  }

});


// creating server
app.listen(3000, function () {
  console.log('Example app listening on port 3000!')

})



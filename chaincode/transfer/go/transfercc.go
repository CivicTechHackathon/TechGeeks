
package main

import (
	"bytes"
	"encoding/json"
	"fmt"
	"strconv"

	"github.com/hyperledger/fabric/core/chaincode/shim"
	sc "github.com/hyperledger/fabric/protos/peer"
)

// Define the Smart Contract structure
type SmartContract struct {
}


type Transfer struct {
	Ownercnic   string `json:"ownercnic"`
	Transfercnic   string `json:"transfercnic"`
	Property   string `json:"property"`
	PaymentProof   string `json:"paymentproof"`
	Status   string `json:"status"`
	
}


func (s *SmartContract) Init(APIstub shim.ChaincodeStubInterface) sc.Response {
	return shim.Success(nil)
}


func (s *SmartContract) Invoke(APIstub shim.ChaincodeStubInterface) sc.Response {

	// Retrieve the requested Smart Contract function and arguments
	function, args := APIstub.GetFunctionAndParameters()
	
	// Route to the appropriate handler function to interact with the ledger appropriately
	if function == "initLedger" {
		return s.initLedger(APIstub)
	} else if function == "queryAllTransfer" {
		return s.queryAllTransfer(APIstub)
	} else if function == "queryTransfer" {
		return s.queryTransfer(APIstub, args)
	} else if function == "createTransfer" {
		return s.createTransfer(APIstub, args)
	} else if function == "addPaymentProof" {
		return s.addPaymentProof(APIstub, args)
	} else if function == "approveReq" {
		return s.approveReq(APIstub, args)
	}

	return shim.Error("Invalid Smart Contract function name.")
}



func (s *SmartContract) initLedger(APIstub shim.ChaincodeStubInterface) sc.Response {
	return shim.Success(nil)
}



func (s *SmartContract) queryAllTransfer(APIstub shim.ChaincodeStubInterface) sc.Response {
	
	startKey := ""
	endKey := ""	

	resultsIterator, err := APIstub.GetStateByRange(startKey, endKey)
	if err != nil {
		return shim.Error(err.Error())
	}
	defer resultsIterator.Close()

	// buffer is a JSON array containing QueryResults
	var buffer bytes.Buffer
	buffer.WriteString("[")

	bArrayMemberAlreadyWritten := false
	for resultsIterator.HasNext() {
		queryResponse, err := resultsIterator.Next()
		if err != nil {
			return shim.Error(err.Error())
		}
		// Add a comma before array members, suppress it for the first array member
		if bArrayMemberAlreadyWritten == true {
			buffer.WriteString(",")
		}
		buffer.WriteString("{\"Key\":")
		buffer.WriteString("\"")
		buffer.WriteString(queryResponse.Key)
		buffer.WriteString("\"")

		buffer.WriteString(", \"Record\":")
		// Record is a JSON object, so we write as-is
		buffer.WriteString(string(queryResponse.Value))
		buffer.WriteString("}")
		bArrayMemberAlreadyWritten = true
	}
	buffer.WriteString("]")

	fmt.Printf("- queryAllTransfer:\n%s\n", buffer.String())

	return shim.Success(buffer.Bytes())
}



func (s *SmartContract) queryTransfer(APIstub shim.ChaincodeStubInterface, args []string) sc.Response {

	if len(args) != 1 {
		return shim.Error("Incorrect number of arguments. Expecting 1")
	}

	transferAsByte, _ := APIstub.GetState(args[0])
	return shim.Success(transferAsByte)
}


func (s *SmartContract) createTransfer(APIstub shim.ChaincodeStubInterface, args []string) sc.Response {

	if len(args) != 4 {
		return shim.Error("Incorrect number of arguments. Expecting 4")
	}
	
	startKey := ""
	endKey := ""	
	check := true

	counter, err := APIstub.GetStateByRange(startKey, endKey)
	if err != nil {
		return shim.Error(err.Error())
	}
	defer counter.Close()
	i := 0
	for counter.HasNext() {
		t, _ := counter.Next()
		if(t.Key == args[0]) {
			check = false	
			break	
		}
		fmt.Println(t)
		i++
	}

	if(check) {	

		total := int64(i+1)
		tid := "TRANSFER"+strconv.FormatInt(total,10)			

		var transfer = Transfer{Ownercnic: args[0],Transfercnic: args[1], Property: args[2], PaymentProof: args[3], Status: "0"}

		transferAsBytes, _ := json.Marshal(transfer)
		APIstub.PutState(tid, transferAsBytes)

		return shim.Success(nil)
	} else {
		return shim.Error("Land Exist")	
		
	}
}

func (s *SmartContract) addPaymentProof(APIstub shim.ChaincodeStubInterface, args []string) sc.Response {

	if len(args) != 2 {
		return shim.Error("Incorrect number of arguments. Expecting 1")
	}

	transferAsBytes, _ := APIstub.GetState(args[0])
	transfer := Transfer{}

	json.Unmarshal(transferAsBytes, &transfer)
	transfer.PaymentProof = args[1]

	transferAsBytes, _ = json.Marshal(transfer)
	APIstub.PutState(args[0], transferAsBytes)

	return shim.Success(nil)
}

func (s *SmartContract) approveReq(APIstub shim.ChaincodeStubInterface, args []string) sc.Response {

	if len(args) != 1 {
		return shim.Error("Incorrect number of arguments. Expecting 1")
	}

	transferAsBytes, _ := APIstub.GetState(args[0])
	transfer := Transfer{}

	json.Unmarshal(transferAsBytes, &transfer)
	transfer.Status = "1"

	transferAsBytes, _ = json.Marshal(transfer)
	APIstub.PutState(args[0], transferAsBytes)

	return shim.Success(nil)
}


func main() {

	err := shim.Start(new(SmartContract))
	if err != nil {
		fmt.Printf("Error creating new Smart Contract: %s", err)
	}
}

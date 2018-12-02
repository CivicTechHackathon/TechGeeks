
package main

import (
	"bytes"
	"encoding/json"
	"fmt"

	"github.com/hyperledger/fabric/core/chaincode/shim"
	sc "github.com/hyperledger/fabric/protos/peer"
)

// Define the Smart Contract structure
type SmartContract struct {
}


type Land struct {
	Owner   string `json:"owner"`
	Plotno   string `json:"plotno"`
	Block   string `json:"block"`
	Sqryd  string `json:"sqryd"`
	City string `json:"city"`
	District  string `json:"district"`
	Town  string `json:"town"`
	Type  string `json:"type"`

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
	} else if function == "queryAllLands" {
		return s.queryAllLands(APIstub)
	} else if function == "queryLand" {
		return s.queryLand(APIstub, args)
	} else if function == "createLand" {
		return s.createLand(APIstub, args)
	}

	return shim.Error("Invalid Smart Contract function name.")
}



func (s *SmartContract) initLedger(APIstub shim.ChaincodeStubInterface) sc.Response {
	return shim.Success(nil)
}



func (s *SmartContract) queryAllLands(APIstub shim.ChaincodeStubInterface) sc.Response {
	
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

	fmt.Printf("- queryAllUsers:\n%s\n", buffer.String())

	return shim.Success(buffer.Bytes())
}



func (s *SmartContract) queryLand(APIstub shim.ChaincodeStubInterface, args []string) sc.Response {

	if len(args) != 1 {
		return shim.Error("Incorrect number of arguments. Expecting 1")
	}

	landAsByte, _ := APIstub.GetState(args[0])
	return shim.Success(landAsByte)
}

func (s *SmartContract) createLand(APIstub shim.ChaincodeStubInterface, args []string) sc.Response {

	if len(args) != 9 {
		return shim.Error("Incorrect number of arguments. Expecting 9")
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

			

		var land = Land{Owner: args[1], Plotno: args[2],Block: args[3] ,Sqryd: args[4] , City: args[5], District: args[6], Town: args[7], Type: args[8]}

		landAsBytes, _ := json.Marshal(land)
		APIstub.PutState(args[0], landAsBytes)

		return shim.Success(nil)
	} else {
		return shim.Error("Land Exist")	
		
	}
}


func main() {

	err := shim.Start(new(SmartContract))
	if err != nil {
		fmt.Printf("Error creating new Smart Contract: %s", err)
	}
}

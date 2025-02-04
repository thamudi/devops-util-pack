package main

import (
	"bytes"
	"encoding/json"
	"fmt"
	"os"
	"os/exec"
)

type pvData struct {
	Items []struct {
		Metadata struct {
			Name              string `json:"name"`
			CreationTimeStamp string `json:"creationTimeStamp"`
		} `json:"metadata"`
		Spec struct {
			Capacity struct {
				Storage string `json:"storage"`
			} `json:"capacity"`
			AccessModes []string `json:"accessModes"`
			ClimRef     struct {
				Namespace string `json:"namespace"`
				Name      string `json:"name"`
			} `json:"claimRef"`
			StorageClassName              string `json:"storageClassName"`
			PersistentVolumeReclaimPolicy string `json:"persistentVolumeReclaimPolicy"`
		} `json:"spec"`
	} `json:"items"`
}

type thing struct {
	PVName            string
	Capacity          string
	AccessMode        string
	NameSpace         string
	Name              string
	StorageClass      string
	CreationTimeStamp string
	ClaimPolicy       string
}

func mapToThing(data pvData) []thing {
	things := make([]thing, 0)
	for _, item := range data.Items {
		things = append(things, thing{
			PVName:            item.Metadata.Name,
			Capacity:          item.Spec.Capacity.Storage,
			AccessMode:        item.Spec.AccessModes[0],
			NameSpace:         item.Spec.ClimRef.Namespace,
			Name:              item.Spec.ClimRef.Name,
			StorageClass:      item.Spec.StorageClassName,
			CreationTimeStamp: item.Metadata.CreationTimeStamp,
			ClaimPolicy:       item.Spec.PersistentVolumeReclaimPolicy,
		})
	}
	return things
}

func main() {
	cmd := exec.Command("kubectl", "get", "pv", "-A", "-o", "json")
	buff := bytes.NewBuffer([]byte{})
	cmd.Stdout = buff
	err := cmd.Run()
	if err != nil {
		panic(err)
	}

	var pvData pvData
	err = json.NewDecoder(buff).Decode(&pvData)

	if err != nil {
		panic(err)
	}

	fmt.Printf("%+v", pvData)

	thingz := mapToThing(pvData)

	file, err := os.Create("pv.csv")

	if err != nil {
		panic(err)
	}

	defer file.Close()

	file.WriteString("PV Name, Name, Storage Class, Access Mode, Capacity, Creation Timestamp, Retention Policy \n")
	for _, thing := range thingz {

		fmt.Fprintf(file, "%s,%s,%s,%s,%s,%s,%s\n",
			thing.PVName, thing.Name,
			thing.StorageClass,
			thing.AccessMode, thing.Capacity,
			thing.CreationTimeStamp, thing.ClaimPolicy,
		)

	}

}
